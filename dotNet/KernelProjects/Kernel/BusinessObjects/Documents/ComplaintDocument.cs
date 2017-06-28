using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    [XmlSerializable(XmlField = "complaintDocument")]
    [DatabaseMapping(TableName = "complaintDocumentHeader",
		GetData = StoredProcedure.complaint_p_getComplaintDocumentData, GetDataParamName = "complaintDocumentHeaderId", List = StoredProcedure.complaint_p_getComplaintDocuments)]
    internal class ComplaintDocument : Document, IAllocationOwner
    {
        [XmlSerializable(XmlField = "contractor", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorId", OnlyId = true)]
        public Contractor Contractor { get; set; }

        [XmlSerializable(XmlField = "addressId", EncapsulatingXmlField = "contractor", ProcessLast = true)]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "contractorAddressId")]
        public Guid? ContractorAddressId { get; set; }

        [XmlSerializable(XmlField = "issuer", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "issuerContractorId", OnlyId = true)]
        public Contractor Issuer { get; set; }

        [XmlSerializable(XmlField = "addressId", EncapsulatingXmlField = "issuer", ProcessLast = true)]
        [Comparable]
        [DatabaseMapping(ColumnName = "issuerContractorAddressId")]
        public Guid IssuerAddressId { get; set; }

        [XmlSerializable(XmlField = "lines", ProcessLast = true)]
        public ComplaintDocumentLines Lines { get; private set; }

        public AllocationCollection AllocationCollection { get; set; }

		public override string ParentIdColumnName
		{
			get
			{
				return "complaintDocumentHeaderId";
			}
		}

        public ComplaintDocument()
            : base(BusinessObjectType.ComplaintDocument)
        {
            this.Lines = new ComplaintDocumentLines(this);

            Contractor issuer = (Contractor)DependencyContainerManager.Container.Get<ContractorMapper>().LoadBusinessObject(BusinessObjectType.Contractor, new Guid(ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "document.defaults.issuerId").First().Value.Value));
            this.Issuer = issuer;

            //znajdywanie adresu do faktury
            Guid billingId = DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Billing).Id.Value;
            Guid defaultId = DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Default).Id.Value;
            ContractorAddress billingAddress = issuer.Addresses.Children.Where(a => a.ContractorFieldId == billingId).FirstOrDefault();

            Guid? contractorAddressId = null;

            if (billingAddress != null)
                contractorAddressId = billingAddress.Id.Value;
            else
                contractorAddressId = issuer.Addresses.Children.Where(a => a.ContractorFieldId == defaultId).FirstOrDefault().Id.Value;

            this.IssuerAddressId = contractorAddressId.Value;
        }

        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            if (element.Element("allocations") != null)
                this.AllocationCollection = new AllocationCollection(element.Element("allocations"));
            else
                this.AllocationCollection = null;
        }

        public override void ValidateConsistency()
        {
            if (this.Contractor == null)
                throw new ClientException(ClientExceptionId.ContractorIsMandatory);
        }

        public override void Validate()
        {
            base.Validate();

            if (this.Lines != null)
                this.Lines.Validate();
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Lines != null)
                this.Lines.SaveChanges(document);

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

        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Lines != null)
            {
                this.Lines.UpdateStatus(isNew);

                if (this.Lines.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }
        }

        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            ComplaintDocument alternateDocument = (ComplaintDocument)alternate;

            if (this.Lines != null)
                this.Lines.SetAlternateVersion(alternateDocument.Lines);
        }
    }
}
