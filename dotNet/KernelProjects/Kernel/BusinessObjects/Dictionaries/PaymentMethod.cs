using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a payment method (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "paymentMethod")]
    [DatabaseMapping(TableName = "paymentMethod")]
    internal class PaymentMethod : BusinessObject, ILabeledDictionaryBusinessObject, IVersionedBusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets <see cref="PaymentMethod"/>'s symbol. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "dueDays")]
        [Comparable]
        [DatabaseMapping(ColumnName = "dueDays")]
        public int DueDays { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="PaymentMethod"/> is generating cashier document.
        /// </summary>
        [XmlSerializable(XmlField = "isGeneratingCashierDocument")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isGeneratingCashierDocument")]
        public bool IsGeneratingCashierDocument { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="PaymentMethod"/> is incrementing 'due amount' or 'received amount'.
        /// </summary>
        [XmlSerializable(XmlField = "isIncrementingDueAmount")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isIncrementingDueAmount")]
        public bool IsIncrementingDueAmount { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Country"/>'s label. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

        [XmlSerializable(XmlField = "isRequireSettlement")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isRequireSettlement")]
        public bool IsRequireSettlement { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="PaymentMethod"/> class with a specified xml root element.
        /// </summary>
        public PaymentMethod()
            : base(null, BusinessObjectType.PaymentMethod)
        {
            this.Labels = new XElement("labels");
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.Labels == null || !this.Labels.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlLabels");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }
    }
}
