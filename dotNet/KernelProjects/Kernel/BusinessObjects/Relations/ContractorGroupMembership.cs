using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing <see cref="Contractor"/>'s group membership.
    /// </summary>
    [XmlSerializable(XmlField = "groupMembership")]
    [DatabaseMapping(TableName = "contractorGroupMembership")]
    public class ContractorGroupMembership : BusinessObject, IBusinessObjectDictionaryRelation
    {
        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the main <see cref="BusinessObject"/>.
        /// </summary>
        /// <value></value>
        public bool UpgradeMainObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets related dictionary object's id.
        /// </summary>
        /// <value></value>
        public Guid RelatedDictionaryObjectId
        {
            get { return this.ContractorGroupId; }
            set { this.ContractorGroupId = value; }
        }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        /// <value></value>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        /// <value></value>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets contractor's group Id.
        /// </summary>
        [XmlSerializable(XmlField = "contractorGroupId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorGroupId")]
        public Guid ContractorGroupId { get; set; }

        [DatabaseMapping(ColumnName = "contractorId")]
        public Guid ContractorId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorGroupMembership"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Contractor"/>.</param>
        public ContractorGroupMembership(Contractor parent)
            : base(parent, BusinessObjectType.ContractorGroupMembership)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ContractorGroupId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:contractorGroupId");
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
                BusinessObjectHelper.SaveDictionaryRelationChanges(this, document);
            }
        }
    }
}
