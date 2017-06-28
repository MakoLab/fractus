using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
	internal static class SalesOrderFactory
	{
		public static void BindCashOutcomeDocumentToSalesOrder(XElement source, FinancialDocument destination)
		{
			/*
				<source type="salesOrder">
				  <salesOrderId>{documentId}</salesOrderId>
				</source>
			 */
			var payment = destination.Payments.CreateNew();
			payment.Description = "Za fakturę nr: ";
			payment.SalesOrderId = new Guid(source.Element("salesOrderId").Value);
		}

        public static void GenerateSalesOrderFromBill(XElement source, CommercialDocument destination)
        {
            Guid docId = new Guid(source.Element("salesDocumentId").Value);
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
            CommercialDocument doc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);

            SalesOrderFactory.CopyLinesToSalesOrder(doc, destination);

        }

		public static void GenerateInvoiceFromMultipleSalesOrders(XElement source, CommercialDocument destination)
		{
			/*
				<source type="multipleSalesOrders">
				  <salesOrderId>{documentId}</salesOrderId>
				  <salesOrderId>{documentId}</salesOrderId>
				  <salesOrderId>{documentId}</salesOrderId>
				  .........
				</source>
			 */

			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			List<CommercialDocument> soDocs = new List<CommercialDocument>();

			CalculationType? calcType = null;

			foreach (XElement soId in source.Elements("salesOrderId"))
			{
				Guid docId = new Guid(soId.Value);

				var exists = soDocs.Where(d => d.Id.Value == docId).FirstOrDefault();

				if (exists != null)
					continue;

				CommercialDocument doc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);
				soDocs.Add(doc);

				if (calcType == null)
					calcType = doc.CalculationType;
				else if (calcType.Value != doc.CalculationType)
					throw new ClientException(ClientExceptionId.DifferentCalculationTypes);
			}

			if (calcType.Value != destination.CalculationType && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
				destination.CalculationType = calcType.Value;

			//sprawdzamy czy dok. zrodlowe maja wspolnego kontrahenta. jezeli tak to kopiujemy go na fakture
			bool copyContractor = true;

			//jezeli gdzies nie ma kontrahenta to nie kopiujemy
			var emptyContractor = soDocs.Where(w => w.Contractor == null).FirstOrDefault();

			if (emptyContractor != null)
				copyContractor = false;

			if (copyContractor)
			{
				var differentContractor = soDocs.Where(ww => ww.Contractor.Id.Value != soDocs[0].Contractor.Id.Value).FirstOrDefault();

				if (differentContractor != null)
					copyContractor = false;
			}

			if (copyContractor)
			{
				destination.Contractor = soDocs[0].Contractor;

				if (destination.Contractor != null)
				{
					var address = destination.Contractor.Addresses.GetBillingAddress();

					if (address != null)
						destination.ContractorAddressId = address.Id.Value;
				}
			}

			//kopiujemy atrybuty jezeli sa jakies takie
			DuplicableAttributeFactory.DuplicateAttributes(soDocs, destination);

			XElement tagXml = new XElement("salesOrders");

			foreach (CommercialDocument salesOrder in soDocs)
			{
				if (salesOrder.Relations.Where(rr => rr.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null)
					throw new ClientException(ClientExceptionId.UnableToCreateInvoiceToSalesOrder, null, "orderNumber:" + salesOrder.Number.FullNumber);

				SalesOrderFactory.CopyLinesFromSalesOrder(salesOrder, destination, true, false, true,true);
				tagXml.Add(new XElement("salesOrder", new XAttribute("id", salesOrder.Id.ToUpperString()), new XAttribute("version", salesOrder.Version.ToUpperString())));
			}

			destination.Calculate();
			destination.Tag = tagXml.ToString(SaveOptions.DisableFormatting);
		}

        public static void GeneratePurchaseInvoiceFromMultipleSalesOrders(XElement source, CommercialDocument destination)
        {
            /*
                robimy fakture zakupową na pozycje usługowe
             */

            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

            List<CommercialDocument> soDocs = new List<CommercialDocument>();

            CalculationType? calcType = CalculationType.Net;
            destination.CalculationType = calcType.Value;

            foreach (XElement soId in source.Elements("salesOrderId"))
            {
                Guid docId = new Guid(soId.Value);

                var exists = soDocs.Where(d => d.Id.Value == docId).FirstOrDefault();

                if (exists != null)
                    continue;

                CommercialDocument doc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);
                soDocs.Add(doc);

            }


            //kopiujemy atrybuty jezeli sa jakies takie
            DuplicableAttributeFactory.DuplicateAttributes(soDocs, destination);

            XElement tagXml = new XElement("salesOrders");

            foreach (CommercialDocument salesOrder in soDocs)
            {
                 //Dla dokumentu zakupowego nie ma ograniczenia
                //if (salesOrder.Relations.Where(rr => rr.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null)
                //    throw new ClientException(ClientExceptionId.UnableToCreateInvoiceToSalesOrder, null, "orderNumber:" + salesOrder.Number.FullNumber);

                SalesOrderFactory.CopyLinesFromSalesOrder(salesOrder, destination, true, false, true,false);
                tagXml.Add(new XElement("salesOrder", new XAttribute("id", salesOrder.Id.ToUpperString()), new XAttribute("version", salesOrder.Version.ToUpperString())));
            }

            destination.Calculate();
            destination.Tag = tagXml.ToString(SaveOptions.DisableFormatting);
        }

		public static void CheckIfSalesOrderHasWarehouseDocumentsWithInvoices(CommercialDocument salesOrder, bool closeOrder)
		{
			//sprawdzamy czy ZSP ma WZ ktory ma fakture
			foreach (var relation in salesOrder.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToWarehouseDocument))
			{
				WarehouseDocument whDoc = null;

				if (relation.RelatedDocument.Version != null)
					whDoc = (WarehouseDocument)relation.RelatedDocument;
				else
				{
					whDoc = (WarehouseDocument)DependencyContainerManager.Container.Get<DocumentMapper>().LoadBusinessObject(BusinessObjectType.WarehouseDocument, relation.RelatedDocument.Id.Value);
					relation.RelatedDocument = whDoc;
				}

				if (whDoc.Relations.Where(rr => rr.RelationType == DocumentRelationType.SalesOrderToWarehouseDocument).Count() > 1)
				{
					if (closeOrder)
						throw new ClientException(ClientExceptionId.UnableToCreateSettlementDocument2);
					else
						throw new ClientException(ClientExceptionId.UnableToCreatePrepaymentDocument2);
				}

				foreach (var line in whDoc.Lines)
				{
					if (line.CommercialWarehouseRelations.Where(l => l.IsCommercialRelation).FirstOrDefault() != null)
					{
						if (closeOrder)
							throw new ClientException(ClientExceptionId.UnableToCreateSettlementDocument);
						else
							throw new ClientException(ClientExceptionId.UnableToCreatePrepaymentDocument);
					}
				}
			}
		}

		public static bool TryCloseSalesOrder(CommercialDocument salesOrder)
		{
			if (salesOrder.DocumentType.DocumentCategory != DocumentCategory.SalesOrder) return false;
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
			mapper.AddItemsToItemTypesCache(salesOrder);
			var dict = SessionManager.VolatileElements.ItemTypesCache;

			//sprawdzamy czy zamowienie ma wszelkie wz-ty i rw na pozycjach z towarami (pomijamy uslugi)
			foreach (var line in salesOrder.Lines)
			{
				if (!DictionaryMapper.Instance.GetItemType(dict[line.ItemId]).IsWarehouseStorable)
					continue;

				decimal relQuantity = line.CommercialWarehouseRelations.Sum(r => r.Quantity);

				if (line.Quantity != relQuantity)
					return false;
			}

			SalesOrderFactory.CloseSalesOrder(salesOrder);
			salesOrder.DocumentStatus = DocumentStatus.Committed;

			return true;
		}

		internal static void CloseSalesOrder(CommercialDocument salesOrder)
		{
			salesOrder.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "closed";
			ProcessManager.Instance.SetProcessStateChangeDate(salesOrder);
		}

		internal static void OpenSalesOrder(CommercialDocument salesOrder)
		{
			salesOrder.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "open";
			ProcessManager.Instance.SetProcessStateChangeDate(salesOrder);
		}

		public static bool IsSalesOrderClosed(CommercialDocument order)
		{
			DocumentAttrValue attrValue = order.Attributes[DocumentFieldName.Attribute_ProcessState];
			return attrValue != null && attrValue.Value.Value == "closed";
		}

		public static void GeneratePrepaymentDocument(XElement source, CommercialDocument destination)
		{
			/*
				<source type="salesOrder">
				  <salesOrderId>{documentId}</salesOrderId>
				  <processObject>prepaidInvoice</processObject>
				  <closeOrder>false</closeOrder>
				</source>
			 */
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			bool closeOrder = false;

			if (source.Element("closeOrder") != null && source.Element("closeOrder").Value.ToUpperInvariant() == "TRUE")
				closeOrder = true;

			CommercialDocument salesOrder = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(source.Element("salesOrderId").Value));


			SalesOrderFactory.CheckIfSalesOrderHasWarehouseDocumentsWithInvoices(salesOrder, closeOrder);

			SalesOrderSettlements salesOrderSettlements = new SalesOrderSettlements();
			salesOrderSettlements.LoadSalesOrder(salesOrder);
			XElement settledAmount = mapper.GetSalesOrderSettledAmount(salesOrder.Id.Value);
			salesOrderSettlements.LoadPrepaids(settledAmount);
			destination.SalesOrderSettlements = salesOrderSettlements;

			string processType = salesOrder.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value;
			string processObject = source.Element("processObject").Value;
			bool isSimulated = processObject == "simulatedInvoice";
			bool hasProtocole = source.Element("protocole") != null && source.Element("protocole").Value == "true";
			
			ProcessManager.Instance.AppendProcessAttributes(destination, processType, processObject, null, null);
			DuplicableAttributeFactory.DuplicateAttributes(salesOrder, destination);

			if (isSimulated && hasProtocole)
			{
				destination.Attributes.GetOrCreateNew(DocumentFieldName.Attribute_IsSimulateSettlementInvoiceWithProtocole).Value.Value = "1";
			}

			//sprawdzamy czy dokumenty zrodlowe maja zgodne sposoby liczenia

			if (salesOrder.CalculationType != destination.CalculationType && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
				destination.CalculationType = salesOrder.CalculationType;

			if (salesOrder.Contractor != null)
				destination.Contractor = (Contractor)salesOrder.Contractor;

			if (salesOrder.ContractorAddressId != null)
				destination.ContractorAddressId = salesOrder.ContractorAddressId;

			int prepaidDocuments = 0;

			prepaidDocuments = salesOrder.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).Count();

			destination.Tag = prepaidDocuments.ToString(CultureInfo.InvariantCulture);

			/* teraz wybieramy odpowiednia sciezke algorytmu. mamy takie mozliwosc:
			 * 1) wystawiamy zaliczke
			 *    - w takiej sytuacji wybieramy id towaru zaliczkowego dla kazdej ze stawek vat i wpisujemy tam wartosci nierozliczone
			 * 2) wystawiamy fakture rozliczajaca (closeOrder == true) podczas gdy mamy zaliczki (prepaidDocuments > 0)
			 *    - kopiujemy wszystkie pozycje z ZS 1:1, a tabele vat pomniejszamy o sume zaliczek
			 * 3) wystawiamy fakture rozliczajaca (closeOrder == true) i nie mamy dokumentow zaliczkowych (prepaidDocuments == 0)
			 *    - w takim przypadku zamowienie sprzedazowe traktujemy jako proforme, kopiujemy wszystkie pozycje i tabele vat bez zmian i tyle
			 */


			//wstawiamy odpowiedni towar na zaliczke + ustawiamy odpowiednai wartosc
			int stage = 0;

			if (closeOrder)
				stage = 0;
			else if (prepaidDocuments == 0)
				stage = 1;
			else if (prepaidDocuments == 1)
				stage = 2;
			else if (prepaidDocuments == 2)
				stage = 3;
			else if (prepaidDocuments >= 3)
				stage = 4;

			List<Guid> items = new List<Guid>(2);

			ICollection<SalesOrderSettlement> unsettledValues = salesOrderSettlements.GetUnsettledValues();

			foreach (var v in salesOrder.VatTableEntries.GetVatRates())
				items.Add(ProcessManager.Instance.GetPrepaidItemId(salesOrder, stage, v));

			XDocument xml = DependencyContainerManager.Container.Get<ItemMapper>().GetItemsDetailsForDocument(false, null, null, items);

			if (closeOrder)
			{
				SalesOrderFactory.CopyLinesFromSalesOrder(salesOrder, destination, false, true, false,true);
				destination.Calculate();

				//Ostatnia rata pchamy do atrybutu zeby wydruk fiskalny wiedzial co ma wydrukowac
				if (destination.CalculationType == CalculationType.Gross && !isSimulated)
				{
					XElement fiscalLines = new XElement("fiscalLines");

					foreach (var v in unsettledValues)
					{
						XElement itemXml = xml.Root.Elements().Where(i => i.Attribute("id").Value == ProcessManager.Instance.GetPrepaidItemId(salesOrder, stage, v.VatRateId).ToUpperString()).First();
						XElement fiscalLine = new XElement("fiscalLine");
						fiscalLine.Add(new XElement("itemName", itemXml.Attribute("name").Value));
						fiscalLine.Add(new XElement("quantity", "1"));
						fiscalLine.Add(new XElement("vatRateId", itemXml.Attribute("vatRateId").Value));
						fiscalLine.Add(new XElement("grossPrice", v.GrossValue.ToString(CultureInfo.InvariantCulture)));
						fiscalLine.Add(new XElement("grossValue", v.GrossValue.ToString(CultureInfo.InvariantCulture)));
						fiscalLine.Add(new XElement("unitId", itemXml.Attribute("unitId").Value));
						fiscalLines.Add(fiscalLine);
					}

					var attribute = destination.Attributes.CreateNew(DocumentFieldName.Attribute_FiscalPrepayment);
					attribute.Value = fiscalLines;
				}

				if (prepaidDocuments > 0) // *2)
				{
					decimal maxDifference = ProcessManager.Instance.GetMaxSettlementDifference(salesOrder);

					foreach (var v in salesOrderSettlements.Prepaids)
					{
						if (v.NetValue > 0 || v.GrossValue > 0 || v.VatValue > 0)
						{
							var vt = destination.VatTableEntries.Where(t => t.VatRateId == v.VatRateId).FirstOrDefault();
							var prepaidVt = destination.VatTableEntries.CreateNewAfter(vt, v.VatRateId);
							prepaidVt.VatRateId = v.VatRateId;
							prepaidVt.NetValue = -v.NetValue;
							prepaidVt.GrossValue = -v.GrossValue;
							prepaidVt.VatValue = -v.VatValue;

							decimal vtNetValue = 0;
							decimal vtGrossValue = 0;
							decimal vtVatValue = 0;
							if (vt != null)
							{
								vtNetValue = vt.NetValue;
								vtGrossValue = vt.GrossValue;
								vtVatValue = vt.VatValue;
							}

							decimal grossBalance = vtGrossValue + prepaidVt.GrossValue;
							decimal netBalance = vtNetValue + prepaidVt.NetValue;
							decimal vatBalance = vtVatValue + prepaidVt.VatValue;

							SalesOrderBalanceValidator validator =
								new SalesOrderBalanceValidator(maxDifference, grossBalance, netBalance, vatBalance);

							if (validator.IsIllegalOverPayment)
								throw new ClientException(ClientExceptionId.SalesOrderSettlementOverpaidError, null, "value:" + (-grossBalance).ToString(CultureInfo.InvariantCulture).Replace('.', ','));//nadpłata powyżej granicy błędu
							else if (validator.IsAcceptableOverPayment) //czyli mamy nadplate w granicy bledu
							{
								prepaidVt.NetValue = -vtNetValue;
								prepaidVt.GrossValue = -vtGrossValue;
								prepaidVt.VatValue = -vtVatValue;
							}
						}
					}
				}
				else
					throw new ClientException(ClientExceptionId.UnableToCreateSettlementDocument3);

				decimal netValue = 0;
				decimal grossValue = 0;
				decimal vatValue = 0;

				foreach (var vt in destination.VatTableEntries)
				{
					netValue += vt.NetValue;
					grossValue += vt.GrossValue;
					vatValue += vt.VatValue;
				}

				destination.NetValue = netValue;
				destination.GrossValue = grossValue;
				destination.VatValue = vatValue;

				destination.DisableLinesChange = DisableDocumentChangeReason.LINES_SETTLEMENT_INVOICE;

				if (!isSimulated)
				{
					var attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_IsSettlementDocument);
					attr.Value.Value = "1";
				}
			}
			else //1) wystawiamy zaliczke
			{
				foreach (XElement itemXml in xml.Root.Elements("item"))
				{
					CommercialDocumentLine line = destination.Lines.CreateNew();
					line.ItemId = new Guid(itemXml.Attribute("id").Value);
					Guid vatRateId = new Guid(itemXml.Attribute("vatRateId").Value);

					if (itemXml.Attribute("code") != null)
						line.ItemCode = itemXml.Attribute("code").Value;

					line.UnitId = new Guid(itemXml.Attribute("unitId").Value);
					line.VatRateId = vatRateId;
					line.ItemVersion = new Guid(itemXml.Attribute("version").Value);
					line.Quantity = 1;
					line.ItemName = itemXml.Attribute("name").Value;
				}

				destination.Calculate();
			}
		}

		/// <summary>
		/// Zwraca listę idków ZSP, które są zapisane w xmlu source
		/// </summary>
		/// <param name="source">Source przekazywany przy tworzeniu dokumentu z innego dokumentu/ów</param>
		/// <returns>Lista id zamówień sprzedażowych</returns>
		public static List<Guid> ExtractSourceSalesOrdersIds(XElement source)
		{
			List<Guid> sourceDocumentsIds = new List<Guid>();
			if (source.Attribute(XmlName.CommercialDocumentId) != null)
			{
				sourceDocumentsIds.Add(new Guid(source.Attribute(XmlName.CommercialDocumentId).Value));
			}
			else if (source.Element(XmlName.SalesOrderId) != null)
			{
				foreach (XElement guidElem in source.Elements(XmlName.SalesOrderId))
				{
					sourceDocumentsIds.Add(new Guid(guidElem.Value));
				}
			}
			return sourceDocumentsIds;
		}

		private static void CopyLinesFromSalesOrder(CommercialDocument salesOrder, CommercialDocument destination, 
			bool onlyLeftQuantities, bool throwExceptionOnNoLinesToCopy, bool isSalesOrderRealization, bool costPositionOnly)
		{
			List<Guid> items = new List<Guid>();

			foreach (var srcLine in salesOrder.Lines)
			{
				var attr = srcLine.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];
                if (costPositionOnly)
                {
				    if (attr.Value.Value == "2" || attr.Value.Value == "4") //pozycje kosztowe pomijamy
					    continue;
                }
                else
                {
                    DictionaryMapper mapper = DependencyContainerManager.Container.Get<DictionaryMapper>();
                    
                    if (!(attr.Value.Value == "1" && mapper.GetItemType(new Guid(srcLine.ItemTypeId)).Name == "Service")) //pozycje niekosztowe pomijamy
                        continue;
                }
				decimal quantity = srcLine.Quantity;

				if (onlyLeftQuantities)
					quantity -= srcLine.CommercialWarehouseRelations.Sum(r => r.Quantity);

				if (quantity == 0)
					continue;

				items.Add(srcLine.ItemId);

				var dstLine = destination.Lines.CreateNew();
				dstLine.Tag = srcLine.Id.ToUpperString();
                if (costPositionOnly)
                {
                    dstLine.DiscountGrossValue = srcLine.DiscountGrossValue;
                    dstLine.DiscountNetValue = srcLine.DiscountNetValue;
                    dstLine.DiscountRate = srcLine.DiscountRate;
                    dstLine.GrossPrice = srcLine.GrossPrice;
                    dstLine.GrossValue = srcLine.GrossValue;
                    dstLine.InitialGrossPrice = srcLine.InitialGrossPrice;
                    dstLine.InitialGrossValue = srcLine.InitialGrossValue;
                    dstLine.InitialNetPrice = srcLine.InitialNetPrice;
                    dstLine.InitialNetValue = srcLine.InitialNetValue;
                    dstLine.VatRateId = srcLine.VatRateId;
                    dstLine.VatValue = srcLine.VatValue;
                    dstLine.NetPrice = srcLine.NetPrice;
                    dstLine.NetValue = srcLine.NetValue;
                }
                else
                {
                    dstLine.DiscountGrossValue = 0;
                    dstLine.DiscountNetValue = 0;
                    dstLine.DiscountRate = 0;
                    dstLine.GrossPrice = 0;
                    dstLine.GrossValue = 0;
                    dstLine.InitialGrossPrice = 0;
                    dstLine.InitialGrossValue = 0;
                    dstLine.InitialNetPrice = 0;
                    dstLine.InitialNetValue = 0;
                    dstLine.VatRateId = srcLine.VatRateId;
                    dstLine.VatValue = 0;
                    dstLine.NetPrice = 0;
                    dstLine.NetValue = 0;
                    // isSalesOrderRealization = false;
                }

				dstLine.ItemCode = srcLine.ItemCode;
				dstLine.ItemId = srcLine.ItemId;
				dstLine.ItemName = srcLine.ItemName;
				dstLine.ItemVersion = srcLine.ItemVersion;
				dstLine.Quantity = quantity;
				dstLine.UnitId = srcLine.UnitId;
				dstLine.ItemTypeId = srcLine.ItemTypeId;
				dstLine.WarehouseId = srcLine.WarehouseId;
				dstLine.Calculate(dstLine.Quantity, dstLine.InitialNetPrice, dstLine.DiscountRate, dstLine.InitialGrossPrice);
				CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);
			}

			destination.Calculate();

			XDocument xml = new XDocument(new XElement("root"));

			if (items.Count == 0 && throwExceptionOnNoLinesToCopy)
				throw new ClientException(ClientExceptionId.UnableToRealizeSalesOrder3);
			else if (items.Count > 0)
				xml = DependencyContainerManager.Container.Get<DocumentMapper>().GetItemsForDocument(items);

			foreach (var line in destination.Lines)
			{
				XElement item = xml.Root.Elements().Where(x => x.Attribute("id").Value == line.ItemId.ToUpperString()).FirstOrDefault();

				if (item != null)
					line.ItemVersion = new Guid(item.Attribute("version").Value);
			}
		}

        private static void CopyLinesToSalesOrder(CommercialDocument salesOrder, CommercialDocument destination)
        {
            List<Guid> items = new List<Guid>();

            foreach (var srcLine in salesOrder.Lines)
            {
                items.Add(srcLine.ItemId);

                var dstLine = destination.Lines.CreateNew();
                dstLine.Tag = srcLine.Id.ToUpperString();
                dstLine.DiscountGrossValue = srcLine.DiscountGrossValue;
                dstLine.DiscountNetValue = srcLine.DiscountNetValue;
                dstLine.DiscountRate = srcLine.DiscountRate;
                dstLine.GrossPrice = srcLine.GrossPrice;
                dstLine.GrossValue = srcLine.GrossValue;
                dstLine.InitialGrossPrice = srcLine.InitialGrossPrice;
                dstLine.InitialGrossValue = srcLine.InitialGrossValue;
                dstLine.InitialNetPrice = srcLine.InitialNetPrice;
                dstLine.InitialNetValue = srcLine.InitialNetValue;
                dstLine.ItemCode = srcLine.ItemCode;
                dstLine.ItemId = srcLine.ItemId;
                dstLine.ItemName = srcLine.ItemName;
                dstLine.ItemVersion = srcLine.ItemVersion;
                dstLine.NetPrice = srcLine.NetPrice;
                dstLine.NetValue = srcLine.NetValue;
                dstLine.Quantity = srcLine.Quantity;
                dstLine.UnitId = srcLine.UnitId;
                dstLine.VatRateId = srcLine.VatRateId;
                dstLine.VatValue = srcLine.VatValue;
                dstLine.ItemTypeId = srcLine.ItemTypeId;
                dstLine.WarehouseId = srcLine.WarehouseId;
                dstLine.Calculate(dstLine.Quantity, dstLine.InitialNetPrice, dstLine.DiscountRate, dstLine.InitialGrossPrice);
                //CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);
            }

            destination.Calculate();

            XDocument xml = new XDocument(new XElement("root"));

            foreach (var line in destination.Lines)
            {
                XElement item = xml.Root.Elements().Where(x => x.Attribute("id").Value == line.ItemId.ToUpperString()).FirstOrDefault();

                if (item != null)
                    line.ItemVersion = new Guid(item.Attribute("version").Value);
            }
        }



	}
}
