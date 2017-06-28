using System;
using System.Collections.Generic;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    public class WarehouseItemQuantityInventoryDocumentDictionary
    {
        public class QuantityObject
        {
            public decimal Quantity { get; set; }
            public decimal SystemQuantity { get; set; }
            public Guid UnitId { get; set; }
        }

        public Dictionary<Guid, Dictionary<Guid, QuantityObject>> Dictionary { get; private set; }

        public WarehouseItemQuantityInventoryDocumentDictionary()
        {
            this.Dictionary = new Dictionary<Guid, Dictionary<Guid, QuantityObject>>();
        }

        public void Add(Guid warehouseId, Guid itemId, decimal quantity, decimal systemQuantity, Guid unitId)
        {
            Dictionary<Guid, QuantityObject> innerDict = null;

            if (this.Dictionary.ContainsKey(warehouseId))
                innerDict = this.Dictionary[warehouseId];
            else
            {
                innerDict = new Dictionary<Guid, QuantityObject>();
                this.Dictionary.Add(warehouseId, innerDict);
            }

            if (innerDict.ContainsKey(itemId))
            {
                QuantityObject qty = innerDict[itemId];
                qty.Quantity += quantity;
                qty.SystemQuantity = systemQuantity;
                qty.UnitId = unitId;
            }
            else
                innerDict.Add(itemId, new QuantityObject() { Quantity = quantity, SystemQuantity = systemQuantity, UnitId = unitId });
        }
    }
}
