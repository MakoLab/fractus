using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Xml.XPath;
using System.Net;
using System.Text;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Documents.Options;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;
using Makolab.Fractus.Kernel.ObjectFactories;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    /// <summary>
    /// Class that contains logic of commercial documents.
    /// </summary>
    internal class CommercialDocumentLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        /// <summary>
        /// Initializes a new instance of the <see cref="CommercialDocumentLogic"/> class.
        /// </summary>
        /// <param name="coordinator">The parent coordinator.</param>
        public CommercialDocumentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        /// <summary>
        /// Executes the custom logic.
        /// </summary>
        /// <param name="document">The document to execute custom logic for.</param>
        private void ExecuteCustomLogic(CommercialDocument document)
        {
            //create new contractor and attach him to the document if its neccesary
            if (document.ReceivingPerson != null && document.ReceivingPerson.IsNew &&
                (document.ReceivingPerson != null && document.Contractor == null) == false)
            {
                using (ContractorCoordinator contractorCoordinator = new ContractorCoordinator(false, false))
                {
                    Contractor newContractor = (Contractor)contractorCoordinator.CreateNewBusinessObject(BusinessObjectType.Contractor, null, null);

                    newContractor.ShortName = document.ReceivingPerson.ShortName;
                    newContractor.FullName = document.ReceivingPerson.FullName;
                    newContractor.IsBusinessEntity = document.ReceivingPerson.IsBusinessEntity;
                    newContractor.Status = BusinessObjectStatus.New;
                    document.ReceivingPerson = newContractor;

                    //load full document contractor data (maybe its not necessary, but we dont know if we already have full info about contractor)
                    Contractor documentContractor = (Contractor)contractorCoordinator.LoadBusinessObject(document.Contractor.BOType,
                        document.Contractor.Id.Value);
                    document.Contractor = documentContractor;
                }
            }

            if (!String.IsNullOrEmpty(document.DocumentType.CommercialDocumentOptions.SimulatedInvoice) ||
                document.IsBeforeSystemStart) //czyli jestesmy w proformie albo w fakturze sprzed startu systemu
            {
                foreach (var pt in document.Payments)
                    pt.Direction = 0;
            }

            this.CorrectQuantityInRelations(document);
            this.ProcessInvoiceToBill(document);
            this.ProcessInvoiceToServiceDocument(document);
            this.ProcessInvoiceToSalesOrder(document);
        }

        private void ProcessInvoiceToMultipleReservations(CommercialDocument commercialDocument)
        {
            // Sprawdzanie wersji powiązanych dokumentów nie ma sensu, są zablokowane
            //if (commercialDocument.IsNew && commercialDocument.Source != null && commercialDocument.Source.Attribute("type") != null &&
            //    commercialDocument.Source.Attribute("type").Value == "multipleReservations")
            //{
            //    string[] versions = commercialDocument.Tag.Split(new char[] { ',' });

            //    foreach (string version in versions)
            //    {
            //        this.mapper.CheckCommercialDocumentVersion(new Guid(version));
            //    }
            //}
        }

        private void ProcessInvoiceToMultipleSalesOrders(CommercialDocument commercialDocument)
        {
            if (commercialDocument.IsNew && commercialDocument.Source != null && commercialDocument.Source.Attribute("type") != null &&
                commercialDocument.Source.Attribute("type").Value == "multipleSalesOrders")
            {
                List<CommercialDocument> soDocs = new List<CommercialDocument>();
                List<Guid> itemsId = new List<Guid>();

                if (String.IsNullOrEmpty(commercialDocument.Tag))
                    throw new InvalidOperationException("Missing 'tag' attribute in document's xml");

                //robimy liste wygenerowanych wczesniej WZtek
                List<WarehouseDocument> generatedOutcomes = new List<WarehouseDocument>();

                foreach (var d in commercialDocument.RelatedObjects)
                {
                    WarehouseDocument whDoc = d as WarehouseDocument;

                    if (whDoc != null && whDoc.WarehouseDirection == WarehouseDirection.Outcome)
                        generatedOutcomes.Add(whDoc);
                }
                //

                XElement tagXml = XElement.Parse(commercialDocument.Tag);

                foreach (XElement soId in commercialDocument.Source.Elements("salesOrderId"))
                {
                    Guid docId = new Guid(soId.Value);

                    var exists = soDocs.Where(d => d.Id.Value == docId).FirstOrDefault();

                    if (exists != null)
                        continue;

                    CommercialDocument soDoc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, docId);
                    soDocs.Add(soDoc);

                    XElement soXml = tagXml.Elements().Where(x => x.Attribute("id").Value == soId.Value).First();

                    if (soXml.Attribute("version").Value != soDoc.Version.ToUpperString())
                        throw new ClientException(ClientExceptionId.VersionMismatch, null, "objType:salesOrder");

                    if (soDoc.Relations.Where(rr => rr.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null && commercialDocument.DocumentType.DocumentCategory.ToString() != "Purchase")
                        throw new ClientException(ClientExceptionId.UnableToCreateInvoiceToSalesOrder, null, "orderNumber:" + soDoc.Number.FullNumber);

                    List<WarehouseDocument> relatedOutcomes = new List<WarehouseDocument>();

                    //generowanie wz mamy juz za soba bo opcje wykonuja sie wczesniej (a przynajmniej tak zakladam i tak powinno byc)
                    //wiec teraz lecimy po wszystkich wygenerowanych WZtkach
                    foreach (CommercialDocumentLine soLine in soDoc.Lines)
                    {
                        decimal quantityToGo = soLine.Quantity - soLine.CommercialWarehouseRelations.Sum(ll => ll.Quantity);

                        foreach (WarehouseDocument whDoc in generatedOutcomes)
                        {
                            if(quantityToGo == 0)
                                break;

                            foreach (WarehouseDocumentLine whLine in whDoc.Lines)
                            {
                                if(quantityToGo == 0)
                                    break;

                                if (whLine.ItemId == soLine.ItemId && whDoc.WarehouseId == soLine.WarehouseId.Value)
                                {
                                    decimal unrelatedSo = whLine.Quantity - whLine.CommercialWarehouseRelations.Where(f => !f.IsCommercialRelation).Sum(ff => ff.Quantity);

                                    if (unrelatedSo >= quantityToGo) //wiecej niz potrzeba
                                    {
                                        CommercialWarehouseRelation rel = soLine.CommercialWarehouseRelations.CreateNew();
                                        rel.Quantity = quantityToGo;
                                        rel.RelatedLine = whLine;
                                        rel.IsOrderRelation = true;
										rel.DontSave = true;

                                        rel = whLine.CommercialWarehouseRelations.CreateNew();
                                        rel.Quantity = quantityToGo;
                                        rel.RelatedLine = soLine;
                                        rel.IsOrderRelation = true;

                                        quantityToGo = 0;

                                        if (!relatedOutcomes.Contains(whDoc))
                                            relatedOutcomes.Add(whDoc);
                                    }
                                    else if (unrelatedSo > 0 && unrelatedSo < quantityToGo) //mniej niz potrzeba
                                    {
                                        CommercialWarehouseRelation rel = soLine.CommercialWarehouseRelations.CreateNew();
                                        rel.Quantity = unrelatedSo;
                                        rel.RelatedLine = whLine;
                                        rel.IsOrderRelation = true;
										rel.DontSave = true;

                                        rel = whLine.CommercialWarehouseRelations.CreateNew();
                                        rel.Quantity = unrelatedSo;
                                        rel.RelatedLine = soLine;
                                        rel.IsOrderRelation = true;

                                        quantityToGo -= unrelatedSo;

                                        if (!relatedOutcomes.Contains(whDoc))
                                            relatedOutcomes.Add(whDoc);
                                    }
                                }
                            }
                        }
                    }

                    //teraz wiazemy ZSP ze wszystkimi rozchodami ktore sa powiazane na liniach. musi byc powiazanie naglowkowe dla spojnosci
                    //bo np. walidacja czy wz ma wiele ZSow tego uzywa
                    foreach (var whDoc in relatedOutcomes)
                    {
                        var relation = whDoc.Relations.CreateNew();
                        relation.RelationType = DocumentRelationType.SalesOrderToWarehouseDocument;
                        relation.RelatedDocument = soDoc;

                        relation = soDoc.Relations.CreateNew();
                        relation.RelationType = DocumentRelationType.SalesOrderToWarehouseDocument;
                        relation.RelatedDocument = whDoc;
						relation.DontSave = true;
					}
                }

				commercialDocument.AddRelatedObjectsAsFirst(soDocs.Select(doc => (IBusinessObject)doc).ToList());
            }
        }

        private void ProcessInvoiceToSalesOrder(CommercialDocument commercialDocument)
        {
            if (commercialDocument.IsNew && commercialDocument.CheckSourceType(SourceType.SalesOrder))
            {
                CommercialDocument salesOrder = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(commercialDocument.Source.Element(XmlName.SalesOrderId).Value));
                bool closeOrder = (commercialDocument.Source.Element(XmlName.CloseOrder) != null && commercialDocument.Source.Element(XmlName.CloseOrder).Value.ToUpperInvariant() == "TRUE");

				XElement processObjectElement = commercialDocument.Source.Element(XmlName.ProcessObject);
				string processObjectValue = processObjectElement != null ? processObjectElement.Value : String.Empty;
				bool isSimulatedInvoice = processObjectValue == ProcessObjectName.SimulatedInvoice;

				//poprawić aby prawidłowo wystawiały się proformy do zamówienia sprzedażowego

				//co ze specyfikacją zamówienia??
                if (!closeOrder) //zaliczki maja specyfikacje zamowienia
                {
                    var attr = commercialDocument.Attributes.CreateNew(DocumentFieldName.Attribute_SalesOrderXml);
                    attr.Value = salesOrder.Serialize();
                    //wywalamy pozycje kosztowe
                    List<XElement> linesToDelete = new List<XElement>();
                    XElement lines = attr.Value.Element("lines");
                    string attrId = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption).Id.ToUpperString();

                    foreach (XElement line in lines.Elements())
                    {
                        var lineAttr = line.Element("attributes").Elements().Where(a => a.Element("documentFieldId").Value == attrId).First();

                        if (lineAttr.Element("value").Value == "2" || lineAttr.Element("value").Value == "4")
                            linesToDelete.Add(line);
                    }

                    foreach (var l in linesToDelete)
                        l.Remove();
                }

				DocumentRelationType documentRelationType = isSimulatedInvoice 
					? DocumentRelationType.SalesOrderToSimulatedInvoice : DocumentRelationType.SalesOrderToInvoice;

                DocumentRelation relation = commercialDocument.Relations.CreateNew(BusinessObjectStatus.New);
                relation.RelationType = documentRelationType;
                relation.RelatedDocument = salesOrder;
                relation.DontSave = true;

                relation = salesOrder.Relations.CreateNew();
                relation.RelationType = documentRelationType;
                relation.RelatedDocument = commercialDocument;

                commercialDocument.AddRelatedObject(salesOrder);

                // relacje zapisujemy od strony zamowienia sprzedazowego, dlatego ze tam musi byc walidacja czy suma zaliczek jest rowna wartosci zs +/- wartosc odchylku
				if (closeOrder && commercialDocument.IsSettlementDocument)
				{
					//generujemy dokumenty magazynowe ktore jeszcze nie zostaly wygenerowane
					this.coordinator.RealizeSalesOrder(salesOrder, new XDocument(new XElement("root", new XElement("closeOrder", "true"))));

					//dodajemy powiazania pomiedzy faktura rozliczajaca a wszelkimi dok. magazynowymi co ZS posiada
					foreach (var line in commercialDocument.Lines)
					{
						if (!String.IsNullOrEmpty(line.Tag))
						{
							Guid soLineId = new Guid(line.Tag);
							var soLine = salesOrder.Lines.Where(l => l.Id.Value == soLineId).FirstOrDefault();

							if (soLine != null)
							{
								foreach (var soRel in soLine.CommercialWarehouseRelations)
								{
									var rel = line.CommercialWarehouseRelations.CreateNew();
									rel.RelatedLine = soRel.RelatedLine;
									rel.Quantity = soRel.Quantity;
									rel.IsCommercialRelation = true;
								}
							}
						}
					}
				}
				else if (commercialDocument.Tag == "0") //czyli to pierwsza zaliczka
					salesOrder.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "open";
			}

            //edycja lub nowa faktura zaliczkowa/rozliczajaca - jezeli payment jest w granicy bledu to go wywalamy
            if (commercialDocument.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null)
            {
                List<Payment> paymentsToDelete = new List<Payment>();

                foreach (var pt in commercialDocument.Payments)
                {
                    if (pt.Amount == 0)
                        paymentsToDelete.Add(pt);
                }

                foreach (var pt in paymentsToDelete)
                    commercialDocument.Payments.Remove(pt);
            }
        }

        private void ProcessInvoiceToServiceDocument(CommercialDocument commercialDocument)
        {
            if (commercialDocument.IsNew && commercialDocument.Source != null && commercialDocument.Source.Attribute("type") != null &&
                commercialDocument.Source.Attribute("type").Value == "serviceDocument")
            {
                if (String.IsNullOrEmpty(commercialDocument.Tag))
                    throw new InvalidOperationException("Missing 'tag' attribute from commercialDocument node");

                string[] versions = commercialDocument.Tag.Split(new char[] { ',' });

                foreach (string version in versions)
                    this.mapper.CheckCommercialDocumentVersion(new Guid(version));

                List<ServiceDocument> serviceDocuments = new List<ServiceDocument>();

                ServiceDocument serviceDocument = null;

                foreach (XElement srvDocId in commercialDocument.Source.Elements("serviceDocumentId"))
                {
                    Guid serviceDocumentId = new Guid(srvDocId.Value);

                    serviceDocument = (ServiceDocument)mapper.LoadBusinessObject(BusinessObjectType.ServiceDocument, serviceDocumentId);

                    if (serviceDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value == "closed")
                        throw new ClientException(ClientExceptionId.InvoiceToClosedServiceDocument);

                    serviceDocuments.Add(serviceDocument);
                }

                foreach (CommercialDocumentLine line in commercialDocument.Lines.Children)
                {
                    if (String.IsNullOrEmpty(line.Tag)) //linie dodane z palca pomijamy
                        continue;

                    string[] tags = line.Tag.Split(new char[] { ',' }); //0 to ordinalNumber linii, 1 to id naglowka

                    serviceDocument = serviceDocuments.Where(d => d.Id.Value == new Guid(tags[1])).First();

                    var serviceLine = serviceDocument.Lines[Convert.ToInt32(tags[0], CultureInfo.InvariantCulture) - 1];

                    var srvRealizedAttr = serviceLine.Attributes[DocumentFieldName.LineAttribute_ServiceRealized];

                    if (srvRealizedAttr == null)
                    {
                        srvRealizedAttr = serviceLine.Attributes.CreateNew();
                        srvRealizedAttr.DocumentFieldName = DocumentFieldName.LineAttribute_ServiceRealized;
                        srvRealizedAttr.Value.Value = "0";
                    }

                    decimal realized = Convert.ToDecimal(srvRealizedAttr.Value.Value, CultureInfo.InvariantCulture);

                    realized += line.Quantity;

                    if (realized > serviceLine.Quantity) //realizujemy nie wiecej niz mozna
                        realized = serviceLine.Quantity;

                    srvRealizedAttr.Value.Value = realized.ToString(CultureInfo.InvariantCulture);
                }

                foreach (ServiceDocument srvDocument in serviceDocuments)
                {
                    bool isServiceReservationEnabled = ProcessManager.Instance.IsServiceReservationEnabled(srvDocument);

                    //na WZ nie trzeba ustawiac zadnej flagi zeby pomijal zarezerwowane bo najpierw i tak ZS sie zapisze

                    commercialDocument.AddRelatedObject(srvDocument);
                    var relation = commercialDocument.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.ServiceToInvoice;
                    relation.RelatedDocument = srvDocument;

                    relation = srvDocument.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.ServiceToInvoice;
                    relation.RelatedDocument = commercialDocument;
                    relation.DontSave = true;

                    //generujemy RWtki
                    CommercialDocumentLogic.GenerateInternalOutcomesToServiceDocument(srvDocument);

                    //sprawdzamy czy mamy zamknac zlecenie
                    if (commercialDocument.Source.Element("closeOrder") != null && commercialDocument.Source.Element("closeOrder").Value.ToUpperInvariant() == "TRUE")
                    {
                        srvDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "closed";

                        if (srvDocument.DocumentStatus == DocumentStatus.Saved)
                            srvDocument.DocumentStatus = DocumentStatus.Committed;

                        srvDocument.ClosureDate = SessionManager.VolatileElements.CurrentDateTime;
                    }
                    else if (isServiceReservationEnabled) //wlaczone rezerwacje a mamy nie zamykac
                        throw new ClientException(ClientExceptionId.ServiceProcessConfigurationError);
                }
            }
        }

        public static void GenerateInternalOutcomesToServiceDocument(ServiceDocument serviceDocument)
        {
            string template = ProcessManager.Instance.GetDocumentTemplate(serviceDocument, "internalOutcome");
            ICollection<WarehouseDocument> generatedOutcomes = CommercialWarehouseDocumentFactory.Generate(serviceDocument, template, false, false);

            string processType = serviceDocument.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value;

            DocumentRelation relation = null;

            bool isServiceReservationEnabled = ProcessManager.Instance.IsServiceReservationEnabled(serviceDocument);

            foreach (var outcome in generatedOutcomes)
            {
                if (isServiceReservationEnabled)
                    outcome.SkipReservedQuantityCheck = true;

                relation = serviceDocument.Relations.CreateNew();
                relation.RelationType = DocumentRelationType.ServiceToInternalOutcome;
                relation.RelatedDocument = outcome;

                relation = outcome.Relations.CreateNew();
                relation.RelationType = DocumentRelationType.ServiceToInternalOutcome;
                relation.RelatedDocument = serviceDocument;
                relation.DontSave = true;

                ProcessManager.Instance.AppendProcessAttributes(outcome, processType, "internalOutcome", null, null);

                serviceDocument.AddRelatedObject(outcome);
            }

            //oznaczamy wszystkie pozycje na zleceniu serwisowym, ktora maja opcje z RW ze sa calkowicei zrealizowane
            foreach (CommercialDocumentLine line in serviceDocument.Lines.Children)
            {
                var attrib = line.Attributes[DocumentFieldName.LineAttribute_ServiceRealized];

                if (attrib == null)
                {
                    attrib = line.Attributes.CreateNew();
                    attrib.DocumentFieldName = DocumentFieldName.LineAttribute_ServiceRealized;
                }

                attrib.Value.Value = line.Quantity.ToString(CultureInfo.InvariantCulture);
            }
        }

        private void ProcessInvoiceToBill(CommercialDocument commercialDocument)
        {
            if (commercialDocument.IsNew && commercialDocument.Source != null && commercialDocument.Source.Attribute("type") != null &&
                commercialDocument.Source.Attribute("type").Value == "invoiceToBill")
            {
                Guid sourceDocumentId = new Guid(commercialDocument.Source.Element("commercialDocumentId").Value);

                CommercialDocument sourceDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, sourceDocumentId);
                sourceDocument.SkipCorrectionEditCheck = true;
                sourceDocument.ClearDisableLinesChangeReason();
                SessionManager.VolatileElements.SourceDocument = sourceDocument;

                if (sourceDocument.DocumentStatus == DocumentStatus.Canceled)
                    throw new ClientException(ClientExceptionId.CreateNewDocumentFromCanceledDocument);

                //sprawdzamy korekty tutaj

                ICollection<Guid> previousDocumentsId = mapper.GetCommercialCorrectiveDocumentsId(sourceDocumentId);

                CommercialDocument lastDoc = sourceDocument;

                foreach (Guid corrId in previousDocumentsId)
                {
                    CommercialDocument correctiveDoc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, corrId);
                    correctiveDoc.SkipCorrectionEditCheck = true;
                    CommercialCorrectiveDocumentFactory.RelateTwoCorrectiveDocuments(lastDoc, correctiveDoc, true);

                    lastDoc = correctiveDoc;
                }

                SessionManager.VolatileElements.LastCorrectiveDocument = lastDoc;

                //poki mamy wartosci roznicowe to latwo nam jest teraz sprawdzic ktore linie dok. handlowego powinny przejsc
                //na FD a wiec wiemy ktore nalezy odpiac z magazynem. dokument dodamy do RelatedObjects w daleszej czesci algorytmu
                //wiec tutaj tylko czyscimy powiazania

                foreach (CommercialDocumentLine lastLine in lastDoc.Lines.Children)
                {
                    if (lastDoc != sourceDocument && lastLine.Quantity != 0) //czyli mamy korekty
                        continue;

                    CommercialDocumentLine srcLine = lastLine;

                    if (lastLine.InitialCommercialDocumentLine != null)
                        srcLine = lastLine.InitialCommercialDocumentLine;

                    srcLine.CommercialWarehouseRelations.RemoveAll();
                    srcLine.CommercialWarehouseValuations.RemoveAll();

                    srcLine.CommercialDirection = 0;
                }

                commercialDocument.AddRelatedObject(sourceDocument);

                foreach (var pt in commercialDocument.Payments)
                    pt.Direction = 0;
            }
        }

        private void ExecuteDocumentOptions(CommercialDocument document, bool withinTransaction)
        {
            foreach (IDocumentOption option 
				in document.DocumentOptions.Where(docOption => docOption.ExecuteWithinTransaction == withinTransaction))
            {
                option.Execute(document);
            }
        }

        /// <summary>
        /// Executes the custom logic during transaction.
        /// </summary>
        /// <param name="document">The document to execute custom logic for.</param>
        private void ExecuteCustomLogicDuringTransaction(CommercialDocument document)
        {
            if (document.ReceivingPerson != null && document.ReceivingPerson.IsNew)
            {
                using (ContractorCoordinator contractorCoordinator = new ContractorCoordinator(false, false))
                {
                    Contractor documentContractor = (Contractor)document.Contractor;
                    Contractor receivingContractor = (Contractor)document.ReceivingPerson;

                    ContractorRelation relation = documentContractor.Relations.CreateNew();
                    relation.ContractorRelationTypeName = ContractorRelationTypeName.Contractor_ContactPerson;
                    relation.RelatedObject = receivingContractor;

                    contractorCoordinator.SaveBusinessObject(documentContractor);

                    document.ReceivingPerson.Version = receivingContractor.NewVersion;
                }
            }

            //jezeli dokument byl wystawiony z jakiegos magazynowego
            if (document.Source != null && document.Source.Attribute("type").Value == "warehouseDocument")
            {
                List<WarehouseDocumentLine> whLines = new List<WarehouseDocumentLine>();

                //wczytujemy na nowo wszystkie powiazane dok. magazynowe i sprawdzamy/walidujemy relacje
                foreach (XElement whId in document.Source.Elements("warehouseDocumentId"))
                {
                    WarehouseDocument doc = (WarehouseDocument)mapper.LoadBusinessObject(BusinessObjectType.WarehouseDocument, new Guid(whId.Value));

                    CommercialWarehouseDocumentFactory.CheckIfWarehouseDocumentHasSalesOrderWithPrepaids(doc);

                    foreach (WarehouseDocumentLine line in doc.Lines.Children)
                        whLines.Add(line);
                }

                foreach (CommercialDocumentLine line in document.Lines.Children.Where(l => l.CommercialWarehouseRelations.Children.Count > 0))
                {
                    for (int i = 0; i < line.CommercialWarehouseRelations.Children.Count; i++)
                    {
                        WarehouseDocumentLine whLine = whLines.Where(w => w.Id.Value == line.CommercialWarehouseRelations[i].RelatedLine.Id.Value).FirstOrDefault();

                        if (whLine != null)
                        {
                            CommercialWarehouseRelation relation = line.CommercialWarehouseRelations[i];
                            //na wszelki wypadek zapisujemy sobie referencje do pelnej linii a nie tylko szczatkow co z xmla od panelu przyszlo
                            relation.RelatedLine = whLine;

                            decimal unrelatedWhQuantity = whLine.Quantity - whLine.CommercialWarehouseRelations.Children.Sum(s => s.IsCommercialRelation ? s.Quantity : 0);

                            //korygujemy ilosc na nowym powiazaniu tak zeby nie powiazac wiecej niz jest niepowiazanych na dok magazynowym
                            if (line.Quantity >= unrelatedWhQuantity)
                                relation.Quantity = unrelatedWhQuantity;
                            else
                                relation.Quantity = line.Quantity;

                            if (((WarehouseDocument)whLine.Parent).WarehouseDirection == WarehouseDirection.Income)
                            {
                                //sprawdzamy ile pozycji jest niewycenionych jeszcze i wyceniamy nie min(ilosc powiazanych teraz ilosciowo, ilosc niewycenionych)
                                decimal unvaluatedCount = whLine.Quantity - whLine.CommercialWarehouseValuations.Children.Sum(v => v.Quantity);

                                if (unvaluatedCount > 0)
                                {
                                    var valuation = line.CommercialWarehouseValuations.CreateNew(BusinessObjectStatus.New);
                                    valuation.RelatedLine = whLine;
                                    valuation.Quantity = Math.Min(unvaluatedCount, relation.Quantity);
                                    valuation.Price = line.NetPrice;
                                }
                            }
                        }
                    }
                }
            }
            else if (document.Source != null && document.Source.Attribute("type").Value == "salesOrder")
            {
                //sprawdzamy czy wystawiajac fakture do ZSP to czy czasem ZSP nie ma wztow z fakturami
                bool closeOrder = false;

                if (document.Source.Element("closeOrder") != null && document.Source.Element("closeOrder").Value.ToUpperInvariant() == "TRUE")
                    closeOrder = true;

                SalesOrderFactory.CheckIfSalesOrderHasWarehouseDocumentsWithInvoices(document, closeOrder);
            }

            this.ProcessInvoiceToMultipleReservations(document);
        }

        private void ValidateDuringTransaction(CommercialDocument document)
        {
            if (!document.IsNew && !document.SkipCorrectionEditCheck)
            {
                bool areCorrectionsExist = this.mapper.AreLaterCorrectionExist(document.Id.Value);

                if (areCorrectionsExist && document.DocumentStatus == DocumentStatus.Canceled)
                    throw new ClientException(ClientExceptionId.UnableToCancelCorrectedDocument);
                else if (areCorrectionsExist)
                    throw new ClientException(ClientExceptionId.UnableToEditDocumentBecauseOfCorrections);
            }

            if (document.IsNew && document.Source != null && document.Source.Attribute("type") != null &&
                document.Source.Attribute("type").Value == "serviceDocument")
            {
                if (String.IsNullOrEmpty(document.Tag))
                    throw new InvalidOperationException("Missing 'tag' attribute from commercialDocument node");

                string[] tags = document.Tag.Split(new char[] { ',' });

                foreach (string tag in tags)
                    this.mapper.CheckCommercialDocumentVersion(new Guid(tag));
            }

            if (document.IsNew && document.Source != null && document.Source.Attribute("type") != null &&
                document.Source.Attribute("type").Value == "simulatedInvoice")
            {
                if (String.IsNullOrEmpty(document.Tag))
                    throw new InvalidOperationException("Missing 'tag' attribute from commercialDocument node");

                this.mapper.CheckCommercialDocumentVersion(new Guid(document.Tag));
            }

            if (document.IsNew && document.Source != null && document.Source.Attribute("type") != null &&
                document.Source.Attribute("type").Value == "salesOrder" && !String.IsNullOrEmpty(document.Tag))
            {
                int prepaids = Convert.ToInt32(document.Tag, CultureInfo.InvariantCulture);
                int prepaidsFromDb = this.mapper.GetPrepaidDocumentsNumber(new Guid(document.Source.Element("salesOrderId").Value));

                if (prepaids != prepaidsFromDb)
                    throw new ClientException(ClientExceptionId.SalesOrderPrepaidsNumberMismatch);
            }

			#region Walidacja zmian w dokumencie sprzedażowym realizującym zamówienie sprzedażowe,
			//Tylko jeśli dokument był edytowany w panelu a nie zapisywany jako powiązany z innym dokumentem akurat edytowanym

			if (this.coordinator.CanCommitTransaction)
			{
				document.ValidateSalesOrderRealizedLines(true);
			}

			#endregion

			#region Walidacja realizacji zamówienia sprzedażowego za pomocą dokumentu sprzedażowego

			bool isSingleSalesOrderRealization = document.CheckSourceType(SourceType.SalesOrderRealization);
			bool isMultipleSalesOrderRealization = document.CheckSourceType(SourceType.MultipleSalesOrders);
            

			if (isSingleSalesOrderRealization || isMultipleSalesOrderRealization)
			{
				//Zabraniamy przy realizacji ZS dokumentem sprzedażowym odznaczenie opcji generowania WZ, uwaga PROFORMA jest zawsze wystawiana bez magazynowych
				if (document.DocumentType.DocumentCategory.ToString() != "Purchase" && !document.IsSimulatedInvoice && !document.DocumentOptionsContains(typeof(GenerateDocumentOption), GenerateDocumentOption.OutcomeFromSalesMethod))
				{
					throw new ClientException(ClientExceptionId.GenerateOutcomeFromSalesOptionMissing);
				}

				List<Guid> salesOrdersIds = SalesOrderFactory.ExtractSourceSalesOrdersIds(document.Source);
				DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
				List<CommercialDocument> salesOrders = mapper.LoadBusinessObjects<CommercialDocument>(BusinessObjectType.CommercialDocument, salesOrdersIds);
				SalesOrderRealizationInfo relatedCommercialDocumentsLines = mapper.GetCommercialDocumentLinesRealizingSalesOrders(salesOrders);
				foreach (CommercialDocumentLine line in document.Lines)
				{
					Guid? relatedLineId = line.Attributes.GetGuidValueByFieldName(DocumentFieldName.LineAttribute_RealizedSalesOrderLineId);
					//Uwzgledniamy jedynie linie realizujące pozycje z zam. sprzedażowego
					if (relatedLineId.HasValue)
					{
						if (isSingleSalesOrderRealization)
						{
							//Sprawdzamy czy user nie zwiększył wartości na pozycji podczas realizacji
							string sourceQuantity = document.Source.Elements()
								.Where(el => el.Attribute(XmlName.Id) != null
									&& (new Guid(el.Attribute(XmlName.Id).Value)) == relatedLineId.Value && el.Attribute(XmlName.Quantity) != null)
								.Select(el => el.Attribute(XmlName.Quantity).Value).FirstOrDefault();
							if (String.IsNullOrEmpty(sourceQuantity) || Convert.ToDecimal(sourceQuantity, CultureInfo.InvariantCulture) < line.Quantity)
							{
								throw new ClientException(ClientExceptionId.LineQuantityChangeForbiddenDuringRelazationOfSalesOrder);
							}
						}

						decimal salesOrderLineQuantity = 0;
						var salesOrderLines =
							(from salesOrder in salesOrders
							 where salesOrder.Lines.Where(l => l.Id == relatedLineId.Value).Count() != 0
							 select salesOrder.Lines.Where(l => l.Id == relatedLineId.Value).FirstOrDefault());
						CommercialDocumentLine salesOrderLine = salesOrderLines.FirstOrDefault();
						if (salesOrderLine != null)
						{
							salesOrderLineQuantity = salesOrderLine.Quantity;
						}
						decimal commercialDocumentsQuantity = relatedCommercialDocumentsLines.SumQuantity(relatedLineId.Value);
						//Jeśli ilość na wszystkich realizujących pozycjach we wszystkich dokumentach łącznie z aktualnie wystawianym jest większa niż na pozycji realizowanej - nie pozwalamy na to, zakładamy, że pełna ilość na pozycji dok. sprzed. realizuje pozycję z ZS.
                        if (document.DocumentType.DocumentCategory.ToString() != "Purchase" && commercialDocumentsQuantity + line.AbsoluteCommercialQuantity > salesOrderLineQuantity)
						{
							throw new ClientException(ClientExceptionId.ExcessiveSalesOrderRealizationByCommercialDocument, null,
								"order:" + line.Order.ToString(CultureInfo.InvariantCulture)
								, "allowedQuantity:" + (salesOrderLine.Quantity - commercialDocumentsQuantity).ToString("0.##", CultureInfo.InvariantCulture));
						}
					}
				}
			}
			#endregion
		}

        private void CalculateDifferentialCorrectiveValue(CommercialDocument document)
        {
            foreach (CommercialDocumentLine line in document.Lines.Children.Reverse())
            {
                line.DiscountGrossValue -= line.CorrectedLine.DiscountGrossValue;
                line.DiscountNetValue -= line.CorrectedLine.DiscountNetValue;
                line.DiscountRate -= line.CorrectedLine.DiscountRate;
                line.GrossPrice -= line.CorrectedLine.GrossPrice;
                line.GrossValue -= line.CorrectedLine.GrossValue;
                line.InitialGrossPrice -= line.CorrectedLine.InitialGrossPrice;
                line.InitialGrossValue -= line.CorrectedLine.InitialGrossValue;
                line.InitialNetPrice -= line.CorrectedLine.InitialNetPrice;
                line.InitialNetValue -= line.CorrectedLine.InitialNetValue;
                line.NetPrice -= line.CorrectedLine.NetPrice;
                line.NetValue -= line.CorrectedLine.NetValue;
                line.Quantity -= line.CorrectedLine.Quantity;
                line.VatValue -= line.CorrectedLine.VatValue;
            }

            CommercialDocument originalDocument = (CommercialDocument)document.Lines.Children.First().CorrectedLine.Parent;

            //calculate differential vat table

            foreach (CommercialDocumentVatTableEntry vtEntry in document.VatTableEntries.Children)
            {
                var query = originalDocument.VatTableEntries.Children.Where(v => v.VatRateId == vtEntry.VatRateId);

                if (originalDocument.IsSettlementDocument)
                    query = query.Where(vv => vv.NetValue > 0 && vv.GrossValue > 0 && vv.VatValue > 0);

                CommercialDocumentVatTableEntry vtEntryBeforeCorrection = query.FirstOrDefault();

                if (vtEntryBeforeCorrection != null)
                {
                    vtEntry.GrossValue -= vtEntryBeforeCorrection.GrossValue;
                    vtEntry.NetValue -= vtEntryBeforeCorrection.NetValue;
                    vtEntry.VatValue -= vtEntryBeforeCorrection.VatValue;
                }
            }

            decimal netValue = originalDocument.NetValue;
            decimal grossValue = originalDocument.GrossValue;
            decimal vatValue = originalDocument.VatValue;

            if (originalDocument.IsSettlementDocument)
            {
                netValue = originalDocument.VatTableEntries.Where(ss => ss.NetValue > 0 && ss.GrossValue > 0 && ss.VatValue > 0).Sum(s => s.NetValue);
                grossValue = originalDocument.VatTableEntries.Where(ss => ss.NetValue > 0 && ss.GrossValue > 0 && ss.VatValue > 0).Sum(s => s.GrossValue);
                vatValue = originalDocument.VatTableEntries.Where(ss => ss.NetValue > 0 && ss.GrossValue > 0 && ss.VatValue > 0).Sum(s => s.VatValue);
            }

            document.NetValue -= netValue;
            document.GrossValue -= grossValue;
            document.VatValue -= vatValue;
        }

        private void ProcessCorrectiveDocument(CommercialDocument document)
        {
            CommercialDocument originalCorrection = null;

            if (document.IsNew)
            {
                originalCorrection = (CommercialDocument)this.coordinator.CreateNewBusinessObject(BusinessObjectType.CommercialDocument,
                    document.Source.Attribute("template").Value, document.Source);
            }
            else
            {
                originalCorrection = (CommercialDocument)this.coordinator.LoadBusinessObject(BusinessObjectType.CommercialDocument, document.Id.Value);
            }

            foreach (CommercialDocumentLine lineFromPanel in document.Lines.Children)
            {
                //dwie linie korygujace to samo
                CommercialDocumentLine line = originalCorrection.Lines.Children.Where(l => l.CorrectedLine.Id.Value == lineFromPanel.CorrectedLine.Id.Value).FirstOrDefault();

                if (line != null)
                    lineFromPanel.CorrectedLine = line.CorrectedLine;
                else
                {
                    line = document.Lines.Children.Where(ll => ll.Id.Value == lineFromPanel.CorrectedLine.Id.Value).FirstOrDefault();

                    if (line != null)
                        lineFromPanel.CorrectedLine = line;
                    else
                        throw new InvalidOperationException("Cannot locate line to correct.");
                }
            }

            document.CorrectedDocument = originalCorrection.CorrectedDocument;

			if (document.VatTableEntries.Children.Count > 0)
			{
				document.GrossValue = document.VatTableEntries.Sum(vt => vt.GrossValue);
				document.NetValue = document.VatTableEntries.Sum(vt => vt.NetValue);
				document.VatValue = document.VatTableEntries.Sum(vt => vt.VatValue);
			}
			
			this.CalculateDifferentialCorrectiveValue(document);
        }

        private void CheckForPreviousCorrectionChanges(CommercialDocument document)
        {
            CommercialDocumentLine line = document.Lines.Children.First();

            while (line.CorrectedLine != null)
            {
                this.mapper.CheckBusinessObjectVersion(line.CorrectedLine.Parent);
                line = line.CorrectedLine;
            }
        }

        private void GenerateNormalWarehouseCorrection(CommercialDocument document, bool incomeCorrection)
        {
            IDictionary<Guid, Guid> itemTypeCache = SessionManager.VolatileElements.ItemTypesCache;

            List<CommercialDocumentLine> linesToProcess = new List<CommercialDocumentLine>();
            List<Guid> linesId = new List<Guid>();

            foreach (CommercialDocumentLine line in document.Lines.Children)
            {
                if (!DictionaryMapper.Instance.GetItemType(itemTypeCache[line.ItemId]).IsWarehouseStorable)
                    continue;

				//uwzględniamy też pozycje korygujące
                if (line.Quantity < 0 || document.Lines.Any(dline => dline.Id == line.CorrectedLine.Id) 
					|| incomeCorrection && line.NetPrice != 0)
                {
                    linesToProcess.Add(line);
                    //id pozycji wz powiazanej z pozycja pierwotnej faktury

                    CommercialDocumentLine commLine = line.InitialCommercialDocumentLine;
                    var relations = commLine.CommercialWarehouseRelations.Children.Where(r => r.IsCommercialRelation == true);

                    if (relations.Count() != 1)
                        throw new ClientException(ClientExceptionId.WarehouseCorrectionError2);

                    linesId.Add(relations.First().RelatedLine.Id.Value);
                }
            }

            //process lines
            ICollection<GetHeadersIdForWarehouseLinesResponse> responses = this.mapper.GetHeadersIdForWarehouseLines(linesId);
            Dictionary<Guid, WarehouseDocument> whCorrections = new Dictionary<Guid, WarehouseDocument>();

            foreach (var response in responses)
            {
                //sprawdzamy czy mamy juz utworzona korekte wz'tki do ktorej nalezy ta linia
                WarehouseDocument correction = null;

                if (whCorrections.ContainsKey(response.WarehouseDocumentHeaderId))
                    correction = whCorrections[response.WarehouseDocumentHeaderId];
                else //zakladamy nowa korekte
                {
                    //sprawdzamy jakim szablonem korygowac ta wz-tke
                    DocumentType dt = DictionaryMapper.Instance.GetDocumentType(response.DocumentTypeId);
                    string template = dt.WarehouseDocumentOptions.CorrectiveDocumentTemplate;

                    using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                    {
                        correction = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument,
                            template, new XElement("source", new XAttribute("type", "correction"), new XElement("correctedDocumentId", response.WarehouseDocumentHeaderId.ToUpperString())));
                    }
					//W tej chwili korekta będzie miala atrybuty skopiowane z dok. magazynowego, który koryguje. Musimy również skopiować wymagane atrybuty z korekty dok. handlowego.
					//Skopiowanie z korekty handlowego nastąpi tylko raz bo potem dodamy już do cache i potem z niego będziemy pobierać
					List<Guid> attrsToCopy = new List<Guid> ();
					DuplicableAttributeFactory.DuplicateAttributes(document, correction, attrsToCopy);
					//Jeśli atrybut zostanie zablokowany bo już jest i jest OneInstance to go i tak kopiujemy
					DuplicableAttributeFactory.CopyAttributes(document, correction, attrsToCopy);

                    whCorrections.Add(response.WarehouseDocumentHeaderId, correction);
                }

                //odszukujemy linie korygowana na fakturze (wersja po korekcie z ostatniej korekty) i linie po korekcie na nowo
                //tworzonej wz i sprawdzamy czy maja zgodne ilosci

				//ta zmienna zawiera również pozycję korygującą
				var correctingLines = linesToProcess.Where(l => l.InitialCommercialDocumentLine != null && l.InitialCommercialDocumentLine.CommercialWarehouseRelations.Children.Where(rr => rr.IsCommercialRelation == true).First().RelatedLine.Id.Value == response.LineId);
                CommercialDocumentLine line = correctingLines.FirstOrDefault();
                /*CommercialDocumentLine latestCommLine = line.CorrectedLine;
                IEnumerable<CommercialWarehouseRelation> latestCommLineRelations = latestCommLine.CommercialWarehouseRelations.Children.Where(r => r.IsCommercialRelation && r.Quantity > 0);

                if (latestCommLineRelations.Count() != 1)
                    throw new ClientException(ClientExceptionId.WarehouseCorrectionError2);*/

                /*
                 * Powyzszy kod zostal zmodyfikowany o mozliwosc cofnania sie do tylu w korektach az do momentu
                 * napotkania pozycji korekty ktora ma jakies powiazania z magazynem i wtedy dopiero sprawdzamy
                 * czy powiazania sa zgodne. Jest to zrobione dlatego ze w przeciwnym wypadku korekta wartosciowa
                 * nie ma powiazan z WZk (bo wzk nie ma) i potem po wartosciowej nie mozna wystawic juz ilosciowej
                 */

                //poczatek zmiany
                CommercialDocumentLine latestCommLine = line.CorrectedLine;
                IEnumerable<CommercialWarehouseRelation> latestCommLineRelations = null;

                CommercialDocumentLine ptrLine = latestCommLine;

                while (ptrLine != null && latestCommLineRelations == null)
                {
                    if (ptrLine.CommercialWarehouseRelations.Children.Count > 0) //jezeli linia ma choc jedno powiazanie z magazynem
                        latestCommLineRelations = ptrLine.CommercialWarehouseRelations.Children.Where(r => r.IsCommercialRelation && r.Quantity > 0);
                    else //jezeli nie ma to idziemy dalej wstecz
                        ptrLine = ptrLine.CorrectedLine;
                }

                if (latestCommLineRelations == null || latestCommLineRelations.Count() != 1)
                    throw new ClientException(ClientExceptionId.WarehouseCorrectionError2);
                //////koniec zmiany

                Guid whLineId = latestCommLineRelations.First().RelatedLine.Id.Value;

                WarehouseDocumentLine latestWhLine = correction.Lines.Children.Where(wl => wl.Id.Value == whLineId || (wl.InitialWarehouseDocumentLine != null && wl.InitialWarehouseDocumentLine.Id.Value == whLineId)).FirstOrDefault();

				if (latestWhLine == null || latestCommLine.Quantity != latestWhLine.Quantity)
                    throw new ClientException(ClientExceptionId.WarehouseCorrectionError3);

				latestWhLine.Quantity += correctingLines.Sum(l => l.Quantity);

                if (incomeCorrection)
                {
                    latestWhLine.Price += correctingLines.Sum(l => l.NetPrice);
                    latestWhLine.Value = latestWhLine.Price * latestWhLine.Quantity;
                }

				latestWhLine.CommercialCorrectiveLine = line;
			}

            using (DocumentCoordinator c = new DocumentCoordinator(false, false))
            {
                foreach (var value in whCorrections.Values)
                {
                    c.SaveBusinessObject(value);
                }
            }
        }

        private void GenerateBeforeSystemStartWarehouseCorrection(CommercialDocument document)
        {
            IDictionary<Guid, Guid> itemTypeCache = SessionManager.VolatileElements.ItemTypesCache;

            List<CommercialDocumentLine> linesToProcess = new List<CommercialDocumentLine>();
            Dictionary<Guid, WarehouseDocument> whCorrections = new Dictionary<Guid, WarehouseDocument>(); //whId->doc

            string template = null;

            CommercialDocument ptr = document;

            while (ptr.CorrectedDocument != null)
                ptr = ptr.CorrectedDocument;

            template = ptr.DocumentType.CommercialDocumentOptions.BeforeSystemStartWhCorrectionTemplate;

            if (String.IsNullOrEmpty(template))
                throw new ClientException(ClientExceptionId.MissingBeforeSystemStartWhCorrectionTemplate);

			bool isOutcome = false;

            foreach (CommercialDocumentLine line in document.Lines.Children)
            {
                if (!DictionaryMapper.Instance.GetItemType(itemTypeCache[line.ItemId]).IsWarehouseStorable)
                    continue;

                if (line.Quantity < 0)
                {
                    WarehouseDocument correction = null;

                    if (whCorrections.ContainsKey(line.WarehouseId.Value))
                        correction = whCorrections[line.WarehouseId.Value];
                    else
                    {
                        using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                        {
                            correction = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, template, null);
							isOutcome = correction.DocumentType.WarehouseDocumentOptions.WarehouseDirection == WarehouseDirection.Outcome;
                        }

                        correction.WarehouseId = line.WarehouseId.Value;
                        correction.Contractor = document.Contractor;
                        whCorrections.Add(line.WarehouseId.Value, correction);
                        correction.SkipQuantityValidation = true;
                    }

                    WarehouseDocumentLine whLine = correction.Lines.CreateNew();
                    whLine.Direction = -whLine.Direction; //zmieniamy znak
                    whLine.Quantity = line.Quantity;
                    whLine.ItemId = line.ItemId;
                    whLine.UnitId = line.UnitId;
                    var rel = whLine.CommercialWarehouseRelations.CreateNew();
                    rel.IsCommercialRelation = true;
                    rel.RelatedLine = line;
                    rel.Quantity = line.Quantity;
                }
            }

			if (ConfigurationMapper.Instance.IsWmsEnabled && isOutcome)
			{
				this.ProcessWMSForBeforeSystemStartWarehouseCorrection(whCorrections);
			}

            using (DocumentCoordinator c = new DocumentCoordinator(false, false))
            {
                foreach (var value in whCorrections.Values)
                {
                    c.SaveBusinessObject(value);
                }
            }
        }

		/// <summary>
		/// Create IORs and ShiftTransaction with shifts for BSS outcome Warehouse Corrections
		/// </summary>
		/// <param name="warehouseCorrections"></param>
		private void ProcessWMSForBeforeSystemStartWarehouseCorrection(Dictionary<Guid, WarehouseDocument> warehouseCorrections)
		{
			Configuration confCorrectionSlot
				= ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "warhouse.correctionSlot").FirstOrDefault();
			if (confCorrectionSlot == null)
				confCorrectionSlot = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "warehouse.correctionSlot").FirstOrDefault();

			if (confCorrectionSlot == null)
				return;

			string correctionSlotName = confCorrectionSlot.Value.Value;

			foreach (Guid warehouseId in warehouseCorrections.Keys)
			{
				if (DictionaryMapper.Instance.GetWarehouse(warehouseId).ValuationMethod == ValuationMethod.DeliverySelection)
				{
					WarehouseDocument correction = warehouseCorrections[warehouseId];

					correction.IsBeforeSystemStartOutcomeCorrection = true;

					CommercialWarehouseDocumentFactory.GenerateRelationsAndShiftsForOutcomeWarehouseDocument(correction, correctionSlotName);
				}
			}
		}

        private void GenerateWarehouseCorrection(CommercialDocument document)
        {
            bool generate = false;
            bool incomeCorrection = false;
            
            //spiecie korekt magazynu z handlowymi
            foreach (IDocumentOption option in document.DocumentOptions)
            {
                GenerateDocumentOption genOption = option as GenerateDocumentOption;

                if (genOption != null && genOption.Method == "correctiveOutcomeFromCorrectiveSales")
                {
                    generate = true;
                    break;
                }
                else if (genOption != null && genOption.Method == "correctiveIncomeFromCorrectivePurchase")
                {
                    generate = true;
                    incomeCorrection = true;
                    break;
                }
            }

            bool linesChanged = false;

            this.mapper.AddItemsToItemTypesCache(document);
            IDictionary<Guid, Guid> itemTypeCache = SessionManager.VolatileElements.ItemTypesCache;

            if (!document.IsNew && generate)
            {
                foreach (CommercialDocumentLine line in document.Lines.Children)
                {
                    if (!DictionaryMapper.Instance.GetItemType(itemTypeCache[line.ItemId]).IsWarehouseStorable)
                        continue;

                    if (line.Status == BusinessObjectStatus.New)
                    {
                        linesChanged = true;
                        break;
                    }
                    else if (line.Status == BusinessObjectStatus.Modified)
                    {
                        CommercialDocumentLine alternateLine = (CommercialDocumentLine)line.AlternateVersion;
                        
                        if (line.Quantity != alternateLine.Quantity)
                        {
                            linesChanged = true;
                            break;
                        }
                    }
                }

                if (((CommercialDocument)document.AlternateVersion).Lines.Children.Where(l => l.Status == BusinessObjectStatus.Deleted).FirstOrDefault() != null)
                {
                    linesChanged = true;
                }

                if (linesChanged)
                    throw new ClientException(ClientExceptionId.WarehouseCorrectionError);
            }

            //jezeli jest opcja zeby generowac i nie jest to edycja
            if (generate && document.IsNew)
            {
                CommercialDocument ptrDoc = document;

                while (ptrDoc.CorrectedDocument != null)
                    ptrDoc = ptrDoc.CorrectedDocument;

                if (!ptrDoc.IsBeforeSystemStart)
                    this.GenerateNormalWarehouseCorrection(document, incomeCorrection);
                else
                    this.GenerateBeforeSystemStartWarehouseCorrection(document);
            }
        }

        private void CorrectQuantityInRelations(CommercialDocument document)
        {
            /* trzeba poprawic ilosci na nowych relacjach ilosciowych bo moze byc sytuacja
             * gdzie wystawiamy sobie dokument z magazynu, po czym klient edytuje sobie ilosci na pozycji
             * ale oczywiscie glupi flex edytuje tylko ilosci na pozycji a nie rusza relacji i wysyla nam takiego
             * zwalonego xmla to teraz w tym etapie trzeba to poprawic bo potem nie bedzie mozna okreslic latwo
             * ile tak naprawde ilosci na pozycji jest powiazanych ilosciowo czy wycenionych
             */

            foreach (CommercialDocumentLine line in document.Lines.Children)
            {
                foreach (CommercialWarehouseRelation rel in line.CommercialWarehouseRelations.Children)
                {
                    if (rel.Status == BusinessObjectStatus.New && rel.Quantity > line.Quantity)
                        rel.Quantity = line.Quantity;
                }
            }
        }

        private void CheckDateDifference(CommercialDocument document)
        {
            if (document.AlternateVersion != null)
            {
                CommercialDocument alternate = (CommercialDocument)document.AlternateVersion;

                if (document.IssueDate > alternate.IssueDate) //zmieniono date na przyszlosc
                    document.IssueDate = new DateTime(document.IssueDate.Year, document.IssueDate.Month, document.IssueDate.Day, 0, 0, 0, 0);
                else if (document.IssueDate < alternate.IssueDate)
                    document.IssueDate = new DateTime(document.IssueDate.Year, document.IssueDate.Month, document.IssueDate.Day, 23, 59, 59, 500);

                if (document.EventDate > alternate.EventDate) //zmieniono date na przyszlosc
                    document.EventDate = new DateTime(document.EventDate.Year, document.EventDate.Month, document.EventDate.Day, 0, 0, 0, 0);
                else if (document.EventDate < alternate.EventDate)
                    document.EventDate = new DateTime(document.EventDate.Year, document.EventDate.Month, document.EventDate.Day, 23, 59, 59, 500);
            }
        }

        /// <summary>
        /// Saves the business object.
        /// </summary>
        /// <param name="document"><see cref="CommercialDocument"/> to save.</param>
        /// <returns>Xml containing result of oper</returns>
        public XDocument SaveBusinessObject(CommercialDocument document)
        {
			DocumentCategory category = document.DocumentType.DocumentCategory;
			
			DictionaryMapper.Instance.CheckForChanges();

			//Bezwarunkowo skopiuj kontrahenta z dokumentu do płatności.
			document.Payments.CopyDocumentContractor();

			//Wygenerowanie requestu dla modyfikacji ostatniej ceny zakupu. Tworzony już tutaj abyśmy mieli prawidłową wartość dla korekt (nie rożnicową)
			UpdateLastPurchasePriceRequest updateLastPurchasePriceRequest = null;
			if (category == DocumentCategory.Purchase || category == DocumentCategory.PurchaseCorrection)
			{
				updateLastPurchasePriceRequest = new UpdateLastPurchasePriceRequest(document);
			}


			if (document.IsCorrectiveDocument())
			{
				this.ProcessCorrectiveDocument(document);
                if (updateLastPurchasePriceRequest != null) //fix By Dominik - jest ok
				    updateLastPurchasePriceRequest.UpdateIssueDateForCorrectiveDocument(document);
			}

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            this.CheckDateDifference(document);

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            this.ExecuteCustomLogic(document);
            this.ExecuteDocumentOptions(document, false);
            this.ProcessInvoiceToMultipleSalesOrders(document);

            //validate
            document.Validate();

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            document.Validate();

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(document);

				this.ExecuteDocumentOptions(document, true);
				
				if (document.IsCorrectiveDocument())
                    this.CheckForPreviousCorrectionChanges(document);


                this.ExecuteCustomLogicDuringTransaction(document);
                this.ValidateDuringTransaction(document);
				//w transakcji modyfikujemy ostatnią cenę zakupu jeśli wcześniej był wygenerowany request 
				//i jeśli konfiguracja na to pozwala
				if (document.DocumentType.CommercialDocumentOptions.UpdateLastPurchasePrice)
				{
					this.mapper.UpdateStock(updateLastPurchasePriceRequest);
				}
				//logika dla automatycznego zamykania ZS w realizacji bezzaliczkowej
				this.coordinator.TryCloseSalesOrdersWhileRealization(document);
				this.SendRemoteOrder(document);

                DocumentLogicHelper.AssignNumber(document, this.mapper);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.UpdateDocumentInfoOnPayments(document);
                    this.mapper.CreateCommunicationXml(document);
                    this.mapper.UpdateDictionaryIndex(document);
                }
                
                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((CommercialDocument)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                    this.mapper.ExecuteOperations(operations);

                this.mapper.DeleteDocumentAccountingData(document);

                if (document.DocumentType.DocumentCategory == DocumentCategory.Reservation ||
                        document.DocumentType.DocumentCategory == DocumentCategory.Order)
                {
                    this.mapper.UpdateReservationAndOrderStock(document);
                }

                if (operations.Root.HasElements)
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow

                if (category == DocumentCategory.SalesCorrection || category == DocumentCategory.PurchaseCorrection)
                    this.GenerateWarehouseCorrection(document);

                if (category == DocumentCategory.Sales || category == DocumentCategory.SalesCorrection)
                {
                    ((DocumentMapper)this.mapper).ValuateCommercialDocument(document);

                    this.ValidateSalesBelowPurchasePrice(document);

                    if (document.NewVersion != null)
                        document.Version = document.NewVersion.Value;

                    document.NewVersion = Guid.NewGuid();
                    this.mapper.CreateCommunicationXml(document);

                    if (document.DocumentStatus != DocumentStatus.Canceled && category == DocumentCategory.Sales && !document.SkipMinimalMarginValidation)
                        this.ValidateProfitMarginAndMaxDiscount(document.Id.Value);
                }

                this.ValuateIncomeSourceDocuments(document);

                if (document.DraftId != null)
                    this.mapper.DeleteDraft(document.DraftId.Value);

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", document.Id.ToUpperString()));

				//Custom validation
				this.mapper.ExecuteOnCommitValidationCustomProcedure(document);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:41");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:42");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        private void ValidateProfitMarginAndMaxDiscount(Guid commercialDocumentId)
        {
            if (!ConfigurationMapper.Instance.MinimalProfitMarginValidation) return;

			//po stronie bazy jest robiona wycena przy zapisie - odczytujemy obiekt po zapisie do bazy gdyż wycena jest potrzebna przy tej walidacji
            CommercialDocument document = (CommercialDocument)this.mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, commercialDocumentId);
            List<Guid> items = new List<Guid>();

            foreach (var line in document.Lines)
            {
                if (!items.Contains(line.ItemId))
                {
                    items.Add(line.ItemId);
                }
            }

            XElement itemsGroups = DependencyContainerManager.Container.Get<ItemMapper>().GetItemsGroups(items);

            //robimy slownik itemId -> miminalna marza
            Dictionary<Guid, decimal> dctItemIdToMinimalMargin = new Dictionary<Guid, decimal>();
			//oraz itemId -> maksymalny rabat
			Dictionary<Guid, decimal> dctItemIdToMaximalDiscount = new Dictionary<Guid, decimal>();

			//sprawdzamy czy user ma uprawnienia do korzystania ze specjalnego rabatu
			ContractorAttrValue contractorAttr = document.Contractor != null ? 
				document.Contractor.Attributes[ContractorFieldName.Attribute_AllowSpecialDiscount] : null;
			bool canUseSpecialDiscount = contractorAttr != null && contractorAttr.Value.Value == "1";

			//towar może należeć do wielu grup - dla minimalnej marży więc liczymy minimum z minimalnych marż ustawionych dla tych grup, dla maksymalnego rabatu liczymy maksimum
			#region Compute values to compare with
			foreach (var itemXml in itemsGroups.Elements())
            {
                decimal? minimalMargin = null;
				decimal? maximalDiscount = null;

                foreach (var groupIdXml in itemXml.Elements())
                {
                    decimal? margin = DictionaryMapper.Instance.GetMinimalMarginForGroup(new Guid(groupIdXml.Value));
					decimal? discount = DictionaryMapper.Instance.GetMaximalDiscountForGroup(new Guid(groupIdXml.Value), canUseSpecialDiscount);

                    if (margin.HasValue && (margin < minimalMargin || !minimalMargin.HasValue))
                        minimalMargin = margin;

					if (discount.HasValue && (discount > maximalDiscount || !maximalDiscount.HasValue))
						maximalDiscount = discount;
                }

				Guid itemId = new Guid(itemXml.Attribute(XmlName.Id).Value);
                if (minimalMargin.HasValue && minimalMargin >= 0)
                    dctItemIdToMinimalMargin.Add(itemId, minimalMargin.Value);

				if (maximalDiscount.HasValue)
					dctItemIdToMaximalDiscount.Add(itemId, maximalDiscount.Value);
			}
			#endregion

			//walidacja minimalnej marży
			#region Minimal Profit Margin Check

			foreach (var line in document.Lines)
            {
                decimal qSum = 0;
                decimal vSum = 0;

                foreach (var val in line.CommercialWarehouseValuations)
                {
                    qSum += val.Quantity;
                    vSum += val.Value;
                }

				//zakładam, że waluacje są zawsze w walucie systemowej - muszę przeliczyć tylko netPrice do porównania jeśli waluta inna niż systemowa

				decimal lineNetPrice = document.GetValueInSystemCurrency(line.NetPrice);

                if (qSum > 0 && dctItemIdToMinimalMargin.ContainsKey(line.ItemId))
                {
                    decimal avgPurchasePrice = Decimal.Round(vSum / qSum, 2, MidpointRounding.AwayFromZero);

					if ((((lineNetPrice - avgPurchasePrice) / lineNetPrice) * 100) < dctItemIdToMinimalMargin[line.ItemId])
                        throw new ClientException(ClientExceptionId.MinimalMarginValidationError, null, "itemName:" + line.ItemName, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));
                }
			}
			#endregion

			//walidacja maksymalnego rabatu
			#region Maximum Discount Check
			foreach(CommercialDocumentLine line in document.Lines)
			{
				if (dctItemIdToMaximalDiscount.ContainsKey(line.ItemId))
				{
					Item item = (Item)DependencyContainerManager.Container.Get<ItemMapper>().LoadBusinessObject(BusinessObjectType.Item, line.ItemId);
					decimal? discPriceSpecial = item.Attributes.GetDecimalValue(ItemFieldName.Price_Special);
					if (discPriceSpecial.HasValue)
					{
						//discPriceSpecial w walucie systemowej 
						decimal lineNetPrice = document.GetValueInSystemCurrency(line.NetPrice);

						decimal discountRate = (discPriceSpecial.Value - lineNetPrice) / discPriceSpecial.Value * 100;
						if (discountRate > dctItemIdToMaximalDiscount[line.ItemId])
						{
							throw new ClientException(ClientExceptionId.MaximalDiscountValidationError, null, "itemName:" + line.ItemName, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));
						}
					}
				}
			}
			#endregion
		}

        private void ValidateSalesBelowPurchasePrice(CommercialDocument document)
        {
            if (document.IsNew && document.DocumentType.DocumentCategory == DocumentCategory.Sales &&
                ((ConfigurationMapper.Instance.SalesPriceBelowPurchasePriceValidation.InvaluatedOutcomes != ErrorLevel.None && !document.SkipInvaluatedOutcomesValidation) ||
                (ConfigurationMapper.Instance.SalesPriceBelowPurchasePriceValidation.SalesPriceBelowPurchasePrice != ErrorLevel.None && !document.SkipSalesPriceBelowPurchaseValidation)) &&
                document.RelatedObjects.Where(o => o.BOType == BusinessObjectType.WarehouseDocument).FirstOrDefault() != null)
            {
                ErrorLevel salesPriceBelowPurchase = ConfigurationMapper.Instance.SalesPriceBelowPurchasePriceValidation.SalesPriceBelowPurchasePrice;
                
                if (document.SkipSalesPriceBelowPurchaseValidation)
                    salesPriceBelowPurchase = ErrorLevel.None;

                ErrorLevel invaluatedOutcomes = ConfigurationMapper.Instance.SalesPriceBelowPurchasePriceValidation.InvaluatedOutcomes;
                
                if (document.SkipInvaluatedOutcomesValidation)
                    invaluatedOutcomes = ErrorLevel.None;

                ICollection<GetDocumentCostResponse> responses = this.mapper.GetDocumentCost(document.Id.Value);

                var cache = SessionManager.VolatileElements.ItemTypesCache;

                List<int> salesPriceBelowPurchaseList = new List<int>();
                List<int> invaluatedOutcomesList = new List<int>();

                foreach (CommercialDocumentLine line in document.Lines)
                {
                    var it = DictionaryMapper.Instance.GetItemType(cache[line.ItemId]);

                    if (!it.IsWarehouseStorable)
                        continue;

                    var response = responses.Where(r => r.LineId == line.Id.Value).FirstOrDefault();

                    if (response == null || response.Quantity == null || response.Value == null || response.Quantity.Value < line.Quantity)
                        invaluatedOutcomesList.Add(line.OrdinalNumber);
                    else if (line.NetValue < response.Value)
                        salesPriceBelowPurchaseList.Add(line.OrdinalNumber);
                }

                if (salesPriceBelowPurchase != ErrorLevel.None && salesPriceBelowPurchaseList.Count > 0)
                {
                    string ordinalNumbers = String.Empty;

                    foreach (int i in salesPriceBelowPurchaseList)
                    {
                        if (ordinalNumbers.Length > 0)
                            ordinalNumbers += ", ";

                        ordinalNumbers += i.ToString(CultureInfo.InvariantCulture);
                    }

                    if (salesPriceBelowPurchase == ErrorLevel.Error)
                        throw new ClientException(ClientExceptionId.SalesPriceBelowPurchaseError, null, "ordinalNumbers:" + ordinalNumbers);
                    else
                        throw new ClientException(ClientExceptionId.SalesPriceBelowPurchaseWarning, null, "ordinalNumbers:" + ordinalNumbers);
                }

                if (invaluatedOutcomes != ErrorLevel.None && invaluatedOutcomesList.Count > 0)
                {
                    string ordinalNumbers = String.Empty;

                    foreach (int i in invaluatedOutcomesList)
                    {
                        if (ordinalNumbers.Length > 0)
                            ordinalNumbers += ", ";

                        ordinalNumbers += i.ToString(CultureInfo.InvariantCulture);
                    }

                    if (invaluatedOutcomes == ErrorLevel.Error)
                        throw new ClientException(ClientExceptionId.InvaluatedOutcomesError, null, "ordinalNumbers:" + ordinalNumbers);
                    else
                        throw new ClientException(ClientExceptionId.InvaluatedOutcomesWarning, null, "ordinalNumbers:" + ordinalNumbers);
                }
            }
        }

        private void SendRemoteOrder(CommercialDocument document)
        {
            ContractorAttrValue attribute = null;

            if (ConfigurationMapper.Instance.IsRemoteOrderSendingEnabled && document.Contractor != null &&
                document.DocumentType.DocumentCategory == DocumentCategory.Order)
            {
                //sprawdzamy czy dokument czasem nie ma opcji ktora powoduje tymczasowe wylaczenie tego ficzera
                if (document.DocumentOptions.Where(d => d is DisableRemoteOrderSendingOption).FirstOrDefault() == null)
                    attribute = document.Contractor.Attributes.Children.Where(a => a.ContractorFieldName == ContractorFieldName.Attribute_RemoteOrder).FirstOrDefault();
            }

            if (attribute != null)
            {
                string url = attribute.Value.Element("url").Value;
                string contractorCode = attribute.Value.Element("contractorCode").Value;

                //robimy liste itemow do ktorych z bazy musimy dociagnac producenta i kod
                List<Guid> items = new List<Guid>();

                foreach (var line in document.Lines.Children)
                    items.Add(line.ItemId);

                XDocument requestXml = DependencyContainerManager.Container.Get<ItemMapper>().GetItemsManufacturerAndCode(items);

                //sprawdzamy czy kazdy towar ma producenta i kod producenta
                foreach (var line in document.Lines.Children)
                {
                    var lineXml = requestXml.Root.Elements().Where(e => e.Attribute("id").Value == line.ItemId.ToUpperString()).FirstOrDefault();

                    if (lineXml == null || lineXml.Attribute("manufacturer") == null || lineXml.Attribute("manufacturer").Value == String.Empty ||
                        lineXml.Attribute("manufacturerCode") == null || lineXml.Attribute("manufacturerCode").Value == String.Empty)
                    {
                        throw new ClientException(ClientExceptionId.ManufacturerAndCodeLineException, null, "itemName:" + line.ItemName);
                    }
                    else
                        lineXml.Add(new XAttribute("quantity", ((int)line.Quantity).ToString(CultureInfo.InvariantCulture)));
                }

                requestXml.Root.Add(new XAttribute("contractorCode", contractorCode));
                requestXml.Root.Name = XName.Get("items");

                string remarks = String.Empty;

                if (document.Source != null && document.Source.Attribute("type") != null &&
                    document.Source.Attribute("type").Value == "order")
                {
                    Guid reservationId = new Guid(document.Source.Attribute("commercialDocumentId").Value);
                    string fullName = this.mapper.GetDocumentContractorFullName(reservationId);

                    remarks += fullName;
                }
                
                var customerOrderNumber = document.Attributes.Children.Where(c => c.DocumentFieldName == DocumentFieldName.Attribute_CustomerOrderNumber).FirstOrDefault();

                if (customerOrderNumber != null)
                {
                    if (!String.IsNullOrEmpty(remarks))
                        remarks += ", ";

                    remarks += customerOrderNumber.Value.Value;
                }

                if (!String.IsNullOrEmpty(remarks))
                    requestXml.Root.Add(new XAttribute("remarks", remarks));

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);
                req.Timeout = 20000;
                req.ContentType = "text/xml";
                req.Method = "POST";

                StreamWriter wr = new StreamWriter(req.GetRequestStream(), Encoding.UTF8);
                wr.Write(requestXml.ToString(SaveOptions.DisableFormatting));
                wr.Flush();
                wr.Close();
                XDocument responseXml = null;
                Stream responseStream = null;
                StreamReader r = null;

                try
                {
                    WebResponse response = req.GetResponse();

                    responseStream = response.GetResponseStream();
                    r = new StreamReader(responseStream);

                    string responseText = r.ReadToEnd();

                    LogManager.LogRemoteOrder(requestXml.Root, responseText);

                    responseXml = XDocument.Parse(responseText);

                    if (responseXml.Root.Element("error") != null)
                        throw new RawClientException(responseXml.Root.Element("error").Value);
                    else if (responseXml.Root.Element("documentNumber") != null)
                    {
                        var newAttrib = document.Attributes.CreateNew(BusinessObjectStatus.New);
                        newAttrib.DocumentFieldName = DocumentFieldName.Attribute_RemoteOrderNumber;
                        newAttrib.Value.Value = responseXml.Root.Element("documentNumber").Value;
                    }
                    else
                        throw new ClientException(ClientExceptionId.RemoteOrderSendingException1);
                }
                catch (RawClientException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:50");
                    throw;
                }
                catch (ClientException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:51");
                    throw;
                }
                catch (Exception)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:52");
                    throw new ClientException(ClientExceptionId.RemoteOrderSendingException1);
                }
                finally
                {
                    if (r != null)
                        r.Dispose();

                    if (responseStream != null)
                        responseStream.Dispose();

                    if (wr != null)
                        wr.Dispose();
                }
            }
        }

        private void ValuateIncomeSourceDocuments(CommercialDocument document)
        {
            if (document.DocumentType.DocumentCategory == DocumentCategory.Purchase && document.Source != null
                    && document.Source.Attribute("type").Value == "warehouseDocument")
            {
                //wyceniamy pz-ty z ktorych utworzylismy fakture
                List<Guid> whDocsId = new List<Guid>();

                foreach (CommercialDocumentLine line in document.Lines.Children)
                {
                    foreach (CommercialWarehouseRelation rel in line.CommercialWarehouseRelations.Children)
                    {
                        if (rel.RelatedLine.Parent != null && !whDocsId.Contains(rel.RelatedLine.Parent.Id.Value))
                            whDocsId.Add(rel.RelatedLine.Parent.Id.Value);
                    }
                }

                foreach (Guid whDocId in whDocsId)
                {
                    using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                    {
                        WarehouseDocument whDoc = (WarehouseDocument)c.LoadBusinessObject(BusinessObjectType.WarehouseDocument, whDocId);

                        foreach (WarehouseDocumentLine line in whDoc.Lines.Children)
                        {
                            if (line.Value == 0 && line.CommercialWarehouseValuations.Children.Sum(v => v.Quantity) == line.Quantity)
                            {
                                line.Value = line.CommercialWarehouseValuations.Children.Sum(vv => vv.Quantity * vv.Price);
                                line.Price = Decimal.Round(line.Value / line.Quantity, 2, MidpointRounding.AwayFromZero);
                            }
                        }

                        if (whDoc.Lines.Children.Where(l => l.Price == 0).FirstOrDefault() == null)
                            whDoc.Value = whDoc.Lines.Children.Sum(ll => ll.Value);

                        whDoc.SkipManualValuations = true;
                        c.SaveBusinessObject(whDoc);
                    }
                }
            }
        }
    }
}
