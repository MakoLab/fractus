using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SalesOrderTracker.Messages;
using System.Collections;
using TrackerDataAccessLayer.Events;
using TrackerDataAccessLayer;
using System.Transactions;
using TrackerDataAccessLayer.Enums;
using Makolab.Fractus.Commons;
using System.Configuration;
using System.Data.Common;
using System.Data.SqlClient;
using System.Data.EntityClient;
using System.Data.Metadata.Edm;
using System.Reflection;
using System.Threading;
using System.Data;

namespace SalesOrderTracker
{
	public class MessagingLogic
	{
		private List<SalesOrderTrackerQueueEntry> SalesOrdersCurrentFullQueue;

		private Guid? SalesOrderId;

		private void GetCurrentSalesOrdersQueue(TrackerEntitiesContainer tec)
		{
			SalesOrdersCurrentFullQueue = TrackerEntitiesManager.Instance.GetCurrentSOTQEntries(tec);
			SalesOrderId = SalesOrdersCurrentFullQueue.Select(entry => entry.SalesOrderId).FirstOrDefault();
		}

		private void MarkSalesOrdersQueueAsCompleted()
		{
			foreach (SalesOrderTrackerQueueEntry entry in SalesOrdersCurrentFullQueue)
			{
				entry.IsCompleted = true;
			}
		}

		private List<Event> GetNewEvents(List<Event> oldEvents, List<Event> newEvents)
		{
			List<Event> result = newEvents.Where(newEvent => !oldEvents.Contains(newEvent)).ToList();
			return result;

			//We do not send messages for events that had already generated messages
			//First different message and later are checked to produce messages

			//IEnumerator<Event> oldEventsEnumerator = oldEvents.GetEnumerator();
			//IEnumerator<Event> newEventsEnumerator = newEvents.GetEnumerator();

			//while (oldEventsEnumerator.MoveNext() && newEventsEnumerator.MoveNext())
			//{
			//    if (!oldEventsEnumerator.Current.Equals(newEventsEnumerator.Current))
			//    {
			//        result.Add(newEventsEnumerator.Current);
			//        while (newEventsEnumerator.MoveNext())
			//        {
			//            result.Add(newEventsEnumerator.Current);
			//        }
			//    }
			//}

			////Jeśli lista nowa jest dłuższa niż start może się zdarzyć, że poprzednia pętla nie skonsumuje wszystkich nowych 
			//if (newEvents.Count > oldEvents.Count)
			//{
			//    while (newEventsEnumerator.MoveNext())
			//    {
			//        result.Add(newEventsEnumerator.Current);
			//    }
			//}

			//return result;
		}

		private List<Message> GenerateMessages(SalesOrderSnapshot salesOrderSnapshot, List<Event> events)
		{
			Contractor contractor = salesOrderSnapshot.Contractor;

			events = events.OrderBy(ev => ev.EventDate).ThenBy(ev => ev.Name).ToList();
			List<Message> result = new List<Message>();

			bool emailEnabled = contractor.HasEmailAddress;
			bool smsEnabled = !contractor.HasEmailAddress && contractor.HasPhoneNumber && !contractor.IsAps;

			if (emailEnabled || smsEnabled)
			{
				MessageType defaultMessageType = smsEnabled ? MessageType.Sms : MessageType.Email;
				foreach (Event newEvent in events)
				{
					//Nie generujemy powiadomienia o wystawieniu FSR dla zamówień towarowych
					if (newEvent.Name == EventName.DocumentSettled && salesOrderSnapshot.SalesTypeName == SalesTypeName.Items)
						continue;

					MessageType usedType
						= newEvent.Name == EventName.MarkedAsPlanned && emailEnabled ? MessageType.Email : defaultMessageType;
					string recipient = usedType == MessageType.Email ? contractor.Email : contractor.Phone;
					string sender = usedType == MessageType.Email ? TemplatesCache.EmailSender : TemplatesCache.SmsSender;
					SOTMessage message = new SOTMessage(newEvent.Name, usedType, sender, recipient, newEvent.Parameters);

					if (message != null && message.InnerMessage != null)
						result.Add(message.InnerMessage);
				}
			}

			return result;
		}

		private void SaveEntities(SalesOrderSnapshot salesOrderSnapshot, SalesOrderSnapshot oldSnapshot
			, List<Message> messages, TrackerEntitiesContainer tec)
		{
			using (TransactionScope ts = new TransactionScope())
			{
				TrackerEntitiesManager.Instance.InsertMessages(messages, tec);

				TrackerEntitiesManager.Instance.PersistSalesOrderSnapshot(salesOrderSnapshot, oldSnapshot, messages, tec);

				TrackerEntitiesManager.Instance.UpdateSOTQEntries(SalesOrdersCurrentFullQueue, tec);

				ts.Complete();
			}
		}

		public void ProcessSalesOrderEvents()
		{
			int noErrors = 0;
			int idleDelay = Convert.ToInt32(ConfigurationManager.AppSettings["idleDelay"] ?? "60");
			int errorsDelay = Convert.ToInt32(ConfigurationManager.AppSettings["errorsDelay"] ?? "300");
			int maxErrors = Convert.ToInt32(ConfigurationManager.AppSettings["errorsCount"] ?? "10");
			bool idle = false;
			while (true)
			{
				try
				{
					using (TrackerEntitiesContainer tec = TrackerEntitiesManager.GetNewTrackerObjectContext())
					{
						//Open connection before any operation on context in order to ensure that all operations will run under same local transaction!!
						tec.Connection.Open();
						GetCurrentSalesOrdersQueue(tec);
						if (SalesOrderId.HasValue && SalesOrderId != Guid.Empty)
						{
							SalesOrderSnapshot newSnapshot
								= TrackerEntitiesManager.Instance.CreateNewSalesOrderSnapshot(SalesOrderId.Value);
							if (newSnapshot == null)
								throw new ApplicationException("Nie odnaleziono obiektu o id = " + SalesOrderId);
							SalesOrderSnapshot oldSnapshot
								= TrackerEntitiesManager.Instance.GetSalesOrderSnapshot(SalesOrderId.Value, tec);

							var previousEvents = TrackerEntitiesManager.Instance.CreateEventsList(oldSnapshot);
							var currentEvents = TrackerEntitiesManager.Instance.CreateEventsList(newSnapshot);
							var newEvents = GetNewEvents(previousEvents, currentEvents);
							newEvents = newEvents.Where(ev => ev.EventDate >= TemplatesCache.StartDate).ToList();
							List<Message> newMessages = GenerateMessages(newSnapshot, newEvents);
							MarkSalesOrdersQueueAsCompleted();
							SaveEntities(newSnapshot, oldSnapshot, newMessages, tec);
						}
						else
						{
							idle = true;
						}
					}
					if (idle == true)
					{
						Thread.Sleep(TimeSpan.FromSeconds(idleDelay));
						idle = false;
					}
				}
				catch (Exception ex)
				{
					noErrors++;
					Utils.LogException(ex, typeof(MessagingLogic), ConfigurationManager.AppSettings["LogFolder"]);
					if (noErrors == maxErrors)
					{
						Thread.Sleep(TimeSpan.FromSeconds(errorsDelay));
						noErrors = 0;
					}
				}
			}
		}
	}
}
