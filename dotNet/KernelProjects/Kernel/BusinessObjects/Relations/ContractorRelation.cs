using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing <see cref="Contractor"/>'s relation.
    /// </summary>
    [XmlSerializable(XmlField = "relation")]
    [DatabaseMapping(TableName = "contractorRelation")]
    public class ContractorRelation : BusinessObject, IBusinessObjectRelation, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets the relation's description id.
        /// </summary>
        [XmlSerializable(XmlField = "contractorRelationTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorRelationTypeId")]
        public Guid ContractorRelationTypeId { get; set; }

        /// <summary>
        /// Relation's name
        /// </summary>
        private ContractorRelationTypeName contractorRelationTypeName;

        /// <summary>
        /// Gets or sets the relation's type
        /// </summary>
        public ContractorRelationTypeName ContractorRelationTypeName
        {
            get { return this.contractorRelationTypeName; }
            set
            {
                if (value != ContractorRelationTypeName.Unknown)
                {
                    this.ContractorRelationTypeId = DictionaryMapper.Instance.GetContractorRelationType(value).Id.Value;
                }

                this.contractorRelationTypeName = value;
            }
        }

        /// <summary>
        /// Gets or sets related <see cref="Contractor"/>.
        /// </summary>
        [XmlSerializable(XmlField = "relatedContractor", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "relatedContractorId", OnlyId = true)]
        public Contractor RelatedContractor { get; set; }

        /// <summary>
        /// Gets or sets related <see cref="BusinessObject"/>.
        /// </summary>
        public IBusinessObject RelatedObject
        {
            get { return this.RelatedContractor; }
            set { this.RelatedContractor = (Contractor)value; }
        }

        /// <summary>
        /// Gets or sets <see cref="ContractorRelation"/>'s attributes.
        /// </summary>
        [XmlSerializable(XmlField = "xmlAttributes")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlAttributes")]
        public XElement Attributes { get; set; }

        [DatabaseMapping(ColumnName = "contractorId")]
        public Guid ContractorId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the main <see cref="BusinessObject"/>.
        /// </summary>
        public bool UpgradeMainObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the related <see cref="BusinessObject"/>.
        /// </summary>
        public bool UpgradeRelatedObjectVersion { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorRelation"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Contractor"/>.</param>
        public ContractorRelation(Contractor parent)
            : base(parent, BusinessObjectType.ContractorRelation)
        {
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and attaches them to proper xml elements.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            //update the relation type name
            this.contractorRelationTypeName = DictionaryMapper.Instance.GetContractorRelationType(this.ContractorRelationTypeId).TypeName;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ContractorRelationTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:contractorRelationTypeId");

            if (this.RelatedObject == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:relatedContractor");
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            if (this.AlternateVersion != null)
                this.RelatedObject.SetAlternateVersion(((ContractorRelation)this.AlternateVersion).RelatedObject);
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/>.
        /// </summary>
        /// <param name="isNew">Value indicating whether the <see cref="BusinessObject"/> should be considered as the new one or the old one.</param>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            //this 'if' should protect from situation where panel adds an existing contractor as a related
            if (isNew && !this.RelatedObject.IsNew)
                this.RelatedObject.Status = BusinessObjectStatus.Unchanged;
            else
                this.RelatedObject.UpdateStatus(isNew);
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            //save related contractor only if the relations is not marked as deleted
            if(this.Status != BusinessObjectStatus.Deleted)
                this.RelatedObject.SaveChanges(document);
            
            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                BusinessObjectHelper.SaveRelationChanges(this, document);
            }
        }
    }
}
