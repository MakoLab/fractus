using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DataAccessLayerHelper;
using TrackerDataAccessLayer.Enums;
using System.Data.Objects;
using TrackerDataAccessLayer.Events;
using System.Data;
using TrackerDataAccessLayer.Exceptions;
using System.Threading;

namespace TrackerDataAccessLayer
{
	public class TrackerEntitiesManager
	{
		public const string Fraktusek2EntitiesConnectionStringName = "Fraktusek2EntitiesConnectionStringName";
		public const string TrackerConnectionStringNameKey = "TrackerEntitiesConnectionStringName";

		public static TrackerEntitiesContainer GetNewTrackerObjectContext()
		{
			return EntityFrameworkHelper.Instance.CreateInstance<TrackerEntitiesContainer>(TrackerConnectionStringNameKey);
		}

		private static TrackerEntitiesManager _Instance;

		public static TrackerEntitiesManager Instance
		{
			get
			{
				if (_Instance == null)
				{
					_Instance = new TrackerEntitiesManager();
				}
				return _Instance;
			}
		}

		public const string ConnectionStringNameKey = "MessengerEntitiesConnectionStringName";

		/// <summary>
		/// SOTQ stands for Sales Order Tracker Queue
		/// Get all unprocessed entries for first salesOrderId in a Queue
		/// </summary>
		/// <returns></returns>
		public List<SalesOrderTrackerQueueEntry> GetCurrentSOTQEntries(TrackerEntitiesContainer tec)
		{
			ObjectQuery<SalesOrderTrackerQueueEntry> query =
				(ObjectQuery<SalesOrderTrackerQueueEntry>)tec.SalesOrderTrackerQueueEntries
				.Where(entry => !entry.IsCompleted).OrderBy(entry => entry.Date);
			query.MergeOption = MergeOption.NoTracking;

			List<SalesOrderTrackerQueueEntry> list = query.ToList();

			if (list.Count == 0)
				return new List<SalesOrderTrackerQueueEntry>();

			Guid firstSalesOrderId = list.Select(entry => entry.SalesOrderId).First();

			return list.Where(entry => entry.SalesOrderId == firstSalesOrderId).ToList();
		}

		public void UpdateSOTQEntries(List<SalesOrderTrackerQueueEntry> entries, TrackerEntitiesContainer tec)
		{
			EntityFrameworkHelper.Instance.UpdateEntities<SalesOrderTrackerQueueEntry>(tec
				, tec.SalesOrderTrackerQueueEntries.EntitySet.Name, entries);
		}

		public List<MessageReference> GetMessageReferences(Guid salesOrderId)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				return tec.MessageReferences.Where(mr => mr.SalesOrderId == salesOrderId).ToList();
			}
		}

		public SalesOrderSnapshot GetSalesOrderSnapshot(Guid salesOrderId, TrackerEntitiesContainer tec)
		{
			return tec.SalesOrderSnapshots.Include(tec.SalesOrderEvents.EntitySet.Name)
				.Where(sos => sos.Id == salesOrderId).FirstOrDefault();
		}

		public SalesOrderSnapshot CreateNewSalesOrderSnapshot(Guid salesOrderId)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				GetSalesOrderDetails_Result result = tec.GetSalesOrderDetails(salesOrderId).FirstOrDefault();
				if (result == null)
					return null;
				
				SalesOrderSnapshot snapshot = this.CreateSalesOrderSnapshot(result, salesOrderId);

				var historyEvents = tec.GetSalesOrderHistory(salesOrderId).OrderBy(he => he.eventDate);

				bool isFirstPrepayment = true;
				foreach (GetSalesOrderHistory_Result hResult in historyEvents)
				{
					SalesOrderEvent soe = this.CreateSalesOrderEvent(hResult, snapshot, isFirstPrepayment);
					snapshot.SalesOrderEvents.Add(soe);
					if (soe.EventName == EventName.FirstPrepayment && isFirstPrepayment)
					{
						isFirstPrepayment = false;
					}
				}

				return snapshot;
			}
		}

		public List<SalesOrderSnapshot> GetSalesOrdersList(Guid contractorId)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				List<SalesOrderSnapshot> createdList = new List<SalesOrderSnapshot>();

				var results = tec.GetSalesOrderList(contractorId);
				foreach (var result in results)
				{
					createdList.Add(CreateSalesOrderSnapshot(result));
				}

				return createdList;
			}
		}

		public Contractor GetContractor(Guid contractorId)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				return CreateContractor(tec.GetContractorData(contractorId).FirstOrDefault());
			}
		}

		public List<Item> GetSalesOrderItems(Guid salesOrderId)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				return tec.GetItems(salesOrderId).ToList();
			}
		}

		public void InsertMessageReferences(List<MessageReference> entities)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				InsertMessageReferences(entities, tec);
			}
		}

		public void InsertMessageReferences(List<MessageReference> entities, TrackerEntitiesContainer tec)
		{
			foreach (MessageReference messRef in entities.Where(mref => mref.Id == Guid.Empty))
			{
				messRef.Id = Guid.NewGuid();
			}
			EntityFrameworkHelper.Instance.InsertEntities<MessageReference>(tec, tec.MessageReferences.EntitySet.Name, entities);
		}

		public void PersistSalesOrderSnapshot(SalesOrderSnapshot salesOrderSnapshot, SalesOrderSnapshot oldSnapshot
			, List<Message> messages, TrackerEntitiesContainer tec)
		{
			#region Message references - create them and insert to collection
			foreach (Message message in messages)
			{
				MessageReference reference = new MessageReference() { Id = Guid.NewGuid(), MessageId = message.Id, SalesOrderId = salesOrderSnapshot.Id };
				salesOrderSnapshot.MessageReferences.Add(reference);
			}			
			#endregion

			#region Related Events - delete old events and create ids for new events
			if (oldSnapshot != null)
			{
				while (oldSnapshot.SalesOrderEvents.Count > 0)
					tec.DeleteObject(oldSnapshot.SalesOrderEvents.Last());
			}
			foreach (SalesOrderEvent newEvent in salesOrderSnapshot.SalesOrderEvents)
			{
				newEvent.Id = Guid.NewGuid();
			}
			#endregion

			#region Set all objects state before saving

			object oldObject = null;
			string entitySetName = tec.SalesOrderSnapshots.EntitySet.Name;
			tec.TryGetObjectByKey(tec.CreateEntityKey(entitySetName, salesOrderSnapshot), out oldObject);

			if (oldObject == null) 
			{
				tec.AddObject(entitySetName, salesOrderSnapshot); //all related objects will be also added
			}
			else
			{
				tec.ApplyCurrentValues(entitySetName, salesOrderSnapshot);
				//salesOrderSnapshot remains detached. Status of related objects must be set manualy.
				oldSnapshot = (SalesOrderSnapshot)oldObject;

				while (salesOrderSnapshot.MessageReferences.Count > 0)
					oldSnapshot.MessageReferences.Add(salesOrderSnapshot.MessageReferences.Last());
					//tec.AddObject(tec.MessageReferences.EntitySet.Name, messageReference);

				while (salesOrderSnapshot.SalesOrderEvents.Count > 0)
					oldSnapshot.SalesOrderEvents.Add(salesOrderSnapshot.SalesOrderEvents.Last());
					//tec.AddObject(tec.SalesOrderEvents.EntitySet.Name, soEvent);
			}

			#endregion

			tec.SaveChanges();
		}

		public List<Event> CreateEventsList(SalesOrderSnapshot salesOrder)
		{
			List<Event> result = new List<Event>();

			if (salesOrder != null)
			{
				foreach (SalesOrderEvent salesOrderEvent in salesOrder.SalesOrderEvents.OrderBy(soe => soe.Date))
				{
					Event createEvent = ToSOTEvent(salesOrderEvent, salesOrder);
					if (createEvent != null)
					{
						result.Add(createEvent);
					}
				}
			}

			return result;
		}

		private Event ToSOTEvent(SalesOrderEvent salesOrderEvent, SalesOrderSnapshot salesOrder)
		{
			Event result = null;
			switch (salesOrderEvent.EventName)
			{
				case EventName.DocumentIssued:
					result = new DocumentIssuedEvent(salesOrderEvent.EventName, salesOrderEvent.ContractNumber, salesOrderEvent.Date.Value)
					{
						Login = salesOrder.Contractor.Login,
						Password = salesOrder.Contractor.Password,
						RelatedDocumentNumber = salesOrderEvent.Number
					};
					break;
				case EventName.DocumentSettled:
				case EventName.FirstPrepayment:
				case EventName.NextPrepayment:
				case EventName.RelatedSalesDocumentIssued:
					result = new RelatedDocumentEvent(salesOrderEvent.EventName, salesOrderEvent.ContractNumber, salesOrderEvent.Date.Value, salesOrderEvent.Number, salesOrderEvent.Value.Value);
					break;
				case EventName.MarkedAsPlanned:
					result = new MarkedAsPlannedEvent(salesOrderEvent.EventName, salesOrderEvent.ContractNumber, salesOrderEvent.Date.Value, salesOrder.ProductionOrderNumber);
					break;
				case EventName.MarkedAsReady:
				case EventName.MarkedAsReadyToInstallation:
					result = new Event(salesOrderEvent.EventName, salesOrderEvent.ContractNumber, salesOrderEvent.Date.Value);
					break;
			}
			if (result != null)
			{
				result.InitDescription();
				salesOrderEvent.Description = result.Description;
			}
			return result;
		}

		private SalesOrderSnapshot CreateSalesOrderSnapshot(GetSalesOrderDetails_Result result, Guid salesOrderId)
		{
			return new SalesOrderSnapshot()
			{
				Id = salesOrderId,
				Contractor = new Contractor()
				{
					Address = result.contractorAddress,
					City = result.contractorCity,
					Email = result.contractorEmail,
					FullName = result.contractorFullName,
					IsAps = result.contractorIsAps == 1,
					Login = result.contractorLogin,
					Password = result.contractorPassword,
					Phone = result.contractorPhone,
					Type = result.contractorType ? 1 : 0
				},
				FittingDate = result.fittingDate,
				Number = result.orderNumber,
				RegistrationDate = result.registrationDate,
				Remarks = result.orderRemarks,
				ProductionOrderNumber = result.productionOrderNumber,
				SalesType = result.salesType,
				Status = result.status,
				Value = result.orderValue
			};
		}

		private SalesOrderSnapshot CreateSalesOrderSnapshot(GetSalesOrderList_Result result)
		{
			return new SalesOrderSnapshot()
			{
				Id = result.id,
				RegistrationDate = result.creationDate,
				Status = result.status,
				SalesType = result.salesType,
				Number = result.orderNumber
			};
		}

		private SalesOrderEvent CreateSalesOrderEvent(GetSalesOrderHistory_Result hResult, SalesOrderSnapshot salesOrder, bool isFirstPrepayment)
		{
			var result = new SalesOrderEvent()
			{
				Date = hResult.eventDate,
				Number = hResult.documentNumber,
				Value = hResult.documentValue,
				ContractNumber = salesOrder.Number
			};
			result.SetEventType(hResult.eventType.Value, salesOrder.SalesTypeName, isFirstPrepayment);
			return result;
		}

		private Contractor CreateContractor(ContractorData result)
		{
			if (result != null)
				return new Contractor()
				{
					Address = result.contractorAddress,
					City = result.contractorCity,
					Email = result.contractorEmail,
					FullName = result.contractorFullName,
					Login = result.contractorLogin,
					Password = result.contractorPassword,
					Phone = result.contractorPhone,
					Type = result.contractorType.HasValue && result.contractorType.Value ? 1 : 0
				};
			else
				return null;
		}

		#region Messages

		public List<Message> GetMessages(List<Guid> messageIds)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				return tec.Messages.Where(m => messageIds.Contains(m.Id)).ToList();
			}
		}

		public Message GetMessage(Guid messageId)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				return tec.Messages.Where(m => m.Id == messageId).FirstOrDefault();
			}
		}

		/// <summary>
		/// Insert or update message
		/// </summary>
		/// <param name="message"></param>
		public void PersistMessage(Message message)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				try
				{
					string entitySetName = tec.Messages.EntitySet.Name;
					message.Id = Guid.NewGuid();
					EntityFrameworkHelper.Instance.PersistEntity<Message>(tec, entitySetName, message);
				}
				catch (OptimisticConcurrencyException)
				{
					throw new MessageAlreadySentException();
				}
			}
		}

		public void DeleteMessage(Message message)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				string entitySetName = tec.Messages.EntitySet.Name;
				EntityFrameworkHelper.Instance.DeleteEntity<Message>(tec, entitySetName, message);
			}
		}

		public void InsertMessages(List<Message> messages)
		{
			using (TrackerEntitiesContainer tec = GetNewTrackerObjectContext())
			{
				InsertMessages(messages, tec);
			}
		}

		public void InsertMessages(List<Message> messages, TrackerEntitiesContainer tec)
		{
			foreach (Message message in messages.Where(msg => msg.Id == Guid.Empty))
			{
				message.Id = Guid.NewGuid();
			}
			string entitySetName = tec.Messages.EntitySet.Name;
			foreach (Message message in messages)
			{
				EntityFrameworkHelper.Instance.InsertEntity(tec, entitySetName, message);
				Thread.Sleep(10);
			}
		}
		#endregion
	}
}
