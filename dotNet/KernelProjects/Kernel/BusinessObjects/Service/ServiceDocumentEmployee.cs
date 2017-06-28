using System;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Service
{
    [XmlSerializable(XmlField = "serviceDocumentEmployee")]
    [DatabaseMapping(TableName = "serviceHeaderEmployees")]
    internal class ServiceDocumentEmployee : BusinessObject, IOrderable
    {
        [XmlSerializable(XmlField = "employeeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "employeeId")]
        public Guid EmployeeId { get; set; }

        [XmlSerializable(XmlField = "workTime")]
        [Comparable]
        [DatabaseMapping(ColumnName = "workTime")]
        public decimal? WorkTime { get; set; }

        [XmlSerializable(XmlField = "timeFraction")]
        [Comparable]
        [DatabaseMapping(ColumnName = "timeFraction")]
        public decimal? TimeFraction { get; set; }

        [XmlSerializable(XmlField = "plannedStartDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "plannedStartDate")]
        public DateTime? PlannedStartDate { get; set; }

        [XmlSerializable(XmlField = "plannedEndDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "plannedEndDate")]
        public DateTime? PlannedEndDate { get; set; }

        [XmlSerializable(XmlField = "description")]
        [Comparable]
        [DatabaseMapping(ColumnName = "description")]
        public string Description { get; set; }

        [XmlSerializable(XmlField = "ordinalNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ordinalNumber")]
        public int OrdinalNumber { get; set; }

        [DatabaseMapping(ColumnName = "serviceHeaderId")]
        public Guid ServiceDocumentId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        public int Order { get { return this.OrdinalNumber; } set { this.OrdinalNumber = value; } }

        public ServiceDocumentEmployee(ServiceDocument parent)
            : base(parent)
        {
        }

        public override void ValidateConsistency()
        {
            if (this.EmployeeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:employeeId");
        }

        public override void SaveChanges(System.Xml.Linq.XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
        }
    }
}
