using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    [XmlSerializable(XmlField = "shift")]
	[DatabaseMapping(TableName = "shift", Insert = StoredProcedure.warehouse_p_insertShift, Update = StoredProcedure.warehouse_p_updateShiftTransaction)]
    internal class Shift : BusinessObject, IOrderable
    {
        public int Order { get { return this.OrdinalNumber; } set { this.OrdinalNumber = value; } }

        [XmlSerializable(XmlField = "ordinalNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ordinalNumber")]
        public int OrdinalNumber { get; set; }

        private Guid? _shiftTransactionId;

        [XmlSerializable(XmlField = "shiftTransactionId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "shiftTransactionId")]
        public Guid? ShiftTransactionId
        {
            get
            {
                if (this.Parent != null)
                    return Parent.Id.Value;
                else
                    return this._shiftTransactionId;
            }
            set { this._shiftTransactionId = value; }
        }

        [XmlSerializable(XmlField = "incomeWarehouseDocumentLineId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "incomeWarehouseDocumentLineId")]
        public Guid IncomeWarehouseDocumentLineId { get; set; }

        [XmlSerializable(XmlField = "warehouseId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseId")]
        public Guid WarehouseId { get; set; }

        [XmlSerializable(XmlField = "containerId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "containerId")]
        public Guid? ContainerId { get; set; }

        [XmlSerializable(XmlField = "quantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "quantity")]
        public decimal Quantity { get; set; }

        [XmlSerializable(XmlField = "warehouseDocumentLineId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseDocumentLineId")]
        public Guid? WarehouseDocumentLineId { get; set; }

        [XmlSerializable(XmlField = "sourceShiftId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "sourceShiftId")]
        public Guid? SourceShiftId { get; set; }

        [XmlSerializable(XmlField = "sourceContainerId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "sourceContainerId", LoadOnly = true)]
        public Guid? SourceContainerId { get; set; }

        [XmlSerializable(XmlField = "status")]
        [Comparable]
        [DatabaseMapping(ColumnName = "status")]
        public int ShiftStatus { get; set; }

        [XmlSerializable(XmlField = "itemId")]
        [DatabaseMapping(ColumnName = "itemId", LoadOnly = true)]
        public Guid? ItemId { get; set; }

        [XmlSerializable(XmlField = "itemName")]
        [DatabaseMapping(ColumnName = "itemName", LoadOnly = true)]
        public string ItemName { get; set; }

        [XmlSerializable(XmlField = "lineOrdinalNumber", UseAttribute = true)]
        public int? LineOrdinalNumber { get; set; }

        public CommercialDocumentLine RelatedCommercialDocumentLine { get; set; }
        public WarehouseDocumentLine RelatedWarehouseDocumentLine { get; set; }

        [XmlSerializable(XmlField = "attributes", ProcessLast = true)]
        public ShiftAttrValues Attributes { get; private set; }

        public Shift(ShiftTransaction parent)
            : base(parent)
        {
            if (parent != null)
                this.ShiftTransactionId = parent.Id.Value;

            this.Attributes = new ShiftAttrValues(this);

            this.ShiftStatus = 40;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ShiftTransactionId == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:shiftTransactionId");

            if (this.IncomeWarehouseDocumentLineId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:incomeWarehouseDocumentLineId");

            if (this.WarehouseId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:warehouseId");

            //if (this.SourceShiftId == null && this.ContainerId == null)
            //    throw new ClientException(ClientExceptionId.SourceAndDestinationContainersAreTheSame);

            if (this.ShiftStatus == 0)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:status");
        }

        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            Shift alternateShift = (Shift)alternate;

            if (this.Attributes != null)
                this.Attributes.SetAlternateVersion(alternateShift.Attributes);
        }

        public override void Validate()
        {
            base.Validate();

            if (this.Quantity <= 0)
                throw new ClientException(ClientExceptionId.ZeroQuantityOnShift);

            bool isRelatedToOutcome = false;

            if (this.Parent != null && this.Parent.Parent != null
                && this.Parent.Parent.BOType == BusinessObjectType.WarehouseDocument)
            {
                WarehouseDocument whDoc = (WarehouseDocument)this.Parent.Parent;

                if (whDoc.WarehouseDirection == WarehouseDirection.Outcome ||
                    whDoc.WarehouseDirection == WarehouseDirection.OutcomeShift)
                    isRelatedToOutcome = true;
            }

            if (!isRelatedToOutcome && this.ContainerId == null)
                throw new ClientException(ClientExceptionId.NoContainerIdOnShift);

            if (this.Attributes != null)
                this.Attributes.Validate();
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            //save changes of child elements first
            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                if (this.RelatedWarehouseDocumentLine == null || this.RelatedWarehouseDocumentLine.Status != BusinessObjectStatus.Deleted)
                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }

        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Status == BusinessObjectStatus.Modified || this.Status == BusinessObjectStatus.New)
            {
                if (this.RelatedWarehouseDocumentLine != null && this.RelatedWarehouseDocumentLine.Status != BusinessObjectStatus.New)
                    this.RelatedWarehouseDocumentLine.Status = BusinessObjectStatus.Modified;
            }

            if (this.Attributes != null)
            {
                this.Attributes.UpdateStatus(isNew);

                if (this.Attributes.IsAnyChildDeleted() && this.AlternateVersion != null && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }
        }
    }
}
