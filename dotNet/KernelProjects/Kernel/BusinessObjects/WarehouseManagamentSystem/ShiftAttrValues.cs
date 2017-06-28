using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    internal class ShiftAttrValues : BusinessObjectsContainer<ShiftAttrValue>
    {
        public ShiftAttrValues(Shift parent)
            : base(parent, "attribute")
        {
        }

        public override ShiftAttrValue CreateNew()
        {
            ShiftAttrValue attribute = new ShiftAttrValue((Shift)this.Parent);

            attribute.Order = this.Children.Count + 1;

            this.Children.Add(attribute);

            return attribute;
        }

        public void CopyFrom(ShiftAttrValues attributes)
        {
            foreach (ShiftAttrValue val in attributes.Children)
            {
                var attr = this.CreateNew();
                attr.ShiftFieldId = val.ShiftFieldId;
                attr.Value = new XElement(val.Value);
            }
        }

        public override void Validate()
        {
            foreach (ShiftAttrValue attribute in this.Children)
            {
                //ShiftField df = DictionaryMapper.Instance.GetShiftField(attribute.ShiftFieldId);

                var count = this.Children.Where(c => c.ShiftFieldId == attribute.ShiftFieldId && c != attribute).Count();

                if (count > 0)
                {
                    var field = DictionaryMapper.Instance.GetDocumentField(attribute.ShiftFieldId);

                    if (field.Metadata.Element("allowMultiple") == null)
                        throw new ClientException(ClientExceptionId.SingleAttributeMultipled, null, "name:" + BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(field).Value);
                }
            }

            base.Validate();
        }
    }
}
