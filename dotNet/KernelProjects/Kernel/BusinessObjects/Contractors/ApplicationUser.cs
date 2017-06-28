using System;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class representing a bank.
    /// </summary>
    [DatabaseMapping(TableName = "applicationUser")]
    internal class ApplicationUser : Contractor
    {
        [XmlSerializable(XmlField = "login")]
        [Comparable]
        [DatabaseMapping(TableName = "applicationUser", ColumnName = "login")]
        public string Login { get; set; }

        [XmlSerializable(XmlField = "isActive")]
        [Comparable]
        [DatabaseMapping(TableName = "applicationUser", ColumnName = "isActive")]
        public string isActive { get; set; }

        [XmlSerializable(XmlField = "password")]
        [Comparable]
        [DatabaseMapping(TableName = "applicationUser", ColumnName = "password")]
        public string Password { get; set; }

        [XmlSerializable(XmlField = "permissionProfile")]
        [Comparable]
        [DatabaseMapping(TableName = "applicationUser", ColumnName = "permissionProfile")]
        public string PermissionProfile { get; set; }

        [XmlSerializable(XmlField = "versionApplicationUser")]
        [DatabaseMapping(TableName = "applicationUser", ColumnName = "version")]
        public Guid? VersionApplicationUser { get; set; }

        [DatabaseMapping(TableName = "applicationUser", ColumnName = "contractorId")]
        public Guid ContractorId { get { return this.Id.Value; } }

		[XmlSerializable(XmlField = "databaseId")]
		[Comparable]
		[DatabaseMapping(TableName = "applicationUser", ColumnName = "restrictDatabaseId")]
		public Guid? RestrictDatabaseId { get; set; }

        public ApplicationUser(BusinessObject parent)
            : base(parent, BusinessObjectType.ApplicationUser)
        {
        }
    }
}
