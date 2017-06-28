using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    class AllocationCollection
    {
        public ICollection<Allocation> Allocations { get; set; }

        public AllocationCollection()
        {
            this.Allocations = new List<Allocation>();
        }

        public AllocationCollection(XElement element)
            : this()
        {
            foreach (var e in element.Elements())
            {
                this.Allocations.Add(new Allocation(e));
            }
        }

        public Allocation CreateNew()
        {
            var a = new Allocation();
            this.Allocations.Add(a);
            return a;
        }

        public Allocation Get(Guid itemId, Guid warehouseId)
        {
            var a = this.Allocations.Where(s => s.ItemId == itemId && s.WarehouseId == warehouseId).FirstOrDefault();

            if (a == null)
            {
                a = new Allocation() { ItemId = itemId, WarehouseId = warehouseId };
                this.Allocations.Add(a);
            }

            return a;
        }

        public XElement Serialize()
        {
            XElement allocations = new XElement("allocations");

            foreach (var a in this.Allocations)
            {
                allocations.Add(a.Serialize());
            }

            return allocations;
        }
    }
}
