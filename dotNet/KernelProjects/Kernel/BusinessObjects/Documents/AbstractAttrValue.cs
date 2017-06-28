using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    internal abstract class AbstractDocAttrValue : BusinessObject, IOrderable
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
        [XmlSerializable(XmlField = "documentFieldId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "documentFieldId")]
        public Guid DocumentFieldId { get; set; }

        /// <summary>
        /// Field's name
        /// </summary>
        private DocumentFieldName documentFieldName;

        /// <summary>
        /// Gets or sets the field's name
        /// </summary>
        public DocumentFieldName DocumentFieldName
        {
            get { return this.documentFieldName; }
            set
            {
                if (value != DocumentFieldName.Unknown)
                {
                    DocumentField df = DictionaryMapper.Instance.GetDocumentField(value);

                    if (df == null)
                        throw new ClientException(ClientExceptionId.MissingAttribute, null, "name:" + value.ToString());

                    this.DocumentFieldId = df.Id.Value;
                }

                this.documentFieldName = value;
            }
        }

        /// <summary>
        /// Gets or sets attribute value. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value", VariableColumnName = true)]
        public XElement Value { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentAttrValue"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Document"/>.</param>
        public AbstractDocAttrValue(BusinessObject parent)
            : base(parent)
        {
            this.Value = new XElement("value");
        }

        public bool IsDuplicableTo(Guid documentTypeId)
        {
            DocumentField df = DictionaryMapper.Instance.GetDocumentField(this.DocumentFieldId);
            DocumentType dstDocType = DictionaryMapper.Instance.GetDocumentType(documentTypeId);

            return df.DuplicateAction != DuplicatedAttributeAction.NoDuplicate && dstDocType.CanHaveAttribute(df.Name, df.Id.Value);
        }

        public bool AllowMultiple
        {
            get
            {
                DocumentField df = DictionaryMapper.Instance.GetDocumentField(this.DocumentFieldId);

                return df.AllowMultiple;
            }
        }

        public DuplicatedAttributeAction DuplicateAction
        {
            get
            {
                DocumentField df = DictionaryMapper.Instance.GetDocumentField(this.DocumentFieldId);

                return df.DuplicateAction;
            }
        }

		/// <summary>
		/// Algorytm kopiowania atrybutów używa tej flagi. Jeśli jest ustawiona na true to algorytm nie usuwa atrubutu jeśli dokument docelowy nie powinien go mieć
		/// </summary>
		public bool Automatic { get; set; }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.DocumentFieldId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:documentFieldId");

            if (this.Value == null || (this.Value.Value.Length == 0 && !this.Value.HasElements && !this.Value.HasAttributes && this.Value.Name.LocalName == "value"))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:value");
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            this.documentFieldName = DictionaryMapper.Instance.GetDocumentField(this.DocumentFieldId).TypeName;
        }
    }
}
