using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Finances
{
    [XmlSerializable(XmlField = "financialReport")]
    [DatabaseMapping(TableName = "financialReport",
		GetData = StoredProcedure.finance_p_getFinancialReportData, GetDataParamName = "financialReportId", List = StoredProcedure.finance_p_getFinancialReports)]
    internal class FinancialReport : SimpleDocument
    {
        [XmlSerializable(XmlField = "financialRegisterId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "financialRegisterId")]
        public Guid FinancialRegisterId { get; set; }

        [XmlSerializable(XmlField = "creatingUser", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "creatingApplicationUserId", OnlyId = true)]
        public Contractor CreatingUser { get; set; }

        [XmlSerializable(XmlField = "creationDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "creationDate")]
        public DateTime CreationDate { get; set; }

        [XmlSerializable(XmlField = "closingUser", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "closingApplicationUserId", OnlyId = true)]
        public Contractor ClosingUser { get; set; }

        [XmlSerializable(XmlField = "closureDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "closureDate")]
        public DateTime? ClosureDate { get; set; }

        [XmlSerializable(XmlField = "openingUser", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "openingApplicationUserId", OnlyId = true)]
        public Contractor OpeningUser { get; set; }

        [XmlSerializable(XmlField = "openingDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "openingDate")]
        public DateTime? OpeningDate { get; set; }

        [XmlSerializable(XmlField = "initialBalance")]
        [Comparable]
        [DatabaseMapping(ColumnName = "initialBalance")]
        public decimal InitialBalance { get; set; }

        [XmlSerializable(XmlField = "incomeAmount")]
        [Comparable]
        [DatabaseMapping(ColumnName = "incomeAmount")]
        public decimal? IncomeAmount { get; set; }

        [XmlSerializable(XmlField = "outcomeAmount")]
        [Comparable]
        [DatabaseMapping(ColumnName = "outcomeAmount")]
        public decimal? OutcomeAmount { get; set; }

        [XmlSerializable(XmlField = "isClosed")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isClosed")]
        public bool IsClosed { get; set; }

        [XmlSerializable(XmlField = "isFirstReport", UseAttribute = true)]
        public bool IsFirstReport { get; set; }

        public override string Symbol { get { return DictionaryMapper.Instance.GetFinancialRegister(this.FinancialRegisterId).Symbol; } }
        public override DateTime IssueDate { get { return this.CreationDate; } set { this.CreationDate = value; } }

        public bool SkipFurtherReportRecalculation { get; set; }

        public FinancialReport()
            : base(BusinessObjectType.FinancialReport)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.FinancialRegisterId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:financialRegisterId");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

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
    }
}
