using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a relation between document type and a document field (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "documentFieldRelation")]
    [DatabaseMapping(TableName = "documentFieldRelation")]
    internal class DocumentFieldRelation : BusinessObject, IVersionedBusinessObject
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
        /// Gets or sets the <see cref="DocumentField"/> id.
        /// </summary>
        [XmlSerializable(XmlField = "documentFieldId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "documentFieldId")]
        public Guid DocumentFieldId { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="DocumentType"/> id.
        /// </summary>
        [XmlSerializable(XmlField = "documentTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "documentTypeId")]
        public Guid DocumentTypeId { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentFieldRelation"/> class with a specified xml root element.
        /// </summary>
        public DocumentFieldRelation()
            : base(null, BusinessObjectType.DocumentFieldRelation)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.DocumentFieldId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:documentTypeId");

            if (this.DocumentTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:documentFieldId");
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
