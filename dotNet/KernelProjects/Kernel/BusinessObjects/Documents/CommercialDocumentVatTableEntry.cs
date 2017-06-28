using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class representing <see cref="CommercialDocument"/>'s VAT table entry.
    /// </summary>
    [XmlSerializable(XmlField = "vtEntry")]
    [DatabaseMapping(TableName = "commercialDocumentVatTable")]
    internal class CommercialDocumentVatTableEntry : BusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets <see cref="VatRate"/>'s id.
        /// </summary>
        [XmlSerializable(XmlField = "vatRateId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "vatRateId")]
        public Guid VatRateId { get; set; }

        /// <summary>
        /// Gets or sets net value.
        /// </summary>
        [XmlSerializable(XmlField = "netValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "netValue")]
        public decimal NetValue { get; set; }

        /// <summary>
        /// Gets or sets gross value.
        /// </summary>
        [XmlSerializable(XmlField = "grossValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "grossValue")]
        public decimal GrossValue { get; set; }

        /// <summary>
        /// Gets or sets vat value.
        /// </summary>
        [XmlSerializable(XmlField = "vatValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "vatValue")]
        public decimal VatValue { get; set; }

        [DatabaseMapping(ColumnName = "commercialDocumentHeaderId")]
        public Guid CommercialDocumentHeaderId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        public CommercialDocumentVatTableEntry(CommercialDocumentBase parent)
            : base(parent)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.VatRateId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:vatRateId");
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
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }
    }
}
