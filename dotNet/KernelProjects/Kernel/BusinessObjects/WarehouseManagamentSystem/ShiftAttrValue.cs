using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    [XmlSerializable(XmlField = "attribute")]
	[DatabaseMapping(TableName = "shiftAttrValue", Insert = StoredProcedure.warehouse_p_insertShiftAttrValue, Update = StoredProcedure.warehouse_p_updateShiftAttrValue)]
    internal class ShiftAttrValue : BusinessObject, IOrderable
    {
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        [XmlSerializable(XmlField = "shiftFieldId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "shiftFieldId")]
        public Guid ShiftFieldId { get; set; }

        private ShiftFieldName shiftFieldName;

        public ShiftFieldName ShiftFieldName
        {
            get { return this.shiftFieldName; }
            set
            {
                if (value != ShiftFieldName.Unknown)
                {
                    this.ShiftFieldId = DictionaryMapper.Instance.GetShiftField(value).Id.Value;
                }

                this.shiftFieldName = value;
            }
        }

        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value", VariableColumnName = true)]
        public XElement Value { get; set; }

        [DatabaseMapping(ColumnName = "shiftId")]
        public Guid ShiftId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        public ShiftAttrValue(Shift parent)
            : base(parent)
        {
            this.Value = new XElement("value");
        }

        public bool AllowMultiple
        {
            get
            {
                ShiftField sf = DictionaryMapper.Instance.GetShiftField(this.ShiftFieldId);

                return sf.AllowMultiple;
            }
        }

        public DuplicatedAttributeAction DuplicateAction
        {
            get
            {
                ShiftField sf = DictionaryMapper.Instance.GetShiftField(this.ShiftFieldId);

                return sf.DuplicateAction;
            }
        }

        public override void ValidateConsistency()
        {
            if (this.ShiftFieldId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:shiftFieldId");

            if (this.Value == null || this.Value.Value.Length == 0 && this.Value.HasElements == false)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:value");
        }

        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            this.shiftFieldName = DictionaryMapper.Instance.GetShiftField(this.ShiftFieldId).TypeName;
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                ShiftField field = DictionaryMapper.Instance.GetShiftField(this.ShiftFieldId);

                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, field.Metadata.Element("dataType").Value);
            }
        }
    }
}
