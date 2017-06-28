using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
	[DatabaseMapping(TableName = "commercialDocumentHeader",
		GetData = StoredProcedure.document_p_getCommercialDocumentData, GetDataParamName = "commercialDocumentHeaderId", List = StoredProcedure.document_p_getCommercialDocuments)]
    internal abstract class CommercialDocumentBase : Document, ICurrencyDocument
    {
        /// <summary>
        /// Gets or sets the document contractor.
        /// </summary>
        [XmlSerializable(XmlField = "contractor", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "contractorId", OnlyId = true)]
        public Contractor Contractor { get; set; }

        /// <summary>
        /// Gets or sets selected contractor's <see cref="ContractorAddress"/> id.
        /// </summary>
        [XmlSerializable(XmlField = "addressId", EncapsulatingXmlField = "contractor", ProcessLast = true)]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "contractorAddressId")]
        public Guid? ContractorAddressId { get; set; }

        /// <summary>
        /// Gets or sets the receiving person.
        /// </summary>
        [XmlSerializable(XmlField = "receivingPerson", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "receivingPersonContractorId", OnlyId = true)]
        public Contractor ReceivingPerson { get; set; }

        /// <summary>
        /// Gets or sets the issuing person.
        /// </summary>
        [XmlSerializable(XmlField = "issuer", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "issuerContractorId", OnlyId = true)]
        public Contractor Issuer { get; set; }

        /// <summary>
        /// Gets or sets selected issuing person's <see cref="ContractorAddress"/> id.
        /// </summary>
        [XmlSerializable(XmlField = "addressId", EncapsulatingXmlField = "issuer", ProcessLast = true)]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "issuerContractorAddressId")]
        public Guid IssuerAddressId { get; set; }

        /// <summary>
        /// Gets or sets the issuing person.
        /// </summary>
        [XmlSerializable(XmlField = "issuingPerson", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "issuingPersonContractorId", OnlyId = true)]
        public Contractor IssuingPerson { get; set; }

        /// <summary>
        /// Gets or sets exchange date.
        /// </summary>
        [XmlSerializable(XmlField = "exchangeDate")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "exchangeDate")]
        public DateTime ExchangeDate { get; set; }

        /// <summary>
        /// Gets or sets exchange scale.
        /// </summary>
        [XmlSerializable(XmlField = "exchangeScale")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "exchangeScale")]
        public int ExchangeScale { get; set; }

        /// <summary>
        /// Gets or sets exchange rate.
        /// </summary>
        [XmlSerializable(XmlField = "exchangeRate")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "exchangeRate")]
        public decimal ExchangeRate { get; set; }

        /// <summary>
        /// Gets or sets <see cref="IssuePlace"/>'s id.
        /// </summary>
        [XmlSerializable(XmlField = "issuePlaceId")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "issuePlaceId")]
        public Guid IssuePlaceId { get; set; }

        /// <summary>
        /// Gets or sets event date.
        /// </summary>
        [XmlSerializable(XmlField = "eventDate")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "eventDate")]
        public DateTime EventDate { get; set; }

        /// <summary>
        /// Gets or sets document's net value.
        /// </summary>
        [XmlSerializable(XmlField = "netValue")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "netValue")]
        public decimal NetValue { get; set; }

        /// <summary>
        /// Gets or sets document's gross value.
        /// </summary>
        [XmlSerializable(XmlField = "grossValue")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "grossValue")]
        public decimal GrossValue { get; set; }

        /// <summary>
        /// Gets or sets document's vat value.
        /// </summary>
        [XmlSerializable(XmlField = "vatValue")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "vatValue")]
        public decimal VatValue { get; set; }

        /// <summary>
        /// Gets or sets print date.
        /// </summary>
        [XmlSerializable(XmlField = "printDate")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "printDate")]
        public DateTime? PrintDate { get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the <see cref="CommercialDocument"/> has been exported for accounting.
        /// </summary>
        [XmlSerializable(XmlField = "isExportedForAccounting")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "isExportedForAccounting")]
        public bool IsExportedForAccounting { get; set; }

		[XmlSerializable(XmlField = "selected", UseAttribute = true, EncapsulatingXmlField = "netCalculationType")]
		public bool CalculationTypeSelected { get; set; }
		
		/// <summary>
        /// Gets or sets the document's calculation type.
        /// </summary>
        [XmlSerializable(XmlField = "netCalculationType")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "netCalculationType")]
        public CalculationType CalculationType { get; set; }

        /// <summary>
        /// Gets or sets the document's summation type.
        /// </summary>
        [XmlSerializable(XmlField = "vatRatesSummationType")]
        [Comparable]
        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "vatRatesSummationType")]
        public SummationType SummationType { get; set; }

        [XmlSerializable(XmlField = "lines", ProcessLast = true)]
        public CommercialDocumentLines Lines { get; private set; }

        [XmlSerializable(XmlField = "vatTable", ProcessLast = true)]
        public CommercialDocumentVatTableEntries VatTableEntries { get; private set; }

        [DatabaseMapping(TableName = "commercialDocumentHeader", ColumnName = "xmlConstantData")]
        public XElement XmlConstantData { get { return this.GetConstantData(); } }

		public override string ParentIdColumnName
		{
			get
			{
				return "commercialDocumentHeaderId";
			}
		}

        private ShiftTransaction _shiftTransaction;
        public ShiftTransaction ShiftTransaction
        {
            get { return this._shiftTransaction; }
            set
            {
                this._shiftTransaction = value;

                if (value != null)
                {
                    foreach (Shift shift in this._shiftTransaction.Shifts.Children)
                    {
                        shift.RelatedCommercialDocumentLine = this.Lines[shift.LineOrdinalNumber.Value - 1];
                    }
                }
            }
        }

        public CommercialDocumentBase(BusinessObjectType boType)
            : base(boType)
        {
            this.Lines = new CommercialDocumentLines(this);
            this.VatTableEntries = new CommercialDocumentVatTableEntries(this);

            DateTime currentDateTime = SessionManager.VolatileElements.CurrentDateTime;

            //document defaults
            this.EventDate = currentDateTime;
            this.IssuePlaceId = new Guid(ConfigurationMapper.Instance.GetSingleConfigurationEntry("document.defaults.issuePlaceId").Value.Value);
			this.ExchangeDate = currentDateTime.PreviousWorkDay();
            this.ExchangeScale = 1;
            this.ExchangeRate = 1;

            Contractor issuingPerson = (Contractor)DependencyContainerManager.Container.Get<ContractorMapper>().LoadBusinessObject(BusinessObjectType.Contractor, SessionManager.User.UserId);
            this.IssuingPerson = issuingPerson;

            Contractor issuer = (Contractor)DependencyContainerManager.Container.Get<ContractorMapper>().LoadBusinessObject(BusinessObjectType.Contractor, new Guid(ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "document.defaults.issuerId").First().Value.Value));
            this.Issuer = issuer;

            //znajdywanie adresu do faktury
            Guid billingId = DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Billing).Id.Value;
            Guid defaultId = DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Default).Id.Value;
            ContractorAddress issuerAddress = issuer.Addresses.Children.Where(a => a.ContractorFieldId == billingId).FirstOrDefault();

            if (issuerAddress == null)
				issuerAddress = issuer.Addresses.Children.Where(a => a.ContractorFieldId == defaultId).FirstOrDefault();

			if (issuerAddress == null)
				throw new ClientException(ClientExceptionId.MissingDefaultOrBillingAddress, null, "name:" + issuer.FullName); 

            this.IssuerAddressId = issuerAddress.Id.Value;
        }


        public override void SaveRelations(XDocument document)
        {
            foreach (CommercialDocumentLine line in this.Lines.Children)
            {
                line.CommercialWarehouseRelations.SaveChanges(document);
                line.CommercialWarehouseValuations.SaveChanges(document);
            }

            base.SaveRelations(document);
        }

        /// <summary>
        /// Gets the constant data that should be saved in present version to a separate column.
        /// </summary>
        /// <returns><see cref="XElement"/> containing constant data.</returns>
        protected XElement GetConstantData()
        {
            XElement constant = new XElement("constant");

            if (this.Contractor != null)
            {
                XElement el = Document.GetContractorConstantData(this.Contractor, "contractor");

                if (el != null)
                    constant.Add(el);
            }

            if (this.ReceivingPerson != null)
            {
                XElement el = Document.GetContractorConstantData(this.ReceivingPerson, "receivingPerson");

                if (el != null)
                    constant.Add(el);
            }

            if (this.Issuer != null)
            {
                XElement el = Document.GetContractorConstantData(this.Issuer, "issuer");

                if (el != null)
                    constant.Add(el);
            }

            if (this.IssuingPerson != null)
            {
                XElement el = Document.GetContractorConstantData(this.IssuingPerson, "issuingPerson");

                if (el != null)
                    constant.Add(el);
            }

            return constant;
        }

        /// <summary>
        /// Calculates vat table and sets document value as sum of all lines (without round).
        /// </summary>
        private void CalculateVatTable()
        {
            //store previous vtEntries
            //dictionary vatRateId - vtEntry (previous)
            Dictionary<Guid, CommercialDocumentVatTableEntry> previousVatTableEntries = new Dictionary<Guid, CommercialDocumentVatTableEntry>();

            foreach (CommercialDocumentVatTableEntry vtEntry in this.VatTableEntries.Children)
            {
                previousVatTableEntries.Add(vtEntry.VatRateId, vtEntry);
            }

            this.VatTableEntries.RemoveAll();

            this.NetValue = 0;
            this.GrossValue = 0;
            this.VatValue = 0;

            //generate new vtEntry or update an existing one
            foreach (CommercialDocumentLine line in this.Lines.Children)
			{
				#region Skip Sales Order cost positions
				string salesOrderGDO = SalesOrderGenerateDocumentOption.TryGetOption(line);
				if (salesOrderGDO != null && SalesOrderGenerateDocumentOption.IsCost(salesOrderGDO))
				{
					continue;//
				}
				#endregion

				var vtEntries = from entry in this.VatTableEntries.Children
                                where entry.VatRateId == line.VatRateId
                                select entry;

                CommercialDocumentVatTableEntry vtEntry = null;

                if (vtEntries.Count() == 1) //update the entry
                    vtEntry = vtEntries.ElementAt(0);
                else //generate new entry
                {
                    vtEntry = this.VatTableEntries.CreateNew();
                    vtEntry.VatRateId = line.VatRateId;

                    if (previousVatTableEntries.ContainsKey(line.VatRateId)) //get id and version from the previous one
                    {
                        CommercialDocumentVatTableEntry previousVtEntry = previousVatTableEntries[line.VatRateId];
                        vtEntry.Id = previousVtEntry.Id;
                        vtEntry.Version = previousVtEntry.Version;

                        if (previousVtEntry.AlternateVersion != null)
                            vtEntry.SetAlternateVersion(previousVtEntry.AlternateVersion);
                    }
                }

                vtEntry.NetValue += line.NetValue;
                vtEntry.GrossValue += line.GrossValue;
                vtEntry.VatValue += line.VatValue;

                this.NetValue += line.NetValue;
                this.GrossValue += line.GrossValue;
                this.VatValue += line.VatValue;
            }
        }

        /// <summary>
        /// Calculates the document. With the precision of 2.
        /// </summary>
        public void Calculate()
        {
            this.Calculate(2);
        }

        /// <summary>
        /// Calculates the document and vat table.
        /// </summary>
        /// <param name="precision">The precision.</param>
        public void Calculate(int precision)
        {
            this.CalculateVatTable();

            if (this.SummationType == SummationType.VatRates)
            {
                this.NetValue = 0;
                this.GrossValue = 0;
                this.VatValue = 0;
                foreach (CommercialDocumentVatTableEntry vtEntry in this.VatTableEntries.Children)
                {
                    decimal vatRate = DictionaryMapper.Instance.GetVatRate(vtEntry.VatRateId).Rate;

                    if (this.CalculationType == CalculationType.Net)
                    {
                        vtEntry.NetValue = Decimal.Round(vtEntry.NetValue, precision, MidpointRounding.AwayFromZero);
                        vtEntry.VatValue = Decimal.Round((vtEntry.NetValue * vatRate / 100), precision, MidpointRounding.AwayFromZero);
                        vtEntry.GrossValue = Decimal.Round((vtEntry.NetValue + vtEntry.VatValue), precision, MidpointRounding.AwayFromZero);
                    }
                    else
                    {
                        vtEntry.GrossValue = Decimal.Round(vtEntry.GrossValue, precision, MidpointRounding.AwayFromZero);
                        vtEntry.VatValue = Decimal.Round((vtEntry.GrossValue * vatRate / (100 + vatRate)), precision, MidpointRounding.AwayFromZero);
                        vtEntry.NetValue = Decimal.Round((vtEntry.GrossValue - vtEntry.VatValue), precision, MidpointRounding.AwayFromZero);
                    }

                    this.NetValue += vtEntry.NetValue;
                    this.GrossValue += vtEntry.GrossValue;
                    this.VatValue += vtEntry.VatValue;
                }
            }
            else //sum_lines
            {
                foreach (CommercialDocumentVatTableEntry vtEntry in this.VatTableEntries.Children)
                {
                    vtEntry.NetValue = Decimal.Round(vtEntry.NetValue, precision, MidpointRounding.AwayFromZero);
                    vtEntry.GrossValue = Decimal.Round(vtEntry.GrossValue, precision, MidpointRounding.AwayFromZero);
                    vtEntry.VatValue = Decimal.Round(vtEntry.VatValue, precision, MidpointRounding.AwayFromZero);
                }
            }

            this.NetValue = Decimal.Round(this.NetValue, precision, MidpointRounding.AwayFromZero);
            this.GrossValue = Decimal.Round(this.GrossValue, precision, MidpointRounding.AwayFromZero);
            this.VatValue = Decimal.Round(this.VatValue, precision, MidpointRounding.AwayFromZero);
        }


		public decimal GetValueInSystemCurrency(decimal valueInDocumentCurrency)
		{
			return this.HasSystemCurrency ? valueInDocumentCurrency : 
					Math.Round(valueInDocumentCurrency * this.ExchangeRate / (decimal)this.ExchangeScale, 2, MidpointRounding.AwayFromZero);
		}
    }
}
