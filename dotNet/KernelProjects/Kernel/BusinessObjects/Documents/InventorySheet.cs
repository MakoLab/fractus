using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
	[XmlSerializable(XmlField = "sheet", RootXmlField = "inventorySheet")]
    [DatabaseMapping(TableName = "inventorySheet",
		GetData = StoredProcedure.document_p_getInventorySheetData, GetDataParamName = "inventorySheetId")]
    internal class InventorySheet : BusinessObject, IOrderable
    {
        public int Order { get { return this.OrdinalNumber; } set { this.OrdinalNumber = value; } }

        [XmlSerializable(XmlField = "inventoryDocumentFullNumber")]
        [DatabaseMapping(ColumnName = "inventoryDocumentFullNumber", LoadOnly = true)]
        public string InventoryDocumentFullNumber { get; set; }

        [XmlSerializable(XmlField = "ordinalNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ordinalNumber")]
        public int OrdinalNumber { get; set; }

        [XmlSerializable(XmlField = "status")]
        [Comparable]
        [DatabaseMapping(ColumnName = "status")]
        public DocumentStatus DocumentStatus { get; set; }

        [XmlSerializable(XmlField = "creationApplicationUserId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "creationApplicationUserId")]
        public Guid CreationApplicationUserId { get; set; }

        [XmlSerializable(XmlField = "creationDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "creationDate")]
        public DateTime CreationDate { get; set; }

        [XmlSerializable(XmlField = "modificationApplicationUserId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "modificationApplicationUserId")]
        public Guid? ModificationApplicationUserId { get; set; }

        [XmlSerializable(XmlField = "modificationDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "modificationDate")]
        public DateTime? ModificationDate { get; set; }

        [XmlSerializable(XmlField = "warehouseId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseId")]
        public Guid? WarehouseId { get; set; }

        [XmlSerializable(XmlField = "closureApplicationUserId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "closureApplicationUserId")]
        public Guid? ClosureApplicationUserId { get; set; }

        [XmlSerializable(XmlField = "closureDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "closureDate")]
        public DateTime? ClosureDate { get; set; }

        private Guid? _inventoryDocumentHeaderId;

        [XmlSerializable(XmlField = "inventoryDocumentHeaderId")]
        [DatabaseMapping(ColumnName = "inventoryDocumentHeaderId")]
        public Guid? InventoryDocumentHeaderId
        {
            get
            {
                if (this._inventoryDocumentHeaderId != null)
                    return this._inventoryDocumentHeaderId;
                else if (this.Parent != null)
                    return this.Parent.Id.Value;
                else
                    return null;
            }

            set
            {
                this._inventoryDocumentHeaderId = value;
            }
        }

        [XmlSerializable(XmlField = "lines", ProcessLast = true)]
        public InventorySheetLines Lines { get; set; }

        [XmlSerializable(XmlField = "tag", UseAttribute = true)]
        public string Tag { get; set; }

        public bool SkipLinesSave { get; set; }

        public bool SkipItemsUnblock { get; set; }

        public InventorySheet(InventoryDocument parent)
            : base(parent, BusinessObjectType.InventorySheet)
        {
            this.Lines = new InventorySheetLines(this);

            this.CreationDate = SessionManager.VolatileElements.CurrentDateTime;
            this.CreationApplicationUserId = SessionManager.User.UserId;
            this.DocumentStatus = DocumentStatus.Saved;
        }

        public override void ValidateConsistency()
        {
            if (this.InventoryDocumentHeaderId == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:inventoryDocumentHeaderId");

            if (this.DocumentStatus == 0)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:status");
        }

        public override void Validate()
        {
            base.Validate();

            if (this.AlternateVersion != null && ((InventorySheet)this.AlternateVersion).ClosureDate != null)
                throw new ClientException(ClientExceptionId.ClosedInventorySheetEdition);

            if (!this.SkipLinesSave && this.Lines != null)
                this.Lines.Validate();
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Lines != null && !this.SkipLinesSave)
                this.Lines.SaveChanges(document);

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }

        public override void UpdateStatus(bool isNew)
        {
            if(this.SkipLinesSave) return;

            base.UpdateStatus(isNew);

            if (this.Lines != null)
            {
                this.Lines.UpdateStatus(isNew);

                if (this.Lines.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.Status == BusinessObjectStatus.Modified)
            {
                this.ModificationDate = SessionManager.VolatileElements.CurrentDateTime;
                this.ModificationApplicationUserId = SessionManager.User.UserId;
            }
        }

        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            InventorySheet alternateDocument = (InventorySheet)alternate;

            if (this.Lines != null && !this.SkipLinesSave)
                this.Lines.SetAlternateVersion(alternateDocument.Lines);
        }
    }
}
