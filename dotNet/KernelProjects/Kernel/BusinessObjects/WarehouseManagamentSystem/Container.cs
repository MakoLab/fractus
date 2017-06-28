using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    [XmlSerializable(XmlField = "container")]
	[DatabaseMapping(TableName = "container", Insert = StoredProcedure.warehouse_p_insertContainer, Update = StoredProcedure.warehouse_p_updateContainer)]
    internal class Container : BusinessObject, IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        [XmlSerializable(XmlField = "symbol")]
        [Comparable]
        [DatabaseMapping(ColumnName = "symbol")]
        public string Symbol { get; set; }

        [XmlSerializable(XmlField = "containerTypeId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "containerTypeId")]
        public Guid ContainerTypeId { get; set; }

        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

        [XmlSerializable(XmlField = "xmlMetadata")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlMetadata")]
        public XElement Metadata { get; set; }

        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        [XmlSerializable(XmlField = "isActive")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isActive")]
        public bool IsActive { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        public Container(BusinessObject parent)
            : base(parent, BusinessObjectType.Container)
        {
            this.Labels = new XElement("labels");
            this.Metadata = new XElement("metadata");
            this.IsActive = true;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Symbol))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:symbol");

            if (this.ContainerTypeId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:containerTypeId");

            if (this.Labels == null || !this.Labels.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlLabels");

            if (this.Metadata == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlMetadata");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            //if the contractor has been changed or some of his children have been changed
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
    }
}
