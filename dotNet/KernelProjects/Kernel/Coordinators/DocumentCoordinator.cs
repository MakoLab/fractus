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
using Makolab.Fractus.Kernel.BusinessObjects.Documents.Options;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Coordinators.Logic;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Class that coordinates business logic of Document's BusinessObject
    /// </summary>
    public class DocumentCoordinator : TypedCoordinator<DocumentMapper>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentCoordinator"/> class.
        /// </summary>
        public DocumentCoordinator()
            : this(true, true)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentCoordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        public DocumentCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:23");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        public void FiscalizeCommercialDocument(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;

            CommercialDocument commercialDocument = (CommercialDocument)this.Mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(requestXml.Root.Element("id").Value));

            DocumentAttrValue attr = commercialDocument.Attributes.CreateNew();
            attr.DocumentFieldName = DocumentFieldName.Attribute_FiscalPrintDate;

            attr.Value.Value = SessionManager.VolatileElements.CurrentDateTime.ToIsoString();
            commercialDocument.SkipCorrectionEditCheck = true;
            commercialDocument.SkipRealizeClosedSalesOrderCheck = true;

            this.SaveBusinessObject(commercialDocument);
        }

        /// <summary>
        /// Checks whether the specified number already exists.
        /// </summary>
        /// <param name="requestXml">Client request xml containing seriesValue and number.</param>
        /// <returns>true if the number already exists; otherwise false.</returns>
        public bool CheckNumberExistence(XDocument requestXml)
        {
            if (requestXml.Root.Element("seriesValue") == null)
                throw new ArgumentException("seriesValue is required in input xml.");

            if (requestXml.Root.Element("number") == null)
                throw new ArgumentException("number is required in input xml.");

            return ((DocumentMapper)this.Mapper).IsNumberExist(requestXml.Root.Element("seriesValue").Value,
                Convert.ToInt32(requestXml.Root.Element("number").Value, CultureInfo.InvariantCulture));
        }

        public XDocument GetContractorDealing(XDocument requestXml)
        {
            Guid contractorId = new Guid(requestXml.Root.Element("contractorId").Value);
            int days = Convert.ToInt32(requestXml.Root.Element("days").Value, CultureInfo.InvariantCulture);

            DateTime date = SessionManager.VolatileElements.CurrentDateTime;
            date = date.Subtract(new TimeSpan(days, 0, 0, 0));
            date = new DateTime(date.Year, date.Month, date.Day, 0, 0, 0);

            decimal dealing = ((DocumentMapper)this.Mapper).GetContractorDealing(contractorId, date);

            return XDocument.Parse("<root>" + dealing.ToString(CultureInfo.InvariantCulture) + "</root>");
        }

        /// <summary>
        /// Creates a new <see cref="IBusinessObject"/>.
        /// </summary>
        /// <param name="type">Type of the <see cref="IBusinessObject"/> to create.</param>
        /// <param name="template">The template name for business object creation.</param>
        /// <returns>
        /// A newly created <see cref="IBusinessObject"/>.
        /// </returns>
        internal override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, string template, XElement source)
        {
            IBusinessObject bo = base.CreateNewBusinessObject(type, template, source);
            SimpleDocument simpleDocument = bo as SimpleDocument;
            Document document = bo as Document;



            #region Financial Document Handling
            if (bo.BOType == BusinessObjectType.FinancialDocument && !String.IsNullOrEmpty(template))
            {
                FinancialDocument financialDoc = (FinancialDocument)bo;
                XElement templateXml = ConfigurationMapper.Instance.Templates[bo.BOType][template].Element("financialDocument");
                FinancialReport financialReport = null;
                Guid? registerId = null;

                if (templateXml.Element("financialRegisterId") == null && templateXml.Element("documentTypeId") != null)
                {
                    Guid documentTypeId = new Guid(templateXml.Element("documentTypeId").Value);
                    int registerCategory = DictionaryMapper.Instance.GetDocumentType(documentTypeId).FinancialDocumentOptions.RegisterCategory;
                    registerId = DictionaryMapper.Instance.GetFirstFinancialRegisterId(registerCategory);

                    if (registerId != null)
                        financialReport = this.GetOpenedFinancialReport(registerId.Value);
                }
                else
                {
                    registerId = new Guid(templateXml.Element("financialRegisterId").Value);
                    financialReport = this.GetOpenedFinancialReport(registerId.Value);
                }

                if (financialReport != null)
                    financialDoc.FinancialReport = financialReport;
                else if (registerId != null)
                {
                    FinancialReport r = new FinancialReport();
                    r.FinancialRegisterId = registerId.Value;
                    r.Id = null;
                    financialDoc.FinancialReport = r;
                }
            }
            #endregion

            #region New Payments Handling
            IPaymentsContainingDocument paymentsContainingDocument = bo as IPaymentsContainingDocument;
            bool hasPaymentCollection = paymentsContainingDocument != null && paymentsContainingDocument.Payments != null;

            //Standardowe obliczenia dla nowych paymentów
            if (hasPaymentCollection)
            {
                foreach (Payment payment in paymentsContainingDocument.Payments)
                {
                    payment.LoadPaymentMethodDefaults();
                }
                //				DateTime subtrahend = simpleDocument.
                //paymentsContainingDocument.Payments.CalculateDueDaysOnPayments();
            }
            #endregion

            //dodanie id profilu stanowiska
            this.TrySaveProfileIdAttribute(document);
            bool stackPosition = false;

            #region Source
            if (source != null)
            {
                /**
                 * If source has payments and there are payments in document (copy from template) they must be deleted
                 */
                if (hasPaymentCollection && paymentsContainingDocument.Payments.Children.Count() > 0)
                {
                    paymentsContainingDocument.Payments.Children.Clear();
                }

                switch (source.Attribute("type").Value)
                {
                    case "outcomeShift":
                        WarehouseShiftDocumentFactory.CreateIncomeShiftDocumentFromOutcomeShift(source, (WarehouseDocument)bo);
                        break;
                    case "outcomeShiftFromWarehouseDocument":
                        WarehouseShiftDocumentFactory.CreateOutcomeShiftFromWarehouseDocument(source, (WarehouseDocument)bo);
                        break;
                    case SourceType.SalesOrderRealization:
                    case "order":
                        if (type == BusinessObjectType.WarehouseDocument)
                        {
                            WarehouseDocument whDoc = (WarehouseDocument)bo;
                            CommercialWarehouseDocumentFactory.GenerateOrderRealizationDocument(source, whDoc);
                            whDoc.DocumentOptions.Add(new RealizeOrderOption());
                        }
                        else if (type == BusinessObjectType.CommercialDocument)
                        {
                            XElement warehouseTemplateXml = ConfigurationMapper.Instance.Templates[bo.BOType][template].Element("commercialDocument");
                            if (warehouseTemplateXml != null && warehouseTemplateXml.Attribute("category") != null && warehouseTemplateXml.Attribute("category").Value == "production")
                            {
                                if (warehouseTemplateXml.Element("materialProduction").Value == "1")
                                    CommercialDocumentFactory.GenerateProductionOrderForMaterialFromCommercialDocument(source, (CommercialDocument)bo);
                                else
                                    CommercialDocumentFactory.GenerateProductionOrderFromCommercialDocument(source, (CommercialDocument)bo);
                                //category="production"
                            }
                            else
                                CommercialDocumentFactory.GenerateSalesDocumentFromCommercialDocument(source, (CommercialDocument)bo);
                        }
                        break;
                    case "technology":
                        if (type == BusinessObjectType.WarehouseDocument)
                        {
                            WarehouseDocument whDoc = (WarehouseDocument)bo;
                            CommercialWarehouseDocumentFactory.GenerateOrderRealizationDocument(source, whDoc);
                            whDoc.DocumentOptions.Add(new RealizeOrderOption());
                        }
                        else if (type == BusinessObjectType.CommercialDocument)
                            CommercialDocumentFactory.GenerateSalesDocumentFromCommercialDocument(source, (CommercialDocument)bo);
                        break;
                    case "multipleReservations":
                        //Pobieram info z templejta, posłuży do mapowania lub stackowania itemków na handlowym
                        if (!String.IsNullOrEmpty(template))
                        {
                            XElement warehouseTemplateXml = ConfigurationMapper.Instance.Templates[bo.BOType][template].Element("commercialDocument");
                            if (warehouseTemplateXml != null)
                            {
                                if (warehouseTemplateXml.Element("stackPosition") != null)
                                    stackPosition = Convert.ToBoolean(warehouseTemplateXml.Element("stackPosition").Value);
                            }
                        }

                        if (type == BusinessObjectType.CommercialDocument)
                        {

                            if (!stackPosition)
                            {
                                //bo.FullXml
                                CommercialDocumentFactory.GenerateInvoiceFromMultipleReservations(source, (CommercialDocument)bo);
                            }
                            else
                                CommercialDocumentFactory.CreateStackCommercialDocumentFromMultipleReservations((CommercialDocument)bo, source);
                        }
                        else
                        {

                            WarehouseDocument whDoc = (WarehouseDocument)bo;
                            if (!stackPosition)
                                CommercialWarehouseDocumentFactory.GenerateWarehouseDocumentFromMultipleReservations(source, whDoc);
                            else
                                CommercialWarehouseDocumentFactory.GenerateStackWarehoueDocumentFromMultipleReservations(source, whDoc);

                            whDoc.DocumentOptions.Add(new RealizeOrderOption());
                        }
                        break;
                    case "warehouseDocument":
                        //Pobieram info z templejta, posłuży do mapowania lub stackowania itemków na handlowym
 

                        if (bo.BOType == BusinessObjectType.CommercialDocument && !String.IsNullOrEmpty(template))
                        {
                            XElement warehouseTemplateXml = ConfigurationMapper.Instance.Templates[bo.BOType][template].Element("commercialDocument");
                            if (warehouseTemplateXml != null && warehouseTemplateXml.Element("stackPosition") != null)
                                stackPosition = Convert.ToBoolean(warehouseTemplateXml.Element("stackPosition").Value);
                            
                        }
                        if (!stackPosition)
                            CommercialWarehouseDocumentFactory.CreateCommercialDocumentFromWarehouseDocument((CommercialDocument)bo, source);
                        else
                            CommercialWarehouseDocumentFactory.CreateStackCommercialDocumentFromWarehouseDocument((CommercialDocument)bo, source);
                        break;
                    case "clipboard":
                        CommercialWarehouseDocumentFactory.GenerateDocumentFromClipboard(source, (Document)bo);
                        break;
                    case "correction":
                        if (bo.BOType == BusinessObjectType.CommercialDocument)
                            CommercialCorrectiveDocumentFactory.CreateCorrectiveDocument(source, (CommercialDocument)bo);
                        else if (bo.BOType == BusinessObjectType.WarehouseDocument)
                            WarehouseCorrectiveDocumentFactory.CreateCorrectiveDocument(source, (WarehouseDocument)bo);
                        break;
                    case "financialRegister":
                        FinancialDocumentFactory.CreateFinancialReportToFinancialRegister(source, (FinancialReport)bo);
                        break;
                    case "externalDocument":
                        CommercialWarehouseDocumentFactory.GenerateDocumentFromExternalDocument(source, (Document)bo);
                        break;
                    case "serviceDocument":
                        CommercialDocumentFactory.GenerateInvoiceFromServiceDocument(source, (CommercialDocument)bo);
                        break;
                    case "invoiceToBill":
                        CommercialDocument commercialDocument = (CommercialDocument)bo;
                        CommercialDocumentFactory.GenerateInvoiceFromBill(source, commercialDocument);
                        commercialDocument.DisableLinesChange = DisableDocumentChangeReason.LINES_INVOICE_FROM_BILL;
                        break;
                    case "appendToInventoryDocument":
                        InventoryDocumentFactory.CreateInventorySheetToInventoryDocument((InventorySheet)bo, source);
                        break;
                    case "servicedObject":
                        CommercialDocumentFactory.GenerateServiceDocumentFromServicedObject(source, (ServiceDocument)bo);
                        break;
                    case SourceType.SimulatedInvoice:
                        CommercialDocumentFactory.GenerateSalesDocumentFromSimulatedInvoice(source, (CommercialDocument)bo);
                        break;
                    case "externalDocument2":
                        CommercialDocumentFactory.GeneratePurchaseDocumentFromExternalDocument(source, (CommercialDocument)bo);
                        break;
                    case "orderDbXml":
                        CommercialDocumentFactory.GenerateReservationFromOrderDbXml(source, (CommercialDocument)bo);
                        break;
                    case SourceType.SalesOrder:
                        if (bo.BOType == BusinessObjectType.CommercialDocument)
                            SalesOrderFactory.GeneratePrepaymentDocument(source, (CommercialDocument)bo);
                        else if (bo.BOType == BusinessObjectType.FinancialDocument)
                            SalesOrderFactory.BindCashOutcomeDocumentToSalesOrder(source, (FinancialDocument)bo);
                        break;
                    case SourceType.MultipleSalesOrders:
                        if (template == "purchaseInvoice")
                            SalesOrderFactory.GeneratePurchaseInvoiceFromMultipleSalesOrders(source, (CommercialDocument)bo);
                        else
                        {
                            SalesOrderFactory.GenerateInvoiceFromMultipleSalesOrders(source, (CommercialDocument)bo);
                        }
                        break;
                    case SourceType.SalesDocument:
                        Guid docId = new Guid(source.Element("salesDocumentId").Value);
                        DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
                        CommercialDocument doc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);

                        if (doc.DocumentType.DocumentCategory.ToString() == "13")
                        {
                            SalesOrderFactory.GenerateSalesOrderFromBill(source, (CommercialDocument)bo);
                        }
                        else
                        {
                            if (type == BusinessObjectType.CommercialDocument)
                                CommercialDocumentFactory.GenerateSalesDocumentFromCommercialDocument(source, (CommercialDocument)bo);
                            if (type == BusinessObjectType.WarehouseDocument)
                            {
                                //WarehouseDocument whDoc = (WarehouseDocument)bo;
                                ICollection<WarehouseDocument> generatedOutcomes = CommercialWarehouseDocumentFactory.Generate(doc, template, false, false);
                                bo = generatedOutcomes.FirstOrDefault();
                            }

                        }

                        break;
                    case SourceType.ExternalPortaSalesInvoice:
                        PortaIntegrationFactory.GeneratePurchaseInvoiceFromExternalSalesInvoice(source, (CommercialDocument)bo);
                        break;
                    case SourceType.PortaOrder:
                        PortaIntegrationFactory.GenerateSalesOrder(source, (CommercialDocument)bo, true);
                        break;
                    case SourceType.PortaOrderCsv:
                        PortaIntegrationFactory.GenerateSalesOrderCvs(source, (CommercialDocument)bo, true);
                        break;
                    case SourceType.EcOrder:
                        EcIntegrationFactory.GenerateSalesOrder(source, (CommercialDocument)bo, true);
                        //bo.FullXml.Root.Add(XElement.Load(source.Element("root").Element("itemsNotFound").CreateReader()));
                        break;
                }

                XElement src = new XElement(source);

                if (!String.IsNullOrEmpty(template))
                {
                    if (src.Attribute("template") == null)
                        src.Add(new XAttribute("template", template));
                    else
                        src.Attribute("template").Value = template;
                }

                if (simpleDocument != null)
                    simpleDocument.Source = src;
            }
            #endregion

            #region Number
            if (simpleDocument != null && simpleDocument.Number.NumberSettingId != Guid.Empty && simpleDocument.Number.SeriesId == null)
            {
                DocumentMapper documentMapper = (DocumentMapper)this.Mapper;
                string computedSeries = documentMapper.ComputeSeries(simpleDocument);
                simpleDocument.Number.Number = documentMapper.GetFreeNumberForSeries(simpleDocument.Number.NumberSettingId, computedSeries);
                simpleDocument.Number.FullNumber = documentMapper.ComputeFullDocumentNumber(simpleDocument, simpleDocument.Number.Number);
            }
            #endregion

            return bo;
        }

        /// <summary>
        /// Uzupełnienie id profilu stanowiska
        /// </summary>
        /// <param name="document"></param>
        internal void TrySaveProfileIdAttribute(Document document)
        {
            if (document != null)
            {
                DocumentAttrValue profileIdAttr = document.Attributes.GetOrCreateNew(DocumentFieldName.Attribute_DocumentIssueProfileId, true);
                if (String.IsNullOrEmpty(SessionManager.ProfileId))
                {
                    document.Attributes.Remove(profileIdAttr);
                }
                else
                {
                    profileIdAttr.Value.Value = SessionManager.ProfileId;
                }
            }
        }

        internal void RealizeSalesOrder(CommercialDocument salesOrder, XDocument requestXml)
        {
            /*
             * <root>
             *      <line id="...." quantity="..." />
             *      <line id="...." quantity="..." />
             *      <closeOrder>true</closeOrder>
             * </root>
             */

            DependencyContainerManager.Container.Get<DocumentMapper>().AddItemsToItemTypesCache(salesOrder);
            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            if (requestXml.Root.Element("closeOrder") != null && requestXml.Root.Element("closeOrder").Value.ToUpperInvariant() == "TRUE")
            {
                requestXml.Root.Elements("line").Remove();

                foreach (var line in salesOrder.Lines)
                {
                    Guid itemTypeId = cache[line.ItemId];
                    ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                    if (!itemType.IsWarehouseStorable)
                        continue;

                    decimal realizedQuantity = line.CommercialWarehouseRelations.Sum(r => r.Quantity);

                    if (realizedQuantity < line.Quantity)
                        requestXml.Root.Add(new XElement("line", new XAttribute("id", line.Id.ToUpperString()), new XAttribute("quantity", (line.Quantity - realizedQuantity).ToString(CultureInfo.InvariantCulture))));
                }

                salesOrder.DocumentStatus = DocumentStatus.Committed;
                SalesOrderFactory.CloseSalesOrder(salesOrder);
            }

            Dictionary<Guid, WarehouseDocument> dictWarehouseIdInternal = new Dictionary<Guid, WarehouseDocument>(); //slownik magazyn->RW
            Dictionary<Guid, WarehouseDocument> dictWarehouseIdExternal = new Dictionary<Guid, WarehouseDocument>(); //slownik magazyn->WZ

            Dictionary<Guid, WarehouseDocument> dictPointer = null;
            string documentName = null;
            bool reservationEnabled = false;

            foreach (var lineXml in requestXml.Root.Elements("line"))
            {
                var comLine = salesOrder.Lines.Where(l => l.Id.Value == new Guid(lineXml.Attribute("id").Value)).First();

                Guid itemTypeId = cache[comLine.ItemId];
                ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                if (!itemType.IsWarehouseStorable)
                    continue;

                decimal relatedQuantity = comLine.CommercialWarehouseRelations.Sum(r => r.Quantity);

                decimal quantity = Convert.ToDecimal(lineXml.Attribute("quantity").Value, CultureInfo.InvariantCulture);

                if (quantity > (comLine.Quantity - relatedQuantity))
                    throw new ClientException(ClientExceptionId.UnableToRealizeSalesOrder, null, "itemName:" + comLine.ItemName);

                WarehouseDocument whDoc = null;

                string option = comLine.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption].Value.Value;

                if (option == "1" || option == "3")
                {
                    dictPointer = dictWarehouseIdExternal;
                    documentName = "externalOutcome";
                }
                else if (option == "2" || option == "4")
                {
                    dictPointer = dictWarehouseIdInternal;
                    documentName = "internalOutcome";
                }

                if (option == "3" || option == "4")
                    reservationEnabled = true;
                else
                    reservationEnabled = false;

                if (dictPointer.ContainsKey(comLine.WarehouseId.Value))
                    whDoc = dictPointer[comLine.WarehouseId.Value];
                else
                {
                    string template = ProcessManager.Instance.GetDocumentTemplate(salesOrder, documentName);
                    whDoc = (WarehouseDocument)this.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, template, null);
                    whDoc.WarehouseId = comLine.WarehouseId.Value;
                    whDoc.Contractor = salesOrder.Contractor;
                    DuplicableAttributeFactory.DuplicateAttributes(salesOrder, whDoc);
                    string processType = salesOrder.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value;
                    ProcessManager.Instance.AppendProcessAttributes(whDoc, processType, documentName, null, null);
                    var relation = whDoc.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.SalesOrderToWarehouseDocument;
                    relation.DontSave = true;
                    relation.RelatedDocument = salesOrder;

                    relation = salesOrder.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.SalesOrderToWarehouseDocument;
                    relation.RelatedDocument = whDoc;

                    salesOrder.AddRelatedObject(whDoc);
                    dictPointer.Add(whDoc.WarehouseId, whDoc);
                }

                var whLine = whDoc.Lines.CreateNew();
                whLine.Quantity = quantity;
                whLine.ItemId = comLine.ItemId;
                whLine.ItemName = comLine.ItemName;
                whLine.ItemCode = comLine.ItemCode;
                whLine.UnitId = comLine.UnitId;

                var cwRelation = whLine.CommercialWarehouseRelations.CreateNew();
                cwRelation.RelatedLine = comLine;
                cwRelation.Quantity = quantity;
                cwRelation.IsOrderRelation = reservationEnabled;

                cwRelation = comLine.CommercialWarehouseRelations.CreateNew();
                cwRelation.RelatedLine = whLine;
                cwRelation.DontSave = true;
                cwRelation.Quantity = quantity;
                cwRelation.IsOrderRelation = reservationEnabled;
            }
        }

        public void ValuateIncomeShiftDocument(XElement outcomeShiftValuation)
        {
            Guid outcomeShiftId = new Guid(outcomeShiftValuation.Element("warehouseDocumentValuation").Attribute("outcomeShiftId").Value);

            WarehouseDocument document = ((DocumentMapper)this.Mapper).GetIncomeShiftByOutcomeId(outcomeShiftId);

            if (document == null)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            foreach (XElement entry in outcomeShiftValuation.Element("warehouseDocumentValuation").Elements())
            {
                int ordinalNumber = Convert.ToInt32(entry.Attribute("outcomeShiftOrdinalNumber").Value, CultureInfo.InvariantCulture);

                //odszukaj linie na MM+ o tej samej liczbie porzadkowej
                WarehouseDocumentLine line = document.Lines[ordinalNumber - 1];
                line.CommercialWarehouseValuations.RemoveAll();
                CommercialWarehouseValuation valuation = line.CommercialWarehouseValuations.CreateNew();
                valuation.Quantity = Convert.ToDecimal(entry.Element("quantity").Value, CultureInfo.InvariantCulture);
                valuation.Price = Convert.ToDecimal(entry.Element("incomePrice").Value, CultureInfo.InvariantCulture);
                valuation.Value = Convert.ToDecimal(entry.Element("incomeValue").Value, CultureInfo.InvariantCulture);
            }

            document.Value = document.Lines.Children.Sum(l => l.Value);

            this.SaveBusinessObject(document);
        }

        public override XDocument LoadBusinessObject(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;
            BusinessObjectType type;

            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), requestXml.Root.Element("type").Value);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:24");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + requestXml.Root.Element("type").Value);
            }

            IBusinessObject bo = this.LoadBusinessObject(type, new Guid(requestXml.Root.Element("id").Value));

            #region Prepayments
            //do zaliczek dolaczamy informacje o pobranych zaliczkach
            if (bo.BOType == BusinessObjectType.CommercialDocument)
            {
                CommercialDocument comDoc = (CommercialDocument)bo;

                var relation = comDoc.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault();
                var settlAttr = comDoc.Attributes[DocumentFieldName.Attribute_SalesOrderXml];
                DocumentMapper mapper = (DocumentMapper)this.Mapper;

                if (comDoc.DocumentType.DocumentCategory == DocumentCategory.Sales && relation != null && settlAttr != null) //czyli jestesmy w fakturze zaliczkowej
                {
                    CommercialDocument salesOrder = (CommercialDocument)relation.RelatedDocument;

                    if (salesOrder.Version == null) //nie wczytany do konca
                        salesOrder = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, salesOrder.Id.Value);

                    SalesOrderSettlements salesOrderSettlements = new SalesOrderSettlements();
                    salesOrderSettlements.LoadSalesOrder(salesOrder);
                    XElement settledAmount = mapper.GetSalesOrderSettledAmount(relation.RelatedDocument.Id.Value);
                    salesOrderSettlements.LoadPrepaids(settledAmount);
                    salesOrderSettlements.SubtractPrepaidDocument(comDoc); //odejmujemy biezaca zaliczke
                    comDoc.SalesOrderSettlements = salesOrderSettlements;

                    bool hasLaterPrepayments = mapper.HasLaterPrepayments(comDoc);

                    if (hasLaterPrepayments)
                        comDoc.DisableDocumentChange = DisableDocumentChangeReason.DOCUMENT_LATER_PREPAYMENTS;
                }
                else if (comDoc.DocumentType.DocumentCategory == DocumentCategory.ProductionOrder)
                    mapper.AppendProductionOrderLineLabels(comDoc);
            }
            #endregion

            #region Payments
            //Obliczamy DueDays dla paymentów
            IPaymentsContainingDocument paymentsContainingDocument = bo as IPaymentsContainingDocument;
            Document document = bo as Document;
            if (paymentsContainingDocument != null)
            {
                if (document != null)
                {
                    DateTime subtrahend = document.GetCalculateDueDaysOnPaymentSubtrahend();
                    paymentsContainingDocument.Payments.CalculateDueDaysOnPayments(subtrahend);
                }
            }
            #endregion

            #region Source

            XElement source = requestXml.Root.Element(XmlName.Source);

            if (source != null && source.Attribute(XmlName.Type) != null)
            {
                switch (source.Attribute(XmlName.Type).Value)
                {
                    case SourceType.PortaOrder:
                        PortaIntegrationFactory.GenerateSalesOrder(source, (CommercialDocument)bo, false);
                        break;
                    case SourceType.PortaOrderCsv:
                        PortaIntegrationFactory.GenerateSalesOrderCvs(source, (CommercialDocument)bo, false);
                        break;
                }
            }

            #endregion

            XDocument retXml = bo.FullXml;

            if (document != null)
            {
                XElement operations = ProcessManager.Instance.GetDocumentOperations(document);

                if (operations != null && operations.HasElements)
                {
                    retXml.Root.Add(operations);
                }
            }

            return retXml;
        }

        internal override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            IBusinessObject obj = base.LoadBusinessObject(type, id);

            ICollection<Guid> allCorrections = null;

            //korekty
            if (obj.BOType == BusinessObjectType.CommercialDocument)
            {
                CommercialDocument commercialDocument = (CommercialDocument)obj;
                DocumentMapper mapper = (DocumentMapper)this.Mapper;

                if (commercialDocument.IsCorrectiveDocument())
                {
                    ICollection<Guid> previousCorrects = mapper.GetPreviousCommercialCorrectiveDocumentsId(commercialDocument.Id.Value);

                    //zaczynamy wiązać od bieżącego dokumentu, aż do korygowanego - wtedy jeśli jakieś powiązanie nie będzie możliwe wystarczy, że pominiemy ten jeden dokument z którym powiązanie możliwe nie jest
                    CommercialDocument nextDoc = commercialDocument;
                    bool areRelated = true;

                    int cItemNo = 1;

                    foreach (Guid docId in previousCorrects.Reverse())
                    {

                        CommercialDocument doc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);

                        areRelated = CommercialCorrectiveDocumentFactory.RelateTwoCorrectiveDocuments(doc, nextDoc, cItemNo == previousCorrects.Count);
                        cItemNo++;

                        //Jeśli nie można powiązać dwóch korekt - co może się zdarzyć gdy rozważamy jako doc korektę anulowaną 
                        //a jako nextDoc korektę wystawioną po tej anulowanej - gdyż będzie ona powiązana z dokumentem a nie poprzednią anulowaną korektą
                        if (areRelated)
                        {
                            nextDoc = doc;
                        }
                    }

                    CommercialCorrectiveDocumentFactory.CalculateDocumentsAfterCorrection(commercialDocument);
                }

                allCorrections = mapper.GetCommercialCorrectiveDocumentsId(commercialDocument.Id.Value);
            }
            else if (obj.BOType == BusinessObjectType.WarehouseDocument)
            {
                DocumentMapper mapper = (DocumentMapper)this.Mapper;
                allCorrections = mapper.GetWarehouseCorrectiveDocumentsId(obj.Id.Value);
            }

            if (allCorrections != null && allCorrections.Count != 0)
                ((Document)obj).DisableDocumentChange = DisableDocumentChangeReason.DOCUMENT_RELATED_CORRECTIVE_DOCUMENTS;

            return obj;
        }

        public XDocument GetWarehouseDocumentLinesTree(XDocument requestXml)
        {
            XDocument xml = ((DocumentMapper)this.Mapper).GetAllWarehouseCorrectiveLines(new Guid(requestXml.Root.Element("documentId").Value));

            List<XElement> linesToProcess = new List<XElement>();
            List<XElement> lines = new List<XElement>();

            foreach (XElement line in xml.Root.Elements().OrderBy(x => Convert.ToInt32(x.Element("ordinalNumber").Value, CultureInfo.InvariantCulture)))
            {
                if (line.Element("initialWarehouseDocumentLineId") == null)
                    linesToProcess.Add(line);
            }

            foreach (XElement line in linesToProcess)
            {
                line.Remove();
                this.CreateLineTree(xml.Root, line);
                lines.Add(line);
            }

            foreach (XElement line in lines)
                xml.Root.Add(line);

            BusinessObjectHelper.GetPrintXml(xml);
            return xml;
        }

        private void CreateLineTree(XElement warehouseDocumentLine, XElement line)
        {
            if (line.Element("correctiveLines") == null)
                line.Add(new XElement("correctiveLines"));

            List<XElement> linesToProcess = new List<XElement>();

            foreach (XElement entry in warehouseDocumentLine.Elements().OrderBy(x => DateTime.Parse(x.Element("issueDate").Value, CultureInfo.InvariantCulture))
                .ThenBy(x => x.Element("correctedWarehouseDocumentLineId") != null ? x.Element("correctedWarehouseDocumentLineId").Value : "")
                .ThenBy(x => Convert.ToDecimal(x.Element("quantity").Value, CultureInfo.InvariantCulture)))
            {
                if (entry.Element("correctedWarehouseDocumentLineId") != null &&
                    entry.Element("correctedWarehouseDocumentLineId").Value == line.Element("id").Value)
                    linesToProcess.Add(entry);
            }

            foreach (XElement ln in linesToProcess)
            {
                ln.Remove();
                line.Element("correctiveLines").Add(ln);
                this.CreateLineTree(warehouseDocumentLine, ln);
            }
        }

        public override XDocument LoadBusinessObjectForPrinting(XDocument requestXml, string customLabelsLanguage)
        {
            XDocument retXml = null;

            if (requestXml.Root.Element("storedProcedure") == null)
                retXml = base.LoadBusinessObjectForPrinting(requestXml, customLabelsLanguage);
            else
            {
                DictionaryMapper.Instance.CheckForChanges();
                retXml = ((DocumentMapper)this.Mapper).LoadBusinessObjectForPrinting(requestXml.Root.Element("storedProcedure").Value, requestXml.Root.Element("id").Value);

                BusinessObjectHelper.GetPrintXml(retXml, customLabelsLanguage);
            }

            if (requestXml.Root.Element("isFiscalPrint") != null && requestXml.Root.Element("isFiscalPrint").Value.ToUpperInvariant() == "TRUE")
            {
                List<Guid> itemsId = new List<Guid>();

                if (retXml.Root.Element("commercialDocument") != null)
                {
                    foreach (XElement line in retXml.Root.Element("commercialDocument").Element("lines").Elements())
                    {
                        itemsId.Add(new Guid(line.Element("itemId").Value));
                    }

                    XElement fiscalNames = DependencyContainerManager.Container.Get<ItemMapper>().GetItemsFiscalNames(itemsId);

                    if (fiscalNames != null)
                    {
                        foreach (XElement item in fiscalNames.Elements())
                        {
                            var lines = retXml.Root.Element("commercialDocument").Element("lines").Elements().Where(line => line.Element("itemId").Value == item.Attribute("id").Value);

                            foreach (XElement ln in lines)
                            {
                                ln.Element("itemName").Value = item.Attribute("name").Value;
                            }
                        }
                    }
                }
            }

            return retXml;
        }

        public void CreateOrUpdateReservationFromOrder(XElement orderDbXml)
        {
            Guid attributeId = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.Attribute_OppositeDocumentId).Id.Value;
            var oppositeDocAttribute = orderDbXml.Element("documentAttrValue").Elements().Where(entry => entry.Element("documentFieldId").Value == attributeId.ToUpperString());
            CommercialDocument oppositeDoc = null;

            var docTypeId = orderDbXml.Element("commercialDocumentHeader").Element("entry").Element("documentTypeId").Value;
            bool isShiftOrder = DictionaryMapper.Instance.GetDocumentType(new Guid(docTypeId)).CommercialDocumentOptions.IsShiftOrder;

            if (oppositeDocAttribute.Count() == 0)
            {
                oppositeDoc = ((DocumentMapper)this.Mapper).GetCommercialDocumentByOppositeId(new Guid(orderDbXml.Element("commercialDocumentHeader").Element("entry").Element("id").Value));
            }

            if (oppositeDoc == null && oppositeDocAttribute.Count() == 0)
            {
                XDocument inputXml = XDocument.Parse("<root><type>CommercialDocument</type><template></template><source type=\"orderDbXml\"></source></root>");

                string template = null;

                if (!isShiftOrder)
                {
                    template = ConfigurationMapper.Instance.B2bReservationDocumentTemplate;

                    if (String.IsNullOrEmpty(template))
                        throw new InvalidOperationException("B2bReservationDocumentTemplate is empty");
                }
                else
                {
                    template = ConfigurationMapper.Instance.OutcomeShiftOrderTemplate;

                    if (String.IsNullOrEmpty(template))
                        throw new InvalidOperationException("OutcomeShiftOrderTemplate is empty");
                }

                inputXml.Root.Element("template").Value = template;
                inputXml.Root.Element("source").Add(orderDbXml);

                XDocument reservationXml = this.CreateNewBusinessObject(inputXml);
                this.SaveBusinessObject(reservationXml);
            }
            else //edytujemy, ale to oznacza ze edytujemy zamowienie z rezerwacji (czyli niejako w druga strone)
            {
                //string outcomeShiftStatus = orderDbXml.Element("commercialDocumentHeader").Element("entry").Element("status").Value;

                if (oppositeDoc == null)
                {
                    Guid incomeShiftId = new Guid(oppositeDocAttribute.ElementAt(0).Element("textValue").Value);
                    oppositeDoc = (CommercialDocument)this.LoadBusinessObject(BusinessObjectType.CommercialDocument, incomeShiftId);
                }

                //oppositeDoc to teraz zamowienie (z oddzialu zrodlowego) a orderDbXml to rezerwacja z docelowego

                //numer zamowienia
                DocumentAttrValue attr = oppositeDoc.Attributes.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_OrderNumber).FirstOrDefault();

                if (attr == null)
                    attr = oppositeDoc.Attributes.CreateNew(DocumentFieldName.Attribute_OrderNumber);

                attr.Value.Value = orderDbXml.Element("commercialDocumentHeader").Element("entry").Element("fullNumber").Value;

                //data zamowienia
                attr = oppositeDoc.Attributes.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_OrderIssueDate).FirstOrDefault();

                if (attr == null)
                    attr = oppositeDoc.Attributes.CreateNew(DocumentFieldName.Attribute_OrderIssueDate);

                attr.Value.Value = orderDbXml.Element("commercialDocumentHeader").Element("entry").Element("issueDate").Value.Substring(0, 10);

                //status zamowienia w oddziale docelowym
                attr = oppositeDoc.Attributes.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_OrderStatus).FirstOrDefault();

                if (attr == null)
                    attr = oppositeDoc.Attributes.CreateNew(DocumentFieldName.Attribute_OrderStatus);

                attr.Value.Value = "0";

                string statusAttrId = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.Attribute_OrderStatus).Id.ToUpperString();

                var destinationStatus = orderDbXml.Element("documentAttrValue").Elements().Where(x => x.Element("documentFieldId").Value == statusAttrId).Select(xx => xx.Element("textValue").Value).FirstOrDefault();

                if (destinationStatus != null)
                    attr.Value.Value = destinationStatus;

                //ustawiamy id dokumentu przeciwnego
                if (oppositeDoc.Attributes.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_OppositeDocumentId).FirstOrDefault() == null)
                {
                    attr = oppositeDoc.Attributes.CreateNew(DocumentFieldName.Attribute_OppositeDocumentId);
                    attr.Value.Value = orderDbXml.Element("commercialDocumentHeader").Element("entry").Element("id").Value;
                }

                this.SaveBusinessObject(oppositeDoc);
            }
        }

        public void CreateOrUpdateIncomeShiftDocumentFromOutcomeShift(XElement outcomeShiftDbXml)
        {
            //sprawdzamy czy MM+ mamy wygenerowac nowa czy aktualizowac juz istniejaca
            Guid attributeId = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId).Id.Value;
            var oppositeDocAttribute = outcomeShiftDbXml.Element("documentAttrValue").Elements().Where(entry => entry.Element("documentFieldId").Value == attributeId.ToUpperString());
            WarehouseDocument incomeShift = null;

            if (oppositeDocAttribute.Count() == 0)
            {
                incomeShift = ((DocumentMapper)this.Mapper).GetIncomeShiftByOutcomeId(new Guid(outcomeShiftDbXml.Element("warehouseDocumentHeader").Element("entry").Element("id").Value));
            }

            if (incomeShift == null && oppositeDocAttribute.Count() == 0)
            {
                XDocument inputXml = XDocument.Parse("<root><type>WarehouseDocument</type><template>outcomeShift</template><source type=\"outcomeShift\"></source></root>");

                inputXml.Root.Element("source").Add(outcomeShiftDbXml);

                XDocument incomeShiftXml = this.CreateNewBusinessObject(inputXml);
                DuplicableAttributeFactory.DuplicateShiftAttributes(outcomeShiftDbXml, incomeShiftXml);
                this.SaveBusinessObject(incomeShiftXml);
            }
            else //edytuj
            {
                string outcomeShiftStatus = outcomeShiftDbXml.Element("warehouseDocumentHeader").Element("entry").Element("status").Value;

                if (incomeShift == null)
                {
                    Guid incomeShiftId = new Guid(oppositeDocAttribute.ElementAt(0).Element("textValue").Value);
                    incomeShift = (WarehouseDocument)this.LoadBusinessObject(BusinessObjectType.WarehouseDocument, incomeShiftId);
                }

                foreach (DocumentAttrValue attr in incomeShift.Attributes.Children)
                {
                    if (attr.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentStatus)
                    {
                        attr.Value.Value = outcomeShiftStatus;
                        break;
                    }
                }

                //Copy attributes from outcomeShift
                DuplicableAttributeFactory.DuplicateShiftAttributes(outcomeShiftDbXml, incomeShift);

                foreach (WarehouseDocumentLine line in incomeShift.Lines.Children)
                {
                    var outcomeLineXml = outcomeShiftDbXml.Element("warehouseDocumentLine").Elements().Where(e => e.Element("ordinalNumber").Value == line.OrdinalNumber.ToString(CultureInfo.InvariantCulture)).FirstOrDefault();

                    if (outcomeLineXml != null)
                    {
                        decimal newPrice = Convert.ToDecimal(outcomeLineXml.Element("price").Value, CultureInfo.InvariantCulture);
                        decimal newValue = Convert.ToDecimal(outcomeLineXml.Element("value").Value, CultureInfo.InvariantCulture);

                        line.Price = newPrice;
                        line.Value = newValue;
                    }
                }

                this.SaveBusinessObject(incomeShift);
            }
        }

        /// <summary>
        /// Gets the free document number.
        /// </summary>
        /// <param name="requestXml">Client request xml containing parameters necessary to get the free number.</param>
        /// <returns>Xml containing document number.</returns>
        public XDocument GetFreeDocumentNumber(XDocument requestXml)
        {
            if (requestXml.Root.Element("documentTypeId") == null)
                throw new ArgumentException("documentTypeId is required in input xml.");

            if (requestXml.Root.Element("issueDate") == null)
                throw new ArgumentException("issueDate is required in input xml.");

            if (requestXml.Root.Element("numberSettingId") == null)
                throw new ArgumentException("numberSettingId is required in input xml.");

            DocumentType doctype = DictionaryMapper.Instance.GetDocumentType(new Guid(requestXml.Root.Element("documentTypeId").Value));
            DateTime issueDate = DateTime.Parse(requestXml.Root.Element("issueDate").Value, CultureInfo.InvariantCulture);
            Guid numberSettingId = new Guid(requestXml.Root.Element("numberSettingId").Value);
            CalculationType calculationType = CalculationType.Net;

            if (requestXml.Root.Element("netCalculationType") != null)
                calculationType = (CalculationType)Enum.Parse(typeof(CalculationType), requestXml.Root.Element("netCalculationType").Value);

            string financialRegisterSymbol = null;

            if (requestXml.Root.Element("financialRegisterSymbol") != null)
                financialRegisterSymbol = requestXml.Root.Element("financialRegisterSymbol").Value;

            NumberSetting ns = DictionaryMapper.Instance.GetNumberSetting(numberSettingId);

            DocumentMapper m = (DocumentMapper)this.Mapper;
            int number = m.GetFreeNumberForSeries(numberSettingId, m.ComputePattern(ns.SeriesFormat, issueDate, doctype.Symbol, financialRegisterSymbol, calculationType == CalculationType.Gross));
            string fullNumber = m.ComputeFullDocumentNumber(numberSettingId, number, issueDate, doctype.Symbol, financialRegisterSymbol, calculationType == CalculationType.Gross);

            XDocument xml = XDocument.Parse("<root><number>" + number.ToString(CultureInfo.InvariantCulture) + "</number><fullNumber>" + fullNumber + "</fullNumber></root>");

            return xml;
        }

        /// <summary>
        /// Loads plugins for the current coordinator.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="businessObject">Main business object currently processed.</param>
        protected override void LoadPlugins(CoordinatorPluginPhase pluginPhase, IBusinessObject businessObject)
        {
            base.LoadPlugins(pluginPhase, businessObject);
        }

        private void CorrectDocumentDates(SimpleDocument simpleDocument, CommercialDocument commercialDocument)
        {
            DateTime currentDateTime = SessionManager.VolatileElements.CurrentDateTime;

            if (simpleDocument != null &&
                simpleDocument.BOType != BusinessObjectType.FinancialReport &&
                simpleDocument.BOType != BusinessObjectType.InventoryDocument &&
                simpleDocument.IsNew)
            {
                if (simpleDocument.IssueDate.Date == currentDateTime.Date)
                    simpleDocument.IssueDate = currentDateTime;
                else if (simpleDocument.IssueDate.Date < currentDateTime.Date)
                    simpleDocument.IssueDate = new DateTime(simpleDocument.IssueDate.Year, simpleDocument.IssueDate.Month, simpleDocument.IssueDate.Day, 23, 59, 59, 500);
                else if (simpleDocument.IssueDate.Date > currentDateTime.Date)
                    simpleDocument.IssueDate = new DateTime(simpleDocument.IssueDate.Year, simpleDocument.IssueDate.Month, simpleDocument.IssueDate.Day, 0, 0, 0, 0);
            }

            if (commercialDocument != null && commercialDocument.IsNew)
            {
                if (commercialDocument.EventDate.Date == currentDateTime.Date)
                    commercialDocument.EventDate = currentDateTime;
                else if (commercialDocument.EventDate.Date < currentDateTime.Date)
                    commercialDocument.EventDate = new DateTime(commercialDocument.EventDate.Year, commercialDocument.EventDate.Month, commercialDocument.EventDate.Day, 23, 59, 59, 500);
                else if (commercialDocument.EventDate.Date > currentDateTime.Date)
                    commercialDocument.EventDate = new DateTime(commercialDocument.EventDate.Year, commercialDocument.EventDate.Month, commercialDocument.EventDate.Day, 0, 0, 0, 0);
            }
        }

        /// <summary>
        /// Processes the <see cref="BusinessObject"/> according to its options and finally saves it to database.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObject"/> to save.</param>
        /// <returns>Xml containing operation results.</returns>
        public override XDocument SaveBusinessObject(IBusinessObject businessObject)
        {
            WarehouseDocument warehouseDocument = businessObject as WarehouseDocument;
            CommercialDocument commercialDocument = businessObject as CommercialDocument;
            FinancialDocument financialDocument = businessObject as FinancialDocument;
            FinancialReport financialReport = businessObject as FinancialReport;
            Payment payment = businessObject as Payment;
            SimpleDocument simpleDocument = businessObject as SimpleDocument;
            ServiceDocument serviceDocument = businessObject as ServiceDocument;
            ComplaintDocument complaintDocument = businessObject as ComplaintDocument;
            InventoryDocument inventoryDocument = businessObject as InventoryDocument;
            InventorySheet inventorySheet = businessObject as InventorySheet;
            Document document = businessObject as Document;

            this.CorrectDocumentDates(simpleDocument, commercialDocument);
            SessionManager.VolatileElements.AddSavedDocument(simpleDocument);
            if (businessObject.IsNew)
                this.TrySaveProfileIdAttribute(document);

            if (warehouseDocument != null)
            {
                DocumentType dt = warehouseDocument.DocumentType;
                WarehouseDirection direction = dt.WarehouseDocumentOptions.WarehouseDirection;
                DocumentCategory category = dt.DocumentCategory;

                if (category == DocumentCategory.OutcomeWarehouseCorrection)
                    return new CorrectiveOutcomeWarehouseDocumentLogic(this).ProcessWarehouseCorrectiveDocument(warehouseDocument);
                if (category == DocumentCategory.IncomeWarehouseCorrection)
                    return new CorrectiveIncomeWarehouseDocumentLogic(this).ProcessWarehouseCorrectiveDocument(warehouseDocument);
                else if (direction == WarehouseDirection.Income)
                    return new IncomeWarehouseDocumentLogic(this).SaveBusinessObject(warehouseDocument);
                else if (direction == WarehouseDirection.Outcome)
                    return new OutcomeWarehouseDocumentLogic(this).SaveBusinessObject(warehouseDocument);
                else if (direction == WarehouseDirection.OutcomeShift)
                    return new OutcomeShiftWarehouseDocumentLogic(this).SaveBusinessObject(warehouseDocument);
                else if (direction == WarehouseDirection.IncomeShift)
                    return new IncomeShiftWarehouseDocumentLogic(this).SaveBusinessObject(warehouseDocument);
                else
                    throw new InvalidOperationException("Unknown logic to choose.");
            }
            else if (serviceDocument != null)
                return new ServiceDocumentLogic(this).SaveBusinessObject(serviceDocument);
            else if (commercialDocument != null)
            {
                if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
                    return new SalesOrderLogic(this).SaveBusinessObject(commercialDocument);
                else if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Technology
                    || commercialDocument.DocumentType.DocumentCategory == DocumentCategory.ProductionOrder)
                    return new ProductionLogic(this).SaveBusinessObject(commercialDocument);
                else
                    return new CommercialDocumentLogic(this).SaveBusinessObject(commercialDocument);
            }
            else if (financialDocument != null)
                return new FinancialDocumentLogic(this).SaveBusinessObject(financialDocument);
            else if (financialReport != null)
                return new FinancialReportLogic(this).SaveBusinessObject(financialReport);
            else if (payment != null)
                return new PaymentLogic(this).SaveBusinessObject(payment);
            else if (complaintDocument != null)
                return new ComplaintDocumentLogic(this).SaveBusinessObject(complaintDocument);
            else if (inventoryDocument != null)
                return new InventoryDocumentLogic(this).SaveBusinessObject(inventoryDocument);
            else if (inventorySheet != null)
                return new InventorySheetLogic(this).SaveBusinessObject(inventorySheet);
            else
                return base.SaveBusinessObject(businessObject);
        }

        internal void CancelServiceDocument(ServiceDocument serviceDocument)
        {
            /*
             * Slowa specyfikacji: 
                jezeli nie ma faktury to mozna anulowac i to powoduje anulowanei dokumentow powiazanych. 
                + towary musza wrocic na swoj pierwotny magazyn
                + nie moze byc faktury
                + anulowanie ma zmienic status dokumentu ale nie odwiazywac ich od powiazanych
             */

            //sprawdzamy czy jest fatura
            if (serviceDocument.Relations.Where(r => r.RelationType == DocumentRelationType.ServiceToInvoice).FirstOrDefault() != null)
            {
                string docNumbers = String.Empty;

                foreach (var rel in serviceDocument.Relations.Where(r => r.RelationType == DocumentRelationType.ServiceToInvoice))
                {
                    using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                    {
                        Document doc = (Document)c.LoadBusinessObject(BusinessObjectType.CommercialDocument, rel.RelatedDocument.Id.Value);

                        if (docNumbers.Length != 0)
                            docNumbers += ", ";

                        docNumbers += doc.Number.FullNumber;
                    }
                }

                throw new ClientException(ClientExceptionId.CancelWarehouseDocumentError1, null, "docNumbers:" + docNumbers);
            }

            if (serviceDocument.Relations.Where(r => r.RelationType == DocumentRelationType.ServiceToInternalOutcome).FirstOrDefault() != null)
            {
                string docNumbers = String.Empty;

                foreach (var rel in serviceDocument.Relations.Where(r => r.RelationType == DocumentRelationType.ServiceToInternalOutcome))
                {
                    using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                    {
                        Document doc = (Document)c.LoadBusinessObject(BusinessObjectType.WarehouseDocument, rel.RelatedDocument.Id.Value);

                        if (docNumbers.Length != 0)
                            docNumbers += ", ";

                        docNumbers += doc.Number.FullNumber;
                    }
                }

                throw new ClientException(ClientExceptionId.CancelWarehouseDocumentError4, null, "docNumbers:" + docNumbers);
            }

            //towary musza wrocic na swoj poprzedni magazyn
            DocumentMapper mapper = (DocumentMapper)this.Mapper;

            mapper.AddItemsToItemTypesCache(serviceDocument);
            var cache = SessionManager.VolatileElements.ItemTypesCache;
            WarehouseItemQuantityDictionary dctWarehouseItemIdQuantity = new WarehouseItemQuantityDictionary();

            foreach (CommercialDocumentLine line in serviceDocument.Lines)
            {
                Guid itemTypeId = cache[line.ItemId];
                ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                if (!itemType.IsWarehouseStorable)
                    continue;

                DocumentLineAttrValue attr = line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption];

                if (attr.Value.Value != "2" && attr.Value.Value != "4") //czyli opcja ze NIE generujemy MMki
                    continue;

                dctWarehouseItemIdQuantity.Subtract(line.WarehouseId.Value, line.ItemId, line.Quantity);
            }

            ServiceDocumentLogic.GenerateShifts(serviceDocument, dctWarehouseItemIdQuantity);
            serviceDocument.DocumentStatus = DocumentStatus.Canceled;

            serviceDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "closed";

            this.SaveBusinessObject(serviceDocument);
        }

        public void ChangeDocumentStatus(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;

            if (requestXml.Root.Element("commercialDocumentId") == null &&
                requestXml.Root.Element("warehouseDocumentId") == null &&
                requestXml.Root.Element("financialDocumentId") == null &&
                requestXml.Root.Element("serviceDocumentId") == null &&
                requestXml.Root.Element("inventoryDocumentId") == null &&
                requestXml.Root.Element("complaintDocumentId") == null)
                throw new ArgumentException("'commercialDocumentId' or 'warehouseDocumentId' or 'financialDocumentId' or 'serviceDocumentId' or 'inventoryDocumentId' or 'complaintDocumentId' node don't exist.", "requestXml");

            if (requestXml.Root.Element("status") == null)
                throw new ArgumentException("'status' node doesn't exist.", "requestXml");

            Document document = null;

            if (requestXml.Root.Element("commercialDocumentId") != null)
                document = (Document)this.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(requestXml.Root.Element("commercialDocumentId").Value));
            else if (requestXml.Root.Element("financialDocumentId") != null)
                document = (Document)this.LoadBusinessObject(BusinessObjectType.FinancialDocument, new Guid(requestXml.Root.Element("financialDocumentId").Value));
            else if (requestXml.Root.Element("warehouseDocumentId") != null)
                document = (Document)this.LoadBusinessObject(BusinessObjectType.WarehouseDocument, new Guid(requestXml.Root.Element("warehouseDocumentId").Value));
            else if (requestXml.Root.Element("serviceDocumentId") != null)
                document = (Document)this.LoadBusinessObject(BusinessObjectType.ServiceDocument, new Guid(requestXml.Root.Element("serviceDocumentId").Value));
            else if (requestXml.Root.Element("inventoryDocumentId") != null)
                document = (Document)this.LoadBusinessObject(BusinessObjectType.InventoryDocument, new Guid(requestXml.Root.Element("inventoryDocumentId").Value));
            else if (requestXml.Root.Element("complaintDocumentId") != null)
                document = (Document)this.LoadBusinessObject(BusinessObjectType.ComplaintDocument, new Guid(requestXml.Root.Element("complaintDocumentId").Value));


            DocumentStatus requestedStatus = (DocumentStatus)Convert.ToInt32(requestXml.Root.Element("status").Value, CultureInfo.InvariantCulture);
            new DocumentStatusChangeLogic(this).ChangeDocumentStatus(document, requestedStatus);
        }

        internal FinancialReport GetOpenedFinancialReport(Guid financialRegisterId)
        {
            DocumentMapper mapper = (DocumentMapper)this.Mapper;

            Guid? reportId = mapper.GetOpenedFinancialReportId(financialRegisterId);

            if (reportId == null)
                return null;

            FinancialReport report = (FinancialReport)this.LoadBusinessObject(BusinessObjectType.FinancialReport, reportId.Value);
            return report;
        }

        public XDocument GetOpenedFinancialReport(XDocument requestXml)
        {
            Guid financialRegisterId = new Guid(requestXml.Root.Element("financialRegisterId").Value);

            FinancialReport report = this.GetOpenedFinancialReport(financialRegisterId);

            if (report == null)
                throw new ClientException(ClientExceptionId.OpenedFinancialReportDoesNotExist);

            return report.FullXml;
        }

        public XDocument CloseServiceOrder(XDocument xml)
        {
            DocumentMapper mapper = (DocumentMapper)this.Mapper;

            ServiceDocument serviceDocument = (ServiceDocument)mapper.LoadBusinessObject(BusinessObjectType.ServiceDocument, new Guid(xml.Root.Element("documentId").Value));

            if (serviceDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value != "open")
                throw new ClientException(ClientExceptionId.AlreadyClosedServiceDocument);

            //sprawdzamy czy dokument nie posiada pozycji ktore powinny zostac zrealizowane wz/faktura
            foreach (var line in serviceDocument.Lines)
            {
                var attr = line.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption];

                if (attr != null && (attr.Value.Value == "1" || attr.Value.Value == "2"))
                    throw new ClientException(ClientExceptionId.ServiceDocumentCloseError1);
            }

            CommercialDocumentLogic.GenerateInternalOutcomesToServiceDocument(serviceDocument);

            serviceDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "closed";

            serviceDocument.DocumentStatus = DocumentStatus.Committed;

            serviceDocument.ClosureDate = SessionManager.VolatileElements.CurrentDateTime;

            XDocument retXml = this.SaveBusinessObject(serviceDocument);
            retXml.Root.Add(SessionManager.VolatileElements.GetSavedDocuments(serviceDocument.Id.Value));
            return retXml;
        }

        public void UnrelateCommercialDocumentFromWarehouseDocuments(XDocument requestXml)
        {
            if (requestXml.Root.Element("commercialDocumentId") == null)
                throw new ArgumentException("'commercialDocumentId' node doesn't exist.", "requestXml");

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                Guid commercialDocumentId = new Guid(requestXml.Root.Element("commercialDocumentId").Value);
                XDocument jXml = ((DocumentMapper)this.Mapper).UnrelateCommercialDocumentFromWarehouseDocuments(commercialDocumentId);
                if (ConfigurationMapper.Instance.ExtendedJournal)
                {
                    jXml = new XDocument(requestXml);
                    JournalManager.AddJournalTransactionAttributes(jXml.Root);
                }
                JournalManager.Instance.LogToJournal(JournalAction.Documents_Unrelate, commercialDocumentId, null, null, jXml);
                SqlConnectionManager.Instance.CommitTransaction();
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:25");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.CommercialDocument, this.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:26");
                SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        /// <summary>
        /// Updates the stock using differential quantity.
        /// </summary>
        /// <param name="document">The document that should update stock.</param>
        internal void UpdateStock(WarehouseDocument document)
        {
            UpdateStockRequest request = new UpdateStockRequest(document);
            this.MapperTyped.UpdateStock(request);
        }

        public string RelateCommercialDocumentToWarehouseDocuments(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;

            Guid commercialDocumentId = new Guid(requestXml.Root.Element("commercialDocuments").Element("id").Value);

            List<Guid> warehouseDocumentsId = new List<Guid>();

            foreach (XElement idElement in requestXml.Root.Element("warehouseDocuments").Elements())
            {
                warehouseDocumentsId.Add(new Guid(idElement.Value));
            }

            CommercialDocument commercialDocument = (CommercialDocument)this.Mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, commercialDocumentId);

            List<WarehouseDocument> warehouseDocuments = new List<WarehouseDocument>();

            foreach (Guid id in warehouseDocumentsId)
            {
                WarehouseDocument whDoc = (WarehouseDocument)this.Mapper.LoadBusinessObject(BusinessObjectType.WarehouseDocument, id);
                warehouseDocuments.Add(whDoc);
            }

            bool allLinesRelated = true;

            if (warehouseDocuments.Count > 0)
            {
                if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Sales)
                {
                    allLinesRelated = CommercialWarehouseDocumentFactory.RelateCommercialLinesToWarehousesLines(commercialDocument, warehouseDocuments, false, false, true, false);
                    foreach (WarehouseDocument wDoc in warehouseDocuments)
                    {
                        wDoc.CorrectedDocumentEditEnabled = true;
                    }
                }
                else if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Purchase)
                {
                    allLinesRelated = CommercialWarehouseDocumentFactory.RelateCommercialLinesToWarehousesLines(commercialDocument, warehouseDocuments, true, false, true, false);

                    //jezeli wszystkie wartosci na liniach sa > 0 to sumujemy i wpisujemy w naglowek

                    foreach (WarehouseDocument whDoc in warehouseDocuments)
                    {
                        if (whDoc.Lines.Children.Where(l => l.Price == 0).FirstOrDefault() == null)
                            whDoc.Value = whDoc.Lines.Children.Sum(ll => ll.Value);
                    }
                }
                else if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Order || commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Reservation)
                    allLinesRelated = CommercialWarehouseDocumentFactory.RelateCommercialLinesToWarehousesLines(commercialDocument, warehouseDocuments, false, true, false, false);
            }

            SqlConnectionManager.Instance.BeginTransaction();
            this.CanCommitTransaction = false;

            try
            {
                commercialDocument.DifferentialPaymentsAndDocumentValueCheck = true;
                commercialDocument.SkipCorrectionEditCheck = true;
                this.SaveBusinessObject(commercialDocument);

                DocumentMapper documentMapper = (DocumentMapper)this.Mapper;

                foreach (WarehouseDocument whDoc in warehouseDocuments)
                {
                    if (whDoc.WarehouseDirection == WarehouseDirection.Income ||
                        whDoc.WarehouseDirection == WarehouseDirection.IncomeShift)
                    {
                        documentMapper.ValuateIncomeWarehouseDocument(whDoc);
                    }
                }

                Coordinator.LogRelateDocumentsOperation(commercialDocumentId, warehouseDocumentsId);

                if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
                    SqlConnectionManager.Instance.CommitTransaction();
                else
                    SqlConnectionManager.Instance.RollbackTransaction();
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:27");
                Coordinator.ProcessSqlException(sqle, commercialDocument.BOType, this.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:28");
                SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }

            if (!allLinesRelated)
                return "<root message=\"documents.messages.notAllWarehouseLinesRelated\">ok</root>";
            else
                return "<root>ok</root>";
        }

        /// <summary>
        /// Próba zamknięcia zamówienia sprzedażowego z realizującego dokumentu sprzedażowego lub magazynowego
        /// </summary>
        /// <param name="document"></param>
        /// <returns></returns>
        internal void TryCloseSalesOrdersWhileRealization(Document document)
        {
            //Sprawdzenie nastąpi dla Commerciala realizującego ZS, nie nastąpi dla WZ, które jest wystawiane dla tego commerciala.
            //Natomiast nastąpi dla RW realizującego ZS
            bool whileSingleSalesOrderRealization = document.CheckSourceType(SourceType.SalesOrderRealization);
            bool whileMultipleSalesOrderRealization = document.CheckSourceType(SourceType.MultipleSalesOrders);
            if (whileSingleSalesOrderRealization || whileMultipleSalesOrderRealization)
            {
                CommercialDocument commercialDocument = document as CommercialDocument;
                bool isCommercial = commercialDocument != null;

                //realatedLinesId, abs(quantity*commercialQuantity). Zapamiętać ilości na realizowanych pozycjach przez aktualnie zapisywany dokument.
                Dictionary<Guid, decimal> realizingLines = new Dictionary<Guid, decimal>();
                if (isCommercial)
                {
                    foreach (CommercialDocumentLine cdLine in commercialDocument.Lines)
                    {
                        Guid? relatedLineId =
                            cdLine.Attributes.GetGuidValueByFieldName(DocumentFieldName.LineAttribute_RealizedSalesOrderLineId);
                        if (relatedLineId.HasValue)
                        {
                            realizingLines.Add(relatedLineId.Value, cdLine.AbsoluteCommercialQuantity);
                        }
                    }
                }

                //Utworzenie i uzupełnienie listy wszystkich id realizowanych ZSP
                List<Guid> sourceDocumentsIds = SalesOrderFactory.ExtractSourceSalesOrdersIds(document.Source);

                //Sprawdzamy czy któreś z tych ZSP może być zamknięte i ewentualne zamykanie
                foreach (Guid sourceDocumentId in sourceDocumentsIds)
                {
                    CommercialDocument salesOrder = this.GetOrLoadRelatedSalesOrder(sourceDocumentId, document, isCommercial);
                    this.TryCloseSalesOrderWhileRealization(salesOrder, isCommercial, realizingLines, whileMultipleSalesOrderRealization);
                }
            }
        }

        /// <summary>
        /// Pobiera zamówienie sprzedażowe z dokumentu bądź ładuje z bazy
        /// </summary>
        /// <param name="sourceDocumentId"></param>
        /// <param name="document"></param>
        /// <param name="isCommercial"></param>
        /// <returns></returns>
        private CommercialDocument GetOrLoadRelatedSalesOrder(Guid sourceDocumentId, Document document, bool isCommercial)
        {
            CommercialDocument salesOrder = (CommercialDocument)document.Relations.GetRelatedDocument(sourceDocumentId);

            if (salesOrder == null && isCommercial)
            {
                //Sprawdzamy czy obiekt zamówienia sprzedażowego znajduje się w powiązanych dokumentach magazynowych
                foreach (IBusinessObject relatedDocument in document.RelatedObjects)
                {
                    WarehouseDocument warehouseDocument = relatedDocument as WarehouseDocument;
                    if (warehouseDocument != null)
                    {
                        salesOrder = (CommercialDocument)warehouseDocument.Relations.GetRelatedDocument(sourceDocumentId);
                        if (salesOrder != null)
                        {
                            break;
                        }
                    }
                }
                //W przypadku dok. sprzedażowego nie znajdziemy ZS w relacjach swoich i pow. magazynowych i przy walidacji był wczytywany to odczytujemy z cache, jeśli mimo to nie ma go to wczytujemy go z bazy
                if (salesOrder == null)
                {
                    salesOrder = (CommercialDocument)this.Mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, sourceDocumentId);
                }
            }

            return salesOrder;
        }

        /// <summary>
        /// Próba zamknięcia pojedyńczego powiązanego zamówienia sprzedażowego
        /// </summary>
        /// <param name="salesOrder">ZSP do zamknięcia</param>
        /// <param name="isCommercial">Czy realizujący dokument jest handlowy</param>
        /// <param name="realizingLines">Pozycje, które realizują zamówienia sprzedażowe</param>
        /// <returns></returns>
        private bool TryCloseSalesOrderWhileRealization(CommercialDocument salesOrder, bool isCommercial, Dictionary<Guid, decimal> realizingLines, bool multipleSalesOrder)
        {
            if (salesOrder != null)
            {
                #region Sprawdzenie czy wszystkie pozycje nie towarowe są w pełni zrealizowane przez dokumenty sprzedażowe
                SalesOrderRealizationInfo salesOrderRealizationInfo = ((DocumentMapper)this.Mapper).GetCommercialDocumentLinesRealizingSalesOrder(salesOrder);
                foreach (CommercialDocumentLine salesOrderLine in salesOrder.Lines)
                {
                    string sogdOption = SalesOrderGenerateDocumentOption.GetOption(salesOrderLine);
                    if (SalesOrderGenerateDocumentOption.IsSales(sogdOption))
                    {
                        Guid salesOrderLineId = salesOrderLine.Id.Value;
                        decimal realizingQuantity = salesOrderRealizationInfo.SumQuantity(salesOrderLineId);
                        //w przypadku commerciala musimy dodać ilość na realizującej pozycji o ile istnieje
                        if (isCommercial && realizingLines.ContainsKey(salesOrderLineId))
                        {
                            realizingQuantity += realizingLines[salesOrderLineId];
                        }
                        //jeśli któraś z pozycji nie jest w pełni zrealizowana to nie zamykamy
                        if (salesOrderLine.Quantity != realizingQuantity)
                        {
                            return false;
                        }
                    }
                }
                #endregion
                //to wywołanie sprawdzi czy są wszystkie powiązania na pozycjach z dokumentami magazynowymi i jeśli tak zamknie zamówienie
                if (SalesOrderFactory.TryCloseSalesOrder(salesOrder))
                {
                    using (DocumentCoordinator dc = (DocumentCoordinator)Coordinator.GetCoordinatorForSpecifiedType(salesOrder.BOType, false, false))
                    {
                        //podpora bo sie wywalalo gdy zapisywalem SalesOrder z powiazaniami w tym miejscu przy realizacji wielu zamówień sprzedażowych
                        if (multipleSalesOrder)
                        {
                            salesOrder = (CommercialDocument)this.Mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, salesOrder.Id.Value);
                        }
                        new SalesOrderLogic(dc).SaveBusinessObject(salesOrder);//Zapisanie zamkniętego ZS
                    }
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="DocumentCoordinator"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (!this.IsDisposed)
            {
                if (disposing)
                {
                    //Dispose only managed resources here
                    SqlConnectionManager.Instance.ReleaseConnection();
                }
            }

            base.Dispose(disposing);
        }
    }
}
