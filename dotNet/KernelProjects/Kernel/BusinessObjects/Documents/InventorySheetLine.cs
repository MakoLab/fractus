using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    [XmlSerializable(XmlField = "line")]
    [DatabaseMapping(TableName = "inventorySheetLine")]
    internal class InventorySheetLine : BusinessObject, IOrderable
    {
        public int Order { get { return this.OrdinalNumber; } set { this.OrdinalNumber = value; } }

        [XmlSerializable(XmlField = "ordinalNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ordinalNumber")]
        public int OrdinalNumber { get; set; }

        [XmlSerializable(XmlField = "itemId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemId")]
        public Guid ItemId { get; set; }

        [XmlSerializable(XmlField = "itemName")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemName")]
        public string ItemName { get; set; }

        [XmlSerializable(XmlField = "systemQuantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "systemQuantity")]
        public decimal SystemQuantity { get; set; }


        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value")]
        public decimal Value { get; set; }

        [XmlSerializable(XmlField = "systemDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "systemDate")]
        public DateTime SystemDate { get; set; }

        [XmlSerializable(XmlField = "userQuantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "userQuantity")]
        public decimal? UserQuantity { get; set; }

        [XmlSerializable(XmlField = "userDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "userDate")]
        public DateTime? UserDate { get; set; }

        [XmlSerializable(XmlField = "description")]
        [Comparable]
        [DatabaseMapping(ColumnName = "description")]
        public string Description { get; set; }

        [XmlSerializable(XmlField = "direction")]
        [Comparable]
        [DatabaseMapping(ColumnName = "direction")]
        public int Direction { get; set; }

        [XmlSerializable(XmlField = "unitId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "unitId")]
        public Guid UnitId { get; set; }

        [DatabaseMapping(ColumnName = "inventorySheetId")]
        public Guid InventorySheetId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        public InventorySheetLine(InventorySheet parent)
            : base(parent, BusinessObjectType.InventorySheetLine)
        {
            this.UnitId = new Guid("2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C");
        }

        public override void ValidateConsistency()
        {
            if (this.ItemId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemId");

            if (this.UnitId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:unitId");
        }

        public override void Validate()
        {
            base.Validate();

            if (this.IsNew && ((InventorySheet)this.Parent).DocumentStatus != DocumentStatus.Saved)
                throw new InvalidOperationException("New sheet lines can be added only to a saved sheet");
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }
    }
}
