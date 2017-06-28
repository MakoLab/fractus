using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    [XmlSerializable(XmlField = "containerType")]
    [DatabaseMapping(TableName = "containerType")]
    internal class ContainerType : BusinessObject, ILabeledDictionaryBusinessObject, IVersionedBusinessObject, IOrderable
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
        /// Gets or sets <see cref="Branch"/>'s companyId.
        /// </summary>
        [XmlSerializable(XmlField = "isSlot")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isSlot")]
        public bool IsSlot { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Branch"/>'s databaseId.
        /// </summary>
        [XmlSerializable(XmlField = "isItemContainer")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isItemContainer")]
        public bool IsItemContainer { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Branch"/>'s label. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

        /// <summary>
        /// Gets or sets <see cref="DocumentField"/>'s metadata. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlMetadata")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlMetadata")]
        public XElement Metadata { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ContainerType"/> class with a specified xml root element.
        /// </summary>
        public ContainerType()
            : base(null, BusinessObjectType.ContainerType)
        {
            this.Labels = new XElement("labels");
            this.Metadata = new XElement("metadata");
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.Labels == null || !this.Labels.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlLabels");

            if (this.Metadata == null || !this.Metadata.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlMetadata");
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
