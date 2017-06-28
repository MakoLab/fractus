using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    [XmlSerializable(XmlField = "containerShift")]
	[DatabaseMapping(TableName = "containerShift", Insert = StoredProcedure.warehouse_p_insertContainerShift, Update = StoredProcedure.warehouse_p_updateContainerShift)]
    internal class ContainerShift : BusinessObject, IOrderable
    {
        public int Order { get { return this.OrdinalNumber; } set { this.OrdinalNumber = value; } }

        [XmlSerializable(XmlField = "ordinalNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ordinalNumber")]
        public int OrdinalNumber { get; set; }

        [XmlSerializable(XmlField = "containerId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "containerId")]
        public Guid ContainerId { get; set; }

        [XmlSerializable(XmlField = "parentContainerId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "parentContainerId")]
        public Guid ParentContainerId { get; set; }

        [XmlSerializable(XmlField = "slotContainerId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "slotContainerId")]
        public Guid? SlotContainerId { get; set; }

        [XmlSerializable(XmlField = "shiftTransactionId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "shiftTransactionId")]
        public Guid ShiftTransactionId { get; set; }

        public ContainerShift(ShiftTransaction parent)
            : base(parent)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ContainerId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:containerId");

            if (this.ParentContainerId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:parentContainerId");

            if (this.ShiftTransactionId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:shiftTransactionId");
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
