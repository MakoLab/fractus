using System;
using System.Globalization;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    public class AllocationShift
    {
        public Guid? SourceShiftId { get; set; }
        public Guid IncomeWarehouseDocumentLineId { get; set; }
        public decimal Quantity { get; set; }
        public string ContainerLabel { get; set; }
        public string SlotContainerLabel { get; set; }

        public AllocationShift()
        {
        }

        public AllocationShift(XElement element)
        {
            if (element.Element("sourceShiftId") != null)
                this.SourceShiftId = new Guid(element.Element("sourceShiftId").Value);

            this.IncomeWarehouseDocumentLineId = new Guid(element.Element("incomeWarehouseDocumentLineId").Value);
            this.Quantity = Convert.ToDecimal(element.Element("quantity").Value, CultureInfo.InvariantCulture);
        }

        public XElement Serialize()
        {
            XElement el = new XElement("shift");

            if (this.SourceShiftId != null)
                el.Add(new XElement("sourceShiftId", this.SourceShiftId));

            el.Add(new XElement("incomeWarehouseDocumentLineId", this.IncomeWarehouseDocumentLineId));
            el.Add(new XElement("quantity", this.Quantity));

            if (!String.IsNullOrEmpty(this.SlotContainerLabel))
                el.Add(new XElement("slotContainerLabel", this.SlotContainerLabel));

            if (!String.IsNullOrEmpty(this.ContainerLabel))
                el.Add(new XElement("containerLabel", this.ContainerLabel));

            return el;
        }
    }
}
