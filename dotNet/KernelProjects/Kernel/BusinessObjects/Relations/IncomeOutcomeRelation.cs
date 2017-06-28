using System;
using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing relation between any income <see cref="WarehouseDocument"/> and outcome <see cref="WarehouseDocument"/>.
    /// </summary>
    [XmlSerializable(XmlField = "incomeOutcomeRelation")]
    [DatabaseMapping(TableName = "incomeOutcomeRelation")]
    internal class IncomeOutcomeRelation : BusinessObject
    {
        /// <summary>
        /// Gets or sets related <see cref="WarehouseDocumentLine"/>.
        /// </summary>
        [XmlSerializable(XmlField = "relatedLine", RelatedObjectType = BusinessObjectType.WarehouseDocumentLine)]
        [Comparable]
        public WarehouseDocumentLine RelatedLine { get; set; }

        /// <summary>
        /// Gets or sets quantity on relation.
        /// </summary>
        [XmlSerializable(XmlField = "quantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "quantity")]
        public decimal Quantity { get; set; }

        /// <summary>
        /// Gets or sets income date.
        /// </summary>
        [XmlSerializable(XmlField = "incomeDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "incomeDate")]
        public DateTime IncomeDate { get; set; }

        /// <summary>
        /// Gets or sets the relation's direction.
        /// </summary>
        [XmlSerializable(XmlField = "direction", UseAttribute = true)]
        public WarehouseDirection Direction { get; set; }

        /// <summary>
        /// Gets or sets the outcome date for income lines. If set to <c>null</c> it means that the relation doesn't use all of the income resources.
        /// </summary>
        [DatabaseMapping(ColumnName = "_outcomeDate")]
        public DateTime? OutcomeDate { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="IncomeOutcomeRelation"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="WarehouseDocumentLine"/>.</param>
        /// <param name="direction">The direction of the relation. Specifies whether this relation puts something to warehouse or gets something from warehouse.</param>
        public IncomeOutcomeRelation(BusinessObject parent, WarehouseDirection direction)
            : base(parent, BusinessObjectType.IncomeOutcomeRelation)
        {
            this.Direction = direction;
            this.RelatedLine = new WarehouseDocumentLine(null);
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.RelatedLine == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:relatedLine");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                Dictionary<string, object> forcedToSave = new Dictionary<string, object>();

                string parentColumnName = null;
                string relatedDocumentColumnName = null;

                if (this.Direction == WarehouseDirection.Outcome)
                {
                    parentColumnName = "outcomeWarehouseDocumentLineId";
                    relatedDocumentColumnName = "incomeWarehouseDocumentLineId";
                }
                else
                {
                    parentColumnName = "incomeWarehouseDocumentLineId";
                    relatedDocumentColumnName = "outcomeWarehouseDocumentLineId";
                }

                forcedToSave.Add(relatedDocumentColumnName, this.RelatedLine.Id.ToUpperString());

                forcedToSave.Add(parentColumnName, this.Parent.Id.ToUpperString());

                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, forcedToSave, null);
            }
        }
    }
}
