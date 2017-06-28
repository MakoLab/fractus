using System;
using System.Collections.Generic;
using System.Xml.Linq;
using System.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents.Options
{
	internal class GenerateDocumentOption : IDocumentOption
	{

		public const string OutcomeFromSalesMethod = "outcomeFromSales";
		public const string IncomeFromPurchaseMethod = "incomeFromPurchase";
		public const string FinancialFromCommercialMethod = "financialFromCommercial";

		private string method;
		public string Method { get { return this.method; } }

		public GenerateDocumentOption(XElement element)
		{
			this.method = element.Attribute("method").Value;
		}

		public void Execute(Document document)
		{
			if (document.IsBeforeSystemStart)
				return;

			CommercialDocument commercialDocument = document as CommercialDocument;

			#region Outcome From Sales
			
			if (this.method == OutcomeFromSalesMethod)
			{
				//Pobranie konfiguracji dla typu dokumentu
				XElement configurationSettings = commercialDocument.DocumentType.Options;
				String templateName;
				try 
					{
						templateName = (string)configurationSettings.Descendants("generateDocument").Attributes("templateName").Single();
					}
					catch (Exception)
					{
                        //RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:4");
						templateName = "externalOutcome";
					}

				ICollection<WarehouseDocument> warehouses = CommercialWarehouseDocumentFactory.Generate(commercialDocument, templateName, true, false);

				if (warehouses.Count > 0)
				{
					CommercialWarehouseDocumentFactory.RelateCommercialLinesToWarehousesLines(commercialDocument, warehouses, false, false, true, false);

					XElement source = document.Source;

					if (source != null && (source.Attribute("type").Value == "order" || source.Attribute("type").Value == SourceType.SalesOrderRealization))
					{
						DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
						CommercialDocument order = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(source.Attribute("commercialDocumentId").Value));

						CommercialWarehouseDocumentFactory.RelateWarehousesLinesToOrderLines(warehouses, order, commercialDocument.Source, true, false);

						/*if (SalesOrderFactory.TryCloseSalesOrder(order))
							commercialDocument.AddRelatedObject(order);*/
					}
					else if (source != null && source.Attribute("type").Value == "multipleReservations")
					{
						DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
						List<CommercialDocument> reservations = new List<CommercialDocument>();

						foreach (var orderXml in source.Elements().Where(e => e.Name != "extraParams"))
						{
							CommercialDocument order = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(orderXml.Value));
							reservations.Add(order);
						}

						CommercialWarehouseDocumentFactory.RelateWarehousesLinesToMultipleOrdersLines(warehouses, reservations, true, false);
					}
				}
			}

			#endregion

			#region Income From Purchase

			else if (this.method == IncomeFromPurchaseMethod)
			{
				ICollection<WarehouseDocument> warehouses = CommercialWarehouseDocumentFactory.Generate(commercialDocument, "externalIncome", true, false);

				if (warehouses.Count > 0)
				{
					CommercialWarehouseDocumentFactory.RelateCommercialLinesToWarehousesLines(commercialDocument, warehouses, true, false, true, false);

					XElement source = document.Source;

					if (source != null && source.Attribute("type").Value == "order")
					{
						DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
						CommercialDocument order = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(source.Attribute("commercialDocumentId").Value));

						CommercialWarehouseDocumentFactory.RelateWarehousesLinesToOrderLines(warehouses, order, commercialDocument.Source, true, false);
					}
				}
			}

			#endregion

			else if (this.method == FinancialFromCommercialMethod)
			{
                //Warunek na istnienie jakiego kolwiek settlementu, bez tego nie chciał się dogenerować dokument finansowy
                //Błąd mówił o niejednoznacznych relacjach uniemożliwiających zaktualizowanie dokumentu finansowego
                bool cos = commercialDocument.Payments.Any(p => p.Settlements.Children.Count > 0);
                if (document.IsNew || !cos)
					FinancialDocumentFactory.GenerateFinancialDocumentToCommercialDocument(commercialDocument);
				else
					FinancialDocumentFactory.UpdateFinancialDocumentsInCommercialDocument(commercialDocument);
			}
		}

		public XElement Serialize()
		{
			XElement element = new XElement("generateDocument", new XAttribute("method", this.method));
			return element;
		}

		public bool ExecuteWithinTransaction
		{
			get { return false; }
		}
	}
}
