using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
    /// <summary>
    /// Class that encapsulates return value from <see cref="DocumentMapper.GetDeliveries"/> method.
    /// </summary>
    internal class DeliveryResponse
    {
        /// <summary>
        /// Class that stores information about single delivery of the specified item in the specified warehouse.
        /// </summary>
        internal class SingleDelivery
        {
            /// <summary>
            /// Gets or sets the id of the income warehouse document line.
            /// </summary>
            public Guid IncomeWarehouseDocumentLineId { get; set; }

            /// <summary>
            /// Gets or sets the quantity.
            /// </summary>
            public decimal Quantity { get; set; }

            /// <summary>
            /// Gets or sets the income date.
            /// </summary>
            public DateTime IncomeDate { get; set; }

            public DateTime IssueDate { get; set; }

            public int OrdinalNumber { get; set; }

            /// <summary>
            /// Initializes a new instance of the <see cref="SingleDelivery"/> class.
            /// </summary>
            /// <param name="incomeWarehouseDocumentLineId">The income warehouse document line id.</param>
            /// <param name="quantity">The quantity.</param>
            /// <param name="incomeDate">The income date.</param>
            public SingleDelivery(Guid incomeWarehouseDocumentLineId, decimal quantity, DateTime incomeDate, DateTime issueDate, int ordinalNumber)
            {
                this.IncomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId;
                this.Quantity = quantity;
                this.IncomeDate = incomeDate;
                this.IssueDate = issueDate;
                this.OrdinalNumber = ordinalNumber;
            }
        }

        /// <summary>
        /// Gets or sets item id.
        /// </summary>
        public Guid ItemId { get; private set; }

        /// <summary>
        /// Gets or sets warehouse id.
        /// </summary>
        public Guid WarehouseId { get; private set; }

        public decimal ReservedQuantity { get; private set; }

        public decimal OrderedQuantity { get; private set; }

        /// <summary>
        /// Quantity that is available. It should be changed during logic to mark how much is still left.
        /// </summary>
        public decimal AvailableQuantity { get; set; }

        public decimal QuantityInStock { get; set; }

        /// <summary>
        /// Gets or sets the collection of deliveries for the specified item in the specified warehouse.
        /// </summary>
        public ICollection<SingleDelivery> Deliveries { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DeliveryResponse"/> class.
        /// </summary>
        /// <param name="element">The <see cref="XElement"/> from which to deserialize the object.</param>
        public DeliveryResponse(XElement element)
        {
            this.ItemId = new Guid(element.Attribute("itemId").Value);
            this.WarehouseId = new Guid(element.Attribute("warehouseId").Value);
            this.ReservedQuantity = Convert.ToDecimal(element.Attribute("reservedQuantity").Value, CultureInfo.InvariantCulture);
            this.OrderedQuantity = Convert.ToDecimal(element.Attribute("orderedQuantity").Value, CultureInfo.InvariantCulture);

            decimal quantityInStock = 0;

            List<SingleDelivery> deliveries = new List<SingleDelivery>(element.Elements().Count());

            foreach (XElement delivery in element.Elements())
            {
                decimal quantity = Convert.ToDecimal(delivery.Attribute("quantity").Value, CultureInfo.InvariantCulture);

                deliveries.Add(new SingleDelivery(new Guid(delivery.Attribute("incomeWarehouseDocumentLineId").Value),
                    quantity,
                    DateTime.Parse(delivery.Attribute("incomeDate").Value, CultureInfo.InvariantCulture), 
                    DateTime.Parse(delivery.Attribute("issueDate").Value, CultureInfo.InvariantCulture),
                    Convert.ToInt32(delivery.Attribute("ordinalNumber").Value, CultureInfo.InvariantCulture)));

                quantityInStock += quantity;
            }

            this.Deliveries = deliveries;

            this.AvailableQuantity = quantityInStock - ReservedQuantity;
            this.QuantityInStock = quantityInStock;
        }
    }
}
