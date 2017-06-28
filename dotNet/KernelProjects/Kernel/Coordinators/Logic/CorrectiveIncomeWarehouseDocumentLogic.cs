using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class CorrectiveIncomeWarehouseDocumentLogic : CorrectiveWarehouseDocumentLogic
    {
        public CorrectiveIncomeWarehouseDocumentLogic(DocumentCoordinator coordinator)
            : base(coordinator)
        { }

        private bool CheckForQuantityBelowRelated(WarehouseDocument document)
        {
            bool outcomeCorrectionNeeded = false;
            WarehouseItemQuantityDictionary whItemDict = new WarehouseItemQuantityDictionary();
            List<DeliveryRequest> deliveryRequests = new List<DeliveryRequest>();

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                decimal relatedQuantity = ((WarehouseDocumentLine)line.AlternateVersion).IncomeOutcomeRelations.Children.Sum(s => s.Quantity);

                if (relatedQuantity > 0)
                    outcomeCorrectionNeeded = true;
                /*
                if (line.Quantity < relatedQuantity)
                {
                    string unit = BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(DictionaryMapper.Instance.GetUnit(line.UnitId)).Attribute("symbol").Value;
                    throw new ClientException(ClientExceptionId.WarehouseCorrectionError4, null,
                        "itemName:" + line.ItemName,
                        "count:" + relatedQuantity.ToString("G", CultureInfo.CreateSpecificCulture("pl-PL")),
                        "unit:" + unit);
                }*/ //to byla dawna walidacja zeby nie moznabylo korygowac ponizej wartosci rozchodowanej. teraz jest ona inna bo mozna, ale nie mozna zejsc globalnie z towarem ponizej zera

                decimal differentialQuantity = line.Quantity - ((WarehouseDocumentLine)line.AlternateVersion).Quantity;

                whItemDict.Add(document.WarehouseId, line.ItemId, differentialQuantity);

                DeliveryRequest delivery = deliveryRequests.Where(d => d.ItemId == line.ItemId && d.WarehouseId == line.WarehouseId).FirstOrDefault();

                if (delivery == null)
                    deliveryRequests.Add(new DeliveryRequest(line.ItemId, line.WarehouseId, line.UnitId));
            }

            //pobieramy dostawy
            ICollection<DeliveryResponse> deliveryResponses = this.mapper.GetDeliveries(deliveryRequests);

            //iterujemy po naszym slowniku i sprawdzamy czy ilosci sa na stanie
			if (whItemDict.Dictionary.ContainsKey(document.WarehouseId))
			{
				var dctItemQuantity = whItemDict.Dictionary[document.WarehouseId];

				foreach (var key in dctItemQuantity.Keys) //iterujemy po itemId
				{
					var delivery = deliveryResponses.Where(d => d.ItemId == key).First();

					if (delivery.QuantityInStock - Math.Abs(dctItemQuantity[key]) < 0)
					{
						//wyciagamy nazwe towaru
						string itemName = document.Lines.Where(l => l.ItemId == delivery.ItemId).First().ItemName;
						string warehouseName = BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(DictionaryMapper.Instance.GetWarehouse(document.WarehouseId)).Value;
						throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + warehouseName);
					}
				}
			}

			return outcomeCorrectionNeeded;
        }

        public XDocument ProcessWarehouseCorrectiveDocument(WarehouseDocument document)
        {
            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();

                this.MakeDifferentialDocument(document);

				if (document.DocumentType.WarehouseDocumentOptions.UpdateLastPurchasePrice)
				{
					UpdateLastPurchasePriceRequest updateLastPurchasePriceRequest = new UpdateLastPurchasePriceRequest(document);
					this.mapper.UpdateStock(updateLastPurchasePriceRequest);
				}

                //sprawdzamy czy nie zmniejszylismy gdzies ilosci ponizej ilosci ktora zostala juz rozchodowana
                bool outcomeCorrectionNeeded = this.CheckForQuantityBelowRelated(document);

                document.AlternateVersion = null;
                this.coordinator.UpdateStock(document);

                WarehouseDocument incomeCorrection = (WarehouseDocument)this.coordinator.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, document.Source.Attribute("template").Value, null);
                incomeCorrection.Contractor = document.Contractor;
                incomeCorrection.WarehouseId = document.WarehouseId;
				DuplicableAttributeFactory.CopyAttributes(document, incomeCorrection);
				incomeCorrection.UpdateStatus(true);
                this.SaveDocumentHeaderAndAttributes(incomeCorrection);

                WarehouseDocument outcomeCorrection = null;
                int? outcomeCorrectionOrdinalNumber = null;
                Guid? outcomeCorrectionHeaderId = null;

                if (outcomeCorrectionNeeded)
                {
                    DocumentType dt = incomeCorrection.DocumentType;
                    string template = dt.WarehouseDocumentOptions.AutomaticCostCorrectionTemplate;

                    if (String.IsNullOrEmpty(template))
                        throw new InvalidOperationException("automaticCostCorrectionTemplate is not set for the document type: " + dt.Symbol);

                    outcomeCorrection = (WarehouseDocument)this.coordinator.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, template, null);
                    outcomeCorrection.WarehouseId = document.WarehouseId;
					outcomeCorrection.UpdateStatus(true);
                    this.SaveDocumentHeaderAndAttributes(outcomeCorrection);
                    outcomeCorrectionOrdinalNumber = 0;
                    outcomeCorrectionHeaderId = outcomeCorrection.Id.Value;
                }

                int incomeCorrectionOrdinalNumber = 0;
                XDocument xml = null;
                XDocument operations = XDocument.Parse("<root><incomeOutcomeRelation/><commercialWarehouseRelation/><commercialWarehouseValuation/></root>");

                foreach (WarehouseDocumentLine line in document.Lines.Children)
                {
                    Guid? commercialCorrectiveLineId = null;

                    if (line.CommercialCorrectiveLine != null)
                        commercialCorrectiveLineId = line.CommercialCorrectiveLine.Id;

                    xml = this.mapper.CreateIncomeQuantityCorrection(line.Id.Value, line.Version.Value, incomeCorrection.Id.Value,
                        outcomeCorrectionHeaderId, line.Quantity, line.Value, line.IncomeDate.Value, incomeCorrectionOrdinalNumber, 
                        outcomeCorrectionOrdinalNumber, commercialCorrectiveLineId);

					//Prowizorka umieszczona w celu wychwycenia trudnego do zlokalizowania błędu - przerzucam komunikat od Czarka w wyjątku
					if (!xml.Root.HasElements)
						throw new ClientException(ClientExceptionId.ForwardError, null
							, String.Format("message:{0}", xml.Root.Value));

                    incomeCorrectionOrdinalNumber = Convert.ToInt32(xml.Root.Element("incomeOrdinalNumber").Value, CultureInfo.InvariantCulture);

                    if (outcomeCorrectionOrdinalNumber != null)
                        outcomeCorrectionOrdinalNumber = Convert.ToInt32(xml.Root.Element("outcomeOrdinalNumber").Value, CultureInfo.InvariantCulture);

                    if (xml.Root.Element("incomeOutcomeRelation") != null)
                        operations.Root.Element("incomeOutcomeRelation").Add(xml.Root.Element("incomeOutcomeRelation").Elements());

                    if (xml.Root.Element("commercialWarehouseRelation") != null)
                        operations.Root.Element("commercialWarehouseRelation").Add(xml.Root.Element("commercialWarehouseRelation").Elements());

                    if (xml.Root.Element("commercialWarehouseValuation") != null)
                        operations.Root.Element("commercialWarehouseValuation").Add(xml.Root.Element("commercialWarehouseValuation").Elements());
                }

                if (ConfigurationMapper.Instance.IsWmsEnabled &&
                    DictionaryMapper.Instance.GetWarehouse(incomeCorrection.WarehouseId).ValuationMethod == ValuationMethod.DeliverySelection)
                {
                    using (WarehouseCoordinator whC = new WarehouseCoordinator(false, false))
                    {
                        ShiftTransaction st = (ShiftTransaction)whC.CreateNewBusinessObject(BusinessObjectType.ShiftTransaction, null, null);
                        st.UpdateStatus(true);
                        XDocument shiftTransactionOperations = XDocument.Parse("<root/>");
                        st.SaveChanges(shiftTransactionOperations);
                        this.mapper.ExecuteOperations(shiftTransactionOperations);
                        this.mapper.CreateShiftCorrection(incomeCorrection.Id.Value, st.Id.Value);
                    }
                }

                if (outcomeCorrection != null)
                    this.mapper.ValuateOutcomeWarehouseDocument(outcomeCorrection);

                this.mapper.CreateCommunicationXml(incomeCorrection);

                if (outcomeCorrection != null)
                    this.mapper.CreateCommunicationXml(outcomeCorrection);

                this.mapper.CreateCommunicationXmlForDocumentRelations(operations);

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", incomeCorrection.Id.ToUpperString()));

				//Custom validation
				this.mapper.ExecuteOnCommitValidationCustomProcedure(incomeCorrection);
				if (outcomeCorrection != null)
					this.mapper.ExecuteOnCommitValidationCustomProcedure(outcomeCorrection);

				if (this.coordinator.CanCommitTransaction)
                {
                    if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
                        SqlConnectionManager.Instance.CommitTransaction();
                    else
                        SqlConnectionManager.Instance.RollbackTransaction();
                }

                return returnXml;
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:55");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:56");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
