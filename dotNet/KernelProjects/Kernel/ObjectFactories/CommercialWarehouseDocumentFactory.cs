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
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
    internal static class CommercialWarehouseDocumentFactory
    {
        public static void GenerateDocumentFromExternalDocument(XElement source, Document destination)
        {
            ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();

            List<string> itemsCodes = new List<string>();

            XElement sourceRoot = (XElement)source.FirstNode;

            foreach (XElement itemElement in sourceRoot.Elements("item"))
            {
                itemsCodes.Add(itemElement.Attribute("code").Value);
            }

            XDocument xml = mapper.GetItemsDetailsForDocumentByItemCode(false, null, itemsCodes);

            //merge xml got from the database with the xml got from the client, because only client's xml contains
            //item name that user wants and quantity

            foreach (XElement item in xml.Root.Elements())
            {
                XElement itemFromClient = sourceRoot.Elements().Where(i => i.Attribute("code").Value == item.Attribute("code").Value).First();

                item.Add(itemFromClient.Attribute("netPrice")); //auto-cloning
                item.Add(itemFromClient.Attribute("quantity")); //auto-cloning
            }

            CommercialDocument commercialDocument = destination as CommercialDocument;
            WarehouseDocument warehouseDocument = destination as WarehouseDocument;

            if (commercialDocument != null)
            {
                foreach (XElement item in xml.Root.Elements())
                {
                    CommercialDocumentLine line = commercialDocument.Lines.CreateNew();
                    line.VatRateId = new Guid(item.Attribute("vatRateId").Value);
                    line.ItemVersion = new Guid(item.Attribute("version").Value);
                    line.InitialNetPrice = Convert.ToDecimal(item.Attribute("netPrice").Value, CultureInfo.InvariantCulture);
                    line.ItemName = item.Attribute("name").Value;

                    if (item.Attribute("code") != null)
                        line.ItemCode = item.Attribute("code").Value;

                    line.ItemId = new Guid(item.Attribute("id").Value);
                    line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                    line.UnitId = new Guid(item.Attribute("unitId").Value);

                    line.Calculate(line.Quantity, line.InitialNetPrice, 0);
                }

                commercialDocument.Calculate();
            }
            else if (warehouseDocument != null && warehouseDocument.WarehouseDirection == WarehouseDirection.Outcome
                || warehouseDocument.WarehouseDirection == WarehouseDirection.OutcomeShift)
            {
                foreach (XElement item in xml.Root.Elements())
                {
                    WarehouseDocumentLine line = warehouseDocument.Lines.CreateNew();
                    line.ItemName = item.Attribute("name").Value;

                    if (item.Attribute("code") != null)
                        line.ItemCode = item.Attribute("code").Value;

                    line.ItemId = new Guid(item.Attribute("id").Value);
                    line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                    line.UnitId = new Guid(item.Attribute("unitId").Value);
                }
            }
            else if (warehouseDocument != null && warehouseDocument.WarehouseDirection == WarehouseDirection.Income)
            {
                foreach (XElement item in xml.Root.Elements())
                {
                    WarehouseDocumentLine line = warehouseDocument.Lines.CreateNew();
                    line.ItemName = item.Attribute("name").Value;

                    if (item.Attribute("code") != null)
                        line.ItemCode = item.Attribute("code").Value;

                    line.ItemId = new Guid(item.Attribute("id").Value);
                    line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                    line.UnitId = new Guid(item.Attribute("unitId").Value);
                    line.Price = Convert.ToDecimal(item.Attribute("netPrice").Value, CultureInfo.InvariantCulture);
                    line.Value = line.Quantity * line.Price;
                }

                warehouseDocument.Value = warehouseDocument.Lines.Children.Sum(l => l.Value);
            }

            var attr = destination.Attributes.CreateNew();
            attr.DocumentFieldName = DocumentFieldName.Attribute_Remarks;

            string val = sourceRoot.Attribute("documentNumber").Value + " " + sourceRoot.Attribute("issueDate").Value.Substring(0, 10);

            if (sourceRoot.Attribute("remarks") != null && !String.IsNullOrEmpty(sourceRoot.Attribute("remarks").Value))
                val += "\n" + sourceRoot.Attribute("remarks").Value;

            attr.Value.Value = val;
        }

        public static void GenerateDocumentFromClipboard(XElement source, Document destination)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

            List<Guid> items = new List<Guid>();

            foreach (XElement itemElement in source.Element("clipboard").Elements("item"))
            {
                items.Add(new Guid(itemElement.Attribute("id").Value));
            }

            XDocument xml = mapper.GetItemsForDocument(items);

            //merge xml got from the database with the xml got from the client, because only client's xml contains
            //item name that user wants and quantity

            foreach (XElement item in xml.Root.Elements())
            {
                XElement itemFromClient = source.Element("clipboard").Elements().Where(i => i.Attribute("id").Value == item.Attribute("id").Value).ElementAt(0);

                item.Add(itemFromClient.Attribute("name")); //auto-cloning
                item.Add(itemFromClient.Attribute("quantity")); //auto-cloning
            }

            CommercialDocument commercialDocument = destination as CommercialDocument;
            WarehouseDocument warehouseDocument = destination as WarehouseDocument;
            ServiceDocument serviceDocument = destination as ServiceDocument;

            if (commercialDocument != null)
            { 
                foreach (XElement item in xml.Root.Elements())
                {
                    CommercialDocumentLine line = commercialDocument.Lines.CreateNew();
                    XElement productionMapping = null;
                    if (source.Element("clipboard").Element("item").Attribute("ResponsiblePerson") != null)
                    {
                        var attr = line.Attributes.CreateNew();
                        attr.DocumentFieldName = DocumentFieldName.Attribute_ResponsiblePerson;
                        attr.Value.Value = source.Element("clipboard").Element("item").Attribute("ResponsiblePerson").Value;
                        XDocument xDoc = XDocument.Load(item.CreateReader());
                        productionMapping = mapper.ExecuteCustomProcedure("custom.p_getProductionItemMapping", xDoc);
                        if (productionMapping.Value.ToString() == "Brak technologii dla produktu")
                        {
                            throw new RawClientException("Brak technologii");  
                        }
                    }
                    if (productionMapping != null)
                    {
                        line.VatRateId = new Guid(productionMapping.Attribute("vatRateId").Value.ToString());
                        line.ItemVersion = new Guid(productionMapping.Attribute("version").Value);
                        line.InitialNetPrice = Convert.ToDecimal(item.Attribute("netPrice").Value, CultureInfo.InvariantCulture);
                        line.ItemName = productionMapping.Attribute("name").Value;

                        if (productionMapping.Attribute("code") != null)
                            line.ItemCode = productionMapping.Attribute("code").Value;

                        line.ItemId = new Guid(productionMapping.Attribute("id").Value);
                        line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                        line.UnitId = new Guid(productionMapping.Attribute("unitId").Value);
                    }
                    else
                    {

                    
                        line.VatRateId = new Guid(item.Attribute("vatRateId").Value);
                        line.ItemVersion = new Guid(item.Attribute("version").Value);
                        line.InitialNetPrice = Convert.ToDecimal(item.Attribute("netPrice").Value, CultureInfo.InvariantCulture);
                        line.ItemName = item.Attribute("name").Value;

                        if (item.Attribute("code") != null)
                            line.ItemCode = item.Attribute("code").Value;

                        line.ItemId = new Guid(item.Attribute("id").Value);
                        line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                        line.UnitId = new Guid(item.Attribute("unitId").Value);
                    }

                    line.Calculate(line.Quantity, line.InitialNetPrice, 0);
                }

                commercialDocument.Calculate();

                if (source.Element("clipboard").Element("paymentMethodId") != null)
                {
                    PaymentMethod paymentMethod = DictionaryMapper.Instance.GetPaymentMethod(new Guid(source.Element("clipboard").Element("paymentMethodId").Value));

                    commercialDocument.Payments.RemoveAll();
                    Payment payment = commercialDocument.Payments.CreateNew();

                    DateTime currentDateTime = SessionManager.VolatileElements.CurrentDateTime;
                    payment.Date = currentDateTime;
                    payment.DueDate = currentDateTime.AddDays(paymentMethod.DueDays);
                    payment.ExchangeDate = currentDateTime;
                    payment.ExchangeScale = 1; //TODO: to wczytywac z bazy jak bedzie
                    payment.ExchangeRate = 1;
                    payment.PaymentCurrencyId = commercialDocument.DocumentCurrencyId;
                    payment.PaymentMethodId = paymentMethod.Id.Value;
                    payment.SystemCurrencyId = commercialDocument.SystemCurrencyId;
                    payment.Amount = commercialDocument.GrossValue;
                }
            }
            else if (serviceDocument != null)
            {
                //wyciagamy domyslny sposob generowania dokumentu
                DocumentField df = DictionaryMapper.Instance.GetDocumentField(DocumentFieldName.LineAttribute_GenerateDocumentOption);
                XElement defOpt = df.Metadata.Element("values").Elements().Where(e => e.Element("isDefault") != null && e.Element("isDefault").Value == "1").FirstOrDefault();

                foreach (XElement item in xml.Root.Elements())
                {
                    CommercialDocumentLine line = serviceDocument.Lines.CreateNew();
                    line.VatRateId = new Guid(item.Attribute("vatRateId").Value);
                    line.ItemVersion = new Guid(item.Attribute("version").Value);
                    line.InitialNetPrice = Convert.ToDecimal(item.Attribute("netPrice").Value, CultureInfo.InvariantCulture);
                    line.ItemName = item.Attribute("name").Value;

                    if (item.Attribute("code") != null)
                        line.ItemCode = item.Attribute("code").Value;

                    line.ItemId = new Guid(item.Attribute("id").Value);
                    line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                    line.UnitId = new Guid(item.Attribute("unitId").Value);

                    line.Calculate(line.Quantity, line.InitialNetPrice, 0);

                    if (defOpt != null)
                    {
                        var attr = line.Attributes.CreateNew();
                        attr.DocumentFieldName = DocumentFieldName.LineAttribute_GenerateDocumentOption;
                        attr.Value.Value = defOpt.Element("name").Value;
                    }
                }

                serviceDocument.Calculate();
            }
            else if (warehouseDocument != null && (warehouseDocument.WarehouseDirection == WarehouseDirection.Outcome
                || warehouseDocument.WarehouseDirection == WarehouseDirection.OutcomeShift))
            {
                foreach (XElement item in xml.Root.Elements())
                {
                    WarehouseDocumentLine line = warehouseDocument.Lines.CreateNew();
                    line.ItemName = item.Attribute("name").Value;

                    if (item.Attribute("code") != null)
                        line.ItemCode = item.Attribute("code").Value;

                    line.ItemId = new Guid(item.Attribute("id").Value);
                    line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                    line.UnitId = new Guid(item.Attribute("unitId").Value);
                }
            }
            else if (warehouseDocument != null && warehouseDocument.WarehouseDirection == WarehouseDirection.Income)
            {
                foreach (XElement item in xml.Root.Elements())
                {
                    WarehouseDocumentLine line = warehouseDocument.Lines.CreateNew();
                    line.ItemName = item.Attribute("name").Value;

                    if (item.Attribute("code") != null)
                        line.ItemCode = item.Attribute("code").Value;

                    line.ItemId = new Guid(item.Attribute("id").Value);
                    line.Quantity = Convert.ToDecimal(item.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                    line.UnitId = new Guid(item.Attribute("unitId").Value);
                    //na PZtach nie ustawiamy cen kartotekowych
                    //line.Price = Convert.ToDecimal(item.Attribute("netPrice").Value, CultureInfo.InvariantCulture);
                    //line.Value = line.Quantity * line.Price;
                }

                warehouseDocument.Value = warehouseDocument.Lines.Children.Sum(l => l.Value);
            }
        }

        public static void CheckIfWarehouseDocumentHasSalesOrderWithPrepaids(WarehouseDocument document)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
            //sprawdzamy czy jest to WZ ktory jest powiazany z ZSP ktory ma zaliczke
            if (document.DocumentType.WarehouseDocumentOptions.WarehouseDirection == WarehouseDirection.Outcome)
            {
                var soRelation = document.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToWarehouseDocument).FirstOrDefault();

                if (soRelation != null)
                {
                    CommercialDocument salesOrder = null;

                    if (soRelation.RelatedDocument.Version != null) //jezeli mamy wczytany juz caly
                        salesOrder = (CommercialDocument)soRelation.RelatedDocument;
                    else
                    {
                        salesOrder = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, soRelation.RelatedDocument.Id.Value);
                        soRelation.RelatedDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, soRelation.RelatedDocument.Id.Value);
                    }

                    //mamy ZSP, teraz sparwdzamy czy ma zaliczki

                    if (salesOrder.Relations.Where(rr => rr.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null)
                        throw new ClientException(ClientExceptionId.UnableToCreateInvoiceToWarehouseDocument);
                }
            }
        }

        public static void CreateCommercialDocumentFromWarehouseDocument(CommercialDocument destination, XElement source)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

            List<WarehouseDocument> whDocs = new List<WarehouseDocument>();
            List<Guid> itemsId = new List<Guid>();

            foreach (XElement whId in source.Elements("warehouseDocumentId"))
            {
                Guid docId = new Guid(whId.Value);

                var exists = whDocs.Where(d => d.Id.Value == docId).FirstOrDefault();

                if (exists != null)
                    continue;

                WarehouseDocument doc = (WarehouseDocument)mapper.LoadBusinessObject(BusinessObjectType.WarehouseDocument, docId);
                whDocs.Add(doc);

                CommercialWarehouseDocumentFactory.CheckIfWarehouseDocumentHasSalesOrderWithPrepaids(doc);

                foreach (WarehouseDocumentLine line in doc.Lines.Children)
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

            foreach (WarehouseDocument whDoc in whDocs)
            {
                foreach (WarehouseDocumentLine line in whDoc.Lines.Children)
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
            foreach (WarehouseDocument whDoc in whDocs)
            {
                foreach (WarehouseDocumentLine whLine in whDoc.Lines.Children)
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

                    CommercialDocumentLine comLine = destination.Lines.CreateNew();
                    comLine.ItemId = whLine.ItemId;
                    comLine.ItemName = whLine.ItemName;
                    comLine.ItemCode = whLine.ItemCode;
                    comLine.Quantity = quantityNotRelated;
                    comLine.UnitId = whLine.UnitId;
                    comLine.WarehouseId = whLine.WarehouseId;
                    comLine.NetPrice = whLine.Price;

                    XElement itemXml = xml.Root.Elements("item").Where(i => i.Attribute("id").Value == comLine.ItemId.ToUpperString()).First();

                    comLine.VatRateId = new Guid(itemXml.Attribute("vatRateId").Value);
                    comLine.ItemVersion = new Guid(itemXml.Attribute("version").Value);

                    comLine.InitialNetPrice = Convert.ToDecimal(itemXml.Attribute("netPrice").Value, CultureInfo.InvariantCulture);

                    if (whDoc.WarehouseDirection == WarehouseDirection.Outcome) //dla WZ cena po rabacie ma byc taka jak przed rabatem
                        comLine.NetPrice = comLine.InitialNetPrice;

                    if (whLineOrderLine.ContainsKey(whLine.Id.Value))
                    {
                        XElement xmlLine = orderLines.Root.Element("commercialDocumentLine").Elements().Where(e => e.Element("id").Value == whLineOrderLine[whLine.Id.Value].ToUpperString()).FirstOrDefault();

                        if (xmlLine != null)
                        {
                            comLine.NetPrice = Convert.ToDecimal(xmlLine.Element("netPrice").Value, CultureInfo.InvariantCulture);
                            comLine.VatRateId = new Guid(xmlLine.Element("vatRateId").Value);
                            comLine.UnitId = new Guid(xmlLine.Element("unitId").Value);
                        }
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

        public static ICollection<WarehouseDocument> Generate(CommercialDocumentBase source, string templateName, bool countCommercialRelation, bool countServiceRelation)
        {
            DependencyContainerManager.Container.Get<DocumentMapper>().AddItemsToItemTypesCache(source);

            Dictionary<Guid, WarehouseDocument> dictWarehouseIdToDocument = new Dictionary<Guid, WarehouseDocument>();

            bool calculateValue = false;

            using (DocumentCoordinator coordinator = new DocumentCoordinator(false, false))
            {
                IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

                foreach (CommercialDocumentLine srcLine in source.Lines.Children.Where(l => l.Quantity - l.CommercialWarehouseRelations.Children
                    .Sum(c => (c.IsCommercialRelation & countCommercialRelation) || (c.IsServiceRelation & countServiceRelation) ? c.Quantity : 0) > 0)) //zliczamy tylko te relacje ktore maja ustawione flagki wskazane przez parametry wejsciowe
                {
                    Guid itemTypeId = cache[srcLine.ItemId];
                    ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                    if (itemType.IsWarehouseStorable)
                    {
                        if (!srcLine.WarehouseId.HasValue)
                        {
                            //TODO tymczasowe rozwiązanie
                            throw new ClientException(
                                ClientExceptionId.CommercialDocumentLineWarehouseNotSelected, null, "order:" + srcLine.Order);
                        }
                        Guid warehouseId = srcLine.WarehouseId.Value;
                        decimal quantity = srcLine.Quantity - srcLine.CommercialWarehouseRelations.Children.Sum(c => (c.IsCommercialRelation & countCommercialRelation) || (c.IsServiceRelation & countServiceRelation) ? c.Quantity : 0);

                        if (source.BOType == BusinessObjectType.ServiceDocument)
                        {
                            var genDocOpt = srcLine.Attributes[DocumentFieldName.LineAttribute_GenerateDocumentOption];

                            if (genDocOpt.Value.Value != "3" && genDocOpt.Value.Value != "4")
                                continue;

                            if (genDocOpt.Value.Value == "4") //z mmki, wiec zmieniamy magazyn
                                warehouseId = ProcessManager.Instance.GetServiceWarehouse((ServiceDocument)source);

                            //zliczamy ile jest nierozliczonych jeszcze
                            var realizedAttr = srcLine.Attributes[DocumentFieldName.LineAttribute_ServiceRealized];

                            if (realizedAttr != null)
                                quantity = srcLine.Quantity - Convert.ToDecimal(realizedAttr.Value.Value, CultureInfo.InvariantCulture);
                            else
                                quantity = srcLine.Quantity;
                        }

                        //stworzmy lub wybierzmy z juz istniejacych odpowiedni dokument magazynowy
                        WarehouseDocument destination = null;

                        if (dictWarehouseIdToDocument.ContainsKey(warehouseId))
                            destination = dictWarehouseIdToDocument[warehouseId];
                        else //tworzymy nowy
                        {
                            destination = (WarehouseDocument)coordinator.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, templateName, null);

                            //copy header info
                            if (source.Contractor != null)
                                destination.Contractor = (Contractor)source.Contractor;

                            //destination.DocumentCurrencyId = source.DocumentCurrencyId; -magazynowe są tylko w systemowej
                            destination.WarehouseId = warehouseId;
                            dictWarehouseIdToDocument.Add(warehouseId, destination);

                            if (destination.DocumentType.WarehouseDocumentOptions.WarehouseDirection == WarehouseDirection.Income)
                                calculateValue = true; //dla PZ-ta nalezy obliczac wartosc dokumentu gdy generujemy z FV_Z
                        }

                        WarehouseDocumentLine line = destination.Lines.CreateNew();
                        line.ItemId = srcLine.ItemId;
                        line.UnitId = srcLine.UnitId;
                        line.ItemTypeId = srcLine.ItemTypeId;
                        line.WarehouseId = warehouseId;
                        line.Quantity = quantity;
                        line.ItemCode = srcLine.ItemCode;
                        line.ItemName = srcLine.ItemName;

                        if (calculateValue)
                        {
                            line.Price = Math.Round(srcLine.NetPrice * source.ExchangeRate / (decimal)source.ExchangeScale, 2, MidpointRounding.AwayFromZero);
                            line.Value = line.Quantity * Math.Round(srcLine.NetPrice * source.ExchangeRate / (decimal)source.ExchangeScale, 2, MidpointRounding.AwayFromZero);
                        }

                        if (srcLine.IncomeOutcomeRelations != null)
                        {
                            foreach (IncomeOutcomeRelation comRel in srcLine.IncomeOutcomeRelations.Children)
                            {
                                IncomeOutcomeRelation rel = line.IncomeOutcomeRelations.CreateNew();
                                rel.Quantity = comRel.Quantity;
                                rel.RelatedLine.Id = comRel.RelatedLine.Id.Value;
                            }
                        }
                        //Przegrywam atrybuty linii do nowego dokumentu. 
                        if (srcLine.Attributes != null)
                        {
                            foreach (DocumentLineAttrValue attr in srcLine.Attributes.Children)
                            {
                                DocumentLineAttrValue attrNew = line.Attributes.CreateNew();
                                attrNew.DocumentFieldId = attr.DocumentFieldId;
                                attrNew.Value = new XElement(attr.Value);
                            }

                        }
                        #region WMS
                        if (ConfigurationMapper.Instance.IsWmsEnabled && source.ShiftTransaction != null)
                        {
                            Shift s = source.ShiftTransaction.Shifts.Children.Where(sh => sh.RelatedCommercialDocumentLine == srcLine).FirstOrDefault();
                            WarehouseMapper whMapper = DependencyContainerManager.Container.Get<WarehouseMapper>();

                            if (s != null)
                            {
                                ShiftTransaction st = null;

                                if (destination.ShiftTransaction == null)
                                {
                                    st = whMapper.CreateShiftTransactionFromCommercialShiftTransaction(source.ShiftTransaction);
                                    destination.ShiftTransaction = st;
                                }
                                else
                                    st = destination.ShiftTransaction;

                                var srcShifts = source.ShiftTransaction.Shifts.Children.Where(f => f.RelatedCommercialDocumentLine == srcLine);

                                foreach (var srcShift in srcShifts)
                                {
                                    Shift shift = st.Shifts.CreateNew();
                                    shift.RelatedWarehouseDocumentLine = line;
                                    shift.ShiftStatus = srcShift.ShiftStatus;
                                    shift.WarehouseId = srcShift.WarehouseId;
                                    shift.Quantity = srcShift.Quantity;
                                    shift.ContainerId = srcShift.ContainerId;
                                    shift.IncomeWarehouseDocumentLineId = srcShift.IncomeWarehouseDocumentLineId;
                                    shift.SourceShiftId = srcShift.SourceShiftId;
                                    shift.SourceContainerId = srcShift.SourceContainerId;
                                    shift.Attributes.CopyFrom(srcShift.Attributes);
                                }
                            }
                        }
                        #endregion
                    }
                }
            }

            if (calculateValue)
            {
                foreach (WarehouseDocument whDoc in dictWarehouseIdToDocument.Values)
                {
                    whDoc.Value = whDoc.Lines.Children.Sum(x => x.Value);
                }
            }

            DuplicableAttributeFactory.DuplicateAttributes(source, dictWarehouseIdToDocument.Values);

            return dictWarehouseIdToDocument.Values;
        }

        public static void RelateWarehousesLinesToOrderLines(ICollection<WarehouseDocument> warehouseDocuments, CommercialDocument commercialDocument, XElement source, bool isOrderRelation, bool isCommercialRelation)
        {
            List<Guid> allowedLines = new List<Guid>();
            Dictionary<Guid, decimal> linesFromOrder = new Dictionary<Guid, decimal>();

            foreach (XElement line in source.Elements("line"))
            {
                Guid lnId = new Guid(line.Attribute("id").Value);
                allowedLines.Add(lnId);
                CommercialDocumentLine cln = commercialDocument.Lines.Children.Where(w => w.Id.Value == lnId).First();

                if (!linesFromOrder.ContainsKey(cln.ItemId))
                    linesFromOrder.Add(cln.ItemId, Convert.ToDecimal(line.Attribute("quantity").Value, CultureInfo.InvariantCulture));
                else
                    linesFromOrder[cln.ItemId] += Convert.ToDecimal(line.Attribute("quantity").Value, CultureInfo.InvariantCulture);
            }

            List<WarehouseDocumentLine> notFullyRelatedWhLines = new List<WarehouseDocumentLine>();

            #region wiazemy linie ze zgodnymi magazynami
            foreach (WarehouseDocument whDoc in warehouseDocuments)
            {
                foreach (WarehouseDocumentLine whLine in whDoc.Lines.Children)
                {
                    var commercialLines = from ln in commercialDocument.Lines.Children
                                          where ln.ItemId == whLine.ItemId && ln.WarehouseId != null &&
                                          ln.WarehouseId.Value == whLine.WarehouseId && allowedLines.Contains(ln.Id.Value)
                                          select ln;

                    decimal quantityToGo = whLine.Quantity - whLine.CommercialWarehouseRelations.Where(l => l.IsOrderRelation == isOrderRelation && l.IsCommercialRelation == isCommercialRelation).Sum(ll => ll.Quantity);

                    foreach (CommercialDocumentLine comLine in commercialLines)
                    {
                        decimal realizedQuantity = comLine.CommercialWarehouseRelations.Children.Where(x => x.IsOrderRelation || x.IsSalesOrderRelation).Sum(xx => xx.Quantity);
                        decimal unrealizedQuantity = comLine.Quantity - realizedQuantity;

                        bool _isOrderRelation = isOrderRelation;

                        var attr = comLine.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];

                        if (attr != null && (attr.Value.Value == "3" || attr.Value.Value == "4"))
                            _isOrderRelation = true;
                        else if (attr != null)
                            _isOrderRelation = false;

                        if (unrealizedQuantity == 0 || quantityToGo == 0)
                            continue;
                        if (quantityToGo <= unrealizedQuantity)
                        {
                            //nie wiazemy wiecej niz poczatkowo user chcial powiazac
                            decimal allowedQuantity = linesFromOrder[comLine.ItemId];

                            decimal q = quantityToGo;

                            if (quantityToGo > allowedQuantity)
                                q = allowedQuantity;

                            linesFromOrder[comLine.ItemId] -= q;

                            CommercialWarehouseRelation relation = whLine.CommercialWarehouseRelations.CreateNew();
                            relation.IsOrderRelation = _isOrderRelation;
                            relation.IsCommercialRelation = isCommercialRelation;
                            relation.Quantity = q;
                            relation.RelatedLine = (CommercialDocumentLine)comLine;

                            //relacja po stronie ordera
                            CommercialWarehouseRelation orderRelation = comLine.CommercialWarehouseRelations.CreateNew();
                            orderRelation.Id = relation.Id;
                            orderRelation.DontSave = true;
                            orderRelation.IsOrderRelation = _isOrderRelation;
                            orderRelation.IsCommercialRelation = isCommercialRelation;
                            orderRelation.Quantity = q;
                            orderRelation.RelatedLine = (WarehouseDocumentLine)whLine;

                            quantityToGo = 0;
                        }
                        else //quantityToGo > unrealizedQuantity
                        {
                            //nie wiazemy wiecej niz poczatkowo user chcial powiazac
                            decimal allowedQuantity = linesFromOrder[comLine.ItemId];

                            decimal q = unrealizedQuantity;

                            if (unrealizedQuantity > allowedQuantity)
                                q = allowedQuantity;

                            linesFromOrder[comLine.ItemId] -= q;

                            CommercialWarehouseRelation relation = whLine.CommercialWarehouseRelations.CreateNew();
                            relation.IsOrderRelation = _isOrderRelation;
                            relation.IsCommercialRelation = isCommercialRelation;
                            relation.Quantity = q;
                            relation.RelatedLine = (CommercialDocumentLine)comLine;

                            //relacja po stronie ordera
                            CommercialWarehouseRelation orderRelation = comLine.CommercialWarehouseRelations.CreateNew();
                            orderRelation.Id = relation.Id;
                            orderRelation.DontSave = true;
                            orderRelation.IsOrderRelation = _isOrderRelation;
                            orderRelation.IsCommercialRelation = isCommercialRelation;
                            orderRelation.Quantity = q;
                            orderRelation.RelatedLine = (WarehouseDocumentLine)whLine;

                            quantityToGo -= unrealizedQuantity;
                        }
                    }

                    if (quantityToGo != 0 && linesFromOrder.ContainsKey(whLine.ItemId) && linesFromOrder[whLine.ItemId] > 0)
                        notFullyRelatedWhLines.Add(whLine);
                }
            }
            #endregion

            #region wiazemy linie ktore pozostaly. beda to te ktore maja niezgodne magazyny
            foreach (WarehouseDocumentLine whLine in notFullyRelatedWhLines)
            {
                var commercialLines = from ln in commercialDocument.Lines.Children
                                      where ln.ItemId == whLine.ItemId && allowedLines.Contains(ln.Id.Value)
                                      select ln;

                decimal quantityToGo = whLine.Quantity;

                foreach (CommercialDocumentLine comLine in commercialLines)
                {
                    decimal realizedQuantity = comLine.CommercialWarehouseRelations.Children.Where(x => x.IsOrderRelation).Sum(xx => xx.Quantity);
                    decimal unrealizedQuantity = comLine.Quantity - realizedQuantity;

                    if (unrealizedQuantity == 0)
                        continue;
                    if (quantityToGo <= unrealizedQuantity)
                    {
                        //nie wiazemy wiecej niz poczatkowo user chcial powiazac
                        decimal allowedQuantity = linesFromOrder[comLine.ItemId];

                        decimal q = quantityToGo;

                        if (quantityToGo > allowedQuantity)
                            q = allowedQuantity;

                        linesFromOrder[comLine.ItemId] -= q;

                        CommercialWarehouseRelation relation = whLine.CommercialWarehouseRelations.CreateNew();
                        relation.IsOrderRelation = isOrderRelation;
                        relation.IsCommercialRelation = isCommercialRelation;
                        relation.Quantity = q;
                        relation.RelatedLine = (CommercialDocumentLine)comLine;

                        //relacja po stronie ordera
                        CommercialWarehouseRelation orderRelation = comLine.CommercialWarehouseRelations.CreateNew();
                        orderRelation.Id = relation.Id;
                        orderRelation.DontSave = true;
                        orderRelation.IsOrderRelation = isOrderRelation;
                        orderRelation.IsCommercialRelation = isCommercialRelation;
                        orderRelation.Quantity = q;
                        orderRelation.RelatedLine = (WarehouseDocumentLine)whLine;

                        quantityToGo = 0;
                    }
                    else //quantityToGo > unrealizedQuantity
                    {
                        //nie wiazemy wiecej niz poczatkowo user chcial powiazac
                        decimal allowedQuantity = linesFromOrder[comLine.ItemId];

                        decimal q = unrealizedQuantity;

                        if (unrealizedQuantity > allowedQuantity)
                            q = allowedQuantity;

                        linesFromOrder[comLine.ItemId] -= q;

                        CommercialWarehouseRelation relation = whLine.CommercialWarehouseRelations.CreateNew();
                        relation.IsOrderRelation = isOrderRelation;
                        relation.IsCommercialRelation = isCommercialRelation;
                        relation.Quantity = q;
                        relation.RelatedLine = (CommercialDocumentLine)comLine;

                        //relacja po stronie ordera
                        CommercialWarehouseRelation orderRelation = comLine.CommercialWarehouseRelations.CreateNew();
                        orderRelation.Id = relation.Id;
                        orderRelation.DontSave = true;
                        orderRelation.IsOrderRelation = isOrderRelation;
                        orderRelation.IsCommercialRelation = isCommercialRelation;
                        orderRelation.Quantity = q;
                        orderRelation.RelatedLine = (WarehouseDocumentLine)whLine;

                        quantityToGo -= unrealizedQuantity;
                    }
                }
            }
            #endregion

            if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
            {
                foreach (var whDoc in warehouseDocuments)
                {
                    ProcessManager.Instance.AppendProcessAttributes(whDoc, commercialDocument.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value, "externalOutcome", null, null);
                    var relation = whDoc.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.SalesOrderToWarehouseDocument;
                    relation.RelatedDocument = commercialDocument;

                    relation = commercialDocument.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.SalesOrderToWarehouseDocument;
                    relation.RelatedDocument = whDoc;
                    relation.DontSave = true;
                }
            }
        }

        public static void RelateWarehousesLinesToMultipleOrdersLines(ICollection<WarehouseDocument> warehouseDocuments, ICollection<CommercialDocument> commercialDocuments, bool isOrderRelation, bool isCommercialRelation)
        {
            foreach (var comDoc in commercialDocuments)
            {
                XElement source = new XElement("source");

                foreach (var comLine in comDoc.Lines)
                {
                    decimal unrelatedQty = comLine.Quantity - comLine.CommercialWarehouseRelations.Where(r => r.IsOrderRelation).Sum(rr => rr.Quantity);

                    if (unrelatedQty > 0)
                        source.Add(new XElement("line", new XAttribute("id", comLine.Id.ToUpperString()), new XAttribute("quantity", unrelatedQty.ToString(CultureInfo.InvariantCulture))));
                }

                if (source.HasElements)
                    RelateWarehousesLinesToOrderLines(warehouseDocuments, comDoc, source, isOrderRelation, isCommercialRelation);
            }
        }

        /// <summary>
        /// Relates the commercial and warehouses lines.
        /// </summary>
        /// <param name="commercialDocument">The commercial document to relate.</param>
        /// <param name="warehouseDocuments">The warehouse documents to relate.</param>
        /// <param name="generateValuations">if set to <c>true</c> the method will also generate valuation relations.</param>
        /// <returns><c>true</c> if all warehouse document lines have been related; otherwise <c>false</c>.</returns>
        public static bool RelateCommercialLinesToWarehousesLines(CommercialDocumentBase commercialDocument, ICollection<WarehouseDocument> warehouseDocuments, bool generateValuations, bool isOrderRelation, bool isCommercialRelation, bool isServiceRelation)
        {
            #region Validation
            //sprawdzamy czy wszystkie dokumenty maja status zatwierdzony
            if (commercialDocument.DocumentStatus != DocumentStatus.Committed ||
                warehouseDocuments.Where(w => w.DocumentStatus != DocumentStatus.Committed).FirstOrDefault() != null)
                throw new ClientException(ClientExceptionId.UnableToRelateDocumentBecauseOfStatus);

            /*
             * Dopuszczalne wiązania: 
             *  - zakup - przyjęcie 
             *  - sprzedaż - wydanie 
             *  - rezerwacja - wydanie 
             *  - zamówienie - przyjęcie
             *  - serwis - wydanie
             */
            if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Sales ||
                commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Reservation ||
                commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Service)
            {
                foreach (var whDoc in warehouseDocuments)
                {
                    if (whDoc.WarehouseDirection != WarehouseDirection.Outcome)
                        throw new ClientException(ClientExceptionId.IncorrectDocumentTypesToRelate);
                }
            }
            else if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Purchase ||
                commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Order)
            {
                foreach (var whDoc in warehouseDocuments)
                {
                    if (whDoc.WarehouseDirection != WarehouseDirection.Income)
                        throw new ClientException(ClientExceptionId.IncorrectDocumentTypesToRelate);
                }
            }
            else
                throw new ClientException(ClientExceptionId.IncorrectDocumentTypesToRelate);
            #endregion
            DependencyContainerManager.Container.Get<DocumentMapper>().AddItemsToItemTypesCache(commercialDocument);

            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            //group warehouse lines to specific warehouses
            Dictionary<Guid, List<WarehouseDocumentLine>> dctWarehouseToWhLine = new Dictionary<Guid, List<WarehouseDocumentLine>>();

            foreach (WarehouseDocument whDoc in warehouseDocuments)
            {
                if (generateValuations)
                    whDoc.SkipManualValuations = true;

                List<WarehouseDocumentLine> lines = null;

                if (dctWarehouseToWhLine.ContainsKey(whDoc.WarehouseId))
                    lines = dctWarehouseToWhLine[whDoc.WarehouseId];
                else
                {
                    lines = new List<WarehouseDocumentLine>();
                    dctWarehouseToWhLine.Add(whDoc.WarehouseId, lines);
                }

                foreach (WarehouseDocumentLine line in whDoc.Lines.Children)
                {
                    lines.Add(line);
                }
            }

            //for each line to process
            //wszystkie te linie ktore jeszcze maja cos do powiazania
            foreach (CommercialDocumentLine comLine in commercialDocument.Lines.Children.Where(l => l.Quantity - l.CommercialWarehouseRelations.Children
                .Sum(r => r.IsCommercialRelation == isCommercialRelation && r.IsOrderRelation == isOrderRelation && r.IsServiceRelation == isServiceRelation ? r.Quantity : 0) > 0))
            {
                Guid itemTypeId = cache[comLine.ItemId];
                ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                if (!itemType.IsWarehouseStorable) //skip non storable items
                    continue;

                Guid warehouseId = comLine.WarehouseId.Value;

                if (!dctWarehouseToWhLine.ContainsKey(warehouseId))
                    throw new ClientException(ClientExceptionId.UnableToRelateDocuments);

                List<WarehouseDocumentLine> whLines = dctWarehouseToWhLine[warehouseId];

                decimal quantityToGo = comLine.Quantity - comLine.CommercialWarehouseRelations.Children
                    .Sum(r => r.IsCommercialRelation == isCommercialRelation && r.IsOrderRelation == isOrderRelation && r.IsServiceRelation == isServiceRelation ? r.Quantity : 0);

                var properLines = from ln in whLines
                                  where ln.ItemId == comLine.ItemId
                                  select ln;

                //for each warehouse line, look if we can relate
                foreach (WarehouseDocumentLine whLine in properLines)
                {
                    //count how many quantities are available to relate
                    decimal relatedLineQuantity = whLine.CommercialWarehouseRelations.Children
                        .Where(x => x.IsCommercialRelation == isCommercialRelation && x.IsOrderRelation == isOrderRelation && x.IsServiceRelation == isServiceRelation)
                        .Sum(xx => xx.Quantity);

                    decimal availableQuantity = whLine.Quantity - relatedLineQuantity;

                    /*
                     * to jest po to zeby czasem nie przeliczyc na nowo ceny i wartosci 
                     * na pozycji jezeli natrafilismy na koncu tej petli na sytuacje
                     * w ktorej linia zostala juz wyceniona do konca (ale nie wiemy czy to my ja wycenilismy czy juz bylo tak)
                     */
                    if (availableQuantity == 0)
                        continue;

                    if (availableQuantity >= quantityToGo)
                    {
                        //relation at commercial side
                        CommercialWarehouseRelation relation = comLine.CommercialWarehouseRelations.CreateNew();
                        relation.Quantity = quantityToGo;
                        relation.IsCommercialRelation = isCommercialRelation;
                        relation.IsOrderRelation = isOrderRelation;
                        relation.IsServiceRelation = isServiceRelation;
                        relation.RelatedLine = (WarehouseDocumentLine)whLine;
                        Guid relationId = relation.Id.Value;

                        //relation at warehouse side
                        relation = whLine.CommercialWarehouseRelations.CreateNew();
                        relation.Id = relationId;
                        relation.IsCommercialRelation = isCommercialRelation;
                        relation.IsOrderRelation = isOrderRelation;
                        relation.IsServiceRelation = isServiceRelation;
                        relation.DontSave = true;
                        relation.Quantity = quantityToGo;
                        relation.RelatedLine = (CommercialDocumentLine)comLine;

                        if (generateValuations)
                        {
                            decimal alreadyValuatedQuantity = whLine.CommercialWarehouseValuations.Children.Sum(val => val.Quantity);
                            decimal quantityToValuate = Math.Min(quantityToGo, whLine.Quantity - alreadyValuatedQuantity);

                            if (quantityToValuate > 0)
                            {
                                CommercialWarehouseValuation valuation = comLine.CommercialWarehouseValuations.CreateNew();
                                valuation.Price = Math.Round(comLine.NetPrice * commercialDocument.ExchangeRate / (decimal)commercialDocument.ExchangeScale, 2, MidpointRounding.AwayFromZero);
                                valuation.Quantity = quantityToValuate;
                                valuation.RelatedLine = (WarehouseDocumentLine)whLine;
                                valuation.Value = Math.Round(comLine.NetPrice * commercialDocument.ExchangeRate / (decimal)commercialDocument.ExchangeScale, 2, MidpointRounding.AwayFromZero) * quantityToValuate;
                                Guid valuationId = valuation.Id.Value;

                                //warehouse side
                                valuation = whLine.CommercialWarehouseValuations.CreateNew();
                                valuation.DontSave = true;
                                valuation.Id = valuationId;
                                valuation.Price = Math.Round(comLine.NetPrice * commercialDocument.ExchangeRate / (decimal)commercialDocument.ExchangeScale, 2, MidpointRounding.AwayFromZero);
                                valuation.Quantity = quantityToValuate;
                                valuation.RelatedLine = (CommercialDocumentLine)comLine;
                                valuation.Value = Math.Round(comLine.NetPrice * commercialDocument.ExchangeRate / (decimal)commercialDocument.ExchangeScale, 2, MidpointRounding.AwayFromZero) * quantityToValuate;
                            }
                        }

                        quantityToGo = 0; //everything is related so skip to the next commercial line
                    }
                    else if (availableQuantity > 0)
                    {
                        //relation at commercial side
                        CommercialWarehouseRelation relation = comLine.CommercialWarehouseRelations.CreateNew();
                        relation.Quantity = availableQuantity;
                        relation.RelatedLine = (WarehouseDocumentLine)whLine;
                        relation.IsCommercialRelation = isCommercialRelation;
                        relation.IsOrderRelation = isOrderRelation;
                        relation.IsServiceRelation = isServiceRelation;
                        Guid relationId = relation.Id.Value;

                        //relation at warehouse side
                        relation = whLine.CommercialWarehouseRelations.CreateNew();
                        relation.Id = relationId;
                        relation.DontSave = true;
                        relation.Quantity = availableQuantity;
                        relation.IsCommercialRelation = isCommercialRelation;
                        relation.IsOrderRelation = isOrderRelation;
                        relation.IsServiceRelation = isServiceRelation;
                        relation.RelatedLine = (CommercialDocumentLine)comLine;

                        if (generateValuations)
                        {
                            decimal alreadyValuatedQuantity = whLine.CommercialWarehouseValuations.Children.Sum(val => val.Quantity);
                            decimal quantityToValuate = Math.Min(quantityToGo, whLine.Quantity - alreadyValuatedQuantity);

                            if (quantityToValuate > 0)
                            {
                                CommercialWarehouseValuation valuation = comLine.CommercialWarehouseValuations.CreateNew();
                                valuation.Price = comLine.NetPrice;
                                valuation.Quantity = quantityToValuate;
                                valuation.RelatedLine = (WarehouseDocumentLine)whLine;
                                valuation.Value = comLine.NetPrice * quantityToValuate;
                                Guid valuationId = valuation.Id.Value;

                                //warehouse side
                                valuation = whLine.CommercialWarehouseValuations.CreateNew();
                                valuation.Id = valuationId;
                                valuation.DontSave = true;
                                valuation.Price = comLine.NetPrice;
                                valuation.Quantity = quantityToValuate;
                                valuation.RelatedLine = (CommercialDocumentLine)comLine;
                                valuation.Value = comLine.NetPrice * quantityToValuate;
                            }
                        }

                        quantityToGo -= availableQuantity;
                    }

                    if (generateValuations)
                    {
                        //jezeli linie magazynu wycenilismy juz w pelni to edytujemy jej cene na pozycji
                        decimal valuatedQuantity = whLine.CommercialWarehouseValuations.Children.Sum(val => val.Quantity);

                        if (whLine.Quantity == valuatedQuantity)
                        {
                            decimal value = whLine.CommercialWarehouseValuations.Children.Sum(val2 => val2.Quantity * val2.Price);
                            value = Decimal.Round(value, 2, MidpointRounding.AwayFromZero);
                            whLine.Value = value;
                            whLine.Price = Decimal.Round(value / whLine.Quantity, 2, MidpointRounding.AwayFromZero);
                        }
                    }

                    if (quantityToGo == 0)
                        break;
                }

                if (quantityToGo > 0)
                    throw new ClientException(ClientExceptionId.UnableToRelateDocuments);
            }

            bool allLinesRelated = true;

            //add virtual relation to the commercial document
            foreach (WarehouseDocument whDoc in warehouseDocuments)
            {
                commercialDocument.AddRelatedObject(whDoc);

                decimal totalLinesQuantity = whDoc.Lines.Children.Sum(l => l.Quantity);
                decimal totalRelatedQuantity = whDoc.Lines.Children.Sum(l => l.CommercialWarehouseRelations.Children
                    .Sum(lr => lr.IsCommercialRelation == isCommercialRelation && lr.IsOrderRelation == isOrderRelation && lr.IsServiceRelation == isServiceRelation ? lr.Quantity : 0));

                if (totalLinesQuantity != totalRelatedQuantity)
                    allLinesRelated = false;
            }

            return allLinesRelated;
        }

        public static void GenerateWarehouseDocumentFromMultipleReservations(XElement source, WarehouseDocument destination)
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
            }

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

            if (copyContractor)
                destination.Contractor = reservations[0].Contractor;

            //kopiujemy atrybuty jezeli sa jakies takie
            DuplicableAttributeFactory.DuplicateAttributes(reservations, destination);

            Guid? warehouseId = null;

            foreach (CommercialDocument reservation in reservations)
            {
                foreach (CommercialDocumentLine resLine in reservation.Lines)
                {
                    decimal unrealizedQty = resLine.Quantity - resLine.CommercialWarehouseRelations.Where(r => r.IsOrderRelation).Sum(s => s.Quantity);

                    if (unrealizedQty > 0)
                    {
                        if (warehouseId == null)
                            warehouseId = resLine.WarehouseId.Value;
                        else if (warehouseId.Value != resLine.WarehouseId.Value)
                            throw new ClientException(ClientExceptionId.ReservationsFromMultipleWarehousesError);

                        var line = destination.Lines.CreateNew();
                        line.ItemId = resLine.ItemId;
                        line.ItemCode = resLine.ItemCode;
                        line.ItemName = resLine.ItemName;
                        line.ItemTypeId = resLine.ItemTypeId;
                        line.UnitId = resLine.UnitId;
                        line.Quantity = unrealizedQty;
                    }
                }
            }

            if (warehouseId != null)
                destination.WarehouseId = warehouseId.Value;

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

        public static void GenerateStackWarehoueDocumentFromMultipleReservations(XElement source, WarehouseDocument destination)
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
            }

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

            if (copyContractor)
                destination.Contractor = reservations[0].Contractor;

            //kopiujemy atrybuty jezeli sa jakies takie
            DuplicableAttributeFactory.DuplicateAttributes(reservations, destination);

            Guid? warehouseId = null;

            foreach (CommercialDocument reservation in reservations)
            {
                foreach (CommercialDocumentLine resLine in reservation.Lines)
                {
                    decimal unrealizedQty = resLine.Quantity - resLine.CommercialWarehouseRelations.Where(r => r.IsOrderRelation).Sum(s => s.Quantity);

                    if (unrealizedQty > 0)
                    {
                        if (warehouseId == null)
                            warehouseId = resLine.WarehouseId.Value;
                        else if (warehouseId.Value != resLine.WarehouseId.Value)
                            throw new ClientException(ClientExceptionId.ReservationsFromMultipleWarehousesError);

                        var line = destination.Lines.CreateNew();
                        line.ItemId = resLine.ItemId;
                        line.ItemCode = resLine.ItemCode;
                        line.ItemName = resLine.ItemName;
                        line.ItemTypeId = resLine.ItemTypeId;
                        line.UnitId = resLine.UnitId;
                        line.Quantity = unrealizedQty;
                    }
                }
            }

            if (warehouseId != null)
                destination.WarehouseId = warehouseId.Value;

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

        public static void GenerateOrderRealizationDocument(XElement source, WarehouseDocument destination)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

            Guid documentId = new Guid(source.Attribute("commercialDocumentId").Value);

            CommercialDocument sourceDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, documentId);

            if (sourceDocument.DocumentStatus == DocumentStatus.Canceled)
                throw new ClientException(ClientExceptionId.CreateNewDocumentFromCanceledDocument);

            if (sourceDocument.Contractor != null)
                destination.Contractor = (Contractor)sourceDocument.Contractor;

            DuplicableAttributeFactory.DuplicateAttributes(sourceDocument, destination);

            if (sourceDocument.DocumentType.CommercialDocumentOptions.IsShiftOrder)
            {
                var attr = destination.Attributes.CreateNew(DocumentFieldName.Attribute_IncomeShiftOrderId);
                attr.Value.Value = sourceDocument.Attributes[DocumentFieldName.Attribute_OppositeDocumentId].Value.Value;

                attr = destination.Attributes[DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId];

                if (attr == null)
                    attr = destination.Attributes.CreateNew(DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId);

                attr.Value.Value = sourceDocument.Attributes[DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId].Value.Value;
            }

            Guid? lineWarehouseId = null;

            foreach (XElement line in source.Elements())
            {
                Guid lineId = new Guid(line.Attribute("id").Value);
                decimal quantity = Convert.ToDecimal(line.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                CommercialDocumentLine srcLine = sourceDocument.Lines.Children.Where(l => l.Id == lineId).FirstOrDefault();
                decimal relatedQuantity = srcLine.CommercialWarehouseRelations.Children.Sum(r => r.Quantity);
                decimal allowedQuantity = srcLine.Quantity - relatedQuantity;

                if (lineWarehouseId == null)
                {
                    lineWarehouseId = srcLine.WarehouseId.Value;
                    destination.WarehouseId = srcLine.WarehouseId.Value;
                }
                else if (lineWarehouseId.Value != srcLine.WarehouseId.Value)
                    throw new ClientException(ClientExceptionId.UnableToRealizeOrder2);

                if (quantity > allowedQuantity)
                    throw new ClientException(ClientExceptionId.UnableToRealizeOrder, null, "itemName:" + srcLine.ItemName);

                WarehouseDocumentLine dstLine = destination.Lines.CreateNew();
                dstLine.ItemId = srcLine.ItemId;
                dstLine.Quantity = quantity;
                dstLine.UnitId = srcLine.UnitId;
                dstLine.WarehouseId = lineWarehouseId.Value;
                dstLine.ItemName = srcLine.ItemName;
                dstLine.ItemCode = srcLine.ItemCode;
                dstLine.ItemTypeId = srcLine.ItemTypeId;
            }
        }

        public static void GenerateRelationsAndShiftsForOutcomeWarehouseDocument(WarehouseDocument warehouseDocument, string correctionSlotName = null)
        {
            //Juz zuzyte ilosci z shiftów
            Dictionary<Guid, decimal> usedQuantities = new Dictionary<Guid, decimal>();

            if (warehouseDocument.ShiftTransaction == null)
            {
                warehouseDocument.ShiftTransaction = new ShiftTransaction(warehouseDocument);
            }

            foreach (WarehouseDocumentLine line in warehouseDocument.Lines)
            {
                XElement availableLotsXml
                    = DependencyContainerManager.Container.Get<WarehouseMapper>().GetAvailableLots(line.ItemId, warehouseDocument.WarehouseId);

                //jeśli przekazana nazwa kontenera technicznego to wybieramy tylko z tego kontenera a w przeciwnym przypadku wszystkie
                List<XElement> availableLots = (correctionSlotName == null ? availableLotsXml.Elements() : availableLotsXml.Elements().Where(el =>
                    el.Attribute("slotContainerLabel") != null && el.Attribute("slotContainerLabel").Value == correctionSlotName)).ToList();

                if (availableLots.Count > 0)
                {
                    //Create shifts
                    decimal lineAbsQuantity = Math.Abs(line.Quantity);
                    decimal totalQuantity = 0;
                    foreach (XElement lot in availableLots)
                    {
                        Shift shift = warehouseDocument.ShiftTransaction.Shifts.CreateNew(lot);
                        decimal leftQuantity = shift.Quantity;
                        if (shift.SourceShiftId.HasValue && usedQuantities.ContainsKey(shift.SourceShiftId.Value))
                        {
                            leftQuantity = shift.Quantity - usedQuantities[shift.SourceShiftId.Value];
                        }
                        if (leftQuantity > 0)
                        {
                            shift.Quantity = leftQuantity;
                            shift.LineOrdinalNumber = line.OrdinalNumber;
                            shift.RelatedWarehouseDocumentLine = line;
                            totalQuantity += shift.Quantity;
                        }
                        if (totalQuantity >= lineAbsQuantity)
                        {
                            shift.Quantity -= totalQuantity - lineAbsQuantity;
                            break;
                        }
                    }
                    //Update left quantities
                    foreach (Shift shift in warehouseDocument.ShiftTransaction.Shifts.Where(sh => sh.SourceShiftId.HasValue))
                    {
                        if (usedQuantities.ContainsKey(shift.SourceShiftId.Value))
                        {
                            usedQuantities[shift.SourceShiftId.Value] += shift.Quantity;
                        }
                        else
                        {
                            usedQuantities.Add(shift.SourceShiftId.Value, shift.Quantity);
                        }
                    }
                    //Create IOR
                    foreach (var relation in warehouseDocument.ShiftTransaction.Shifts
                        .Where(sh => sh.LineOrdinalNumber == line.OrdinalNumber)
                        .GroupBy(sh => sh.IncomeWarehouseDocumentLineId)
                        .Select(group => new { Id = group.Key, Quantity = group.Sum(sh => sh.Quantity) }))
                    {
                        IncomeOutcomeRelation ior = line.IncomeOutcomeRelations.CreateNew();
                        ior.Quantity = relation.Quantity;
                        ior.RelatedLine.Id = relation.Id;
                    }
                }
            }
        }

        public static void CreateStackCommercialDocumentFromWarehouseDocument(CommercialDocument destination, XElement source)
        {
            DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

            List<WarehouseDocument> whDocs = new List<WarehouseDocument>();
            List<Guid> itemsId = new List<Guid>();

            foreach (XElement whId in source.Elements("warehouseDocumentId"))
            {
                Guid docId = new Guid(whId.Value);

                var exists = whDocs.Where(d => d.Id.Value == docId).FirstOrDefault();

                if (exists != null)
                    continue;

                WarehouseDocument doc = (WarehouseDocument)mapper.LoadBusinessObject(BusinessObjectType.WarehouseDocument, docId);
                whDocs.Add(doc);

                CommercialWarehouseDocumentFactory.CheckIfWarehouseDocumentHasSalesOrderWithPrepaids(doc);

                foreach (WarehouseDocumentLine line in doc.Lines.Children)
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
             

            foreach (WarehouseDocument whDoc in whDocs)
            {
                

                
                //GetLineMappingForWarehouseDocument
                foreach (WarehouseDocumentLine line in whDoc.Lines.Children)
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
            foreach (WarehouseDocument whDoc in whDocs)
            {
                //Pobieram mapowania towarów
                XDocument mapPat = mapper.GetLineMappingForWarehouseDocument(whDoc);

                foreach (WarehouseDocumentLine whLine in whDoc.Lines.Children)
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
                        if (l.ItemId == new Guid(item.FirstOrDefault().Element("itemId").Value) )
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
                    comLine.NetPrice = whLine.Price;
                    comLine.VatRateId = new Guid(item.FirstOrDefault().Element("vatRateId").Value);
                    comLine.ItemVersion = new Guid(item.FirstOrDefault().Element("version").Value);
                    comLine.InitialNetPrice = Convert.ToDecimal(item.FirstOrDefault().Element("defaultPrice").Value, CultureInfo.InvariantCulture);
                    comLine.NetPrice = comLine.InitialNetPrice;// comLine.InitialNetPrice;

                    if (!newLine)
                    {
                        comLine.Quantity = comLine.Quantity +  quantityNotRelated;
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

    }
}
