using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing relation between any income <see cref="WarehouseDocument"/> and outcome <see cref="WarehouseDocument"/>.
    /// </summary>
    [XmlSerializable(XmlField = "commercialWarehouseValuation")]
    [DatabaseMapping(TableName = "commercialWarehouseValuation")]
    internal class CommercialWarehouseValuation : BusinessObject
    {
        /// <summary>
        /// Gets or sets related line. It stores either <see cref="CommercialDocumentLine"/> or <see cref="WarehouseDocumentLine"/> depending on parent object type.
        /// </summary>
        [XmlSerializable(XmlField = "relatedLine", AutoDeserialization = false)]
        [Comparable]
        public BusinessObject RelatedLine { get; set; }

        /// <summary>
        /// Gets or sets quantity.
        /// </summary>
        [XmlSerializable(XmlField = "quantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "quantity")]
        public decimal Quantity { get; set; }

        /// <summary>
        /// Gets or sets price.
        /// </summary>
        [XmlSerializable(XmlField = "price")]
        [Comparable]
        [DatabaseMapping(ColumnName = "price")]
        public decimal Price { get; set; }

        /// <summary>
        /// Gets or sets value.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value")]
        public decimal Value { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this relation should not be saved. <c>true</c> if the relation should not be saved.
        /// </summary>
        public bool DontSave { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="IncomeOutcomeRelation"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="WarehouseDocumentLine"/>.</param>
        public CommercialWarehouseValuation(BusinessObject parent)
            : base(parent, BusinessObjectType.CommercialWarehouseValuation)
        {
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            this.RelatedLine = null;

            if (element.Element("relatedLine") != null && this.Parent.Parent != null)
            {
                if (this.Parent.Parent.BOType == BusinessObjectType.CommercialDocument)
                {
                    WarehouseDocumentLine line = new WarehouseDocumentLine(null);
                    line.Deserialize(element.Element("relatedLine").Element("line"));
                    this.RelatedLine = line;
                }
                else
                {
                    CommercialDocumentLine line = new CommercialDocumentLine(null);
                    line.Deserialize(element.Element("relatedLine").Element("line"));
                    this.RelatedLine = line;
                }
            }
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.DontSave) return;

            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                Dictionary<string, object> forcedToSave = new Dictionary<string, object>();

                string parentColumnName = null;
                string relatedDocumentColumnName = null;

                //parent of the line
                if (this.Parent.Parent.BOType == BusinessObjectType.CommercialDocument)
                {
                    parentColumnName = "commercialDocumentLineId";
                    relatedDocumentColumnName = "warehouseDocumentLineId";
                }
                else
                {
                    parentColumnName = "warehouseDocumentLineId";
                    relatedDocumentColumnName = "commercialDocumentLineId";
                }

                if (this.RelatedLine != null)
                    forcedToSave.Add(relatedDocumentColumnName, this.RelatedLine.Id.ToUpperString());

                forcedToSave.Add(parentColumnName, this.Parent.Id.ToUpperString());

                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, forcedToSave, null);
            }
        }
    }
}
