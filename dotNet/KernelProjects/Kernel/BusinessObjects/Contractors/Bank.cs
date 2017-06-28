using System;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class representing a bank.
    /// </summary>
    [DatabaseMapping(TableName = "bank")]
    internal class Bank : Contractor
    {
        /// <summary>
        /// <see cref="Bank"/>'s bank number.
        /// </summary>
        [XmlSerializable(XmlField = "bankNumber")]
        [Comparable]
        [DatabaseMapping(TableName = "bank", ColumnName = "bankNumber")]
        public string BankNumber { get; set; }

        /// <summary>
        /// <see cref="Bank"/>'s SWIFT number.
        /// </summary>
        [XmlSerializable(XmlField = "swiftNumber")]
        [Comparable]
        [DatabaseMapping(TableName = "bank", ColumnName = "swiftNumber")]
        public string SwiftNumber { get; set; }

        [XmlSerializable(XmlField = "versionBank")]
        [DatabaseMapping(TableName = "bank", ColumnName = "version")]
        public Guid? VersionBank { get; set; }

        [DatabaseMapping(TableName = "bank", ColumnName = "contractorId")]
        public Guid BankId { get { return this.Id.Value; } }

        /// <summary>
        /// Initializes a new instance of the <see cref="Bank"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        public Bank(BusinessObject parent)
            : base(parent, BusinessObjectType.Bank)
        {
            this.IsBank = true;
            this.IsBusinessEntity = true;
        }
    }
}
