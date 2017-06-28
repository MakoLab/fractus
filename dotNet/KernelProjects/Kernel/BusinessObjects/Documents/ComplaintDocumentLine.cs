using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    [XmlSerializable(XmlField = "line")]
    [DatabaseMapping(TableName = "complaintDocumentLine")]
    internal class ComplaintDocumentLine : BusinessObject, IOrderable
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

        [XmlSerializable(XmlField = "unitId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "unitId")]
        public Guid UnitId { get; set; }

        [XmlSerializable(XmlField = "itemName")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemName")]
        public string ItemName { get; set; }

        [XmlSerializable(XmlField = "quantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "quantity")]
        public decimal Quantity { get; set; }

        [XmlSerializable(XmlField = "remarks")]
        [Comparable]
        [DatabaseMapping(ColumnName = "remarks")]
        public string Remarks { get; set; }

        [XmlSerializable(XmlField = "issueDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "issueDate")]
        public DateTime IssueDate { get; set; }

        [XmlSerializable(XmlField = "issuingPersonContractorId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "issuingPersonContractorId")]
        public Guid IssuingPersonContractorId { get; set; }

        [DatabaseMapping(ColumnName = "complaintDocumentHeaderId")]
        public Guid ComplaintDocumentHeaderId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        [XmlSerializable(XmlField = "complaintDecisions", ProcessLast = true)]
        public ComplaintDecisions ComplaintDecisions { get; private set; }

        public ComplaintDocumentLine(ComplaintDocument parent)
            : base(parent, BusinessObjectType.ComplaintDocumentLine)
        {
            this.ComplaintDecisions = new ComplaintDecisions(this);
        }

        public override void ValidateConsistency()
        {
            if (this.ItemId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemId");

            if (this.UnitId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:unitId");

            if (String.IsNullOrEmpty(this.ItemName))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemName");

            if (this.IssuingPersonContractorId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:issuingPersonContractorId");
        }

        public override void Validate()
        {
            base.Validate();

            if (this.Quantity <= 0)
                throw new ClientException(ClientExceptionId.QuantityBelowOrEqualZero, null, "itemName:" + this.ItemName);

            if (this.ComplaintDecisions != null)
                this.ComplaintDecisions.Validate();

            decimal quantityOnDecisions = this.ComplaintDecisions.Children.Sum(d => d.Quantity);

            if (quantityOnDecisions > this.Quantity)
                throw new ClientException(ClientExceptionId.ComplaintDecisionQuantityError);
        }

        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            if (this.ComplaintDecisions != null)
                this.ComplaintDecisions.SetAlternateVersion(((ComplaintDocumentLine)alternate).ComplaintDecisions);
        }

        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.ComplaintDecisions != null)
                this.ComplaintDecisions.UpdateStatus(isNew);
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.ComplaintDecisions != null)
                this.ComplaintDecisions.SaveChanges(document);

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }
    }
}
