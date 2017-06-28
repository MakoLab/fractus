using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TrackerDataAccessLayer.Enums;
using System.Xml.Linq;
using Makolab.Fractus.Commons;

namespace TrackerDataAccessLayer.Events
{
	public class Event : IEquatable<Event>
	{
		public string ContractNumber { get; set; }
		public EventName Name { get; set; }
		public DateTime EventDate { get; set; }
		public string Description { get; private set; }

		public string[] Parameters
		{
			get
			{
				return ParametersList.ToArray();
			}
		}

		protected virtual List<string> ParametersList
		{
			get
			{
				List<string> paramList = new List<string>();

				if (!String.IsNullOrWhiteSpace(this.ContractNumber))
				{
					paramList.Add(EventContainerName.ContractNumber);
					paramList.Add(ContractNumber);

					paramList.Add(EventContainerName.ContractNumber14);
					string contractNumber14 = ContractNumber.Length > 14 ? ContractNumber.Substring(0, 14) : ContractNumber;
					paramList.Add(contractNumber14.ReplaceLocalCharacters());
				}

				return paramList;
			}
		}

		public Event(EventName name, string contractNumber, DateTime date)
		{
			Name = name;
			ContractNumber = contractNumber;
			EventDate = date;
		}

		public void InitDescription()
		{
			if (DescriptionsCache.MessagesXml == null)
				return;

			XElement eventElement = DescriptionsCache.MessagesXml.Root.Elements("event")
				.Where(el => el.GetAtributeValueOrNull("name") == Name.ToString().Decapitalize()).FirstOrDefault();

			if (eventElement != null)
			{
				Description = Utils.ResolveMessage(eventElement.Value, Parameters);
			}
		}

		public bool Equals(Event other)
		{
			if (other == null)
				return false;
			if (this.Name != other.Name)
				return false;
			//Zakomentowane aby nie wysyłały się nowe wiadomości w momencie gdy ktoś dostawi numer zamówienia w panelu!!
			//if (this.ContractNumber != other.ContractNumber) 
			//    return false;
			if (this.EventDate != other.EventDate)
				return false;

			return true;
		}
	}
}
