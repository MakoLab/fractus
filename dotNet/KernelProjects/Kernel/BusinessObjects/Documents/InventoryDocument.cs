using System;
using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    [XmlSerializable(XmlField = "inventoryDocument")]
    [DatabaseMapping(TableName = "inventoryDocumentHeader",
		GetData = StoredProcedure.document_p_getInventoryDocumentData, GetDataParamName = "inventoryDocumentHeaderId", List = StoredProcedure.document_p_getInventoryDocuments)]
    internal class InventoryDocument : Document
    {
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

        [XmlSerializable(XmlField = "closureApplicationUserId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "closureApplicationUserId")]
        public Guid? ClosureApplicationUserId { get; set; }

        [XmlSerializable(XmlField = "closureDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "closureDate")]
        public DateTime? ClosureDate { get; set; }

        [XmlSerializable(XmlField = "type")]
        [Comparable]
        [DatabaseMapping(ColumnName = "type")]
        public string Type { get; set; }

        [XmlSerializable(XmlField = "warehouseId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseId")]
        public Guid? WarehouseId { get; set; }

        [XmlSerializable(XmlField = "header")]
        [Comparable]
        [DatabaseMapping(ColumnName = "header")]
        public string Header { get; set; }

        [XmlSerializable(XmlField = "footer")]
        [Comparable]
        [DatabaseMapping(ColumnName = "footer")]
        public string Footer { get; set; }

        [XmlSerializable(XmlField = "responsiblePersonCommission")]
        [Comparable]
        [DatabaseMapping(ColumnName = "responsiblePersonCommission")]
        public XElement ResponsiblePersonCommission { get; set; }

        //[XmlSerializable(XmlField = "issueDate")]
        //[Comparable]
        //[DatabaseMapping(ColumnName = "issueDate")]
        //public DateTime issueDate { get; set; }

        [XmlSerializable(XmlField = "sheets", ProcessLast = true)]
        public InventorySheets Sheets { get; set; }

        public bool UnblockItems { get; set; }

        public ICollection<InventorySheet> SheetsToSave { get; private set; }

		public override string ParentIdColumnName
		{
			get
			{
				return "inventoryDocumentHeaderId";
			}
		}

        public InventoryDocument()
            : base(BusinessObjectType.InventoryDocument)
        {
            this.Sheets = new InventorySheets(this);
            this.SheetsToSave = new List<InventorySheet>();

            this.CreationDate = SessionManager.VolatileElements.CurrentDateTime;
            this.CreationApplicationUserId = SessionManager.User.UserId;
        }

        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Type))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:type");

            if (this.CreationApplicationUserId == null)
                throw new ClientException(ClientExceptionId.ContractorIsMandatory);
        }

        public override void Validate()
        {
            base.Validate();

            if (this.Sheets != null)
                this.Sheets.Validate();
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Sheets != null)
                this.Sheets.SaveChanges(document);

            //if the document has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
                    this.Number.SaveChanges(document);
                }
            }
        }

        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.AlternateVersion != null && ((InventoryDocument)this.AlternateVersion).ClosureDate != null)
                throw new ClientException(ClientExceptionId.ClosedInventoryDocumentEdition);

            if (this.Sheets != null)
            {
                this.Sheets.UpdateStatus(isNew);

                if (this.Sheets.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.Status == BusinessObjectStatus.Modified)
            {
                this.ModificationApplicationUserId = SessionManager.User.UserId;
                this.ModificationDate = SessionManager.VolatileElements.CurrentDateTime;
            }
        }

        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            InventoryDocument alternateDocument = (InventoryDocument)alternate;

            if (this.Sheets != null)
                this.Sheets.SetAlternateVersion(alternateDocument.Sheets);
        }
    }
}
