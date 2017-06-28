using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;
using System.Globalization;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
	internal class SalesOrderRealizationInfo
	{
		internal class SingleLineInfo
		{
			public Guid Id { get; set; }
			public Guid ItemId { get; set; }
			/// <summary>
			/// Tak naprawdę to jest abs(quantity * commercialDocument)
			/// </summary>
			public decimal Quantity { get; set; }
			public Guid RelatedSalesOrderLineId { get; set; }

			public SingleLineInfo(XElement element)
			{
				this.Id = new Guid(element.Element(XmlName.Id).Value);
				this.ItemId = new Guid(element.Element(XmlName.ItemId).Value);
				this.Quantity = Convert.ToDecimal(element.Element(XmlName.Quantity).Value, CultureInfo.InvariantCulture);
				this.RelatedSalesOrderLineId = new Guid(element.Element(XmlName.GuidValue).Value);
			}
		}

		public ICollection<SingleLineInfo> Lines { get; private set; }

		public SalesOrderRealizationInfo(XElement element)
		{
			this.Lines = new List<SingleLineInfo>();
			foreach (XElement lineElement in element.Elements(XmlName.CommercialDocumentLine))
			{
				this.Lines.Add(new SingleLineInfo(lineElement));
			}
		}

		public decimal SumQuantity(Guid relatedLineId)
		{
			return this.Lines.Where(l => l.RelatedSalesOrderLineId == relatedLineId).Sum(l => l.Quantity);
		}
	}
}
