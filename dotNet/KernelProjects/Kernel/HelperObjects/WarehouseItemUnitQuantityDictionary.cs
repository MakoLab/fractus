using System;
using System.Collections.Generic;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    public class WarehouseItemUnitQuantityDictionary
    {
        public Dictionary<Guid, Dictionary<Guid, Dictionary<Guid, decimal>>> Dictionary { get; private set; }

        public WarehouseItemUnitQuantityDictionary()
        {
            this.Dictionary = new Dictionary<Guid, Dictionary<Guid, Dictionary<Guid, decimal>>>();
        }

        public void Add(Guid warehouseId, Guid itemId, Guid unitId, decimal quantity)
        {
            Dictionary<Guid, Dictionary<Guid, decimal>> innerDict = null;

            if (this.Dictionary.ContainsKey(warehouseId))
                innerDict = this.Dictionary[warehouseId];
            else
            {
                innerDict = new Dictionary<Guid, Dictionary<Guid, decimal>>();
                this.Dictionary.Add(warehouseId, innerDict);
            }

            Dictionary<Guid, decimal> middleDict = null;

            if (innerDict.ContainsKey(itemId))
                middleDict = innerDict[itemId];
            else
            {
                middleDict = new Dictionary<Guid, decimal>();
                innerDict.Add(itemId, middleDict);
            }

            if (middleDict.ContainsKey(unitId))
                middleDict[unitId] += quantity;
            else
                middleDict.Add(unitId, quantity);
        }
    }
}
