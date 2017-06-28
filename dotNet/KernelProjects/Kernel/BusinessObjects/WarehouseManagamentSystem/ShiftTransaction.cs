using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    [XmlSerializable(XmlField = "shiftTransaction")]
	[DatabaseMapping(TableName = "shiftTransaction", Insert = StoredProcedure.warehouse_p_insertShiftTransaction, Update = StoredProcedure.warehouse_p_updateShiftTransaction)]
    internal class ShiftTransaction : BusinessObject, IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        [XmlSerializable(XmlField = "user", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "applicationUserId", OnlyId = true)]
        public Contractor User { get; set; }

        [XmlSerializable(XmlField = "issueDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "issueDate")]
        public DateTime IssueDate { get; set; }

        [XmlSerializable(XmlField = "number")]
        [Comparable]
        [DatabaseMapping(ColumnName = "number", LoadOnly = true)]
        public int Number { get; set; }

        [XmlSerializable(XmlField = "reasonId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "reasonId")]
        public Guid? ReasonId { get; set; }

        [XmlSerializable(XmlField = "shifts", ProcessLast = true)]
        public Shifts Shifts { get; private set; }

        [XmlSerializable(XmlField = "containerShifts", ProcessLast = true)]
        public ContainerShifts ContainerShifts { get; private set; }

        public ShiftTransaction(BusinessObject parent)
            : base(parent, BusinessObjectType.ShiftTransaction)
        {
            this.Shifts = new Shifts(this);
            this.ContainerShifts = new ContainerShifts(this);

            this.IssueDate = SessionManager.VolatileElements.CurrentDateTime;

            this.User = (Contractor)DependencyContainerManager.Container.Get<ContractorMapper>().LoadBusinessObject(BusinessObjectType.Contractor, SessionManager.User.UserId);
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.User == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:user");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

            if (this.Shifts != null)
                this.Shifts.Validate();
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            //save changes of child elements first
            if (this.Shifts != null)
                this.Shifts.SaveChanges(document);

            //if the document has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
                }
            }
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Shifts != null)
                this.Shifts.UpdateStatus(isNew);
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            ShiftTransaction alternateDocument = (ShiftTransaction)alternate;

            if (this.Shifts != null && alternateDocument != null)
                this.Shifts.SetAlternateVersion(alternateDocument.Shifts);
        }
    }
}
