using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a country (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "warehouse")]
    [DatabaseMapping(TableName = "warehouse")]
    internal class Warehouse : BusinessObject, ILabeledDictionaryBusinessObject, IVersionedBusinessObject, IOrderable
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
        /// Gets or sets <see cref="Warehouse"/>'s symbol. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "symbol")]
        [Comparable]
        [DatabaseMapping(ColumnName = "symbol")]
        public string Symbol { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="Warehouse"/> is active.
        /// </summary>
        [XmlSerializable(XmlField = "isActive")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isActive")]
        public bool IsActive { get; set; }

        [XmlSerializable(XmlField = "valuationMethod")]
        [Comparable]
        [DatabaseMapping(ColumnName = "valuationMethod")]
        public ValuationMethod ValuationMethod { get; set; }

        [XmlSerializable(XmlField = "issuePlaceId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "issuePlaceId")]
        public Guid IssuePlaceId { get; set; }

        [XmlSerializable(XmlField = "branchId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "branchId")]
        public Guid BranchId { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Warehouse"/>'s label. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Warehouse"/>'s metadata. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlMetadata")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlMetadata")]
        public XElement Metadata { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="Warehouse"/> class with a specified xml root element.
        /// </summary>
        public Warehouse()
            : base(null, BusinessObjectType.Warehouse)
        {
            this.Labels = new XElement("labels");
            this.Metadata = new XElement("metadata");
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Symbol))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:symbol");

            if (this.Labels == null || !this.Labels.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlLabels");

            if (this.Metadata == null || !this.Metadata.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlMetadata");

            if (this.BranchId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:branchId");

            if (this.IssuePlaceId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:issuePlaceId");
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

		/// <summary>
		/// Compare warehouse branchId with specified id
		/// </summary>
		/// <param name="branchId"></param>
		/// <returns>true if ids are equal</returns>
		public bool IsLocal
		{
			get {
				return this.BranchId == SessionManager.User.BranchId;
			}
		}
    }
}
