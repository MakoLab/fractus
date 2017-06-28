using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TrackerDataAccessLayer.Enums;

namespace TrackerDataAccessLayer
{
	public partial class SalesOrderEvent
	{
		public EventName EventName
		{
			get
			{
				return (EventName)Type;
			}
			set
			{
				Type = (int)value;
			}
		}

		public void SetEventType(int type, SalesTypeName salesType, bool isFirstPrepayment)
		{
			switch ((ActionName)type)
			{
				case ActionName.DocumentIssued:
					this.EventName = EventName.DocumentIssued;
					break;
				case ActionName.PrepaymentIssued:
					this.EventName = isFirstPrepayment ? EventName.FirstPrepayment : EventName.NextPrepayment;
					break;
				case ActionName.MarkedAsPlanned:
					this.EventName = EventName.MarkedAsPlanned;
					break;
				case ActionName.MarkedAsReady:
					this.EventName = salesType == SalesTypeName.Items ? EventName.MarkedAsReady : EventName.MarkedAsReadyToInstallation;
					break;
				case ActionName.SettlementIssued:
					this.EventName = EventName.DocumentSettled;
					break;
				case ActionName.RelatedSalesDocumentIssued:
					this.EventName = EventName.RelatedSalesDocumentIssued;
					break;
			}
		}

		public string Description { get; set; }
	}
	
}
