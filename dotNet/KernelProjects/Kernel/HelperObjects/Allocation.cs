using System;
using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    public class Allocation
    {
        public Guid ItemId { get; set; }
        public Guid WarehouseId { get; set; }
        public string ItemName { get; set; }

        public ICollection<AllocationShift> AllocationShifts { get; private set; }

        public Allocation()
        {
            this.AllocationShifts = new List<AllocationShift>();
        }

        public Allocation(XElement element)
            : this()
        {
            this.ItemId = new Guid(element.Element("itemId").Value);
            this.WarehouseId = new Guid(element.Element("warehouseId").Value);

            if (element.Element("itemName") != null)
                this.ItemName = element.Element("itemName").Value;
            else
                this.ItemName = null;

            foreach (XElement shift in element.Element("shifts").Elements())
            {
                this.AllocationShifts.Add(new AllocationShift(shift));
            }
        }

        public AllocationShift FirstAllocation()
        {
            if (this.AllocationShifts.Count > 0)
                return ((List<AllocationShift>)this.AllocationShifts)[0];
            else
            {
                var a = new AllocationShift();
                this.AllocationShifts.Add(a);
                return a;
            }
        }

        public XElement Serialize()
        {
            XElement item = new XElement("allocation");

            item.Add(new XElement("itemId", this.ItemId.ToUpperString()));
            item.Add(new XElement("warehouseId", this.WarehouseId.ToUpperString()));

            if (!String.IsNullOrEmpty(this.ItemName))
                item.Add(new XElement("itemName", this.ItemName));

            XElement shifts = new XElement("shifts");
            item.Add(shifts);

            foreach (var allocation in this.AllocationShifts)
            {
                shifts.Add(allocation.Serialize());
            }

            return item;
        }
    }
}
