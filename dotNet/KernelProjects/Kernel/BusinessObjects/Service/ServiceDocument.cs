using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Service
{
    [XmlSerializable(XmlField = "serviceDocument")]
    [DatabaseMapping(TableName = "serviceHeader",
		GetData = StoredProcedure.service_p_getServiceData, GetDataParamName = "serviceHeaderId", List = StoredProcedure.document_p_getCommercialDocuments)]
    internal class ServiceDocument : CommercialDocumentBase
    {
        [XmlSerializable(XmlField = "plannedEndDate")]
        [Comparable]
        [DatabaseMapping(TableName = "serviceHeader", ColumnName = "plannedEndDate")]
        public DateTime PlannedEndDate { get; set; }

        [XmlSerializable(XmlField = "closureDate")]
        [Comparable]
        [DatabaseMapping(TableName = "serviceHeader", ColumnName = "closureDate")]
        public DateTime? ClosureDate { get; set; }

        [XmlSerializable(XmlField = "description")]
        [Comparable]
        [DatabaseMapping(TableName = "serviceHeader", ColumnName = "description")]
        public string Description { get; set; }

        [XmlSerializable(XmlField = "versionService")]
        [DatabaseMapping(TableName = "serviceHeader", ColumnName = "version")]
        public Guid? VersionService { get; set; }

        [XmlSerializable(XmlField = "serviceDocumentEmployees", ProcessLast = true)]
        public ServiceDocumentEmployees ServiceDocumentEmployees { get; set; }

        [XmlSerializable(XmlField = "serviceDocumentServicePlaces", ProcessLast = true)]
        public ServiceDocumentServicePlaces ServiceDocumentServicePlaces { get; set; }

        [XmlSerializable(XmlField = "serviceDocumentServicedObjects", ProcessLast = true)]
        public ServiceDocumentServicedObjects ServiceDocumentServicedObjects { get; set; }

        [DatabaseMapping(TableName = "serviceHeader", ColumnName = "commercialDocumentHeaderId")]
        public Guid CommercialDocumentHeaderId { get { return this.Id.Value; } } //for save object reflection purposes

        public ServiceDocument()
            : base(BusinessObjectType.ServiceDocument)
        {
            this.ServiceDocumentEmployees = new ServiceDocumentEmployees(this);
            this.ServiceDocumentServicePlaces = new ServiceDocumentServicePlaces(this);
            this.ServiceDocumentServicedObjects = new ServiceDocumentServicedObjects(this);

            DateTime currentDateTime = SessionManager.VolatileElements.CurrentDateTime;
            this.PlannedEndDate = currentDateTime;
        }

        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            var attr = this.Attributes[DocumentFieldName.Attribute_ProcessState];

            if (attr != null && attr.Value.Value == "closed")
            {
                if (ProcessManager.Instance.IsServiceReservationEnabled(this))
                    this.DisableLinesChange = DisableDocumentChangeReason.LINES_CLOSED_SERVICE_DOCUMENT;
            }
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            //save changes of child elements first
            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Lines != null)
                this.Lines.SaveChanges(document);

            if (this.VatTableEntries != null)
                this.VatTableEntries.SaveChanges(document);

            if (this.ServiceDocumentEmployees != null)
                this.ServiceDocumentEmployees.SaveChanges(document);

            if (this.ServiceDocumentServicePlaces != null)
                this.ServiceDocumentServicePlaces.SaveChanges(document);

            if (this.ServiceDocumentServicedObjects != null)
                this.ServiceDocumentServicedObjects.SaveChanges(document);

            //if the document has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);

                    this.Number.SaveChanges(document);
                }
            }
        }

        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            ServiceDocument alternateOrder = (ServiceDocument)alternate;

            if (this.Lines != null)
                this.Lines.SetAlternateVersion(alternateOrder.Lines);

            if (this.VatTableEntries != null)
                this.VatTableEntries.SetAlternateVersion(alternateOrder.VatTableEntries);

            if (this.ServiceDocumentEmployees != null)
                this.ServiceDocumentEmployees.SetAlternateVersion(alternateOrder.ServiceDocumentEmployees);

            if (this.ServiceDocumentServicePlaces != null)
                this.ServiceDocumentServicePlaces.SetAlternateVersion(alternateOrder.ServiceDocumentServicePlaces);

            if (this.ServiceDocumentServicedObjects != null)
                this.ServiceDocumentServicedObjects.SetAlternateVersion(alternateOrder.ServiceDocumentServicedObjects);
        }

        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Lines != null)
                this.Lines.UpdateStatus(isNew);

            if (this.VatTableEntries != null)
                this.VatTableEntries.UpdateStatus(isNew);

            if (this.ServiceDocumentEmployees != null)
                this.ServiceDocumentEmployees.UpdateStatus(isNew);

            if (this.ServiceDocumentServicePlaces != null)
                this.ServiceDocumentServicePlaces.UpdateStatus(isNew);

            if (this.ServiceDocumentServicedObjects != null)
                this.ServiceDocumentServicedObjects.UpdateStatus(isNew);
        }

        public override void Validate()
        {
            base.Validate();

            foreach (CommercialDocumentLine line in this.Lines.Children)
            {
                if (line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption] == null || line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption].Value.Value == String.Empty)
                    throw new ClientException(ClientExceptionId.MissingLineAttribute, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

                CommercialDocumentLine alternativeLine = line.AlternateVersion as CommercialDocumentLine;

                if (alternativeLine != null && alternativeLine.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption].Value.Value !=
                    line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption].Value.Value &&
                    alternativeLine.Attributes[DocumentFieldName.LineAttribute_ServiceRealized] != null)
                    throw new ClientException(ClientExceptionId.GenerateDocumentOptionAttriuteChangeError, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

                var realizedAttr = line.Attributes[DocumentFieldName.LineAttribute_ServiceRealized];

                if (realizedAttr != null)
                {
                    decimal realized = Convert.ToDecimal(realizedAttr.Value.Value, CultureInfo.InvariantCulture);

                    if (line.Quantity < realized)
                        throw new ClientException(ClientExceptionId.QuantityBelowServiceRealized, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));
                }
            }

            CommercialDocument alternateDocument = this.AlternateVersion as CommercialDocument;

            if (alternateDocument != null)
            {
                var deletedRealized = alternateDocument.Lines.Children.Where(l => l.Status == BusinessObjectStatus.Deleted && l.Attributes[DocumentFieldName.LineAttribute_ServiceRealized] != null).FirstOrDefault();

                if (deletedRealized != null)
                    throw new ClientException(ClientExceptionId.ServiceRealizedLineRemoval);
            }

            if (this.Lines != null)
                this.Lines.Validate();

            if (this.VatTableEntries != null)
                this.VatTableEntries.Validate();

            if (this.ServiceDocumentEmployees != null)
                this.ServiceDocumentEmployees.Validate();

            if (this.ServiceDocumentServicePlaces != null)
                this.ServiceDocumentServicePlaces.Validate();

            if (this.ServiceDocumentServicedObjects != null)
                this.ServiceDocumentServicedObjects.Validate();
        }
    }
}
