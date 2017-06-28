using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a document field (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "documentField")]
    [DatabaseMapping(TableName = "documentField")]
    internal class DocumentField : BusinessObject, ILabeledDictionaryBusinessObject, IVersionedBusinessObject, IOrderable, IMetadataContainingBusinessObject
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
        /// Gets <see cref="DocumentField"/>'s name.
        /// </summary>
        [XmlSerializable(XmlField = "name")]
        [Comparable]
        [DatabaseMapping(ColumnName = "name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets <see cref="DocumentField"/>'s name.
        /// </summary>
        public DocumentFieldName TypeName
        {
            get
            {
                string[] typeNames = Enum.GetNames(typeof(DocumentFieldName));

                foreach (string name in typeNames)
                {
                    if (name == this.Name)
                        return (DocumentFieldName)Enum.Parse(typeof(DocumentFieldName), this.Name);
                }

                return DocumentFieldName.Unknown;
            }
        }

        /// <summary>
        /// Gets or sets <see cref="DocumentField"/>'s label. Cannot be null.
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

		public string DataType { get { return this.Metadata.Element(XmlName.DataType).Value; } }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentField"/> class with a specified xml root element.
        /// </summary>
        public DocumentField()
            : base(null, BusinessObjectType.DocumentField)
        {
            this.Labels = new XElement("labels");
            this.Metadata = new XElement("metadata");
        }

        public bool AllowMultiple
        {
            get
            {
                if (this.Metadata.Element("allowMultiple") != null)
                    return true;
                else
                    return false;
            }
        }

        public DuplicatedAttributeAction DuplicateAction
        {
            get
            {
				return DuplicatedAttributeActionExtensions.FromXElement(this.Metadata.Element("duplicable"));
            }
        }

		public DuplicatedAttributeAction ShiftDuplicateAction
		{
			get
			{
				return DuplicatedAttributeActionExtensions.FromXElement(this.Metadata.Element("shiftDuplicable"));
			}
		}

		public string FieldId { get { return XmlName.DocumentFieldId; } }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Name))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:name");

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
