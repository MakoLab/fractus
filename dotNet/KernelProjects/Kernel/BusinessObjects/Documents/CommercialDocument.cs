using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;
using Makolab.Fractus.Kernel.BusinessObjects.Documents.Options;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class that represents any commercial document.
    /// </summary>
    [XmlSerializable(XmlField = "commercialDocument")]
    internal class CommercialDocument : CommercialDocumentBase, IPaymentsContainingDocument, IContractorContainingDocument
    {
        public override XDocument FullXml
        {
            get
            {
                XDocument xdoc = base.FullXml;

                if (ConfigurationMapper.Instance.IsWmsEnabled && this.ShiftTransaction != null)
                    xdoc.Root.Add(this.ShiftTransaction.Serialize());

                return xdoc;
            }
        }

        /// <summary>
        /// Gets or sets the <see cref="Payments"/> object that manages <see cref="CommercialDocument"/>'s payments.
        /// </summary>
        [XmlSerializable(XmlField = "payments", ProcessLast = true)]
        public Payments Payments { get; private set; }

        public CommercialDocument CorrectedDocument { get; set; }
        public CommercialDocument InitialCorrectedDocument
        {
            get
            {
                if (this.CorrectedDocument == null)
                    return null;

                CommercialDocument doc = this;

                while (doc.CorrectedDocument != null)
                {
                    doc = doc.CorrectedDocument;
                }

                return doc;
            }
        }


		public decimal GrossValueBeforeCorrection
		{
			get
			{
				decimal grossValueBeforeCorrection = 0;
				if (this.CorrectedDocument != null)
				{
					CommercialDocument previousCorrection = this.CorrectedDocument;
					grossValueBeforeCorrection = previousCorrection.GrossValue;

					if (previousCorrection.IsSettlementDocument)
					{
						grossValueBeforeCorrection = previousCorrection.VatTableEntries
							.Where(ve => ve.GrossValue > 0 && ve.NetValue >= 0 && ve.VatValue >= 0)
							.Sum(ve => ve.GrossValue);
					}
				}

				return grossValueBeforeCorrection;
			}
		}
		
		public bool SkipCorrectionEditCheck { get; set; }

		public bool SkipRealizeClosedSalesOrderCheck { get; set; }

		public bool DifferentialPaymentsAndDocumentValueCheck { get; set; }

        [XmlSerializable(XmlField = "skipSalesPriceBelowPurchaseValidation")]
        public bool SkipSalesPriceBelowPurchaseValidation { get; set; }

        [XmlSerializable(XmlField = "skipInvaluatedOutcomesValidation")]
        public bool SkipInvaluatedOutcomesValidation { get; set; }

        [XmlSerializable(XmlField = "skipMinimalMarginValidation")]
        public bool SkipMinimalMarginValidation { get; set; }

        public bool IsSettlementDocument { get { return this.Attributes[DocumentFieldName.Attribute_IsSettlementDocument] != null; } }

        public SalesOrderSettlements SalesOrderSettlements { get; set; }

		public bool IsSimulatedInvoice
		{
			get { return !String.IsNullOrEmpty(this.DocumentType.CommercialDocumentOptions.SimulatedInvoice); }
		}

		public bool IsRelatedWithSalesOrder { 
			get 
			{
				if (this.Lines.Any(line => line.Attributes[DocumentFieldName.LineAttribute_RealizedSalesOrderLineId] != null))
					return true;
				if (this.Relations.Any(rel => rel.RelationType == DocumentRelationType.SalesOrderToSimulatedInvoice))
					return true;
				return false;  
			} 
		}

        public CommercialDocument()
            : base(BusinessObjectType.CommercialDocument)
        {
            this.Payments = new Payments(this);
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.IssuingPerson == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:issuingPerson");

            if (this.IssuePlaceId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:issuePlaceId");

            if (this.Issuer == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:issuer");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();
            CommercialDocument alternateDocument = this.AlternateVersion as CommercialDocument;

			#region Walidajca dat
			if (this.IssueDate.Date < this.EventDate.Date)
            {
                if (this.DocumentType.DocumentCategory == DocumentCategory.Sales || this.DocumentType.DocumentCategory == DocumentCategory.SalesCorrection)
                    throw new ClientException(ClientExceptionId.IncorrectEventDateSales);
                else if (this.DocumentType.DocumentCategory == DocumentCategory.Purchase || this.DocumentType.DocumentCategory == DocumentCategory.PurchaseCorrection)
                    throw new ClientException(ClientExceptionId.IncorrectEventDatePurchase);
            }

            if ((this.DocumentType.DocumentCategory == DocumentCategory.Sales 
                || this.DocumentType.DocumentCategory == DocumentCategory.SalesCorrection)
                && this.IssueDate.Date > SessionManager.VolatileElements.CurrentDateTime.Date)
                throw new ClientException(ClientExceptionId.IncorrectIssueDateOnSalesDocument);
			#endregion

			#region Walidacja korekt
			if (this.IsCorrectiveDocument())
            {
				CommercialDocument correctedParent = (CommercialDocument)this.Lines[0].CorrectedLine.Parent;
				//data wystawienia nie moze byc pozniejsza niz data na poprzednim dokumencie
				#region
                if (correctedParent.IssueDate > this.IssueDate)
                    throw new ClientException(ClientExceptionId.EarlierIssueDateOnCorrectiveDocument);
				#endregion

				//korekty paragonu moga korygowac tylko do zera - sprawdzamy czy tak na pewno jest
				#region
				if (this.InitialCorrectedDocument.DocumentType.CommercialDocumentOptions.IsInvoiceAppendable)
                {
                    //sprawdzamy czy wszystkie linie co cos korygowaly koryguja do zera
                    foreach (CommercialDocumentLine line in this.Lines.Children)
                    {
                        if (line.Quantity != 0 && line.Quantity + line.CorrectedLine.Quantity > 0 || line.Quantity > 0 ||
                            line.GrossPrice != 0 || line.NetPrice != 0)
                            throw new ClientException(ClientExceptionId.BillCorrectionError);
                    }
				}
				#endregion

				//waluta musi być taka sama jak na dokumencie korygowanym
				if (this.DocumentCurrencyId != correctedParent.DocumentCurrencyId)
					throw new ClientException(ClientExceptionId.IncompatibleDocumentAndCorrectionCurrencies);
			}
			#endregion

			#region Walidacja zamówień MM
			if (this.DocumentType.CommercialDocumentOptions.IsShiftOrder && this.DocumentType.DocumentCategory == DocumentCategory.Order)
            {
                var attr = this.Attributes[DocumentFieldName.Attribute_TargetBranchId];

                if (attr == null)
                    throw new ClientException(ClientExceptionId.NoTargetBranchSelected);

                Guid? whId = null;

                foreach (var line in this.Lines)
                {
                    if(line.WarehouseId == null)
                        continue;

                    if (whId == null)
                        whId = line.WarehouseId.Value;
                    else if (whId != null && whId.Value != line.WarehouseId.Value)
                        throw new ClientException(ClientExceptionId.IncorrectWarehouseOnShiftOrder);
                }
			}
			#endregion

			#region Faktura do paragonu
			var invoiceToBill = this.Relations.Children.Where(r => r.RelationType == DocumentRelationType.InvoiceToBill).FirstOrDefault();
            
            if (invoiceToBill != null && this.IsNew)
            {
                //jezeli wystawiamy fakture do paragonu to musi on miec taka sama forme platnosci
                var oppositeDocument = (CommercialDocument)invoiceToBill.RelatedDocument;
                var oppositePayment = oppositeDocument.Payments[0];

                if (this.Payments[0].PaymentMethodId.Value != oppositePayment.PaymentMethodId.Value)
                    throw new ClientException(ClientExceptionId.InconsistentPaymentMethodOnInvoiceAndBill);

                if (this.CalculationType != oppositeDocument.CalculationType)
                    throw new ClientException(ClientExceptionId.InconsistentCalculationTypeOnInvoiceAndBill);
            }
            else if (invoiceToBill != null) //edycja. wtedy nie mamy wczytanego do konca paragonu wiec walidujemy z alternateVersion
            {
                if (this.Payments[0].PaymentMethodId.Value != alternateDocument.Payments[0].PaymentMethodId.Value)
                    throw new ClientException(ClientExceptionId.InconsistentPaymentMethodOnInvoiceAndBill);

                if (this.CalculationType != alternateDocument.CalculationType)
                    throw new ClientException(ClientExceptionId.InconsistentCalculationTypeOnInvoiceAndBill);
			}
			#endregion

			DocumentType dt = DictionaryMapper.Instance.GetDocumentType(this.DocumentTypeId);

			if (!dt.CommercialDocumentOptions.AllowOtherCurrencies && this.DocumentCurrencyId != this.SystemCurrencyId)
				throw new ClientException(ClientExceptionId.DocumentCurrencyException);

			if (!dt.CommercialDocumentOptions.AllowCalculationTypeChange && this.CalculationType != dt.CommercialDocumentOptions.CalculationType &&
				this.Relations.Children.Where(r => r.RelationType == DocumentRelationType.InvoiceToBill).FirstOrDefault() == null)
				throw new ClientException(ClientExceptionId.CalculationTypeChangeError);

			#region Walidacja kontrahentów
			if (this.ReceivingPerson != null && this.Contractor == null)
                throw new ClientException(ClientExceptionId.ReceivingPersonWithoutContractor);

            if (dt.CommercialDocumentOptions.ContractorOptionality == Optionality.Mandatory && this.Contractor == null)
                throw new ClientException(ClientExceptionId.ContractorIsMandatory);

            if (dt.CommercialDocumentOptions.ContractorOptionality == Optionality.Forbidden && this.Contractor != null)
                throw new ClientException(ClientExceptionId.ContractorIsForbidden);

            //nie mozna zmieniac kontrahenta na czesciowo zrealizownym zamowieniu
            if (this.AlternateVersion != null)
            {
                bool related = false;

                foreach (var line in this.Lines.Children)
                {
                    if (line.CommercialWarehouseRelations.Children.Count != 0)
                    {
                        related = true;
                        break;
                    }
                }

                if (related &&
                    (dt.DocumentCategory == DocumentCategory.Order || dt.DocumentCategory == DocumentCategory.Reservation) &&
                    (this.Contractor != null && alternateDocument.Contractor == null ||
                    this.Contractor == null && alternateDocument.Contractor != null ||
                    (this.Contractor != null && alternateDocument.Contractor != null && this.Contractor.Id.Value != alternateDocument.Contractor.Id.Value)))
                    throw new ClientException(ClientExceptionId.PartiallyRealizedOrderContractorChange);
			}
			#endregion

			if (this.Lines != null)
                this.Lines.Validate();

			#region Walidacja technologii
			if (dt.DocumentCategory == DocumentCategory.Technology)
            {
				DocumentAttrValue attr = this.Attributes[DocumentFieldName.Attribute_ProductionTechnologyName];

				if (attr == null || attr.Value == null || attr.Value.Value.Length == 0)
					throw new ClientException(ClientExceptionId.MissingTechnologyNameOnTechnology);
				
				if (this.Lines.Where(l => l.Attributes[DocumentFieldName.LineAttribute_ProductionItemType].Value.Value == "product").Count() != 1)
                    throw new ClientException(ClientExceptionId.MissingMainProductOnTechnology);

                if (this.Lines.Where(l => l.Attributes[DocumentFieldName.LineAttribute_ProductionItemType].Value.Value == "material").Count() == 0)
                    throw new ClientException(ClientExceptionId.MissingMaterialOnTechnology);
			}
			#endregion

			#region Walidacja stawek VAT

			if (this.VatTableEntries != null)
				this.VatTableEntries.Validate();

			#region Walidacja okresu obowiązywania

			if (this.DocumentType.DocumentCategory == DocumentCategory.Sales)
			{
				//jeśli wpisy dla stawki się bilansują do 0 nie zgłaszamy wyjątku
				if (this.VatTableEntries.Any(vte => 
					!DictionaryMapper.Instance.GetVatRate(vte.VatRateId).IsEventDateValid(this.EventDate)
					&& (this.VatTableEntries.Where(__vte => __vte.VatRateId == vte.VatRateId).Sum(__vte => __vte.GrossValue) != 0
					|| this.VatTableEntries.Where(__vte => __vte.VatRateId == vte.VatRateId).Sum(__vte => __vte.NetValue) != 0
					|| this.VatTableEntries.Where(__vte => __vte.VatRateId == vte.VatRateId).Sum(__vte => __vte.VatValue) != 0)))
				{
					throw new ClientException(ClientExceptionId.VatRateNotAllowedForSelectedSaleDate);
				}
			}

			#endregion

			#endregion

			if (this.Payments != null)
                this.Payments.Validate();

			#region Walidacja blokad edycji pozycji
			if (!this.IsNew && this.DisableLinesChange != null && this.DisableLinesChange.Contains(DisableDocumentChangeReason.LINES_RELATED_WAREHOUSE_DOCUMENT) &&
                (this.Lines.IsAnyChildNew() || this.Lines.IsAnyChildModified() || this.Lines.IsAnyChildDeleted()) &&
                this.DocumentStatus != DocumentStatus.Canceled)
            {
                //teraz mozemy edytowac linie ale tylko na dok. sprzedazowych i tylko wartosci, wiec sprawzamy czy moze tak jest
                if (this.DocumentType.DocumentCategory == DocumentCategory.Sales && !this.Lines.IsAnyChildNew() && !this.Lines.IsAnyChildDeleted())
                {
                    //czyli same zmodyfikowane, sprawdzamy czy ilosciowo tylko
                    foreach (var line in this.Lines)
                    {
                        if (line.Quantity != ((CommercialDocumentLine)line.AlternateVersion).Quantity)
                            throw new ClientException(ClientExceptionId.UnableToEditCommercialDocument);
                    }
                }
                else
                    throw new ClientException(ClientExceptionId.UnableToEditCommercialDocument);
            }

            if (this.DisableDocumentChange != null && this.DisableDocumentChange.Contains(DisableDocumentChangeReason.DOCUMENT_RELATED_CORRECTIVE_DOCUMENTS) &&
                (this.Lines.IsAnyChildNew() || this.Lines.IsAnyChildModified() || this.Lines.IsAnyChildDeleted()))
            {
                throw new ClientException(ClientExceptionId.UnableToEditDocumentBecauseOfCorrections);
			}
			#endregion

			#region Walidacja faktury rozliczającej
			DocumentAttrValue attrib = this.Attributes[DocumentFieldName.Attribute_ProcessType];

            if (attrib != null && attrib.Value.Value == "processes.salesOrder" && this.DocumentType.DocumentCategory != DocumentCategory.SalesOrder)
            {
                //sprawdzamy czy jest to faktura rozliczajaca po tym ze ma ujemne wartosci w tabeli vat
                if (!this.IsSettlementDocument)
                {
                    ICollection<Guid> prepaidItems = ProcessManager.Instance.GetPrepaidItems(this);

                    foreach (var line in this.Lines)
                    {
                        if (!prepaidItems.Contains(line.ItemId))
                            throw new ClientException(ClientExceptionId.PrepaidInvoiceLinesError);
                    }
                }
			}
			#endregion

			#region Walidacja zamowienia sprzedazowego
			if (this.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
            {
                var salesmanAttr = this.Attributes[DocumentFieldName.Attribute_SalesmanId];
                //Nie zawsze potrzebny handlowiec
                var salesmanAttrConf = this.DocumentType.Options.Descendants("attribute").Attributes("name").Where(line => line.Value == "Attribute_SalesmanId").Count();
                if (salesmanAttrConf > 0)
                {
                    if (salesmanAttr == null || salesmanAttr.Value.Value.Length == 0 || !salesmanAttr.Value.Value.IsGuid()) //jezeli nie ma handlowca wybranego
                    {
                        if (alternateDocument == null || alternateDocument.DocumentStatus != DocumentStatus.Committed || this.DocumentStatus != DocumentStatus.Saved) //jezeli jest to nowy dokument lub edycja ale NIE jest to anulowanie rozliczenia
                            throw new ClientException(ClientExceptionId.MissingSalesman);
                    }
                }
                if (this.DocumentType.Options.Descendants("template").Attributes("LineAttribute_SalesOrderGenerateDocumentOption").Count() > 0)
                {
                    foreach (CommercialDocumentLine line in this.Lines.Children)
                    {
                        if (line.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption] == null || line.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption].Value.Value.Length == 0)
                            throw new ClientException(ClientExceptionId.MissingLineAttribute, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

                        CommercialDocumentLine alternativeLine = line.AlternateVersion as CommercialDocumentLine;

                        if (alternativeLine != null && alternativeLine.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption].Value.Value !=
                            line.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption].Value.Value &&
                            alternativeLine.CommercialWarehouseRelations.Children.Count != 0)
                            throw new ClientException(ClientExceptionId.GenerateDocumentOptionAttriuteChangeError, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

                        decimal quantityOnRelations = line.CommercialWarehouseRelations.Sum(s => s.Quantity);

                        if (line.Quantity < quantityOnRelations && line.Quantity > 0) //&& line.Quantity > 0 dodane na potrzeby ujemnej pozycji na zamówieniu
                            throw new ClientException(ClientExceptionId.QuantityBelowServiceRealized, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));
                    }
                }
                if (alternateDocument != null)
                {
                    var deletedRealized = alternateDocument.Lines.Children.Where(l => l.Status == BusinessObjectStatus.Deleted && l.CommercialWarehouseRelations.Children.Count != 0).FirstOrDefault();

                    if (deletedRealized != null)
                        throw new ClientException(ClientExceptionId.ServiceRealizedLineRemoval);
                }
            }
            #endregion
		}

		/// <summary>
		/// Sprawdza czy dokument realizuje zamknięte ZSP oraz opcjonalnie czy na liniach realizujących ZSP niekoniecznie zamknięte doszło do zmiany ilości
		/// </summary>
		/// <param name="checkQuantityChange">czy sprawdzać zmianę ilości na pozycjach realizujących ZSP</param>
		internal void ValidateSalesOrderRealizedLines(bool checkQuantityChange)
		{
			if (!this.IsNew && !this.SkipRealizeClosedSalesOrderCheck)
			{
				CommercialDocument alternateDocument = this.AlternateVersion != null ? 
					(CommercialDocument)this.AlternateVersion : null;
				DocumentMapper mapper =
					(DocumentMapper)DependencyContainerManager.Container.Get<DocumentMapper>();
				foreach (CommercialDocumentLine commLine in this.Lines)
				{
					Guid? relatedSalesOrderId = commLine.Attributes.
						GetGuidValueByFieldName(DocumentFieldName.LineAttribute_RealizedSalesOrderLineId);
					//test czy realizuje zamknięte ZSP
					if (relatedSalesOrderId.HasValue)
					{
						//test czy pozmieniały się ilości
						if (checkQuantityChange && alternateDocument != null)
						{
							CommercialDocumentLine altLine = alternateDocument.Lines.Where(line => line.Id == commLine.Id).FirstOrDefault();
							if (altLine != null && commLine.Quantity != altLine.Quantity)
							{
								throw new ClientException(ClientExceptionId.LineQuantityEditForbiddenRelatedSalesOrder, null, "order:" + commLine.Order);
							}
						}
						CommercialDocument relatedSalesOrder =
							mapper.GetCommercialDocumentByLineId(relatedSalesOrderId.Value);
						if (SalesOrderFactory.IsSalesOrderClosed(relatedSalesOrder))
						{
							throw new ClientException(ClientExceptionId.DocumentEditForbiddenRelatedSalesOrderClosed);
						}
					}
				}
			}
		}

        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            if (this.Relations.Children.Where(r => r.RelationType == DocumentRelationType.InvoiceToBill).FirstOrDefault() != null)
            {
                if (this.DocumentType.CommercialDocumentOptions.IsInvoiceAppendable)
                    this.DisableDocumentChange = DisableDocumentChangeReason.DOCUMENT_BILL_HAS_INVOICE;
                else
                    this.DisableLinesChange = DisableDocumentChangeReason.LINES_INVOICE_FROM_BILL;
            }

            if (this.IsSettlementDocument)
                this.DisableLinesChange = DisableDocumentChangeReason.LINES_SETTLEMENT_INVOICE;
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
            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Lines != null)
                this.Lines.SaveChanges(document);

            if (this.VatTableEntries != null)
                this.VatTableEntries.SaveChanges(document);

            if (this.Payments != null)
                this.Payments.SaveChanges(document);

            //if the document has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    this.SystemStartEditValidation();
                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);

                    this.Number.SaveChanges(document);
                }
            }
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Lines != null)
            {
                this.Lines.UpdateStatus(isNew);

                if (this.Lines.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.VatTableEntries != null)
            {
                this.VatTableEntries.UpdateStatus(isNew);

                if (this.VatTableEntries.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.Payments != null)
            {
                this.Payments.UpdateStatus(isNew);
                //CZAREK - test update payment zawsze przy edycji dokumentu
                if (this.Payments.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            CommercialDocument alternateDocument = (CommercialDocument)alternate;

            if (this.Lines != null)
                this.Lines.SetAlternateVersion(alternateDocument.Lines);

            if (this.VatTableEntries != null)
                this.VatTableEntries.SetAlternateVersion(alternateDocument.VatTableEntries);

            if (this.Payments != null)
                this.Payments.SetAlternateVersion(alternateDocument.Payments);
        }

        public override XElement Serialize(bool selfOnly)
        {
            XElement element = base.Serialize(selfOnly);

            if (!selfOnly && this.DocumentType != null && (this.DocumentType.DocumentCategory == DocumentCategory.SalesCorrection || this.DocumentType.DocumentCategory == DocumentCategory.PurchaseCorrection))
            {
                CommercialDocument previousCorrection = this.CorrectedDocument;
                XElement vtBeforeCorrection = previousCorrection.VatTableEntries.Serialize("vatTableBeforeCorrection");

                decimal netValueBeforeCorrection = previousCorrection.NetValue;
                decimal grossValueBeforeCorrection = previousCorrection.GrossValue;
                decimal vatValueBeforeCorrection = previousCorrection.VatValue;

                if (previousCorrection.IsSettlementDocument)
                {
                    vtBeforeCorrection.Elements().Where(e => Convert.ToDecimal(e.Element("netValue").Value, CultureInfo.InvariantCulture) < 0 ||
                        Convert.ToDecimal(e.Element("grossValue").Value, CultureInfo.InvariantCulture) < 0 ||
                        Convert.ToDecimal(e.Element("vatValue").Value, CultureInfo.InvariantCulture) < 0).Remove();

                    netValueBeforeCorrection = vtBeforeCorrection.Elements().Sum(s => Convert.ToDecimal(s.Element("netValue").Value, CultureInfo.InvariantCulture));
                    grossValueBeforeCorrection = vtBeforeCorrection.Elements().Sum(s => Convert.ToDecimal(s.Element("grossValue").Value, CultureInfo.InvariantCulture));
                    vatValueBeforeCorrection = vtBeforeCorrection.Elements().Sum(s => Convert.ToDecimal(s.Element("vatValue").Value, CultureInfo.InvariantCulture));
                }

                element.Add(vtBeforeCorrection);

                element.Add(new XElement("netValueBeforeCorrection", netValueBeforeCorrection.ToString(CultureInfo.InvariantCulture)));
                element.Add(new XElement("grossValueBeforeCorrection", grossValueBeforeCorrection.ToString(CultureInfo.InvariantCulture)));
                element.Add(new XElement("vatValueBeforeCorrection", vatValueBeforeCorrection.ToString(CultureInfo.InvariantCulture)));

                CommercialDocument sourceInvoice = this.InitialCorrectedDocument;
                element.Add(new XElement("originalDocumentFullNumber", sourceInvoice.Number.FullNumber));
                element.Add(new XElement("originalDocumentIssueDate", sourceInvoice.IssueDate));
            }

            if (this.SalesOrderSettlements != null)
                element.Add(this.SalesOrderSettlements.Serialize());

            return element;
        }

        public bool IsCorrectiveDocument()
        {
            DocumentCategory dc = this.DocumentType.DocumentCategory;

            if (dc == DocumentCategory.SalesCorrection || dc == DocumentCategory.PurchaseCorrection)
                return true;
            else
                return false;
        }
    }
}
