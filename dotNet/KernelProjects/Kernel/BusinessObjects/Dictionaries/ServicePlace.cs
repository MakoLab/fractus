using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    [XmlSerializable(XmlField = "servicePlace")]
    [DatabaseMapping(TableName = "servicePlace")]
    internal class ServicePlace : BusinessObject, IOrderable, IVersionedBusinessObject
    {
        public bool ForceSave { get; set; }

        public Guid? NewVersion { get; set; }

        [XmlSerializable(XmlField = "name")]
        [Comparable]
        [DatabaseMapping(ColumnName = "name")]
        public string Name { get; set; }

        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        public ServicePlace()
            : base(null, BusinessObjectType.ServicePlace)
        {
        }

        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Name))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:name");
        }

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
