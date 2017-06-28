using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
	internal static class CommercialDocumentFactory
	{
		public static void GeneratePurchaseDocumentFromExternalDocument(XElement source, CommercialDocument destination)
		{
			XElement sourceXml = source.Element("root").Element("commercialDocument");

			DocumentAttrValue attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_SupplierDocumentNumber);
			attr.Value.Value = sourceXml.Element("fullNumber").Value;

			attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_SupplierDocumentDate);
			attr.Value.Value = sourceXml.Element("issueDate").Value;
			destination.NetValue = Convert.ToDecimal(sourceXml.Element("netValue").Value, CultureInfo.InvariantCulture);
			destination.GrossValue = Convert.ToDecimal(sourceXml.Element("grossValue").Value, CultureInfo.InvariantCulture);
			destination.VatValue = Convert.ToDecimal(sourceXml.Element("vatValue").Value, CultureInfo.InvariantCulture);

			ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();

			if (sourceXml.Element("issuer") != null && sourceXml.Element("issuer").Element("nip") != null)
			{
				Contractor issuer = contractorMapper.GetContractorByNip(sourceXml.Element("issuer").Element("nip").Value);

				if (issuer != null)
					destination.Contractor = issuer;
			}

			#region przetwarzamy linie dokumentu
			XDocument itemMappingXml = new XDocument(new XElement("root"));

			foreach (XElement line in sourceXml.Element("lines").Elements())
			{
				XElement item = new XElement("item");

				if (line.Element("manufacturer") != null)
					item.Add(new XAttribute("manufacturer", line.Element("manufacturer").Value));

				if (line.Element("manufacturerCode") != null)
					item.Add(new XAttribute("manufacturerCode", line.Element("manufacturerCode").Value));

				if (item.HasAttributes)
					itemMappingXml.Root.Add(item);
			}

			ItemMapper itemMapper = DependencyContainerManager.Container.Get<ItemMapper>();
			itemMappingXml = itemMapper.GetItemsByNamufacturerAndCode(itemMappingXml);

			foreach (XElement line in sourceXml.Element("lines").Elements())
			{
				XElement item = null;

				if (line.Element("manufacturer") != null || line.Element("manufacturerCode") != null)
				{
					var query = itemMappingXml.Root.Elements();

					if (line.Element("manufacturer") != null)
						query = query.Where(i => i.Attribute("manufacturer") != null && i.Attribute("manufacturer").Value == line.Element("manufacturer").Value);

					if (line.Element("manufacturerCode") != null)
						query = query.Where(i => i.Attribute("manufacturerCode") != null && i.Attribute("manufacturerCode").Value == line.Element("manufacturerCode").Value);

					item = query.FirstOrDefault();
				}

				Unit unit = DictionaryMapper.Instance.GetUnit(line.Element("unit").Value);

				if (unit == null)
				{
					//wybieramy domyslna dla towaru jezeli ma kod producenta i producenta
					if (item != null)
						unit = DictionaryMapper.Instance.GetUnit(new Guid(item.Attribute("unitId").Value));

					//wybieramy szt. jako domyslna
					if (unit == null)
						unit = DictionaryMapper.Instance.GetUnit("szt.");

					if (unit == null)
						unit = DictionaryMapper.Instance.GetUnit("szt");
				}

				VatRate vatRate = DictionaryMapper.Instance.GetVatRate(line.Element("vatRate").Value);

				if (vatRate == null)
					throw new ClientException(ClientExceptionId.NoSpecifiedVatRate, null, "symbol:" + line.Element("vatRate").Value);

				CommercialDocumentLine comLine = destination.Lines.CreateNew();
				comLine.UnitId = unit.Id.Value;
				comLine.VatRateId = vatRate.Id.Value;

				if (item != null)
				{
					comLine.ItemId = new Guid(item.Attribute("id").Value);
					comLine.ItemName = item.Attribute("name").Value;
					comLine.ItemVersion = new Guid(item.Attribute("version").Value);

					if (item.Attribute("code") != null)
						comLine.ItemCode = item.Attribute("code").Value;
				}

				comLine.NetPrice = Convert.ToDecimal(line.Element("netPrice").Value, CultureInfo.InvariantCulture);
				comLine.GrossPrice = Convert.ToDecimal(line.Element("grossPrice").Value, CultureInfo.InvariantCulture);
				comLine.NetValue = Convert.ToDecimal(line.Element("netValue").Value, CultureInfo.InvariantCulture);
				comLine.GrossValue = Convert.ToDecimal(line.Element("grossValue").Value, CultureInfo.InvariantCulture);
				comLine.VatValue = Convert.ToDecimal(line.Element("vatValue").Value, CultureInfo.InvariantCulture);

				comLine.InitialGrossPrice = comLine.GrossPrice;
				comLine.InitialGrossValue = comLine.GrossValue;
				comLine.InitialNetPrice = comLine.NetPrice;
				comLine.InitialNetValue = comLine.NetValue;
			}
			#endregion

			#region paymenty
			foreach (XElement payment in sourceXml.Element("payments").Elements())
			{
				Payment pt = destination.Payments.CreateNew();
				pt.Date = DateTime.Parse(payment.Element("date").Value, CultureInfo.InvariantCulture);
				pt.DueDate = DateTime.Parse(payment.Element("dueDate").Value, CultureInfo.InvariantCulture);

				PaymentMethod pm = DictionaryMapper.Instance.GetPaymentMethod(payment.Element("paymentMethod").Value);

				if (pm == null)
					throw new ClientException(ClientExceptionId.NoSpecifiedPaymentMethod, null, "label:" + payment.Element("paymentMethod").Value);

				pt.PaymentMethodId = pm.Id.Value;
				pt.Amount = Convert.ToDecimal(payment.Element("amount").Value, CultureInfo.InvariantCulture);

				Currency currency = DictionaryMapper.Instance.GetCurrency(payment.Element("currency").Value);

				if (currency == null)
					throw new ClientException(ClientExceptionId.NoSpecifiedCurrency, null, "symbol:" + payment.Element("currency").Value);

				pt.PaymentCurrencyId = currency.Id.Value;

				if (payment.Element("contractor") != null)
				{
					if (payment.Element("contractor").Element("fullName").Value == destination.Contractor.FullName)
						pt.Contractor = destination.Contractor;
					else if (payment.Element("contractor").Element("nip") != null)
					{
						Contractor contractor = contractorMapper.GetContractorByNip(payment.Element("contractor").Element("nip").Value);

						if (contractor != null)
							pt.Contractor = contractor;
					}
				}
			}
			#endregion

			#region vat table
			foreach (XElement vtEntry in sourceXml.Element("vatTable").Elements())
			{
				VatRate vr = DictionaryMapper.Instance.GetVatRate(vtEntry.Element("vatRate").Value);

				if (vr == null)
					throw new ClientException(ClientExceptionId.NoSpecifiedVatRate, null, "symbol:" + vtEntry.Element("vatRate").Value);

				var vt = destination.VatTableEntries.CreateNew();
				vt.VatRateId = vr.Id.Value;
				vt.NetValue = Convert.ToDecimal(vtEntry.Element("netValue").Value, CultureInfo.InvariantCulture);
				vt.GrossValue = Convert.ToDecimal(vtEntry.Element("grossValue").Value, CultureInfo.InvariantCulture);
				vt.VatValue = Convert.ToDecimal(vtEntry.Element("vatValue").Value, CultureInfo.InvariantCulture);
			}
			#endregion
		}

        public static void CreateStackCommercialDocumentFromMultipleReservations(CommercialDocument destination, XElement source)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

            List<CommercialDocument> whDocs = new List<CommercialDocument>();
            List<Guid> itemsId = new List<Guid>();

            foreach (XElement whId in source.Elements("reservationId"))
            {
                Guid docId = new Guid(whId.Value);

                var exists = whDocs.Where(d => d.Id.Value == docId).FirstOrDefault();

                if (exists != null)
                    continue;

                CommercialDocument doc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);
                whDocs.Add(doc);

               // CommercialWarehouseDocumentFactory.CheckIfWarehouseDocumentHasSalesOrderWithPrepaids(doc);

                foreach (CommercialDocumentLine line in doc.Lines.Children)
                {
                    if (!itemsId.Contains(line.ItemId))
                        itemsId.Add(line.ItemId);
                }
            }

            //sprawdzamy czy dok. zrodlowe maja wspolnego kontrahenta. jezeli tak to kopiujemy go na fakture
            bool copyContractor = true;

            //jezeli gdzies nie ma kontrahenta to nie kopiujemy
            var emptyContractor = whDocs.Where(w => w.Contractor == null).FirstOrDefault();

            if (emptyContractor != null)
                copyContractor = false;

            if (copyContractor)
            {
                var differentContractor = whDocs.Where(ww => ww.Contractor.Id.Value != whDocs[0].Contractor.Id.Value).FirstOrDefault();

                if (differentContractor != null)
                    copyContractor = false;
            }

            if (copyContractor)
            {
                destination.Contractor = whDocs[0].Contractor;

                if (destination.Contractor != null)
                {
                    var address = destination.Contractor.Addresses.GetBillingAddress();

                    if (address != null)
                        destination.ContractorAddressId = address.Id.Value;
                }
            }

            //kopiujemy atrybuty jezeli sa jakies takie
            DuplicableAttributeFactory.DuplicateAttributes(whDocs, destination);

            XDocument xml = mapper.GetItemsForDocument(itemsId);

            //sprawdzamy czy jakis wz/pz zrodlowy ma powiazanie z zamowieniem/rezerwacja
            XDocument orderLines = XDocument.Parse("<root/>");
            Dictionary<Guid, Guid> whLineOrderLine = new Dictionary<Guid, Guid>();


            foreach (CommercialDocument whDoc in whDocs)
            {



                //GetLineMappingForWarehouseDocument
                foreach (CommercialDocumentLine line in whDoc.Lines.Children)
                {
                    foreach (var relation in line.CommercialWarehouseRelations.Children)
                    {
                        if (relation.IsOrderRelation)
                        {
                            orderLines.Root.Add(new XElement("id", relation.RelatedLine.Id.ToUpperString()));
                            whLineOrderLine.Add(line.Id.Value, relation.RelatedLine.Id.Value);
                        }
                    }
                }
            }

            orderLines = DependencyContainerManager.Container.Get<DocumentMapper>().GetCommercialDocumentLinesXml(orderLines);

            //sposob liczenia przenosimy od pierwszego z gory dokumentu
            CalculationType ct = destination.CalculationType;

            if (orderLines != null
                && orderLines.Root.Element("commercialDocumentLine") != null
                && orderLines.Root.Element("commercialDocumentLine").Element("entry") != null
                && orderLines.Root.Element("commercialDocumentLine").Element("entry").Element("netCalculationType") != null)
                ct = (CalculationType)Enum.Parse(typeof(CalculationType), orderLines.Root.Element("commercialDocumentLine").Element("entry").Element("netCalculationType").Value);

            if (destination.CalculationType != ct && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
                destination.CalculationType = ct;

            //tworzenie linii
            foreach (CommercialDocument whDoc in whDocs)
            {
                //Pobieram mapowania towarów
                XDocument mapPat = mapper.GetLineMappingForCommercialDocument(whDoc);

                foreach (CommercialDocumentLine whLine in whDoc.Lines.Children)
                {
                    decimal quantityNotRelated;
                    //Warunek na podpięcie salesOrder
                    if (destination.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
                    {
                        quantityNotRelated = whLine.Quantity - whLine.CommercialWarehouseRelations.Children.Sum(s => s.IsOrderRelation ? s.Quantity : 0);
                    }
                    else
                    {
                        quantityNotRelated = whLine.Quantity - whLine.CommercialWarehouseRelations.Children.Sum(s => s.IsCommercialRelation ? s.Quantity : 0);
                    }


                    if (quantityNotRelated == 0)
                        continue;

                    IEnumerable<XElement> item = from el in mapPat.Elements("lines").Elements("line")
                                                 where (Guid)el.Element("id") == whLine.Id
                                                 select el;
                    CommercialDocumentLine comLine = null;
                    bool newLine = true;
                    foreach (CommercialDocumentLine l in destination.Lines)
                    {
                        if (l.ItemId == new Guid(item.FirstOrDefault().Element("itemId").Value))
                        {
                            comLine = l;
                            newLine = false;
                        }
                    }
                    if (newLine)
                    {
                        comLine = destination.Lines.CreateNew();
                    }


                    comLine.ItemId = new Guid(item.FirstOrDefault().Element("itemId").Value); //whLine.ItemId;
                    comLine.ItemName = item.FirstOrDefault().Element("itemName").Value;//whLine.ItemName;
                    comLine.ItemCode = item.FirstOrDefault().Element("itemCode").Value;

                    comLine.UnitId = new Guid(item.FirstOrDefault().Element("unitId").Value); //whLine.UnitId;
                    comLine.WarehouseId = whLine.WarehouseId;
                   // comLine.NetPrice = whLine.Price;
                    comLine.VatRateId = new Guid(item.FirstOrDefault().Element("vatRateId").Value);
                    comLine.ItemVersion = new Guid(item.FirstOrDefault().Element("version").Value);
                    comLine.InitialNetPrice = Convert.ToDecimal(item.FirstOrDefault().Element("defaultPrice").Value, CultureInfo.InvariantCulture);
                    comLine.NetPrice = comLine.InitialNetPrice;// comLine.InitialNetPrice;

                    if (!newLine)
                    {
                        comLine.Quantity = comLine.Quantity + quantityNotRelated;
                    }
                    else
                    {
                        comLine.Quantity = quantityNotRelated;
                    }

                    CommercialWarehouseRelation rel = comLine.CommercialWarehouseRelations.CreateNew();
                    rel.Quantity = quantityNotRelated;
                    rel.RelatedLine = whLine;
                    //Warunek na podpięcie salesOrder
                    if (destination.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
                    {
                        rel.IsOrderRelation = true;
                    }
                    else
                    {
                        rel.IsCommercialRelation = true;
                    }

                    if (comLine.InitialNetPrice == 0 && comLine.NetPrice != 0)
                        comLine.InitialNetPrice = comLine.NetPrice;

                    if (comLine.InitialNetPrice != 0)
                        comLine.Calculate(comLine.Quantity, comLine.InitialNetPrice, Decimal.Round(100 * (1 - comLine.NetPrice / comLine.InitialNetPrice), 4, MidpointRounding.AwayFromZero));
                }
            }

            destination.Calculate();
        }
  

		public static void GenerateInvoiceFromMultipleReservations(XElement source, CommercialDocument destination)
		{
			/*
				<source type="multipleReservations">
				  <reservationId>{documentId}</reservationId>
				  <reservationId>{documentId}</reservationId>
				  <reservationId>{documentId}</reservationId>
				  .........
				</source>
			 */

			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			List<CommercialDocument> reservations = new List<CommercialDocument>();

			CalculationType? calcType = null;

			foreach (XElement soId in source.Elements("reservationId"))
			{
				Guid docId = new Guid(soId.Value);

				var exists = reservations.Where(d => d.Id.Value == docId).FirstOrDefault();

				if (exists != null)
					continue;

				CommercialDocument doc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);
				reservations.Add(doc);

				if (doc.DocumentStatus == DocumentStatus.Canceled)
					throw new ClientException(ClientExceptionId.CreateNewDocumentFromCanceledDocument);

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
			var emptyContractor = reservations.Where(w => w.Contractor == null).FirstOrDefault();

			if (emptyContractor != null)
				copyContractor = false;

			if (copyContractor)
			{
				var differentContractor = reservations.Where(ww => ww.Contractor.Id.Value != reservations[0].Contractor.Id.Value).FirstOrDefault();

				if (differentContractor != null)
					copyContractor = false;
			}

			//Kontrahenta nie kopiujemy gdy jest 
			if (copyContractor && destination.DocumentType.CommercialDocumentOptions.ContractorOptionality == Optionality.Forbidden)
			{
				copyContractor = false;
			}

			if (copyContractor)
			{
				destination.Contractor = reservations[0].Contractor;

				if (destination.Contractor != null)
				{
					var address = destination.Contractor.Addresses.GetBillingAddress();

					if (address != null)
						destination.ContractorAddressId = address.Id.Value;
				}
			}

			//kopiujemy atrybuty jezeli sa jakies takie
			DuplicableAttributeFactory.DuplicateAttributes(reservations, destination);

			foreach (CommercialDocument reservation in reservations)
			{
				foreach (CommercialDocumentLine resLine in reservation.Lines)
				{
                    //uznajemy  ze dokument magazynowy może być realizacją Zamówienia jednak nie powinien blokować ponownej realizacji za pomocą faktury
                    decimal unrealizedQty = resLine.Quantity - resLine.CommercialWarehouseRelations.Where(r => r.IsOrderRelation && r.RelatedLine.BOType != Makolab.Fractus.Kernel.Enums.BusinessObjectType.WarehouseDocumentLine).Sum(s => s.Quantity);

					if (unrealizedQty > 0)
					{
						var line = destination.Lines.CreateNew();
						line.ItemId = resLine.ItemId;
						line.ItemCode = resLine.ItemCode;
						line.ItemName = resLine.ItemName;
						line.ItemTypeId = resLine.ItemTypeId;
						line.UnitId = resLine.UnitId;
						line.VatRateId = resLine.VatRateId;
						line.WarehouseId = resLine.WarehouseId;
                        //Dodałem przepisywanie ceny
                        line.InitialGrossPrice = resLine.InitialGrossPrice;
                        line.InitialGrossValue = resLine.InitialGrossValue;
                        line.InitialNetPrice = resLine.InitialNetPrice;
                        line.InitialNetValue = resLine.InitialNetValue;
                        line.NetPrice = resLine.NetPrice;
                        line.NetValue = resLine.NetValue;
                        line.GrossPrice = resLine.GrossPrice;
                        line.GrossValue = resLine.GrossValue;
                        line.DiscountGrossValue = resLine.DiscountGrossValue;
						line.Calculate(unrealizedQty, resLine.InitialNetPrice, resLine.DiscountRate, resLine.InitialGrossPrice);
					}
				}
			}

			destination.Calculate();

			//robimy liste itemId i odczytujemy ich aktualne wersje

			List<Guid> itemsId = new List<Guid>();

			foreach (var comLine in destination.Lines) itemsId.Add(comLine.ItemId);

			XDocument xml = mapper.GetItemsForDocument(itemsId);

			foreach (XElement itemXml in xml.Root.Elements())
			{
				foreach (var line in destination.Lines.Where(l => l.ItemId == new Guid(itemXml.Attribute("id").Value)))
				{
					line.ItemVersion = new Guid(itemXml.Attribute("version").Value);
				}
			}

			//w tagu zostawiamy wersje rezerwacji wszystkich zeby przy zapisie sprawdzic czy sie nie zmienily
			string versions = String.Empty;

			foreach (var r in reservations)
			{
				if (versions.Length != 0)
					versions += ",";

				versions += r.Version.ToUpperString();
			}

			destination.Tag = versions;
		}

		public static void GenerateSalesDocumentFromSimulatedInvoice(XElement source, CommercialDocument destination)
        {
            CommercialDocument sourceDocument = CommercialDocumentFactory.GenerateSalesDocumentFromCommercialDocument(source, destination);
			if (sourceDocument.IsRelatedWithSalesOrder)
			{
				throw new ClientException(ClientExceptionId.SalesDocumentFromSimulatedInvoiceRelatedWithSalesOrderForbidden);
			}
            destination.ReceivingPerson = sourceDocument.ReceivingPerson;
            destination.Tag = sourceDocument.Version.ToUpperString();
            var relation = destination.Relations.CreateNew();
            relation.RelationType = DocumentRelationType.SalesDocumentToSimulatedInvoice;
            relation.RelatedDocument = sourceDocument;
        }

		public static void GenerateReservationFromOrderDbXml(XElement source, CommercialDocument destination)
		{
			ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();

			XElement dbXml = source.Element("root");

			if (dbXml.Element("commercialDocumentHeader").Element("entry").Element("contractorId") != null)
			{
				Contractor contractor = (Contractor)contractorMapper.LoadBusinessObject(BusinessObjectType.Contractor, new Guid(dbXml.Element("commercialDocumentHeader").Element("entry").Element("contractorId").Value));
				destination.Contractor = contractor;

				if (dbXml.Element("commercialDocumentHeader").Element("entry").Element("contractorAddressId") != null)
					destination.ContractorAddressId = new Guid(dbXml.Element("commercialDocumentHeader").Element("entry").Element("contractorAddressId").Value);
			}

			CalculationType sourceCt = (CalculationType)Convert.ToInt32(dbXml.Element("commercialDocumentHeader").Element("entry").Element("netCalculationType").Value, CultureInfo.InvariantCulture);

			if (sourceCt != destination.CalculationType && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
				destination.CalculationType = sourceCt;

			//tworzymy atrybuty
			var attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_OppositeDocumentId);
			attr.Value.Value = dbXml.Element("commercialDocumentHeader").Element("entry").Element("id").Value;

			attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_OrderNumber);
			attr.Value.Value = dbXml.Element("commercialDocumentHeader").Element("entry").Element("fullNumber").Value;

			attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_OrderIssueDate);
			attr.Value.Value = dbXml.Element("commercialDocumentHeader").Element("entry").Element("issueDate").Value.Substring(0, 10);

			attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_TargetBranchId);
			//string targetBranchDfId = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.Attribute_TargetBranchId).Id.ToUpperString();
			string targetBranchId = dbXml.Element("commercialDocumentHeader").Element("entry").Element("branchId").Value; //id oddzialu dok przeciwnego bierzemy z naglowka
			attr.Value.Value = targetBranchId;

			if (destination.DocumentType.CommercialDocumentOptions.IsShiftOrder)
			{
				//biezemy pierwszy z brzegu magazyn z linii i wpisujemy go jako targetBranchId dla pozniejszych MM-
				attr = destination.Attributes.CreateNew(DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId);
				attr.Value.Value = dbXml.Element("commercialDocumentLine").Element("entry").Element("warehouseId").Value;
			}

			attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_OrderStatus);
			attr.Value.Value = "0";

			//wybieramy pierwszy z brzegu warehouseId
			Guid warehouseId = DictionaryMapper.Instance.GetFirstWarehouseByBranchId(SessionManager.User.BranchId).Id.Value;

			//tworzymy linie
			foreach (var lineXml in dbXml.Element("commercialDocumentLine").Elements()
				.OrderBy(l => l.Element("ordinalNumber") != null ? Convert.ToInt32(l.Element("ordinalNumber").Value) : 0))
			{
				var line = destination.Lines.CreateNew();
				line.ItemId = new Guid(lineXml.Element("itemId").Value);
				line.ItemName = lineXml.Element("itemName").Value;
				line.ItemVersion = new Guid(lineXml.Element("itemVersion").Value);
				line.UnitId = new Guid(lineXml.Element("unitId").Value);
				line.WarehouseId = warehouseId;
				line.Quantity = Convert.ToDecimal(lineXml.Element("quantity").Value, CultureInfo.InvariantCulture);
				line.NetPrice = Convert.ToDecimal(lineXml.Element("netPrice").Value, CultureInfo.InvariantCulture);
				line.GrossPrice = Convert.ToDecimal(lineXml.Element("grossPrice").Value, CultureInfo.InvariantCulture);
				line.InitialNetPrice = Convert.ToDecimal(lineXml.Element("initialNetPrice").Value, CultureInfo.InvariantCulture);
				line.InitialGrossPrice = Convert.ToDecimal(lineXml.Element("initialGrossPrice").Value, CultureInfo.InvariantCulture);
				line.DiscountRate = Convert.ToDecimal(lineXml.Element("discountRate").Value, CultureInfo.InvariantCulture);
				line.DiscountNetValue = Convert.ToDecimal(lineXml.Element("discountNetValue").Value, CultureInfo.InvariantCulture);
				line.DiscountGrossValue = Convert.ToDecimal(lineXml.Element("discountGrossValue").Value, CultureInfo.InvariantCulture);
				line.InitialNetValue = Convert.ToDecimal(lineXml.Element("initialNetValue").Value, CultureInfo.InvariantCulture);
				line.InitialGrossValue = Convert.ToDecimal(lineXml.Element("initialGrossValue").Value, CultureInfo.InvariantCulture);
				line.NetValue = Convert.ToDecimal(lineXml.Element("netValue").Value, CultureInfo.InvariantCulture);
				line.GrossValue = Convert.ToDecimal(lineXml.Element("grossValue").Value, CultureInfo.InvariantCulture);
				line.VatValue = Convert.ToDecimal(lineXml.Element("vatValue").Value, CultureInfo.InvariantCulture);
				line.VatRateId = new Guid(lineXml.Element("vatRateId").Value);
				line.Calculate(line.Quantity, line.InitialNetPrice, line.DiscountRate, line.InitialGrossPrice);
			}

			destination.Calculate();
		}

		public static CommercialDocument GenerateSalesDocumentFromCommercialDocument(XElement source, CommercialDocument destination)
		{
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
            Guid documentId ;
            if (source.Attribute("commercialDocumentId") != null)
            {
                documentId  = new Guid(source.Attribute("commercialDocumentId").Value);
            }
            else
            {
                documentId = new Guid(source.Element("salesDocumentId").Value);
            }

			CommercialDocument sourceDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, documentId);

			if (sourceDocument.DocumentStatus == DocumentStatus.Canceled)
				throw new ClientException(ClientExceptionId.CreateNewDocumentFromCanceledDocument);

			bool copyContractor = false;
			DocumentCategory destDocCat = destination.DocumentType.DocumentCategory;
			Optionality destContractorOptionality = destination.DocumentType.CommercialDocumentOptions.ContractorOptionality;

			if (sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Reservation)
			{
				if (destDocCat == DocumentCategory.Sales || destDocCat == DocumentCategory.SalesCorrection)
				{
					copyContractor = true;
				}
			}
			else if (sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Order)
			{
				if (destDocCat == DocumentCategory.Purchase || destDocCat == DocumentCategory.PurchaseCorrection)
					copyContractor = true;
			}
			else //np. proforma
				copyContractor = true;

			//jeśli na docelowym dokumencie nie może być kontrahenta to go nie kopiujemy
			if (destContractorOptionality == Optionality.Forbidden)
			{
				copyContractor = false;
			}

			if (sourceDocument.CalculationType != destination.CalculationType && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
				destination.CalculationType = sourceDocument.CalculationType;

			if (copyContractor)
			{
				if (sourceDocument.Contractor != null)
					destination.Contractor = (Contractor)sourceDocument.Contractor;

				if (sourceDocument.ContractorAddressId != null)
					destination.ContractorAddressId = sourceDocument.ContractorAddressId;
			}

			if (sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Reservation || 
				sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Order)
			{
				if (destDocCat == DocumentCategory.Sales || destDocCat == DocumentCategory.SalesCorrection)
				{
					destination.ExchangeDate = sourceDocument.ExchangeDate;
					destination.ExchangeRate = sourceDocument.ExchangeRate;
					destination.ExchangeScale = sourceDocument.ExchangeScale;
				}
			}

			destination.DocumentCurrencyId = sourceDocument.DocumentCurrencyId;

			DuplicableAttributeFactory.DuplicateAttributes(sourceDocument, destination);

			bool isSalesOrderRealization = source.CheckType(SourceType.SalesOrderRealization);

			if (sourceDocument.DocumentType.CommercialDocumentOptions.SimulatedInvoice != null)
			{
				foreach (var srcLine in sourceDocument.Lines)
				{
					CommercialDocumentLine dstLine = destination.Lines.CreateNew();
					CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, srcLine.Quantity);
					CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);
				}
			}
			else
			{
				if (source.HasElements) //realizuje konkretne pozycje zamówienia z sourca (nie wiem czy coś jeszcze tego używa)
				{
					foreach (XElement line in source.Elements())
					{
						Guid lineId = new Guid(line.Attribute("id").Value);
						decimal quantity = Convert.ToDecimal(line.Attribute("quantity").Value, CultureInfo.InvariantCulture);
						CommercialDocumentLine srcLine = sourceDocument.Lines.Children.Where(l => l.Id == lineId).FirstOrDefault();

						var attr = srcLine.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];

						if (attr != null && (attr.Value.Value == "2" || attr.Value.Value == "4")) //pozycje kosztowe pomijamy
							continue;

						CommercialDocumentLine dstLine = destination.Lines.CreateNew();
						CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, quantity);
						CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);
					}
				}
				//Jeśli w sourcie nie ma linii to kopiowane są wszystkie pozycje. W przypadku zamówienia sprzedażowego nie kopiujemy tych linii - być może trzeba będzie tak jeszcze w innych przypadkach. TODO
				else if (!isSalesOrderRealization)
				{
					foreach (var srcLine in sourceDocument.Lines)
					{
						CommercialDocumentLine dstLine = destination.Lines.CreateNew();
						CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, srcLine.Quantity);
						CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);//to i tak nie zadziała w tym przypadku ale na razie zostawiam na wypadek gdyby się zmieniła koncepcja

						foreach (var srcAttr in srcLine.Attributes)
						{
							var dstAttr = dstLine.Attributes.CreateNew();
							dstAttr.DocumentFieldId = srcAttr.DocumentFieldId;
							dstAttr.Value = srcAttr.Value;
						}
					}
				}
			}

			destination.Calculate();

			if (sourceDocument.Payments != null && sourceDocument.Payments.Children.Count > 0)
			{
				//generowanie paymentow
				destination.Payments.SourceDocument = sourceDocument;
				decimal amountOnPayments = sourceDocument.Payments.Children.Sum(s => s.Amount);

				if (amountOnPayments == destination.GrossValue) //kopiujemy 1:1 paymenty
				{
					foreach (Payment srcPt in sourceDocument.Payments.Children)
					{
						Payment pt = destination.Payments.CreateNew();
						pt.Amount = srcPt.Amount;
						pt.PaymentMethodId = srcPt.PaymentMethodId;
						pt.LoadPaymentMethodDefaults();
					}
				}
				else
				{
					bool first = true;

					foreach (Payment srcPt in sourceDocument.Payments.Children)
					{
						Payment pt = destination.Payments.CreateNew();

						if (first)
						{
							pt.Amount = destination.GrossValue;
							first = false;
						}

						pt.PaymentMethodId = srcPt.PaymentMethodId;
						pt.LoadPaymentMethodDefaults();
					}
				}
			}

			return sourceDocument;
		}
        public static CommercialDocument GenerateProductionOrderForMaterialFromCommercialDocument(XElement source, CommercialDocument destination)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
            Guid documentId;
            documentId = new Guid(source.Attribute("commercialDocumentId").Value);

            CommercialDocument sourceDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, documentId);

            if (sourceDocument.DocumentStatus == DocumentStatus.Canceled)
                throw new ClientException(ClientExceptionId.CreateNewDocumentFromCanceledDocument);

            DocumentCategory destDocCat = destination.DocumentType.DocumentCategory;


            if (sourceDocument.CalculationType != destination.CalculationType && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
                destination.CalculationType = sourceDocument.CalculationType;


            if (sourceDocument.Contractor != null)
                destination.Contractor = (Contractor)sourceDocument.Contractor;

            if (sourceDocument.ContractorAddressId != null)
                destination.ContractorAddressId = sourceDocument.ContractorAddressId;


            //if (sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Reservation ||
            //    sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Order)
            //{
            //    if (destDocCat == DocumentCategory.Sales || destDocCat == DocumentCategory.SalesCorrection)
            //    {
            //        destination.ExchangeDate = sourceDocument.ExchangeDate;
            //        destination.ExchangeRate = sourceDocument.ExchangeRate;
            //        destination.ExchangeScale = sourceDocument.ExchangeScale;
            //    }
            //}

            destination.DocumentCurrencyId = sourceDocument.SystemCurrencyId;

            DuplicableAttributeFactory.DuplicateAttributes(sourceDocument, destination);

            bool isSalesOrderRealization = true;

            if (sourceDocument.DocumentType.CommercialDocumentOptions.SimulatedInvoice != null)
            {
                foreach (var srcLine in sourceDocument.Lines)
                {
                    CommercialDocumentLine dstLine = destination.Lines.CreateNew();
                    CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, srcLine.Quantity);
                    CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);
                }
            }
            else
            {
                if (source.HasElements) //realizuje konkretne pozycje zamówienia z sourca (nie wiem czy coś jeszcze tego używa)
                {
                    foreach (XElement line in source.Elements())
                    {
                        Guid lineId = new Guid(line.Attribute("id").Value);
                        decimal quantity = Convert.ToDecimal(line.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                        CommercialDocumentLine srcLine = sourceDocument.Lines.Children.Where(l => l.Id == lineId).FirstOrDefault();

                        var attr = srcLine.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];

                        if (attr != null && (attr.Value.Value == "2" || attr.Value.Value == "4")) //pozycje kosztowe pomijamy
                            continue;

                        CommercialDocumentLine dstLine = destination.Lines.CreateNew();
                        CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, quantity);
                        XElement techTree = mapper.ExecuteCustomProcedure("document.p_getMaterialFromTechnologyTree", XDocument.Parse("<itemId>" + srcLine.ItemId.ToString() + "</itemId>"));
                        dstLine.ItemCode = techTree.Element("code").Value;
                        dstLine.ItemId = new Guid(techTree.Element("id").Value);
                        dstLine.ItemName = techTree.Element("name").Value + " " + techTree.Element("code").Value + " - " + techTree.Element("col").Value + " - " + techTree.Element("size").Value;
                        

                        CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);

                        DocumentLineAttrValue realizeSalesOrderLineIdAttribute = dstLine.Attributes.CreateNew();
                        realizeSalesOrderLineIdAttribute.DocumentFieldName = DocumentFieldName.LineAttribute_ProductionTechnologyName;
                        XElement ex = mapper.ExecuteCustomProcedure("document.p_getTechnologyByItem", XDocument.Parse("<itemId>" + dstLine.ItemId.ToString() + "</itemId>"));
                        realizeSalesOrderLineIdAttribute.Label = ex.Element("technology").Attribute("technologyName").Value;
                        realizeSalesOrderLineIdAttribute.Value.Value = ex.Element("technology").Attribute("id").Value;

                        //<root><technology id="76253B51-C030-4557-8CE0-7DD7F99524C1" technologyName="Koszulka - 122E195 - bisquit 027 - S" /></root>
                    }
                }
                //Jeśli w sourcie nie ma linii to kopiowane są wszystkie pozycje. W przypadku zamówienia sprzedażowego nie kopiujemy tych linii - być może trzeba będzie tak jeszcze w innych przypadkach. TODO
                else if (!isSalesOrderRealization)
                {
                    foreach (var srcLine in sourceDocument.Lines)
                    {
                        CommercialDocumentLine dstLine = destination.Lines.CreateNew();
                        CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, srcLine.Quantity);
                        CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);//to i tak nie zadziała w tym przypadku ale na razie zostawiam na wypadek gdyby się zmieniła koncepcja

                        foreach (var srcAttr in srcLine.Attributes)
                        {
                            var dstAttr = dstLine.Attributes.CreateNew();
                            dstAttr.DocumentFieldId = srcAttr.DocumentFieldId;
                            dstAttr.Value = srcAttr.Value;
                        }
                    }
                }
            }






            destination.Calculate();
            //NA ZLECENIU NIE MOŻE BY PAYMENTÓW
            //if (sourceDocument.Payments != null && sourceDocument.Payments.Children.Count > 0)
            //{
            //    //generowanie paymentow
            //    destination.Payments.SourceDocument = sourceDocument;
            //    decimal amountOnPayments = sourceDocument.Payments.Children.Sum(s => s.Amount);

            //    if (amountOnPayments == destination.GrossValue) //kopiujemy 1:1 paymenty
            //    {
            //        foreach (Payment srcPt in sourceDocument.Payments.Children)
            //        {
            //            Payment pt = destination.Payments.CreateNew();
            //            pt.Amount = srcPt.Amount;
            //            pt.PaymentMethodId = srcPt.PaymentMethodId;
            //            pt.LoadPaymentMethodDefaults();
            //        }
            //    }
            //    else
            //    {
            //        bool first = true;

            //        foreach (Payment srcPt in sourceDocument.Payments.Children)
            //        {
            //            Payment pt = destination.Payments.CreateNew();

            //            if (first)
            //            {
            //                pt.Amount = destination.GrossValue;
            //                first = false;
            //            }

            //            pt.PaymentMethodId = srcPt.PaymentMethodId;
            //            pt.LoadPaymentMethodDefaults();
            //        }
            //    }
            //}

            return sourceDocument;
        }

        
        public static CommercialDocument GenerateProductionOrderFromCommercialDocument(XElement source, CommercialDocument destination)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
            Guid documentId;
            documentId = new Guid(source.Attribute("commercialDocumentId").Value);

            CommercialDocument sourceDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, documentId);

            if (sourceDocument.DocumentStatus == DocumentStatus.Canceled)
                throw new ClientException(ClientExceptionId.CreateNewDocumentFromCanceledDocument);

            DocumentCategory destDocCat = destination.DocumentType.DocumentCategory;


            if (sourceDocument.CalculationType != destination.CalculationType && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
                destination.CalculationType = sourceDocument.CalculationType;

    
            if (sourceDocument.Contractor != null)
                destination.Contractor = (Contractor)sourceDocument.Contractor;

            if (sourceDocument.ContractorAddressId != null)
                destination.ContractorAddressId = sourceDocument.ContractorAddressId;
            

            if (sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Reservation ||
                sourceDocument.DocumentType.DocumentCategory == DocumentCategory.Order)
            {
                if (destDocCat == DocumentCategory.Sales || destDocCat == DocumentCategory.SalesCorrection)
                {
                    destination.ExchangeDate = sourceDocument.ExchangeDate;
                    destination.ExchangeRate = sourceDocument.ExchangeRate;
                    destination.ExchangeScale = sourceDocument.ExchangeScale;
                }
            }

            destination.DocumentCurrencyId = sourceDocument.DocumentCurrencyId;

            DuplicableAttributeFactory.DuplicateAttributes(sourceDocument, destination);

            bool isSalesOrderRealization = true;

            if (sourceDocument.DocumentType.CommercialDocumentOptions.SimulatedInvoice != null)
            {
                foreach (var srcLine in sourceDocument.Lines)
                {
                    CommercialDocumentLine dstLine = destination.Lines.CreateNew();
                    CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, srcLine.Quantity);
                    CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);
                }
            }
            else
            {
                if (source.HasElements) //realizuje konkretne pozycje zamówienia z sourca (nie wiem czy coś jeszcze tego używa)
                {
                    foreach (XElement line in source.Elements())
                    {
                        Guid lineId = new Guid(line.Attribute("id").Value);
                        decimal quantity = Convert.ToDecimal(line.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                        CommercialDocumentLine srcLine = sourceDocument.Lines.Children.Where(l => l.Id == lineId).FirstOrDefault();

                        var attr = srcLine.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];

                        if (attr != null && (attr.Value.Value == "2" || attr.Value.Value == "4")) //pozycje kosztowe pomijamy
                            continue;

                        CommercialDocumentLine dstLine = destination.Lines.CreateNew();
                        CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, quantity);
                        CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);
 
                        DocumentLineAttrValue realizeSalesOrderLineIdAttribute = dstLine.Attributes.CreateNew();
                        realizeSalesOrderLineIdAttribute.DocumentFieldName = DocumentFieldName.LineAttribute_ProductionTechnologyName;
                        XElement ex = mapper.ExecuteCustomProcedure("document.p_getTechnologyByItem", XDocument.Parse("<itemId>" + srcLine.ItemId.ToString() + "</itemId>"));
                        realizeSalesOrderLineIdAttribute.Label = ex.Element("technology").Attribute("technologyName").Value;
                        realizeSalesOrderLineIdAttribute.Value.Value = ex.Element("technology").Attribute("id").Value;
 
//<root><technology id="76253B51-C030-4557-8CE0-7DD7F99524C1" technologyName="Koszulka - 122E195 - bisquit 027 - S" /></root>
                    }
                }
                //Jeśli w sourcie nie ma linii to kopiowane są wszystkie pozycje. W przypadku zamówienia sprzedażowego nie kopiujemy tych linii - być może trzeba będzie tak jeszcze w innych przypadkach. TODO
                else if (!isSalesOrderRealization)
                {
                    foreach (var srcLine in sourceDocument.Lines)
                    {
                        CommercialDocumentLine dstLine = destination.Lines.CreateNew();
                        CommercialDocumentFactory.CopyCommercialDocumentLineDetails(srcLine, dstLine, srcLine.Quantity);
                        CommercialDocumentFactory.TryAddRealizedSalesOrderLineId(srcLine, dstLine, isSalesOrderRealization);//to i tak nie zadziała w tym przypadku ale na razie zostawiam na wypadek gdyby się zmieniła koncepcja

                        foreach (var srcAttr in srcLine.Attributes)
                        {
                            var dstAttr = dstLine.Attributes.CreateNew();
                            dstAttr.DocumentFieldId = srcAttr.DocumentFieldId;
                            dstAttr.Value = srcAttr.Value;
                        }
                    }
                }
            }


 



            destination.Calculate();

            if (sourceDocument.Payments != null && sourceDocument.Payments.Children.Count > 0)
            {
                //generowanie paymentow
                destination.Payments.SourceDocument = sourceDocument;
                decimal amountOnPayments = sourceDocument.Payments.Children.Sum(s => s.Amount);

                if (amountOnPayments == destination.GrossValue) //kopiujemy 1:1 paymenty
                {
                    foreach (Payment srcPt in sourceDocument.Payments.Children)
                    {
                        Payment pt = destination.Payments.CreateNew();
                        pt.Amount = srcPt.Amount;
                        pt.PaymentMethodId = srcPt.PaymentMethodId;
                        pt.LoadPaymentMethodDefaults();
                    }
                }
                else
                {
                    bool first = true;

                    foreach (Payment srcPt in sourceDocument.Payments.Children)
                    {
                        Payment pt = destination.Payments.CreateNew();

                        if (first)
                        {
                            pt.Amount = destination.GrossValue;
                            first = false;
                        }

                        pt.PaymentMethodId = srcPt.PaymentMethodId;
                        pt.LoadPaymentMethodDefaults();
                    }
                }
            }

            return sourceDocument;
        }

		private static void CopyCommercialDocumentLineDetails(CommercialDocumentLine source, CommercialDocumentLine destination, decimal quantity)
		{
			destination.DiscountGrossValue = source.DiscountGrossValue;
			destination.DiscountNetValue = source.DiscountNetValue;
			destination.DiscountRate = source.DiscountRate;
			destination.GrossPrice = source.GrossPrice;
			destination.GrossValue = source.GrossValue;
			destination.InitialGrossPrice = source.InitialGrossPrice;
			destination.InitialGrossValue = source.InitialGrossValue;
			destination.InitialNetPrice = source.InitialNetPrice;
			destination.InitialNetValue = source.InitialNetValue;
			destination.ItemId = source.ItemId;
			destination.ItemName = source.ItemName;
			destination.ItemCode = source.ItemCode;
			destination.ItemVersion = source.ItemVersion;
			destination.NetPrice = source.NetPrice;
			destination.NetValue = source.NetValue;
			destination.Quantity = quantity;
			destination.UnitId = source.UnitId;
			destination.VatRateId = source.VatRateId;
			destination.VatValue = source.VatValue;
			destination.WarehouseId = source.WarehouseId;
			destination.ItemTypeId = source.ItemTypeId;
			destination.Calculate(destination.Quantity, destination.InitialNetPrice, destination.DiscountRate, destination.InitialGrossPrice);
		}

		/// <summary>
		/// Dodaje atrybut do linii dokumentu sprzedażowego realizującego zamówienie sprzedażowe z id pozycji realizowanej przez pozycję dokumentu sprzedażowego
		/// </summary>
		/// <param name="sourceLine">Pozycja dokumentu sprzedażowego</param>
		/// <param name="destinationLine">Pozycja zamówienia sprzedażowego</param>
		/// <param name="isSalesOrderRealization">Identyfikacja procesu realizacji ZS</param>
		internal static void TryAddRealizedSalesOrderLineId(CommercialDocumentLine sourceLine, CommercialDocumentLine destinationLine, bool isSalesOrderRealization)
		{
			if (isSalesOrderRealization)
			{
				CommercialDocumentFactory.AddRealizedSalesOrderLineId(sourceLine, destinationLine);
			}
		}

		private static void AddRealizedSalesOrderLineId(CommercialDocumentLine sourceLine, CommercialDocumentLine destinationLine)
		{
			DocumentLineAttrValue realizeSalesOrderLineIdAttribute = destinationLine.Attributes.CreateNew();
			realizeSalesOrderLineIdAttribute.DocumentFieldName = DocumentFieldName.LineAttribute_RealizedSalesOrderLineId;
			realizeSalesOrderLineIdAttribute.Value.Value = sourceLine.Id.ToString();
		}

		public static void GenerateInvoiceFromServiceDocument(XElement source, CommercialDocument destination)
		{
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			if (source.Element("processObject") == null)
				throw new InvalidOperationException("No 'processObject' node in source xml");

			string processObject = source.Element("processObject").Value;

			List<ServiceDocument> sourceDocuments = new List<ServiceDocument>();
			ServiceDocument sourceDocument = null;

			foreach (var srcId in source.Elements("serviceDocumentId"))
			{
				Guid sourceDocumentId = new Guid(srcId.Value);
				sourceDocument = (ServiceDocument)mapper.LoadBusinessObject(BusinessObjectType.ServiceDocument, sourceDocumentId);

				string processType = sourceDocument.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value;
				ProcessManager.Instance.AppendProcessAttributes(destination, processType, processObject, null, null);
				DuplicableAttributeFactory.DuplicateAttributes(sourceDocument, destination);
				sourceDocuments.Add(sourceDocument);
			}

			bool copyCalculationType = false;
			bool copyContractor = false;

			//sprawdzamy czy dokumenty zrodlowe maja zgodne sposoby liczenia

			copyCalculationType = sourceDocuments.Where(d => d.CalculationType != sourceDocument.CalculationType).FirstOrDefault() == null;

			if (copyCalculationType && sourceDocument.CalculationType != destination.CalculationType && destination.DocumentType.CommercialDocumentOptions.AllowCalculationTypeChange)
				destination.CalculationType = sourceDocument.CalculationType;

			if (sourceDocument.Contractor != null)
				copyContractor = sourceDocuments.Where(dd => dd.Contractor == null || dd.Contractor.Id.Value != sourceDocument.Contractor.Id.Value).FirstOrDefault() == null;

			if (copyContractor)
			{
				if (sourceDocument.Contractor != null)
					destination.Contractor = (Contractor)sourceDocument.Contractor;

				if (sourceDocument.ContractorAddressId != null)
					destination.ContractorAddressId = sourceDocument.ContractorAddressId;
			}

			destination.Tag = String.Empty;

			foreach (ServiceDocument srcDocument in sourceDocuments)
			{
				foreach (CommercialDocumentLine srcLine in srcDocument.Lines.Children)
				{
					string generateOption = srcLine.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption].Value.Value;
					var realizedAttr = srcLine.Attributes[DocumentFieldName.LineAttribute_ServiceRealized];
					var unrealizedQuantity = srcLine.Quantity;

					if (realizedAttr != null)
						unrealizedQuantity -= Convert.ToDecimal(realizedAttr.Value.Value, CultureInfo.InvariantCulture);

					if (unrealizedQuantity == 0 || //zrealizowane pomijamy
						(generateOption != "1" && generateOption != "2")) //i takie co nie maja generowac wz + fvs
						continue;

					CommercialDocumentLine dstLine = destination.Lines.CreateNew();
					dstLine.DiscountGrossValue = srcLine.DiscountGrossValue;
					dstLine.DiscountNetValue = srcLine.DiscountNetValue;
					dstLine.DiscountRate = srcLine.DiscountRate;
					dstLine.GrossPrice = srcLine.GrossPrice;
					dstLine.GrossValue = srcLine.GrossValue;
					dstLine.InitialGrossPrice = srcLine.InitialGrossPrice;
					dstLine.InitialGrossValue = srcLine.InitialGrossValue;
					dstLine.InitialNetPrice = srcLine.InitialNetPrice;
					dstLine.InitialNetValue = srcLine.InitialNetValue;
					dstLine.ItemId = srcLine.ItemId;
					dstLine.ItemTypeId = srcLine.ItemTypeId;
					dstLine.ItemName = srcLine.ItemName;
					dstLine.ItemCode = srcLine.ItemCode;
					dstLine.ItemVersion = srcLine.ItemVersion;
					dstLine.NetPrice = srcLine.NetPrice;
					dstLine.NetValue = srcLine.NetValue;
					dstLine.Quantity = unrealizedQuantity;
					dstLine.UnitId = srcLine.UnitId;
					dstLine.VatRateId = srcLine.VatRateId;
					dstLine.VatValue = srcLine.VatValue;

					if (generateOption == "2") //mm + wz +fvs
						dstLine.WarehouseId = ProcessManager.Instance.GetServiceWarehouse(srcDocument);
					else
						dstLine.WarehouseId = srcLine.WarehouseId;

					dstLine.Tag = srcLine.OrdinalNumber.ToString(CultureInfo.InvariantCulture) + "," + srcLine.Parent.Id.ToUpperString();

					dstLine.Calculate(dstLine.Quantity, dstLine.InitialNetPrice, dstLine.DiscountRate, dstLine.InitialGrossPrice);
				}

				if (destination.Tag.Length > 0)
					destination.Tag += ",";

				destination.Tag += srcDocument.Version.ToUpperString();
			}

			destination.Calculate();
		}

		public static void GenerateServiceDocumentFromServicedObject(XElement source, ServiceDocument destination)
		{
			ServiceMapper serviceMapper = DependencyContainerManager.Container.Get<ServiceMapper>();
			ServicedObject so = (ServicedObject)serviceMapper.LoadBusinessObject(BusinessObjectType.ServicedObject, new Guid(source.Element("servicedObjectId").Value));

			Contractor contractor = null;

			if (so.OwnerContractorId != null)
			{
				ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
				contractor = (Contractor)contractorMapper.LoadBusinessObject(BusinessObjectType.Contractor, so.OwnerContractorId.Value);
			}

			var servicedObject = destination.ServiceDocumentServicedObjects.CreateNew();
			servicedObject.ServicedObjectId = so.Id.Value;

			if (contractor != null)
			{
				destination.Contractor = contractor;
				var addr = contractor.Addresses.GetBillingAddress();

				if (addr != null)
					destination.ContractorAddressId = addr.Id.Value;
			}
		}

		public static void GenerateInvoiceFromBill(CommercialDocument sourceDocument, CommercialDocument destination)
		{
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			if (sourceDocument.DocumentStatus == DocumentStatus.Canceled)
				throw new ClientException(ClientExceptionId.CreateNewDocumentFromCanceledDocument);

			//sprawdzamy korekty tutaj

			ICollection<Guid> previousDocumentsId = mapper.GetCommercialCorrectiveDocumentsId(sourceDocument.Id.Value);

			CommercialDocument lastDoc = sourceDocument;

			foreach (Guid corrId in previousDocumentsId)
			{
				CommercialDocument correctiveDoc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, corrId);

				CommercialCorrectiveDocumentFactory.RelateTwoCorrectiveDocuments(lastDoc, correctiveDoc, true);

				lastDoc = correctiveDoc;
			}
			//tutaj zaznaczam ze nie wywolujemy metody do przeliczenia wartosci korekt (bo szkoda czasu procesora na to) po korektach, wiec wartosci sa roznicowe !!!
			//zakladamy ze korekty byly dla pozycji tylko calkowite wiec te pozycje ktore sa na lastDoc przenosimy na fakture, ale z sourceDocument'a

			//zmiana zalozen - jednak przeliczamy wartosci po korekcie bo inaczej nie wychwycimy ze gdzies tam wczesniejsza korekta skorygowala pozycje do zera,
			//bo moze byc taki przeplot quantity na pozycji 5,0,0,-5,0,0
			CommercialCorrectiveDocumentFactory.CalculateDocumentsAfterCorrection(lastDoc);

			destination.CalculationType = sourceDocument.CalculationType;

			if (sourceDocument.Contractor != null)
				destination.Contractor = (Contractor)sourceDocument.Contractor;

			if (sourceDocument.ContractorAddressId != null)
				destination.ContractorAddressId = sourceDocument.ContractorAddressId;

			destination.DocumentCurrencyId = sourceDocument.DocumentCurrencyId;
			destination.EventDate = sourceDocument.EventDate;

			DuplicableAttributeFactory.DuplicateAttributes(sourceDocument, destination);

			foreach (CommercialDocumentLine lastLine in lastDoc.Lines.Children)
			{
				if (lastDoc != sourceDocument && lastLine.Quantity == 0) //czyli mamy korekty
					continue;

				CommercialDocumentLine srcLine = lastLine;

				if (lastLine.InitialCommercialDocumentLine != null)
					srcLine = lastLine.InitialCommercialDocumentLine;

				CommercialDocumentLine dstLine = destination.Lines.CreateNew();
				dstLine.DiscountGrossValue = srcLine.DiscountGrossValue;
				dstLine.DiscountNetValue = srcLine.DiscountNetValue;
				dstLine.DiscountRate = srcLine.DiscountRate;
				dstLine.GrossPrice = srcLine.GrossPrice;
				dstLine.GrossValue = srcLine.GrossValue;
				dstLine.InitialGrossPrice = srcLine.InitialGrossPrice;
				dstLine.InitialGrossValue = srcLine.InitialGrossValue;
				dstLine.InitialNetPrice = srcLine.InitialNetPrice;
				dstLine.InitialNetValue = srcLine.InitialNetValue;
				dstLine.ItemId = srcLine.ItemId;
				dstLine.ItemTypeId = srcLine.ItemTypeId;
				dstLine.ItemName = srcLine.ItemName;
				dstLine.ItemCode = srcLine.ItemCode;
				dstLine.ItemVersion = srcLine.ItemVersion;
				dstLine.NetPrice = srcLine.NetPrice;
				dstLine.NetValue = srcLine.NetValue;
				dstLine.Quantity = srcLine.Quantity;
				dstLine.UnitId = srcLine.UnitId;
				dstLine.VatRateId = srcLine.VatRateId;
				dstLine.VatValue = srcLine.VatValue;
				dstLine.WarehouseId = srcLine.WarehouseId;

				foreach (CommercialWarehouseRelation rel in srcLine.CommercialWarehouseRelations.Children)
				{
					var newRel = dstLine.CommercialWarehouseRelations.CreateNew();
					newRel.IsCommercialRelation = rel.IsCommercialRelation;
					newRel.IsOrderRelation = rel.IsOrderRelation;
					newRel.Quantity = rel.Quantity;
					newRel.RelatedLine = rel.RelatedLine;
					newRel.Value = rel.Value;
				}

				//przeniesienie powiązania z ZS jeśli istnieje
				DocumentLineAttrValue realizedSalesOrderLineId = srcLine.Attributes[DocumentFieldName.LineAttribute_RealizedSalesOrderLineId];
				if (realizedSalesOrderLineId != null)
				{
					dstLine.Attributes.CreateNew(realizedSalesOrderLineId);
				}

				dstLine.Calculate(dstLine.Quantity, dstLine.InitialNetPrice, dstLine.DiscountRate, dstLine.InitialGrossPrice);
			}

			destination.Calculate();

			var relation = destination.Relations.CreateNew();
			relation.RelationType = DocumentRelationType.InvoiceToBill;
			relation.RelatedDocument = sourceDocument;

			Payment newPayment = destination.Payments.CreateNew();
			var srcPayment = sourceDocument.Payments[0];
			newPayment.Contractor = srcPayment.Contractor;
			newPayment.ContractorAddressId = srcPayment.ContractorAddressId;
			newPayment.PaymentCurrencyId = srcPayment.PaymentCurrencyId;
			newPayment.PaymentMethodId = srcPayment.PaymentMethodId;
			newPayment.Date = srcPayment.Date;
			newPayment.DueDate = srcPayment.DueDate;
			newPayment.Amount = destination.GrossValue;
		}

		public static void GenerateInvoiceFromBill(XElement source, CommercialDocument destination)
		{
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			Guid sourceDocumentId = new Guid(source.Element("commercialDocumentId").Value);

			CommercialDocument sourceDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, sourceDocumentId);

			CommercialDocumentFactory.GenerateInvoiceFromBill(sourceDocument, destination);
		}
	}
}
