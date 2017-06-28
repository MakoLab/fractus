using System;
using System.Collections.Generic;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    public class WarehouseItemQuantityDictionary
    {
        public Dictionary<Guid, Dictionary<Guid, decimal>> Dictionary { get; private set; }

        public WarehouseItemQuantityDictionary()
        {
            this.Dictionary = new Dictionary<Guid, Dictionary<Guid, decimal>>();
        }

        public void Add(Guid warehouseId, Guid itemId, decimal quantity)
        {
            Dictionary<Guid, decimal> innerDict = null;

            if (this.Dictionary.ContainsKey(warehouseId))
                innerDict = this.Dictionary[warehouseId];
            else
            {
                innerDict = new Dictionary<Guid, decimal>();
                this.Dictionary.Add(warehouseId, innerDict);
            }

            if (innerDict.ContainsKey(itemId))
                innerDict[itemId] += quantity;
            else
                innerDict.Add(itemId, quantity);
        }

        public void Subtract(Guid warehouseId, Guid itemId, decimal quantity)
        {
            this.Add(warehouseId, itemId, -quantity);
        }
    }
}
