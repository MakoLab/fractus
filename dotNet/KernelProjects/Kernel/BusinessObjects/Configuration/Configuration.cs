using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Configuration
{
    /// <summary>
    /// Class representing <see cref="Configuration"/> entry.
    /// </summary>
    [XmlSerializable(XmlField = "configuration")]
    [DatabaseMapping(TableName = "configuration")]
    internal class Configuration : BusinessObject, IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets the company id.
        /// </summary>
        [XmlSerializable(XmlField = "companyContractorId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "companyContractorId")]
        public Guid? CompanyId { get; set; }

        /// <summary>
        /// Gets or sets the point id.
        /// </summary>
        [XmlSerializable(XmlField = "applicationUserId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "applicationUserId")]
        public Guid? UserId { get; set; }

        [XmlSerializable(XmlField = "userProfileId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "userProfileId")]
        public Guid? UserProfileId { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Configuration"/>'s key. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "key")]
        [Comparable]
        [DatabaseMapping(ColumnName = "key")]
        public string Key { get; set; }

        /// <summary>
        /// Gets or sets configuration element value. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value", VariableColumnName = true)]
        public XElement Value { get; set; }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="Configuration"/> class with a specified xml root element.
        /// </summary>
        public Configuration()
            : base(null, BusinessObjectType.Configuration)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Key))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:key");

            if (this.Value == null || this.Value.Value.Length == 0 && !this.Value.HasElements && !this.Value.HasAttributes)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:value");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown
                || this.ForceSave)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, "auto");
            }
        }
    }
}
