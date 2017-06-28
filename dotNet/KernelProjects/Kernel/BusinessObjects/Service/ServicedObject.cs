using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Service
{
    [XmlSerializable(XmlField = "servicedObject")]
    [DatabaseMapping(TableName = "servicedObject")]
    internal class ServicedObject : BusinessObject, IVersionedBusinessObject
    {
        public bool ForceSave { get; set; }

        public Guid? NewVersion { get; set; }

        [XmlSerializable(XmlField = "identifier")]
        [Comparable]
        [DatabaseMapping(ColumnName = "identifier")]
        public string Identifier { get; set; }

        [XmlSerializable(XmlField = "remarks")]
        [Comparable]
        [DatabaseMapping(ColumnName = "remarks")]
        public string Remarks { get; set; }

        [XmlSerializable(XmlField = "description")]
        [Comparable]
        [DatabaseMapping(ColumnName = "description")]
        public string Description { get; set; }

        [XmlSerializable(XmlField = "servicedObjectTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "servicedObjectTypeId")]
        public Guid? ServicedObjectTypeId { get; set; }

        [XmlSerializable(XmlField = "ownerContractorId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ownerContractorId")]
        public Guid? OwnerContractorId { get; set; }

        [XmlSerializable(XmlField = "creationDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "creationDate")]
        public DateTime? CreationDate { get; set; }

        [XmlSerializable(XmlField = "modificationDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "modificationDate")]
        public DateTime? ModificationDate { get; set; }

        public ServicedObject()
            : base(null, BusinessObjectType.ServicedObject)
        {
        }

        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Identifier))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:identifier");
        }

        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Status == BusinessObjectStatus.Modified)
                this.ModificationDate = SessionManager.VolatileElements.CurrentDateTime;
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    if (this.Status == BusinessObjectStatus.New)
                        this.CreationDate = SessionManager.VolatileElements.CurrentDateTime;
                    else if (this.Status == BusinessObjectStatus.Modified)
                        this.ModificationDate = SessionManager.VolatileElements.CurrentDateTime;

                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
                }
            }
        }
    }
}
