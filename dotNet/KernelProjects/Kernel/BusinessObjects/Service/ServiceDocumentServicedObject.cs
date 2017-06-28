using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Service
{
    [XmlSerializable(XmlField = "serviceDocumentServicedObject")]
    [DatabaseMapping(TableName = "serviceHeaderServicedObjects")]
    internal class ServiceDocumentServicedObject : BusinessObject, IOrderable
    {
        [XmlSerializable(XmlField = "servicedObjectId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "servicedObjectId")]
        public Guid? ServicedObjectId { get; set; }

        [XmlSerializable(XmlField = "incomeDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "incomeDate")]
        public DateTime? IncomeDate { get; set; }

        [XmlSerializable(XmlField = "outcomeDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "outcomeDate")]
        public DateTime? OutcomeDate { get; set; }

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

        public int Order { get { return this.OrdinalNumber; } set { this.OrdinalNumber = value; } }

        [DatabaseMapping(ColumnName = "serviceHeaderId")]
        public Guid ServiceDocumentId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        public ServiceDocumentServicedObject(ServiceDocument parent)
            : base(parent)
        {
        }

        public override void ValidateConsistency()
        {
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
        }
    }
}
