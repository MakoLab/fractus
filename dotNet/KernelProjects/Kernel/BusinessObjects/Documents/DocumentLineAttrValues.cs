using System.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;
using System;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    internal class DocumentLineAttrValues : BusinessObjectsContainer<DocumentLineAttrValue>
    {
        public DocumentLineAttrValues(BusinessObject parent)
            : base(parent, "attribute")
        {
        }

        public DocumentLineAttrValue this[DocumentFieldName fieldName]
        {
            get
            {
                return this.Children.Where(a => a.DocumentFieldName == fieldName).FirstOrDefault();
            }
        }

		public Guid? GetGuidValueByFieldName(DocumentFieldName fieldName)
		{
			DocumentLineAttrValue dlAttrVal = this[fieldName];
			if (dlAttrVal == null)
			{
				return null;
			}
			else
			{
				return new Guid(dlAttrVal.Value.Value);
			}
		}

        public override DocumentLineAttrValue CreateNew()
        {
            DocumentLineAttrValue attribute = new DocumentLineAttrValue(this.Parent);

            attribute.Order = this.Children.Count + 1;

            //add the attribute to the attributes collection
            this.Children.Add(attribute);

            return attribute;
        }

		public DocumentLineAttrValue CreateNew(DocumentFieldName name)
		{
			var result = this.CreateNew();
			result.DocumentFieldName = name;
			return result;
		}

		public DocumentLineAttrValue CreateNew(DocumentLineAttrValue other)
		{
			DocumentLineAttrValue attribute = this.CreateNew();
			
			attribute.DocumentFieldId = other.DocumentFieldId;
			attribute.Value = new XElement(other.Value);
			
			return attribute;
		}

        /// <summary>
        /// Validates the collection.
        /// </summary>
        public override void Validate()
        {
            //check for forbidden document featues
            foreach (DocumentLineAttrValue attribute in this.Children)
            {
                //DocumentField df = DictionaryMapper.Instance.GetDocumentField(attribute.DocumentFieldId);

                var count = this.Children.Where(c => c.DocumentFieldId == attribute.DocumentFieldId && c != attribute).Count();

                if (count > 0)
                {
                    var field = DictionaryMapper.Instance.GetDocumentField(attribute.DocumentFieldId);

                    if (field.Metadata.Element("allowMultiple") == null)
                        throw new ClientException(ClientExceptionId.SingleAttributeMultipled, null, "name:" + BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(field).Value);
                }
            }

            base.Validate();
        }
    }
}
