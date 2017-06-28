using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Repository
{
    /// <summary>
    /// Class representing file descriptor.
    /// </summary>
    [XmlSerializable(XmlField = "fileDescriptor")]
    [DatabaseMapping(TableName = "fileDescriptor")]
    internal class FileDescriptor : BusinessObject, IVersionedBusinessObject
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
        /// Gets or sets <see cref="Repository"/> Id.
        /// </summary>
        [XmlSerializable(XmlField = "repositoryId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "repositoryId")]
        public Guid RepositoryId { get; set; }

        /// <summary>
        /// Gets or sets <see cref="MimeType"/> Id.
        /// </summary>
        [XmlSerializable(XmlField = "mimeTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "mimeTypeId")]
        public Guid MimeTypeId { get; set; }

        /// <summary>
        /// Gets or sets modification date.
        /// </summary>
        [XmlSerializable(XmlField = "modificationDate")]
        [DatabaseMapping(ColumnName = "modificationDate")]
        public DateTime ModificationDate { get; set; }

        /// <summary>
        /// Gets or sets <see cref="User"/> Id that modified or created the object.
        /// </summary>
        [XmlSerializable(XmlField = "modificationApplicationUserId")]
        [DatabaseMapping(ColumnName = "modificationApplicationUserId")]
        public Guid ModificationUserId { get; set; }

        /// <summary>
        /// Gets or sets <see cref="FileDescriptor"/>'s original filename. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "originalFilename")]
        [Comparable]
        [DatabaseMapping(ColumnName = "originalFilename")]
        public string OriginalFilename { get; set; }

        /// <summary>
        /// Gets or sets <see cref="FileDescriptor"/>'s tag.
        /// </summary>
        [XmlSerializable(XmlField = "tag")]
        [Comparable]
        [DatabaseMapping(ColumnName = "tag")]
        public string Tag { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="FileDescriptor"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        public FileDescriptor(BusinessObject parent)
            : base(parent, BusinessObjectType.FileDescriptor)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.RepositoryId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:repositoryId");

            if (this.MimeTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:mimeTypeId");

            if (String.IsNullOrEmpty(this.OriginalFilename))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:originalFilename");
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
