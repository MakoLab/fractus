using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    [XmlSerializable(XmlField = "complaintDecision")]
    [DatabaseMapping(TableName = "complaintDecision")]
    internal class ComplaintDecision : BusinessObject, IOrderable
    {
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        [XmlSerializable(XmlField = "replacementItemId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "replacementItemId")]
        public Guid ReplacementItemId { get; set; }

        [XmlSerializable(XmlField = "replacementItemName")]
        [Comparable]
        [DatabaseMapping(ColumnName = "replacementItemName")]
        public string ReplacementItemName { get; set; }

        [XmlSerializable(XmlField = "replacementUnitId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "replacementUnitId")]
        public Guid ReplacementUnitId { get; set; }

        [XmlSerializable(XmlField = "quantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "quantity")]
        public decimal Quantity { get; set; }

        [XmlSerializable(XmlField = "warehouseId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseId")]
        public Guid? WarehouseId { get; set; }

        [XmlSerializable(XmlField = "decisionText")]
        [Comparable]
        [DatabaseMapping(ColumnName = "decisionText")]
        public string DecistionText { get; set; }

        [XmlSerializable(XmlField = "issueDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "issueDate")]
        public DateTime IssueDate { get; set; }

        [XmlSerializable(XmlField = "issuingPersonContractorId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "issuingPersonContractorId")]
        public Guid IssuingPersonContractorId { get; set; }

        [XmlSerializable(XmlField = "realizeOption")]
        [Comparable]
        [DatabaseMapping(ColumnName = "realizeOption")]
        public RealizationStage RealizeOption { get; set; }

        [XmlSerializable(XmlField = "decisionType")]
        [Comparable]
        [DatabaseMapping(ColumnName = "decisionType")]
        public DecisionType DecisionType { get; set; }

        [DatabaseMapping(ColumnName = "complaintDocumentLineId")]
        public Guid ComplaintDocumentLineId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        public ComplaintDecision(ComplaintDocumentLine parent)
            : base(parent)
        {
        }

        public override void ValidateConsistency()
        {
            if (this.ReplacementItemId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:replacementItemId");

            if (this.ReplacementUnitId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:replacementUnitId");

            if (String.IsNullOrEmpty(this.ReplacementItemName))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:replacementItemName");
        }

        public bool IsMarkedForRealization()
        {
            if (this.WarehouseId == null)
                return false;
            else if (this.IsNew && this.RealizeOption == RealizationStage.Realize)
                return true;
            else if (!this.IsNew && ((ComplaintDecision)this.AlternateVersion).RealizeOption == RealizationStage.DontRealize &&
                this.RealizeOption == RealizationStage.Realize)
                return true;
            else
                return false;
        }

        public override void Validate()
        {
            base.Validate();

            if (this.Quantity <= 0)
                throw new ClientException(ClientExceptionId.QuantityBelowOrEqualZero, null, "itemName:" + this.ReplacementItemName);

            if (this.IssuingPersonContractorId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:issuingPersonContractorId");

            ComplaintDecision alternateLine = this.AlternateVersion as ComplaintDecision;

            if (alternateLine != null)
            {
                if ((this.RealizeOption == RealizationStage.DontRealize || this.RealizeOption == RealizationStage.Realize) &&
                    alternateLine.RealizeOption == RealizationStage.Realized &&
                    (this.DecisionType == DecisionType.Disposal || this.DecisionType == DecisionType.ReturnToSupplier))
                    throw new InvalidOperationException("Cannot unrealize ComplaintDecision");

                if (this.Quantity != alternateLine.Quantity && alternateLine.RealizeOption == RealizationStage.Realized)
                    throw new ClientException(ClientExceptionId.RealizedComplaintDecisionQuantityEdition);

                if (alternateLine.RealizeOption == RealizationStage.Realized && this.DecisionType != alternateLine.DecisionType)
                    throw new ClientException(ClientExceptionId.ComplaintDecisionTypeChangeError);
            }

            if (this.Status == BusinessObjectStatus.Deleted && this.RealizeOption == RealizationStage.Realized &&
                (this.DecisionType == DecisionType.Disposal || this.DecisionType == DecisionType.ReturnToSupplier))
                throw new ClientException(ClientExceptionId.RealizedComplaintDecisionRemoval);
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
