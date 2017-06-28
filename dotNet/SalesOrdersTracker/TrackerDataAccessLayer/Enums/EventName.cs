using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TrackerDataAccessLayer.Enums
{
	public enum EventName
	{
		DocumentIssued = 0,
		FirstPrepayment = 1,
		MarkedAsPlanned = 2,
		MarkedAsReady = 3,
		MarkedAsReadyToInstallation = 4,
		NextPrepayment = 5,
		DocumentSettled = 6,
		RelatedSalesDocumentIssued = 7
	}
}
