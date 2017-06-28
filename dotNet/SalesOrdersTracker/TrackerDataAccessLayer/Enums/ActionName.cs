using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TrackerDataAccessLayer.Enums
{
	public enum ActionName
	{
		DocumentIssued = 1, /*Wystawienie dokumentu w systemie*/
		PrepaymentIssued = 2, /*Wystawienie zaliczki*/
		MarkedAsPlanned = 3, /*Oznaczenie jako zaplanowane*/
		MarkedAsReady = 4, /*Oznaczenie jako gotowe*/
		SettlementIssued = 5, /*Wystawienie FSR*/
		RelatedSalesDocumentIssued = 6, /*Wystawienie dok. sprzedaży*/
	}
}
