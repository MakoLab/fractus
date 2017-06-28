using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a mime type (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "mimeType")]
    [DatabaseMapping(TableName = "mimeType")]
    internal class MimeType : BusinessObject, IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets <see cref="MimeType"/>'s content name. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "name")]
        [Comparable]
        [DatabaseMapping(ColumnName = "name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets <see cref="MimeType"/>'s supported file extensions. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "extensions")]
        [Comparable]
        [DatabaseMapping(ColumnName = "extensions")]
        public string Extensions { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="MimeType"/> class with a specified xml root element.
        /// </summary>
        public MimeType()
            : base(null, BusinessObjectType.MimeType)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Name))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:name");

            if (String.IsNullOrEmpty(this.Extensions))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:extensions");
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
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }
    }
}
