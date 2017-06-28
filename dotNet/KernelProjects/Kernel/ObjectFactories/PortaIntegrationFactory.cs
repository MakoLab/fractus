using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using System.Xml.Linq;
using System.Xml.XPath;
using Makolab.Fractus.Kernel.Constants;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Converters.Dictionaries;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using System.Globalization;
using Makolab.Fractus.Kernel.MethodInputParameters;
using LumenWorks.Framework.IO.Csv;
using System.IO;
using Makolab.Fractus.Kernel.HelperObjects;
using System.Diagnostics;
using System.Threading;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
	internal class PortaIntegrationFactory
	{
		public static void GeneratePurchaseInvoiceFromExternalSalesInvoice(XElement source, CommercialDocument destination)
		{
			XElement documentInvoiceElement = source.Element(PortaXmlName.DocumentInvoice);
			if (documentInvoiceElement == null)
				throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);

			XDocument existingItemsDetails = null;
			Dictionary<int, Item> insertedItemsDetails = null;

			#region Items existence, insert or load detail
			using (ItemCoordinator itemCoordinator = new ItemCoordinator(false, true))
			{
				XDocument codesElementDocument = PortaIntegrationFactory.GetCheckItemsExistenceInputXmlForInvoice(documentInvoiceElement);
				insertedItemsDetails = PortaIntegrationFactory.InsertItemsForImportedDocument(itemCoordinator, documentInvoiceElement, null, codesElementDocument, true, out existingItemsDetails);
			}
			PortaIntegrationFactory.UpdateDictionaryIndex(insertedItemsDetails);
			#endregion

			#region Document header
			XElement invoiceHeaderElement = documentInvoiceElement.Element(PortaXmlName.InvoiceHeader);
			if (invoiceHeaderElement == null)
				throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);

			string supplierDocumentNumber = invoiceHeaderElement.GetTextValueOrNull(PortaXmlName.InvoiceNumber);
			if (supplierDocumentNumber != null)
			{
				DocumentAttrValue attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_SupplierDocumentNumber);
				attr.Value.Value = supplierDocumentNumber;
			}

			string supplierDocumentDate = invoiceHeaderElement.GetTextValueOrNull(PortaXmlName.InvoiceDate);
			if (supplierDocumentDate != null)
			{
				DocumentAttrValue attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_SupplierDocumentDate);
				attr.Value.Value = supplierDocumentDate;
			}

			//InvoiceCurrency
			//InvoicePaymentDueDate
			//DocumentFunctionCode --czy faktura, czy korekta - może w przyszłości się wykorzysta
			#endregion

			#region Contractors
			XElement invoicePartiesElement = documentInvoiceElement.Element(PortaXmlName.InvoiceParties);
			XElement sellerElement = invoicePartiesElement != null ? invoicePartiesElement.Element(PortaXmlName.Seller) : null;
            //fragment walidował dokument na istnienie podatku, format obecny nie zawiera podatku
            string taxId = sellerElement != null ? sellerElement.GetTextValueOrNull(PortaXmlName.Name) : null;
            //int numberStart = taxId.IndexOfNumber();
            //if (numberStart != -1)
            //    taxId = taxId.Substring(numberStart);
            //if (String.IsNullOrEmpty(taxId))
            //{
            //    throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
            //}
			ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
			Contractor sourceSeller = contractorMapper.GetContractorByFullName(taxId); //  .GetContractorByNip(taxId);
            if (sourceSeller == null)
            {
                if (taxId.Substring(0,9) == "Porta KMI")
                    sourceSeller = contractorMapper.GetContractorByNip(@"5850006204");
            }
            if (sourceSeller == null)
			{
				throw new ClientException(ClientExceptionId.ObjectNotFound);
			}
			destination.Contractor = sourceSeller;
			#endregion

			#region Lines
			var sourceLines = documentInvoiceElement.XPathSelectElements(@"Invoice-Lines/Line/Line-Item");

			foreach (XElement sourceLine in sourceLines)
			{
				CommercialDocumentLine commercialDocumentLine = destination.Lines.CreateNew();

				XElement lineNumberElement = sourceLine.Element(PortaXmlName.LineNumber);
				string lineNumberStr = lineNumberElement.Value;
				int lineNumber = Convert.ToInt32(lineNumberStr);

				#region Item Details
				Item insertedItemDetails = null;
				XElement existingItemDetails = null;

				if (insertedItemsDetails != null && insertedItemsDetails.ContainsKey(lineNumber))
				{
					insertedItemDetails = insertedItemsDetails[lineNumber];
				}
				else if (existingItemsDetails != null)
				{
					existingItemDetails = existingItemsDetails.Root.Elements(XmlName.Item)
						.Where(el => el.Attribute(PortaXmlName.LineNumber).Value == lineNumberStr).FirstOrDefault();
				}

				PortaIntegrationFactory.UpdateCommercialDocumentLineItemDetails(commercialDocumentLine, insertedItemDetails, existingItemDetails);
				#endregion

				#region Values And Quantities

				decimal vatRate = DictionaryMapper.Instance.GetVatRate(commercialDocumentLine.VatRateId).Rate;

				commercialDocumentLine.Quantity
					= Convert.ToDecimal(sourceLine.Element(PortaXmlName.InvoiceQuantity).Value, CultureInfo.InvariantCulture);
				commercialDocumentLine.NetPrice
					= Convert.ToDecimal(sourceLine.Element(PortaXmlName.InvoiceUnitNetPrice).Value, CultureInfo.InvariantCulture);
				commercialDocumentLine.GrossPrice
					= Math.Round(commercialDocumentLine.NetPrice * (1 + vatRate / 100), 2, MidpointRounding.AwayFromZero);

				commercialDocumentLine.NetValue
					= Convert.ToDecimal(sourceLine.Element(PortaXmlName.NetAmount).Value, CultureInfo.InvariantCulture);
                //w nowym formacie nie ma vat
                if (sourceLine.Element(PortaXmlName.TaxAmount) != null)
                {
                    commercialDocumentLine.VatValue
                    = Convert.ToDecimal(sourceLine.Element(PortaXmlName.TaxAmount).Value, CultureInfo.InvariantCulture);
                }
                else
                {
                    commercialDocumentLine.VatValue
                    = Math.Round(commercialDocumentLine.NetValue * (vatRate / 100), 2, MidpointRounding.AwayFromZero);
                }
				commercialDocumentLine.GrossValue = Math.Round(commercialDocumentLine.NetValue + commercialDocumentLine.VatValue
					, 2, MidpointRounding.AwayFromZero);

				commercialDocumentLine.CalculateSimplified(2);

				#endregion
			}

			#endregion

			#region Summary

			XElement invoiceSummaryElement = documentInvoiceElement.Element(PortaXmlName.InvoiceSummary);

			#region Header

			destination.NetValue = Convert.ToDecimal(invoiceSummaryElement.Element(PortaXmlName.TotalNetAmount).Value
				, CultureInfo.InvariantCulture);
            destination.GrossValue = Math.Round(Convert.ToDecimal(invoiceSummaryElement.Element(PortaXmlName.TotalNetAmount).Value, CultureInfo.InvariantCulture) * Convert.ToDecimal("1,23"), 2, MidpointRounding.AwayFromZero); //Convert.ToDecimal(invoiceSummaryElement.Element(PortaXmlName.TotalGrossAmount).Value
				//, CultureInfo.InvariantCulture);
            //Nowy format pliku nie zawiera vat
            destination.VatValue = destination.GrossValue - destination.NetValue;

			#endregion

			#region Vat Table
            //T
            //foreach (XElement taxSummaryLineElement in invoiceSummaryElement.Element(PortaXmlName.TaxSummary).Elements(PortaXmlName.TaxSummaryLine))
            //Tutaj na twardo, niestety bez danych o vat nie da się innaczej

            CommercialDocumentVatTableEntry vtEnty = destination.VatTableEntries.CreateNew();
            vtEnty.VatRateId =  (Guid)DictionaryMapper.Instance.GetVatRate("23").Id;
            vtEnty.NetValue = destination.NetValue;
            vtEnty.VatValue = destination.VatValue;
            vtEnty.GrossValue = destination.GrossValue;

            //    Guid? vtRateId = PortaIntegrationFactory.GetVatRateId(taxSummaryLineElement);
            //    if (vtRateId != null)
            //    {
            //        CommercialDocumentVatTableEntry vtEnty = destination.VatTableEntries.CreateNew();
            //        vtEnty.VatRateId = vtRateId.Value;
            //        vtEnty.NetValue = Convert.ToDecimal(taxSummaryLineElement.Element(PortaXmlName.TaxableAmount).Value
            //            , CultureInfo.InvariantCulture);
            //        vtEnty.VatValue = Convert.ToDecimal(taxSummaryLineElement.Element(PortaXmlName.TaxAmount).Value
            //            , CultureInfo.InvariantCulture);
            //        vtEnty.GrossValue = Convert.ToDecimal(taxSummaryLineElement.Element(PortaXmlName.GrossAmount).Value
            //            , CultureInfo.InvariantCulture);
            //    }
            //    else
            //        throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
            //}

			if (!destination.VatTableEntries.HasChildren)
			{
				destination.Calculate();
			}

			#endregion

			#endregion

			#region Document Attributes
			PortaIntegrationFactory.AppendSourceTypeAttribute(destination, source);

			string orderNumber = PortaIntegrationFactory.GetOrderNumber(invoiceHeaderElement);
			if (!String.IsNullOrEmpty(orderNumber))
			{
				destination.Attributes.GetOrCreateNew(DocumentFieldName.Attribute_OrderNumber).Value.Value = orderNumber;
			}

			#endregion
		}

		[Obsolete("Operacja nie wykorzystywana przez klienta")]
		public static void GenerateExternalIncomeFromPortaExternalOutcomeDocument(XElement source, WarehouseDocument destination)
		{
			/*
			#region Parsing
			string csvFile = source.Element("sourceDocument").Value;
			csvFile = PortaIntegrationFactory.FilterCsv(csvFile);
			CsvReader csvReader = new CsvReader(new StringReader(csvFile), false);

			var sourceLines = new List<DocumentLineSimpleInfo>();
			XDocument codesInputDocument = XDocument.Parse(XmlName.EmptyRoot);
			int lineNumber = 1;
			while (csvReader.ReadNextRecord())
			{
				if (csvReader.FieldCount > 4)
				{
					var lineInfo = new DocumentLineSimpleInfo();

					lineInfo.ItemCode = csvReader[2].Trim('"');
					//lineInfo.ItemFamily = csvReader[3].Trim('"');
					lineInfo.Quantity = Convert.ToInt32(csvReader[4].Trim('"'), CultureInfo.InvariantCulture);

					sourceLines.Add(lineInfo);
					codesInputDocument.Root.Add(
						new XElement(XmlName.Line
						, new XElement(PortaXmlName.LineNumber, lineNumber.ToStringInvariant())
						, new XElement(XmlName.Code, lineInfo.ItemCode)));
					lineNumber++;
				}
				else if (csvReader.FieldCount != 2)
					throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
			}
			#endregion

			XDocument existingItemsDetails = null;
			Dictionary<int, Item> insertedItemsDetails = null;

			#region Items existence, insert or load details
			XElement insertMissingItemsElement = source.Element("insertMissingItems");
			bool insertMissingItems = insertMissingItemsElement != null && insertMissingItemsElement.Value == "1";
			using (ItemCoordinator itemCoordinator = new ItemCoordinator(false, true))
			{
				insertedItemsDetails = PortaIntegrationFactory.InsertItemsForImportedDocument(itemCoordinator, null
					, sourceLines, codesInputDocument, insertMissingItems, out existingItemsDetails);
			}
			#endregion

			#region Lines

			lineNumber = 1;
			foreach (var sourceLine in sourceLines)
			{
				WarehouseDocumentLine warehouseDocumentLine = destination.Lines.CreateNew();

				#region Item Details
				Item insertedItemDetails = null;
				XElement existingItemDetails = null;

				if (insertedItemsDetails.ContainsKey(lineNumber))
				{
					insertedItemDetails = insertedItemsDetails[lineNumber];
				}
				else
				{
					existingItemDetails = existingItemsDetails.Root.Elements(XmlName.Item)
						.Where(el => el.Attribute(PortaXmlName.LineNumber).Value == lineNumber.ToStringInvariant()).FirstOrDefault();
				}

				if (insertedItemDetails != null)
				{
					if (insertedItemDetails.Id.HasValue)
					{
						warehouseDocumentLine.ItemId = insertedItemDetails.Id.Value;
						warehouseDocumentLine.UnitId = insertedItemDetails.UnitId;
						warehouseDocumentLine.ItemCode = insertedItemDetails.Code;
						warehouseDocumentLine.ItemName = insertedItemDetails.Name;
						warehouseDocumentLine.ItemTypeId = insertedItemDetails.ItemTypeId.ToUpperString();
					}
					else
					{
						throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
					}
				}
				else if (existingItemDetails != null)
				{
					if (existingItemDetails.Element(XmlName.Id) != null)
					{
						warehouseDocumentLine.Id = new Guid(existingItemDetails.Element(XmlName.Id).Value);
						if (existingItemDetails.Element(XmlName.Version) != null)
							warehouseDocumentLine.Version = new Guid(existingItemDetails.Element(XmlName.Version).Value);
						warehouseDocumentLine.ItemId = new Guid(existingItemDetails.Element(XmlName.ItemId).Value);
						warehouseDocumentLine.UnitId = new Guid(existingItemDetails.Element(XmlName.UnitId).Value);
						warehouseDocumentLine.ItemCode = existingItemDetails.Element(XmlName.ItemCode).Value;
						warehouseDocumentLine.ItemName = existingItemDetails.Element(XmlName.ItemName).Value;
						warehouseDocumentLine.ItemTypeId = existingItemDetails.Element(XmlName.ItemTypeId).Value;
					}
					else
					{
						throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
					}
				}
				#endregion

				lineNumber++;
			}

			#endregion
			*/
		}

		public static void GenerateSalesOrder(XElement source, CommercialDocument destination, bool isNew)
		{
			if (destination == null)
				return;

			#region Parsing
			string csvFile = source.Element("sourceDocument").Value.Trim();
			char delimiter = PortaIntegrationFactory.GetCsvSeparator(csvFile);
			string[] filteredFile = PortaIntegrationFactory.FilterCsv(csvFile, delimiter);
			
			csvFile = filteredFile[0];
			string productionOrderNumber = filteredFile[1].SubstringBefore(delimiter.ToString());
			if (productionOrderNumber.Contains("@"))
			{
				productionOrderNumber = productionOrderNumber.SubstringAfter("@");
			}
			productionOrderNumber = String.Concat('@', productionOrderNumber);
			CsvReader csvReader = new CsvReader(new StringReader(csvFile), false, delimiter);

			#region Parsing Lines
			var sourceLines = new List<DocumentLineSimpleInfo>();
			XDocument codesInputDocument = XDocument.Parse(XmlName.EmptyRoot);
			int lineNumber = 1;
			while (csvReader.ReadNextRecord())
			{
				if (csvReader.FieldCount > 3)
				{
					var lineInfo = new DocumentLineSimpleInfo();

					lineInfo.ItemFamily = csvReader[0];
					lineInfo.ItemCode = csvReader[1];
					lineInfo.Quantity = Convert.ToInt32(csvReader[2], CultureInfo.InvariantCulture);

					sourceLines.Add(lineInfo);
					codesInputDocument.Root.Add(
						new XElement(XmlName.Line
						, new XElement(PortaXmlName.LineNumber, lineNumber.ToStringInvariant())
						, new XElement(XmlName.Code, lineInfo.ItemCode)));
					lineNumber++;
				}
				else if (csvReader.FieldCount != 2)
					throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
			}
			#endregion

			#region Read SaleType
			string saleTypeVal = SalesOrderSalesType.ItemSale;
			if (isNew)
			{
				if (source.Element("saleType") != null && source.Element("saleType").Value != "null")
					saleTypeVal = source.Element("saleType").Value;
			}
			else
			{
				DocumentAttrValue salesOrderSalesTypeAttr = destination.Attributes[DocumentFieldName.Attribute_SalesOrderSalesType];
				if (salesOrderSalesTypeAttr != null)
				{
					saleTypeVal = salesOrderSalesTypeAttr.Value.Value;
				}
			}
			SalesOrderSalesType saleType = new SalesOrderSalesType(saleTypeVal);
			#endregion

			#region Reads and sets CalculationType for new documents
			XElement calcTypeElement = source.Element("calcType");
			if (isNew && calcTypeElement != null)
			{
				destination.CalculationType = (CalculationType)Enum.Parse(typeof(CalculationType), calcTypeElement.Value);
				destination.CalculationTypeSelected = true;
			}
			#endregion

			#endregion

			XDocument existingItemsDetails = null;
			Dictionary<int, Item> insertedItemsDetails = null;

			#region Items existence, insert or load details

			using (ItemCoordinator itemCoordinator = new ItemCoordinator(false, true))
			{
				insertedItemsDetails = PortaIntegrationFactory.InsertItemsForImportedDocument(itemCoordinator, null
						, sourceLines, codesInputDocument, true, out existingItemsDetails);
			}
			PortaIntegrationFactory.UpdateDictionaryIndex(insertedItemsDetails);

			#endregion

			#region Lines

			lineNumber = 1;
			foreach (DocumentLineSimpleInfo sourceLine in sourceLines)
			{
				CommercialDocumentLine commercialDocumentLine = destination.Lines.CreateNew();
				commercialDocumentLine.Quantity = sourceLine.Quantity;

				#region Item Details
				Item insertedItemDetails = null;
				XElement existingItemDetails = null;
				if (insertedItemsDetails != null && insertedItemsDetails.ContainsKey(lineNumber))
				{
					insertedItemDetails = insertedItemsDetails[lineNumber];
				}
				else if (existingItemsDetails != null)
				{
					existingItemDetails = existingItemsDetails.Root.Elements(XmlName.Item)
						.Where(el => el.Attribute(PortaXmlName.LineNumber).Value == lineNumber.ToStringInvariant()).FirstOrDefault();
				}

				PortaIntegrationFactory.UpdateCommercialDocumentLineItemDetails(commercialDocumentLine, insertedItemDetails, existingItemDetails);

				#endregion

				commercialDocumentLine.Calculate(commercialDocumentLine.Quantity, commercialDocumentLine.InitialNetPrice, 0);

				lineNumber++;
			}

			#endregion

			#region SaleType

			if (isNew)
			{
				destination.Attributes.CreateNew(DocumentFieldName.Attribute_SalesOrderSalesType).Value.Value = saleType.Type;
			}

			foreach (CommercialDocumentLine line in destination.Lines.Where(line => line.Attributes.Children.Where(attr => attr.DocumentFieldName == DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption).Count() == 0))
			{
				line.Attributes.CreateNew(DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption).Value.Value
					= saleType.GetSalesOrderGenerateDocumentOption(true);
			}

			#endregion

			//Vat Table
			destination.Calculate();

			#region Document Attributes
			PortaIntegrationFactory.AppendSourceTypeAttribute(destination, source);

			if (!String.IsNullOrEmpty(productionOrderNumber) 
				&& destination.Attributes[DocumentFieldName.Attribute_ProductionOrderNumber] == null)
			{
				destination.Attributes.CreateNew(DocumentFieldName.Attribute_ProductionOrderNumber).Value.Value = productionOrderNumber;
			}

			#endregion
		}

        public static void GenerateSalesOrderCvs(XElement source, CommercialDocument destination, bool isNew)
        {
            if (destination == null)
                return;
            string csvFile, productionOrderNumber = null;
            char delimiter;

            #region Parsing
            if (source.Element("fileName") != null)
            {
                csvFile = source.Element("fileName").Value.Trim();
                productionOrderNumber = csvFile.SubstringBefore(".");
                if (productionOrderNumber.Contains("@"))
                {
                    productionOrderNumber = productionOrderNumber.SubstringAfter("@");
                }
                productionOrderNumber = String.Concat('@', productionOrderNumber);
            }
            else
            {
                csvFile = source.Element("sourceDocument").Value.Trim();
            }
            delimiter = PortaIntegrationFactory.GetCsvSeparator(csvFile);
            destination.CalculationTypeSelected = true;
            
            csvFile = source.Element("sourceDocument").Value.Trim();
            CsvReader csvReader = new CsvReader(new StringReader(csvFile), false, delimiter);

            #region Parsing Lines
            var sourceLines = new List<DocumentLineSimpleInfo>();
            XDocument codesInputDocument = XDocument.Parse(XmlName.EmptyRoot);
            int lineNumber = 1;
            while (csvReader.ReadNextRecord())
            {
                if (csvReader.FieldCount > 3)
                {
                    var lineInfo = new DocumentLineSimpleInfo();
                    if (csvReader[0] == "undefined" || csvReader[1] == "undefined" || csvReader[2] == "undefined" || csvReader[3] == "undefined")
                    {
                        throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
                    }
                    lineInfo.ItemFamily = csvReader[0];
                    lineInfo.ItemCode = csvReader[1];
                    lineInfo.Name = csvReader[4];
                    
                    lineInfo.Quantity = Convert.ToInt32(csvReader[2], CultureInfo.InvariantCulture);
                    lineInfo.DefaultPrice = Convert.ToDecimal(csvReader[5], CultureInfo.InvariantCulture);
                    string lastChar = lineInfo.ItemFamily.Substring(lineInfo.ItemFamily.Length - 1,1);
                    //if( lastChar == "W" || lastChar == "B")
                    //    lineInfo.PurchasePrice = true;
                    sourceLines.Add(lineInfo);
                    codesInputDocument.Root.Add(
                        new XElement(XmlName.Line
                        , new XElement(PortaXmlName.LineNumber, lineNumber.ToStringInvariant())
                        , new XElement(XmlName.Code, lineInfo.ItemCode)
                        , new XElement("defaultPrice", lineInfo.DefaultPrice)
                        , new XElement("name", lineInfo.Name)));
                    lineNumber++;
                }
                else if (csvReader.FieldCount != 2)
                    throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
            }
            #endregion

            #region Read SaleType
            string saleTypeVal = SalesOrderSalesType.ItemSale;
            if (isNew)
            {
                if (source.Element("saleType") != null && source.Element("saleType").Value != "null")
                    saleTypeVal = source.Element("saleType").Value;
            }
            else
            {
                DocumentAttrValue salesOrderSalesTypeAttr = destination.Attributes[DocumentFieldName.Attribute_SalesOrderSalesType];
                if (salesOrderSalesTypeAttr != null)
                {
                    saleTypeVal = salesOrderSalesTypeAttr.Value.Value;
                }
            }
            SalesOrderSalesType saleType = new SalesOrderSalesType(saleTypeVal);
            #endregion

            #region Reads and sets CalculationType for new documents
            //XElement calcTypeElement = source.Element("calcType");
            
            if (isNew )
            {
                destination.CalculationType = (CalculationType)Enum.Parse(typeof(CalculationType), source.Element("contractorType").Value );
            }
            #endregion

            #endregion

            XDocument existingItemsDetails = null;
            Dictionary<int, Item> insertedItemsDetails = null;

            #region Items existence, insert or load details

            using (ItemCoordinator itemCoordinator = new ItemCoordinator(false, true))
            {
                insertedItemsDetails = PortaIntegrationFactory.InsertItemsForImportedDocument(itemCoordinator, null
                        , sourceLines, codesInputDocument, true, out existingItemsDetails);
            }
            PortaIntegrationFactory.UpdateDictionaryIndex(insertedItemsDetails);

            #endregion

            #region Lines

            lineNumber = 1;
            foreach (DocumentLineSimpleInfo sourceLine in sourceLines)
            {
                CommercialDocumentLine commercialDocumentLine = destination.Lines.CreateNew();
                commercialDocumentLine.Quantity = sourceLine.Quantity;

                #region Item Details
                Item insertedItemDetails = null;
                XElement existingItemDetails = null;
                if (insertedItemsDetails != null && insertedItemsDetails.ContainsKey(lineNumber))
                {
                    insertedItemDetails = insertedItemsDetails[lineNumber];
                }
                else if (existingItemsDetails != null)
                {
                    existingItemDetails = existingItemsDetails.Root.Elements(XmlName.Item)
                        .Where(el => el.Attribute(PortaXmlName.LineNumber).Value == lineNumber.ToStringInvariant()).FirstOrDefault();
                }

                PortaIntegrationFactory.UpdateCommercialDocumentLineItemDetails(commercialDocumentLine, insertedItemDetails, existingItemDetails);

                #endregion

                commercialDocumentLine.Calculate(commercialDocumentLine.Quantity, commercialDocumentLine.InitialNetPrice, 0);

                lineNumber++;
            }

            #endregion

            #region SaleType

            if (isNew)
            {
                destination.Attributes.CreateNew(DocumentFieldName.Attribute_SalesOrderSalesType).Value.Value = saleType.Type;
            }

            foreach (CommercialDocumentLine line in destination.Lines.Where(line => line.Attributes.Children.Where(attr => attr.DocumentFieldName == DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption).Count() == 0))
            {
                line.Attributes.CreateNew(DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption).Value.Value
                    = saleType.GetSalesOrderGenerateDocumentOption(true);
            }

            #endregion

            //Vat Table
            destination.Calculate();

            #region Document Attributes
            PortaIntegrationFactory.AppendSourceTypeAttribute(destination, source);

            if (!String.IsNullOrEmpty(productionOrderNumber) )
            {
                //Tutaj Pan Tomasz chciał dodawać informacje o kolejnych zamówieniach z których dodajemy pozycje
               // && destination.Attributes[DocumentFieldName.Attribute_ProductionOrderNumber] == null)
                if (destination.Attributes[DocumentFieldName.Attribute_ProductionOrderNumber] != null)
                {
                    string actualValue = destination.Attributes[DocumentFieldName.Attribute_ProductionOrderNumber].Value.Value;
                    destination.Attributes[DocumentFieldName.Attribute_ProductionOrderNumber].Value.Value = actualValue + ", " + productionOrderNumber;
                }
                else
                {
                    destination.Attributes.CreateNew(DocumentFieldName.Attribute_ProductionOrderNumber).Value.Value = productionOrderNumber;
                }
            }

            #endregion
        }

		private static void UpdateCommercialDocumentLineItemDetails(CommercialDocumentLine commercialDocumentLine, Item insertedItemDetails, XElement existingItemDetails)
		{
			if (insertedItemDetails != null)
			{
				if (insertedItemDetails.Id.HasValue)
				{
					commercialDocumentLine.ItemId = insertedItemDetails.Id.Value;
					if (insertedItemDetails.Version.HasValue)
						commercialDocumentLine.ItemVersion = insertedItemDetails.Version.Value;
					else if (insertedItemDetails.NewVersion.HasValue)
						commercialDocumentLine.ItemVersion = insertedItemDetails.NewVersion.Value;
					commercialDocumentLine.UnitId = insertedItemDetails.UnitId;
					commercialDocumentLine.VatRateId = insertedItemDetails.VatRateId;
					commercialDocumentLine.ItemCode = insertedItemDetails.Code;
					commercialDocumentLine.ItemName = insertedItemDetails.Name;
					commercialDocumentLine.ItemTypeId = insertedItemDetails.ItemTypeId.ToUpperString();
					commercialDocumentLine.InitialNetPrice = insertedItemDetails.DefaultPrice;
				}
				else
				{
					throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
				}
			}
			else if (existingItemDetails != null)
			{
				if (existingItemDetails.Attribute(XmlName.Id) != null)
				{
					if (existingItemDetails.Attribute(XmlName.Version) != null)
						commercialDocumentLine.ItemVersion = new Guid(existingItemDetails.Attribute(XmlName.Version).Value);
					commercialDocumentLine.ItemId = new Guid(existingItemDetails.Attribute(XmlName.Id).Value);
					commercialDocumentLine.UnitId = new Guid(existingItemDetails.Attribute(XmlName.UnitId).Value);
					commercialDocumentLine.VatRateId = new Guid(existingItemDetails.Attribute(XmlName.VatRateId).Value);
					commercialDocumentLine.ItemCode = existingItemDetails.Attribute(XmlName.Code).Value;
					commercialDocumentLine.ItemName = existingItemDetails.Attribute(XmlName.Name).Value;
					commercialDocumentLine.ItemTypeId = existingItemDetails.Attribute(XmlName.ItemTypeId).Value;
					commercialDocumentLine.InitialNetPrice
						= Convert.ToDecimal(existingItemDetails.Attribute(XmlName.DefaultPrice).Value, CultureInfo.InvariantCulture);
				}
				else
				{
					throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
				}
			}

			Unit pieceUnit = DictionaryMapper.Instance.GetUnit("szt.") ?? DictionaryMapper.Instance.GetUnit("szt");

			if (pieceUnit != null && commercialDocumentLine.UnitId != pieceUnit.Id)
				throw new ClientException(ClientExceptionId.ForbiddenUnits);
		}

		/// <summary>
		/// Inserts missing items and
		/// </summary>
		/// <param name="source"></param>
		/// <param name="insertMissingItems"></param>
		/// <returns></returns>
		internal static Dictionary<int, Item> InsertItemsForImportedDocument(ItemCoordinator itemCoordinator, XElement source
			, List<DocumentLineSimpleInfo> linesInfo, XDocument checkItemsExistenceInput, bool insertMissingItems
			, out XDocument existingItemsDetails)
		{
			ItemMapper itemMapper = DependencyContainerManager.Container.Get<ItemMapper>();
			XElement documentItems = PortaIntegrationFactory.CheckItemsExistence(itemMapper, checkItemsExistenceInput);
			var completeInfo = PortaIntegrationFactory.GetItemsCompleteInfo(itemMapper, checkItemsExistenceInput);

			var missingItems = documentItems.Elements().Where(
				el => el.Element(XmlName.Id) == null || String.IsNullOrEmpty(el.Element(XmlName.Id).Value));
			var existingItems = documentItems.Elements().Where(
				el => el.Element(XmlName.Id) != null && !String.IsNullOrEmpty(el.Element(XmlName.Id).Value))
				.Select(el => new Guid(el.Element(XmlName.Id).Value));

			Dictionary<int, Item> itemsToSave = new Dictionary<int, Item>(missingItems.Count());

			if (existingItems.Count() > 0)
			{
				var existingItemsList = existingItems.ToList();
				existingItemsDetails = itemMapper.GetItemsDetailsForDocument(false, null, null, existingItemsList);
				XElement itemsGroups = itemMapper.GetItemsGroups(existingItemsList);

				int lineNo = -1;
				List<string> usedLineNumbers = new List<string>();
				foreach (XElement itemDetails in existingItemsDetails.Root.Elements())
				{
					string id = itemDetails.Attribute(XmlName.Id).Value;
					string lineNumber = documentItems.Elements().Where(
						el => el.Element(XmlName.Id) != null 
							&& !String.IsNullOrEmpty(el.Element(XmlName.Id).Value) 
							&& el.Element(XmlName.Id).Value == id)
						.Select(el => el.Element(PortaXmlName.LineNumber).Value)
						.Where(ln => !usedLineNumbers.Contains(ln)).FirstOrDefault();
					lineNo = Convert.ToInt32(lineNumber, CultureInfo.InvariantCulture);
					itemDetails.Add(new XAttribute(PortaXmlName.LineNumber, lineNumber));
					usedLineNumbers.Add(lineNumber);

					XElement itemGroups = itemsGroups.XPathSelectElement(String.Format(@"item[@id='{0}']", id.ToUpperInvariant()));

					Item item = null;
					if (source != null)
					{
						item = PortaIntegrationFactory.UpdateMissingItemPropertiesForInvoice(itemCoordinator, new Guid(id), itemDetails, source, lineNumber, completeInfo, itemGroups);
					}
					else if (linesInfo != null && linesInfo.Count > 0)
					{
						string code = PortaIntegrationFactory.GetItemCodeForSalesOrder(linesInfo, lineNo);
						item = PortaIntegrationFactory.UpdateMissingItemPropertiesForSalesOrder(itemCoordinator, new Guid(id), code, itemDetails, linesInfo, completeInfo, itemGroups);
					}
					if (item != null)
						itemsToSave.Add(lineNo, item);
				}
			}
			else
				existingItemsDetails = null;

			if (missingItems != null && missingItems.Count() > 0)
			{
				if (insertMissingItems)
				{
					Dictionary<string, bool> codesUsed = new Dictionary<string, bool>();
					foreach (XElement missingItemElement in missingItems)
					{
						int lineNumber = Convert.ToInt32(missingItemElement.Element(PortaXmlName.LineNumber).Value);
						
						Item item = (Item)itemCoordinator.CreateNewBusinessObject(BusinessObjectType.Item, "good", null);

						if (source != null)
						{
							PortaIntegrationFactory.UpdateItemForInvoice(item, source, missingItemElement, lineNumber, completeInfo);
						}
						else if (linesInfo != null)
						{
							PortaIntegrationFactory.UpdateItemForSalesOrder(item, linesInfo, completeInfo, lineNumber);
						}
						else 
							throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);

						if (item.Code == null)
							throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);

						if (codesUsed.ContainsKey(item.Code))
						{
							item = itemsToSave.Values.Where(i => i.Code == item.Code).FirstOrDefault();
						}
						else
						{
							codesUsed.Add(item.Code, true);
						}
						
						itemsToSave.Add(lineNumber, item);
					}
				}
				else
				{
					ClientException cex = new ClientException(ClientExceptionId.InsertMissingItems);
					XElement xmlData = XElement.Parse(XmlName.EmptyRoot);
					xmlData.Add(missingItems);
					cex.XmlData = xmlData;
					throw cex;
				}
			}

			if (itemsToSave.Count > 0)
			{
				Item[] items = PortaIntegrationFactory.ConvertItemsToInsertToArray(itemsToSave);
				itemCoordinator.SaveLargeQuantityOfBusinessObjects<Item>(false, items);
				
				return itemsToSave;
			}

			return null;

		}

		private static void UpdateDictionaryIndex(Dictionary<int, Item> insertedItemsDetails)
		{
			if (insertedItemsDetails != null && insertedItemsDetails.Count > 0)
			{
				Item[] items = PortaIntegrationFactory.ConvertItemsToInsertToArray(insertedItemsDetails);
				ParameterizedThreadStart updateDictDelegate
					= new ParameterizedThreadStart(PortaIntegrationFactory.UpdateDictionaryIndexLargeQuantityProxy);
				Thread updateDictionaryIndexThread = new Thread(updateDictDelegate);
				updateDictionaryIndexThread.IsBackground = true;
				updateDictionaryIndexThread.Start(items);
			}
		}

		private static void UpdateDictionaryIndexLargeQuantityProxy(object businessObjects)
		{
			try
			{
				//Inicjalizacja z uwagi na to, że w ramach wątku connection itp. są odrębne
				SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
				SqlConnectionManager.Instance.InitializeConnection();
				using (ItemCoordinator itemCoordinator = new ItemCoordinator(true, true))
				{
					itemCoordinator.UpdateDictionaryIndexLargeQuantity(businessObjects);
				}
				SecurityManager.Instance.LogOff();
				SessionManager.ResetVolatileContainer();
			}
			catch (Exception)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: What is this exception (3)");
			}
		}

		private static Item[] ConvertItemsToInsertToArray(Dictionary<int, Item> itemsToInsert)
		{
			return itemsToInsert.Values.Distinct(ItemComparerByCode.Instance).ToArray();
		}

		private static XDocument GetCheckItemsExistenceInputXmlForInvoice(XElement source)
		{
			XDocument inputXml = XDocument.Parse(XmlName.EmptyRoot);

			var lineItems = source.XPathSelectElements(@"Invoice-Lines/Line/Line-Item");
			foreach (var item in lineItems)
			{
				XElement lineElement = new XElement(XmlName.Line);
				if (item.Element(PortaXmlName.LineNumber) != null)
					lineElement.Add(new XElement(item.Element(PortaXmlName.LineNumber)));

				//extract code
				XElement eanElement = item.Element(PortaXmlName.EAN);
				XElement supplierItemCodeElement = item.Element(PortaXmlName.SupplierItemCode);
				XElement buyerItemCodeElement = item.Element(PortaXmlName.BuyerItemCode);
				string code = null;
				if (supplierItemCodeElement != null && !String.IsNullOrEmpty(supplierItemCodeElement.Value))
					code = supplierItemCodeElement.Value;
				else if (eanElement != null && !String.IsNullOrEmpty(eanElement.Value))
					code = eanElement.Value;
				else if (buyerItemCodeElement != null && !String.IsNullOrEmpty(buyerItemCodeElement.Value))
					code = buyerItemCodeElement.Value;
				if (code != null)
					lineElement.Add(new XElement(XmlName.Code, code));
				inputXml.Root.Add(lineElement);
			}

			return inputXml;
		}

		/// <summary>
		/// Checks items from Porta Document existence in a database
		/// </summary>
		/// <param name="source">Invoice-Lines element</param>
		/// <returns>Xml element containing itemCode, lineNumber and id collection for each item source element.</returns>
		private static XElement CheckItemsExistence(ItemMapper mapper, XDocument inputXml)
		{

			XDocument dbResultXml = mapper.ExecuteStoredProcedure(StoredProcedure.item_p_checkItemsExistenceByCode, true, inputXml);
			//Oczekuje kolekcji w postaci <line><id></id><lineNumber></lineNumber></line>

			//dodanie do xml idków
			foreach (var dbElement in dbResultXml.Root.Elements())
			{
				XElement idElement = dbElement.Element(XmlName.Id);
				if (idElement != null && !String.IsNullOrEmpty(idElement.Value))
				{
					XElement lineNumberElement = dbElement.Element(PortaXmlName.LineNumber);
					string lineNumber = lineNumberElement != null ? lineNumberElement.Value : String.Empty;
					XElement srcLineElement = inputXml.Root.Elements()
						.Where(line => line.Element(PortaXmlName.LineNumber) != null
							&& line.Element(PortaXmlName.LineNumber).Value == lineNumber).FirstOrDefault();
					if (srcLineElement != null)
					{
						srcLineElement.Add(new XElement(idElement));
					}
				}
			}

			return inputXml.Root;
		}

		private static List<ItemInfo> GetItemsCompleteInfo(ItemMapper mapper, XDocument inputXml)
		{
			XDocument dbResultXml = mapper.ExecuteStoredProcedure(StoredProcedure.custom_p_getPortaCompleteItemDetails, true, inputXml);
			List<ItemInfo> result = new List<ItemInfo>();

			if (dbResultXml != null)
			{
				foreach (XElement itemInfoElement in dbResultXml.Root.Elements())
				{
					ItemInfo itemInfo = new ItemInfo();
					itemInfo.Deserialize(itemInfoElement);
					result.Add(itemInfo);
				}
			}

			return result;
		}

		private static bool GetNewGroupMemberships(string familyCode, XElement itemGroups, out List<Guid> matchingItemGroups)
		{
			matchingItemGroups = null;
			if (familyCode != null)
			{
				bool groupsEdit = false;
				matchingItemGroups = DictionaryMapper.Instance.GetItemGroupsIds(familyCode);
				//jeśli nie było przypisania a kod rodziny pasuje do któregoś z wzorców - edycja kartoteki
				groupsEdit = (itemGroups == null || itemGroups.Elements().Count() == 0)
					&& matchingItemGroups != null && matchingItemGroups.Count > 0;
				if (!groupsEdit)
				{
					//jeśli są nowe grupy do przypisania to również edycja kartoteki
					List<Guid> oldGroups = itemGroups.Elements().Select(el => new Guid(el.Value)).ToList();
					groupsEdit = matchingItemGroups != null && matchingItemGroups.Except(oldGroups).Count() > 0;
				}
				return groupsEdit;
			}
			return false;
		}

		private static string GetItemCodeForSalesOrder(List<DocumentLineSimpleInfo> linesInfo, int lineNumber)
		{
			if (linesInfo != null && linesInfo.Count >= lineNumber)
			{
				DocumentLineSimpleInfo lineInfo = linesInfo.ElementAt(lineNumber - 1);
				return lineInfo.ItemCode;
			}
			else
				throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
		}

		private static string GetFamilyCodeForInvoice(XElement codeElement, ItemInfo completeItemInfo)
		{
			return completeItemInfo != null ? completeItemInfo.Family :
				codeElement != null && !String.IsNullOrEmpty(codeElement.Value) ? codeElement.Value :
				completeItemInfo != null ? completeItemInfo.Code : null;
		}

		private static string GetFamilyCodeForSalesOrder(DocumentLineSimpleInfo lineDetails, ItemInfo completeItemDetails)
		{
			return lineDetails != null && !String.IsNullOrEmpty(lineDetails.ItemFamily) ?
					lineDetails.ItemFamily : completeItemDetails != null ? completeItemDetails.Family :
					lineDetails != null && !String.IsNullOrEmpty(lineDetails.ItemCode) ? lineDetails.ItemCode :
					completeItemDetails != null ? completeItemDetails.Code : null;

		}

		private static Item UpdateMissingItemPropertiesForInvoice(ItemCoordinator itemCoordinator, Guid id, XElement itemDetails, XElement source, string lineNumber, List<ItemInfo> completeInfoFull, XElement itemGroups)
		{
			ItemInfo completeItemInfo = completeInfoFull.Where(ci => ci.Code == itemDetails.Attribute(XmlName.Code).Value).FirstOrDefault();
			XElement lineItemElement = source.XPathSelectElements(
				String.Format(@"Invoice-Lines/Line/Line-Item[LineNumber = {0}]", lineNumber)).FirstOrDefault();

			Item result = null;

			#region ItemName
			XElement descElement = lineItemElement.Element(PortaXmlName.ItemDescription);
			string newName = descElement != null && !String.IsNullOrEmpty(descElement.Value) ?
				descElement.Value : completeItemInfo != null && !String.IsNullOrEmpty(completeItemInfo.Name) ?
				completeItemInfo.Name : null;

			XAttribute nameAttr = itemDetails.Attribute(XmlName.Name);

			bool isDifferent = nameAttr != null && newName != null && nameAttr.Value != newName;
			bool isNew = nameAttr == null && descElement != null;
			if (isDifferent || isNew)
			{
				result = (Item)itemCoordinator.LoadBusinessObject(BusinessObjectType.Item, id);
				result.Name = descElement.Value;
			}
			#endregion

			#region Barcode/Ean

			XElement eanElement = lineItemElement.Element(PortaXmlName.EAN);

			XElement oldBarcodes = itemDetails.Element("barcodes");

			string newBarcode = eanElement != null && !String.IsNullOrEmpty(eanElement.Value) ?
				eanElement.Value : completeItemInfo != null && !String.IsNullOrEmpty(completeItemInfo.Barcode) ?
				completeItemInfo.Barcode : null;

			if (Utils.IsNewValue(oldBarcodes, newBarcode))
			{
				result = result ?? (Item)itemCoordinator.LoadBusinessObject(BusinessObjectType.Item, id);
				PortaIntegrationFactory.InsertBarcode(result, newBarcode);
			}

			#endregion

			#region PKWiU

			string pkwiu = PortaIntegrationFactory.GetPKWiU(lineItemElement);
			if (pkwiu != null)
			{
				Item oldItem = result;
				result = result ?? (Item)itemCoordinator.LoadBusinessObject(BusinessObjectType.Item, id);
				ItemAttrValue oldAttr = result.Attributes[ItemFieldName.Attribute_PKWiU];
				string oldValue = oldAttr != null ? oldAttr.Value.Value : null;
				if (oldValue == null || oldValue != pkwiu)
				{
					ItemAttrValue pkwiuAttr = result.Attributes.GetOrCreateNew(ItemFieldName.Attribute_PKWiU);
					pkwiuAttr.Value.Value = pkwiu;
				}
				else //jeśli się nie zmienia pkwiu to nie zapisujemy towaru - chyba, że zmienia się coś innego
					result = oldItem;
			}

			#endregion

			#region Price
			//decimal price = Convert.ToDecimal(itemDetails.Attribute(XmlName.DefaultPrice).Value, CultureInfo.InvariantCulture);
			//if (completeItemInfo != null && price != completeItemInfo.Price)
			//{
			//    result = result ?? (Item)itemCoordinator.LoadBusinessObject(BusinessObjectType.Item, id);
			//    result.DefaultPrice = completeItemInfo.Price;
			//}
			#endregion

			#region Item Groups

			XElement codeElement = lineItemElement.Element(PortaXmlName.SupplierItemCode);
			string codeToMatch = PortaIntegrationFactory.GetFamilyCodeForInvoice(codeElement, completeItemInfo);

			if (!String.IsNullOrEmpty(codeToMatch))
			{
				List<Guid> matchingItemGroups = null;
				bool groupsEdit = PortaIntegrationFactory.GetNewGroupMemberships(codeToMatch, itemGroups, out matchingItemGroups);

				if (groupsEdit && matchingItemGroups != null)
				{
					result = result ?? (Item)itemCoordinator.LoadBusinessObject(BusinessObjectType.Item, id);
					result.AppendGroupMemberships(matchingItemGroups);
				}
			}
			
			#endregion

			return result;
		}

		private static Item UpdateMissingItemPropertiesForSalesOrder(ItemCoordinator itemCoordinator, Guid id, string code, XElement itemDetails, List<DocumentLineSimpleInfo> linesInfo, List<ItemInfo> completeInfoFull, XElement itemGroups)
		{
			Item result = null;
			ItemInfo completeItemInfo = completeInfoFull.Where(ci => ci.Code == code).FirstOrDefault();
			DocumentLineSimpleInfo lineInfo = linesInfo.Where(ci => ci.ItemCode == code).FirstOrDefault();

			if (itemDetails != null)
			{
				/*
				 * <root>
					  <item defaultPrice="0.00" itemTypeId="DD659840-E90E-4C28-8774-4D07B307909A" unitId="2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C" vatRateId="390E10FC-82C5-41CB-9BD0-29059CB4872D" version="35C160E6-E7F5-4B09-A1AF-25FC99FC6624" name="SPFP520P08NK11SB2KO300" id="98B954EA-781B-416B-A4D6-A5D4CA76A86E" code="SPFP520P08NK11SB2KO300">
						<priceList />
					  </item>
					</root>
				 */
				XAttribute nameAttr = itemDetails.Attribute(XmlName.Name);
				XAttribute defaultPrice = itemDetails.Attribute("defaultPrice");
				decimal defaultPriceValue = defaultPrice != null ? Convert.ToDecimal(defaultPrice.Value, CultureInfo.InvariantCulture) : 0;

				XElement oldBarcodes = itemDetails.Element("barcodes");
				string newBarcode = completeItemInfo != null ? completeItemInfo.Barcode : null;
				bool isBarcodeNew = Utils.IsNewValue(oldBarcodes, newBarcode);

				List<Guid> matchingItemGroups = null;
				string familyCode = PortaIntegrationFactory.GetFamilyCodeForSalesOrder(lineInfo, completeItemInfo);
				bool groupsEdit = PortaIntegrationFactory.GetNewGroupMemberships(familyCode, itemGroups, out matchingItemGroups);


                result = (Item)itemCoordinator.LoadBusinessObject(BusinessObjectType.Item, id);
                //24.11.2015 prośba klienta o usunięcie warunku
                if ( lineInfo.DefaultPrice != 0 ) // && !lineInfo.PurchasePrice)
                {
                    result.DefaultPrice = lineInfo.DefaultPrice;
                }
                if (isBarcodeNew)
                {
                    PortaIntegrationFactory.InsertBarcode(result, newBarcode);
                }

                if (lineInfo.Name != null && nameAttr != null && nameAttr.Value != lineInfo.Name)
                {
                    result.Name = lineInfo.Name;
                }
                if (groupsEdit)
                {
                    result.AppendGroupMemberships(matchingItemGroups);
                }
                if (String.IsNullOrEmpty(result.Name) && !String.IsNullOrEmpty(lineInfo.Name))
                {
                    result.Name = lineInfo.Name;
                }
                if (String.IsNullOrEmpty(result.Name) && String.IsNullOrEmpty(lineInfo.Name))
                {
                    result.Name = String.Format("PORTA {0}", result.Code);
                }
				
			}

			return result;
		}

		private static void UpdateItemForSalesOrder(Item item, List<DocumentLineSimpleInfo> linesInfo, List<ItemInfo> completeInfoFull, int lineNumber)
		{
			DocumentLineSimpleInfo lineDetails = linesInfo[lineNumber - 1];
			ItemInfo completeItemInfo = completeInfoFull.Where(ci => ci.Code == lineDetails.ItemCode).FirstOrDefault();

			item.Code = lineDetails.ItemCode;
			#region Group Memberships
			string family = PortaIntegrationFactory.GetFamilyCodeForSalesOrder(lineDetails, completeItemInfo);

			if (!String.IsNullOrEmpty(family))
			{
				item.AppendGroupMemberships(DictionaryMapper.Instance.GetItemGroupsIds(family));
			}
			#endregion
			if (completeItemInfo != null)
			{
				PortaIntegrationFactory.InsertBarcode(item, completeItemInfo.Barcode);
				item.Name = completeItemInfo.Name;
				//item.DefaultPrice = completeItemInfo.Price;
			}
            //Cena domyślna
            if (lineDetails.DefaultPrice != 0 ) ///&& !lineDetails.PurchasePrice)
            {
                item.DefaultPrice = lineDetails.DefaultPrice;
            }
            if (lineDetails.Name != null && item.Name != null && item.Name != lineDetails.Name)
            {
                item.Name = lineDetails.Name;
            }
            if (String.IsNullOrEmpty(item.Name) && !String.IsNullOrEmpty(lineDetails.Name))
            {
                item.Name = lineDetails.Name;
            }
			if (String.IsNullOrEmpty(item.Name))
			{
				item.Name = String.Format("PORTA {0}", item.Code);
			}


		}

		private static void UpdateItemForInvoice(Item item, XElement source, XElement missingItemElement, int lineNumber, List<ItemInfo> completeInfoFull)
		{
			XElement lineItemElement = source.XPathSelectElements(
				String.Format(@"Invoice-Lines/Line/Line-Item[LineNumber = {0}]", lineNumber)).FirstOrDefault();
			PortaIntegrationFactory.UpdateItemForInvoice(item, missingItemElement, lineItemElement, completeInfoFull);
		}

		private static void UpdateItemForInvoice(Item item, XElement codeElement, XElement portaXmlLineItemElement, List<ItemInfo> completeInfoFull)
		{
			if (portaXmlLineItemElement == null)
				throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
			bool invalidFormat = false;

			#region Code
			codeElement = codeElement.Element(XmlName.Code);
			if (codeElement != null)
				item.Code = codeElement.Value;
			#endregion

			#region Unit
			Unit unit = DictionaryMapper.Instance.GetUnit("szt.");
			if (unit == null)
				unit = DictionaryMapper.Instance.GetUnit("szt");
			/*
			XElement unitElement = portaXmlLineItemElement.Element(PortaXmlName.UnitOfMeasure);
			if (unitElement != null)
			{
				string portaUnitSymbol = unitElement.Value;
				SymbolConverter portaUnitConverter = new SymbolConverter(ConvertersConfigKey.DictionarySymbolUnitPorta);
				string nativeUnitSymbol = portaUnitConverter.ConvertSymbol(portaUnitSymbol);

				Unit unit = DictionaryMapper.Instance.GetUnit(nativeUnitSymbol);
				if (unit != null && unit.Id.HasValue)
				{
					item.UnitId = unit.Id.Value;
				}
				else
					invalidFormat = true;
			}
			else
				invalidFormat = true;
			 */
			#endregion

			#region Vat Rate
			Guid? vatRateId = PortaIntegrationFactory.GetVatRateId(portaXmlLineItemElement);
            if (vatRateId.HasValue)
            {
                item.VatRateId = vatRateId.Value;
            }
            else
            {
                item.VatRateId = (Guid)DictionaryMapper.Instance.GetVatRate("23").Id;
            }
			//zmiana formatu plików wejściowych, nie zawierają vat	invalidFormat = true;
			#endregion

			ItemInfo completeItemInfo = completeInfoFull.Where(ci => ci.Code == item.Code).FirstOrDefault();

			#region Name
			XElement descElement = portaXmlLineItemElement.Element(PortaXmlName.ItemDescription);
			string newName = descElement != null && !String.IsNullOrEmpty(descElement.Value) ?
				descElement.Value : completeItemInfo != null && !String.IsNullOrEmpty(completeItemInfo.Name) ?
				completeItemInfo.Name : null;

			if (newName != null)
				item.Name = newName;

			if (String.IsNullOrEmpty(item.Name))
			{
				item.Name = String.Format("PORTA {0}", item.Code);
			}
			#endregion

			#region EAN
			XElement eanElement = portaXmlLineItemElement.Element(PortaXmlName.EAN);
			if (eanElement != null && !String.IsNullOrEmpty(eanElement.Value))
			{
				PortaIntegrationFactory.InsertBarcode(item, eanElement.Value);
			}
			else if (completeItemInfo != null && !String.IsNullOrEmpty(completeItemInfo.Barcode))
			{
				PortaIntegrationFactory.InsertBarcode(item, completeItemInfo.Barcode);
			}
			#endregion

			#region PKWiU
			string pkwiu = PortaIntegrationFactory.GetPKWiU(portaXmlLineItemElement);
			if (pkwiu != null)
			{
				ItemAttrValue pkwiuAttr = item.Attributes.GetOrCreateNew(ItemFieldName.Attribute_PKWiU);
				pkwiuAttr.Value.Value = pkwiu;
			}
			#endregion

			#region Price

			item.DefaultPrice = 0;
			//if (completeItemInfo != null)
			//{
			//    item.DefaultPrice = completeItemInfo.Price;
			//}

			#endregion

			#region Item Groups

			string familyCode = PortaIntegrationFactory.GetFamilyCodeForInvoice(codeElement, completeItemInfo);
			if (!String.IsNullOrEmpty(familyCode))
			{
				item.AppendGroupMemberships(DictionaryMapper.Instance.GetItemGroupsIds(familyCode));
			}

			#endregion

			if (invalidFormat)
				throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
		}

		private static Guid? GetVatRateId(XElement portaXmlLineItemElement)
		{
			string nativeVatRateSymbol = PortaIntegrationFactory.GetVatRateSymbol(portaXmlLineItemElement);

			if (nativeVatRateSymbol != null)
			{
				VatRate vatRate = DictionaryMapper.Instance.GetVatRate(nativeVatRateSymbol);
				if (vatRate != null && vatRate.Id.HasValue)
				{
					return vatRate.Id.Value;
				}
				else
					return null;
			}
			else
				return null;
		}

		private static string GetVatRateSymbol(XElement portaXmlLineItemElement)
		{
			XElement taxCategoryCodeElement = portaXmlLineItemElement.Element(PortaXmlName.TaxCategoryCode);
			XElement taxRateElement = portaXmlLineItemElement.Element(PortaXmlName.TaxRate);
			if (taxCategoryCodeElement != null)
			{
				if (taxCategoryCodeElement.Value == "E")
				{
					return "zw";
				}
				else if (taxRateElement != null)
				{
					return taxRateElement.Value.Contains('.') 
						? taxRateElement.Value.Trim().SubstringBefore(".") : taxRateElement.Value.Trim();
				}
				else
					return null;
			}
			else return null;
		}

		private static char GetCsvSeparator(string input)
		{
			StringBuilder sb = new StringBuilder();
			bool allComas = true;
			bool allColons = true;
			using (StringReader sr = new StringReader(input))
			{
				while (sr.Peek() > 0)
				{
					string line = sr.ReadLine();
					if (!line.Contains(','))
					{
						allComas = false;
					}
					if (!line.Contains(';'))
					{
						allColons = false;
					}
				}
			}

			if (allComas)
				return ',';
			if (allColons)
				return ';';
			return ',';
		}

		private static string[] FilterCsv(string input, char delimiter)
		{
			StringBuilder sb = new StringBuilder();
			int lineNumber = 0;
			string lastRow = String.Empty;
			using (StringReader sr = new StringReader(input))
			{
				while (sr.Peek() > 0)
				{
					string line = sr.ReadLine();
					if (line.Count(c => c == delimiter) >= 3)
					{
						sb.AppendLine(line);
					}
					else if (line.Count(c => c == delimiter) == 1 && lineNumber++ != 0)
					{
						lastRow = line;
					}
				}
			}
			return new string[] { sb.ToString(), lastRow };
		}

		private static string GetPKWiU(XElement portaXmlLineItemElement)
		{
			XElement taxReferenceElement = portaXmlLineItemElement.Element(PortaXmlName.TaxReference);
			if (taxReferenceElement != null)
			{
				XElement refTypeElememt = taxReferenceElement.Element(PortaXmlName.ReferenceType);
				if (refTypeElememt != null && refTypeElememt.Value == "PKWiU")
				{
					XElement refNumberElement = taxReferenceElement.Element(PortaXmlName.ReferenceNumber);
					if (refNumberElement != null)
					{
						return refNumberElement.Value;
					}
				}
			}
			return null;
		}

		private static string GetOrderNumber(XElement element)
		{
			XElement orderElement = element.Element(PortaXmlName.LineOrder);
			if (orderElement == null)
			{
				orderElement = element.Element(PortaXmlName.Order);
			}
			if (orderElement != null)
			{
				XElement buyerOrderElement = orderElement.Element(PortaXmlName.BuyerOrderNumber);
				if (buyerOrderElement != null)
				{
					return buyerOrderElement.Value.Contains("@") ? buyerOrderElement.Value.SubstringAfter("@") : buyerOrderElement.Value;
				}
			}
			return null;
		}

		private static ItemAttrValue InsertBarcode(Item item, string barcodeValue)
		{
			ItemAttrValue barcode = item.Attributes.CreateNew(ItemFieldName.Attribute_Barcode);
			barcode.Value.Value = barcodeValue;
			return barcode;
		}

		private static void AppendSourceTypeAttribute(CommercialDocument destination, XElement source)
		{
			if (source.Attribute(XmlName.Type) != null)
			{
				destination.Attributes.GetOrCreateNew(DocumentFieldName.Attribute_DocumentSourceType).Value.Value
					= source.Attribute(XmlName.Type).Value;
			}
		}
	}
}
