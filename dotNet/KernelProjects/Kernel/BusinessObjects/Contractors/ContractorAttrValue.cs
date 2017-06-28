using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class representing <see cref="Contractor"/>'s attribute.
    /// </summary>
    [XmlSerializable(XmlField = "attribute")]
    [DatabaseMapping(TableName = "contractorAttrValue")]
    public class ContractorAttrValue : BusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets the attribute's description id.
        /// </summary>
        [XmlSerializable(XmlField = "contractorFieldId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorFieldId")]
        public Guid ContractorFieldId { get; private set; }

        /// <summary>
        /// Field's name
        /// </summary>
        private ContractorFieldName contractorFieldName;

        /// <summary>
        /// Gets or sets the field's name
        /// </summary>
        public ContractorFieldName ContractorFieldName
        {
            get { return this.contractorFieldName; }
            set
            {
                if (value != ContractorFieldName.Unknown)
                {
                    this.ContractorFieldId = DictionaryMapper.Instance.GetContractorField(value).Id.Value;
                }

                this.contractorFieldName = value;
            }
        }

        /// <summary>
        /// Gets or sets attribute value. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value", VariableColumnName = true)]
        public XElement Value { get; set; }

        [DatabaseMapping(ColumnName = "contractorId")]
        public Guid ContractorId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorAttrValue"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Contractor"/>.</param>
        public ContractorAttrValue(Contractor parent)
            : base(parent)
        {
            this.Value = new XElement("value");
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and attaches them to proper xml elements.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            this.contractorFieldName = DictionaryMapper.Instance.GetContractorField(this.ContractorFieldId).TypeName;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ContractorFieldId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:contractorFieldId");

            if (this.Value == null || this.Value.Value.Length == 0 && this.Value.HasElements == false)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:value");
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
                ContractorField field = DictionaryMapper.Instance.GetContractorField(this.ContractorFieldId);
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, field.Metadata.Element("dataType").Value);
            }
        }
    }
}
