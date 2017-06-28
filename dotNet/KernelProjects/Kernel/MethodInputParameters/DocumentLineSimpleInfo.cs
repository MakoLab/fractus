using System;
using System.Collections.Generic;
using System.Text;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Enums;
using System.Globalization;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
	public partial class DocumentLineSimpleInfo
	{
		public string ItemCode { get; set; }
		public string ItemFamily { get; set; }
		public decimal Quantity { get; set; }
        public decimal DefaultPrice { get; set; }
        public string Name { get; set; }
        public bool PurchasePrice { get; set; }
	}
}
