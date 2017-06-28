using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a shift field (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "shiftField")]
    [DatabaseMapping(TableName = "shiftField")]
    internal class ShiftField : BusinessObject, ILabeledDictionaryBusinessObject, IVersionedBusinessObject, IOrderable, IMetadataContainingBusinessObject
    {
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        public bool ForceSave { get; set; }

        public Guid? NewVersion { get; set; }

        [XmlSerializable(XmlField = "name")]
        [Comparable]
        [DatabaseMapping(ColumnName = "name")]
        public string Name { get; set; }

        public ShiftFieldName TypeName
        {
            get
            {
                string[] typeNames = Enum.GetNames(typeof(ShiftFieldName));

                foreach (string name in typeNames)
                {
                    if (name == this.Name)
                        return (ShiftFieldName)Enum.Parse(typeof(ShiftFieldName), this.Name);
                }

                return ShiftFieldName.Unknown;
            }
        }

        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

        [XmlSerializable(XmlField = "xmlMetadata")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlMetadata")]
        public XElement Metadata { get; set; }

        public ShiftField()
            : base(null, BusinessObjectType.ShiftField)
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
                if (this.Metadata.Element("duplicable") != null)
                {
                    XAttribute attr = this.Metadata.Element("duplicable").Attribute("action");

                    if (attr == null || attr.Value.ToUpperInvariant() == "ONEINSTANCE")
                        return DuplicatedAttributeAction.OneInstance;
                    else if (attr.Value.ToUpperInvariant() == "CONCATENATE")
                        return DuplicatedAttributeAction.Concatenate;
                    else //if (attr.Value.ToUpperInvariant() == "DUPLICATE")
                        return DuplicatedAttributeAction.Duplicate;
                }
                else
                    return DuplicatedAttributeAction.NoDuplicate;
            }
        }

		public string FieldId { get { return XmlName.ShiftFieldId; } }

        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Name))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:name");

            if (this.Labels == null || !this.Labels.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlLabels");

            if (this.Metadata == null || !this.Metadata.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlMetadata");
        }

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
