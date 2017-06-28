using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Kernel.Enums
{
	public class SourceType
	{
		public const string SalesOrder = "salesOrder";
        public const string SalesDocument = "salesDocument";
		public const string SalesOrderRealization = "salesOrderRealization";
		public const string MultipleSalesOrders = "multipleSalesOrders";
		public const string SimulatedInvoice = "simulatedInvoice";
		public const string ExternalPortaSalesInvoice = "externalPortaSalesInvoice";
		public const string PortaExternalOutcome = "portaExternalOutcome";
		public const string PortaOrder = "portaOrder";
        public const string EcOrder = "ecOrder";
        public const string PortaOrderCsv = "portaOrderCsv";
	}
}
