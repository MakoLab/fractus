using System;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Enums;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
    /// <summary>
    /// Input parameter class for <see cref="DocumentMapper.GetDeliveries"/> method.
    /// </summary>
    internal class DeliveryRequest
    {
        /// <summary>
        /// Gets or sets item id.
        /// </summary>
        public Guid ItemId { get; set; }

        /// <summary>
        /// Gets or sets warehouse id.
        /// </summary>
        public Guid WarehouseId { get; set; }

        /// <summary>
        /// Gets or sets differential quantity related to the quantity that is already in the database.
        /// </summary>
        //public decimal DifferentialQuantity { get; set; }

        /// <summary>
        /// Gets or sets item unit id.
        /// </summary>
        public Guid UnitId { get; set; }

        /// <summary>
        /// Gets or sets flag indicating whether deliveries for this item should be returned.
        /// </summary>
        //public bool WithNoDeliveries { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DeliveryRequest"/> class.
        /// </summary>
        /// <param name="itemId">The item id.</param>
        /// <param name="warehouseId">The warehouse id.</param>
        /// <param name="differentialQuantity">Differential quantity related to the quantity that is already in the database.</param>
        /// <param name="unitId">The unit id.</param>
        /// <param name="withNoDeliveries">if set to <c>true</c> deliveries will be returned; otherwise it will only updates stock and locks the item.</param>
        public DeliveryRequest(Guid itemId, Guid warehouseId, Guid unitId)
        {
            this.ItemId = itemId;
            this.WarehouseId = warehouseId;
            //this.DifferentialQuantity = differentialQuantity;
            this.UnitId = unitId;
            //this.WithNoDeliveries = withNoDeliveries;
        }

        /// <summary>
        /// Serializes the object to <see cref="XElement"/>.
        /// </summary>
        /// <returns>The object serialized to <see cref="XElement"/>.</returns>
        public XElement ToXElement()
        {
            XElement el = new XElement("delivery");
            el.Add(new XAttribute("itemId", this.ItemId.ToUpperString()));
            el.Add(new XAttribute("warehouseId", this.WarehouseId.ToUpperString()));
            //el.Add(new XAttribute("differentialQuantity", this.DifferentialQuantity));
            el.Add(new XAttribute("unitId", this.UnitId.ToUpperString()));
            //el.Add(new XAttribute("withNoDeliveries", this.WithNoDeliveries ? "1" : "0"));

            return el;
        }
    }
}
