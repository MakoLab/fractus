using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TrackerDataAccessLayer.Enums;

namespace TrackerDataAccessLayer.Events
{
	public class DocumentIssuedEvent : Event
	{
		public string RelatedDocumentNumber { get; set; }
		public string Login { get; set; }
		public string Password { get; set; }

		protected override List<string> ParametersList
		{
			get
			{
				List<string> result = base.ParametersList;
				
				if (!String.IsNullOrWhiteSpace(RelatedDocumentNumber))
				{
					result.Add(EventContainerName.RelatedDocumentNumber);
					result.Add(RelatedDocumentNumber);
				}

				if (!String.IsNullOrWhiteSpace(Login))
				{
					result.Add(EventContainerName.Login);
					result.Add(Login);
					result.Add(EventContainerName.SmsLogin);
					result.Add(Login.Length > 9 ? Login.Substring(0, 6) + "..." : Login);
				}
				if (!String.IsNullOrWhiteSpace(Password))
				{
					result.Add(EventContainerName.Password);
					result.Add(Password);
				}
				return result;
			}
		}

		public DocumentIssuedEvent(EventName name, string contractNumber, DateTime date)
			: base(name, contractNumber, date)
		{
			
		}
}
}
