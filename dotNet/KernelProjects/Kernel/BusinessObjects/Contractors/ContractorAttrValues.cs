using System.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class that manages <see cref="Contractor"/>'s attributes.
    /// </summary>
    public class ContractorAttrValues : BusinessObjectsContainer<ContractorAttrValue>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorAttrValues"/> class with a specified <see cref="Contractor"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Contractor"/> to attach to.</param>
        public ContractorAttrValues(Contractor parent)
            : base(parent, "attribute")
        {
        }

        /// <summary>
        /// Creates new <see cref="ContractorAttrValue"/> according to the contractor's defaults and attaches it to the parent <see cref="Contractor"/>.
        /// </summary>
        /// <returns>A new <see cref="ContractorAttrValue"/>.</returns>
        public override ContractorAttrValue CreateNew()
        {
            //create new ContractorAttrValue object and attach it to the element
            ContractorAttrValue attribute = new ContractorAttrValue((Contractor)this.Parent);

            attribute.Order = this.Children.Count + 1;

            //add the attribute to the attributes collection
            this.Children.Add(attribute);

            return attribute;
        }

		public ContractorAttrValue this[ContractorFieldName fieldName]
		{
			get
			{
				return this.Children.Where(c => c.ContractorFieldName == fieldName).FirstOrDefault();
			}
		}

        public override void Validate()
        {
            base.Validate();

            foreach (var attr in this.Children)
            {
                var count = this.Children.Where(c => c.ContractorFieldId == attr.ContractorFieldId && c != attr).Count();

                if (count > 0)
                {
                    var field = DictionaryMapper.Instance.GetContractorField(attr.ContractorFieldId);

                    if (field.Metadata.Element("allowMultiple") == null)
                        throw new ClientException(ClientExceptionId.SingleAttributeMultipled, null, "name:" + BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(field).Value);
                }
            }
        }
    }
}
