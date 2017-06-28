using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class representing <see cref="Contractor"/>'s bank account.
    /// </summary>
    [XmlSerializable(XmlField = "account")]
    [DatabaseMapping(TableName = "contractorAccount")]
    public class ContractorAccount : BusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Contractor"/>'s account number. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "accountNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "accountNumber")]
        public string AccountNumber { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Bank"/> Id.
        /// </summary>
        [XmlSerializable(XmlField = "bankContractorId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "bankContractorId")]
        public Guid? BankId { get; set; }

        [DatabaseMapping(ColumnName = "contractorId")]
        public Guid ContractorId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorAccount"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Contractor"/>.</param>
        public ContractorAccount(Contractor parent)
            : base(parent)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.AccountNumber))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:accountNumber");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
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
