using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Xml.Linq;
using System.Xml.XPath;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Coordinators.Plugins;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Class that coordinates business logic of Item's BusinessObject
    /// </summary>
    public class ItemCoordinator : TypedCoordinator<ItemMapper>
    { 
        /// <summary>
        /// Initializes a new instance of the <see cref="ItemCoordinator"/> class.
        /// </summary>
        public ItemCoordinator() : this(true, true)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemCoordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        public ItemCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<ItemMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:29");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        protected override void LoadPlugins(CoordinatorPluginPhase pluginPhase, IBusinessObject businessObject)
        {
            base.LoadPlugins(pluginPhase, businessObject);
            ItemEquivalentGroupRemovalPlugin.Initialize(pluginPhase, this, businessObject as Item);
            ItemCodeExistenceCheckPlugin.Initialize(pluginPhase, this);
        }

        public override void DeleteBusinessObject(XDocument requestXml)
        {
            this.Mapper.DeleteBusinessObject(BusinessObjectType.Item, new Guid(requestXml.Root.Element("id").Value));
			JournalManager.Instance.LogToJournalWithTransaction(JournalAction.Item_Delete, requestXml);
        }

        /// <summary>
        /// Creates the item equivalent group using specified xml item list.
        /// </summary>
        /// <param name="requestXml">Client's request containing list of items to bind into one equivalent group.</param>
        public void CreateItemEquivalentGroup(string requestXml)
        {
            XDocument xml = XDocument.Parse(requestXml);
            SessionManager.VolatileElements.ClientRequest = xml;

            Item[] items = new Item[xml.Root.Elements().Count()];
            int i = 0;

            foreach (XElement element in xml.Root.Elements())
            {
                IBusinessObject bo = this.Mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(element.Attribute("id").Value));

                items[i++] = (Item)bo;
            }

            //check if any item is already in other equivalent group
            List<Item> alreadyRelatedItems = new List<Item>();
            Guid? itemEqGrpId = null;

            foreach (Item item in items)
            {
                foreach (ItemRelation relation in item.Relations.Children)
                {
                    if (relation.ItemRelationTypeName == ItemRelationTypeName.Item_EquivalentGroup)
                    {
                        if (itemEqGrpId == null)
                            itemEqGrpId = new Guid(((CustomBusinessObject)relation.RelatedObject).Value.Element("id").Value);
                        else if (itemEqGrpId != new Guid(((CustomBusinessObject)relation.RelatedObject).Value.Element("id").Value))
                            throw new ClientException(ClientExceptionId.ItemEquivalentGroupException, null, "itemName:" + item.Name);

                        alreadyRelatedItems.Add(item);
                    }
                }
            }

            if (itemEqGrpId == null)
                itemEqGrpId = Guid.NewGuid();

            foreach (Item item in items)
            {
                if (!alreadyRelatedItems.Contains(item))
                {
                    ItemRelation rel = item.Relations.CreateNew();
                    rel.ItemRelationTypeName = ItemRelationTypeName.Item_EquivalentGroup;
                    CustomBusinessObject bo = CustomBusinessObject.CreateEmpty();

                    bo.Id = itemEqGrpId;
                    bo.Value.Add(new XElement("id", itemEqGrpId.ToUpperString()));

                    rel.RelatedObject = bo;
                }
            }

            this.SaveBusinessObjects(items);
        }
        public void CreateItemEquivalent(string requestXml)
        {
            XDocument xml = XDocument.Parse(requestXml);
            SessionManager.VolatileElements.ClientRequest = xml;

            //check if any item is already in equivalent
            List<Item[,]> alreadyRelatedItems = new List<Item[,]>();
            List<Item[,]> items = new List<Item[,]>();//new List<Item[,]>();
            List<Item> itemsToSave = new List<Item>();
            Item i;

            foreach (XElement element in xml.Root.Elements())
            {
                Item[,] para = new Item[1, 2];
                IBusinessObject bo = this.Mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(element.Attribute("id").Value));
                IBusinessObject relatedItem = null;

                //add related item if exists
                //TODO relacje dwustronne jak brakuje elementu
                if (element.Attribute("relatedItemId") != null)
                {
                    relatedItem = this.Mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(element.Attribute("relatedItemId").Value));
                }

                para[0,0] = (Item)bo;
                para[0,1] = (Item)relatedItem;

                // Dodanie obiektu powiązanego, przypadek tworzenia relacji każdy z każdym
                 if (para[0,1] == null)
                    {
                        foreach (XElement el in xml.Root.Elements())
                        {
                            if (element.Attribute("id").Value != el.Attribute("id").Value)
                            {
                                relatedItem = this.Mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(el.Attribute("id").Value));
                                para[0,1] = (Item)relatedItem;
                                items.Add(para);
                            }
                        }
                    }
                else
	                {
                         items.Add(para);
	                }
               


                //Pętla po relacjach towaru
                foreach (ItemRelation relation in para[0, 0].Relations.Children)
                {
                    //Szukamy relacji tego samego typu
                    if (relation.ItemRelationTypeName == ItemRelationTypeName.Item_Equivalent)
                    {
                        if (para[0, 1].Id == relation.RelatedObject.Id)
                            alreadyRelatedItems.Add(para);
                    }
                }
            }
        

           foreach (Item[,] it in items )
            {
                if (!alreadyRelatedItems.Contains(it)) 
                {
                    Boolean sameItem = false;
                    Int16 index = 0;
                    i = it[0, 0];

                    foreach (Item itm in itemsToSave)
                    {
                        if (itm.Id.ToString() == it[0, 0].Id.ToString())
                        {
                            sameItem = true;
                            i = itemsToSave[index];
                        }
                        index++;
                    }
                    
                    ItemRelation rel = i.Relations.CreateNew();
                    rel.Id = Guid.NewGuid(); 
                    rel.ItemRelationTypeName = ItemRelationTypeName.Item_Equivalent;
                    IBusinessObject bo = it[0, 1];
 
                    rel.RelatedObject = bo;

                    if(!sameItem)
                        itemsToSave.Add(i);
                  
                    }
                }

           this.SaveBusinessObjects(itemsToSave.ToArray());
        }

		public Item[] CreateItemsBarcodes(string requestXml)
		{
			#region Init variables
			XDocument xml = XDocument.Parse(requestXml);
			SessionManager.VolatileElements.ClientRequest = xml;
			Random rnd = new Random();
			int barcodeLength = 6;
			#endregion

			#region Load items
			Item[] items = new Item[xml.Root.Elements().Count()];
			int i = 0;

			foreach (XElement element in xml.Root.Elements())
			{
				IBusinessObject bo = this.Mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(element.Attribute(XmlName.Id).Value));

				items[i++] = (Item)bo;
			}
			#endregion

			#region Generate barcodes

			List<string> generatedBarcodes = new List<string>();
			int quantityToGo = items.Where(it => it.Attributes[ItemFieldName.Attribute_Barcode] == null).Count();

			int repeatCounter = 0;
			while (quantityToGo > 0 && repeatCounter++ < 10)
			{
				XDocument barcodesXml = XDocument.Parse(XmlName.EmptyRoot);
				#region Generate new set of barcodes
				List<string> tmpBarcodes = new List<string>();
				for (int q = 0; q < quantityToGo; q++)
				{
					char[] barcodeChars = new char[barcodeLength];
					for (int j = 0; j < barcodeLength; j++)
					{
						barcodeChars[j] = ConfigurationMapper.Instance.BarcodeCharacters
							[rnd.Next(ConfigurationMapper.Instance.BarcodeCharacters.Length)];
					}
					tmpBarcodes.Add(new String(barcodeChars));
				}
				barcodeLength++;
				#endregion

				#region Uniqueness check and adding to collection
				foreach (string barcode in tmpBarcodes.Distinct().Where(barcode => !generatedBarcodes.Contains(barcode)))
				{
					barcodesXml.Root.Add(new XElement(XmlName.Barcode, barcode));
				}
				
				barcodesXml = this.Mapper.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsByBarcode, true, barcodesXml);

				var uniqueBarcodes = barcodesXml.Root.Elements()
					.Where(el => el.Attribute(XmlName.Id) == null && el.Attribute(XmlName.Barcode) != null)
					.Select(el => el.Attribute(XmlName.Barcode).Value);
				generatedBarcodes.AddRange(uniqueBarcodes);
				quantityToGo -= uniqueBarcodes.Count();
				#endregion
			}

			var barcodesEnumerator = generatedBarcodes.GetEnumerator();

			foreach (Item item in items.Where(it => it.Attributes[ItemFieldName.Attribute_Barcode] == null))
			{
				barcodesEnumerator.MoveNext();
				item.Attributes.CreateNew(ItemFieldName.Attribute_Barcode).Value.Value = barcodesEnumerator.Current;
			}
			#endregion

			this.SaveLargeQuantityOfBusinessObjects<Item>(true, items);

			return items;
		}

        public override void ValidateTransactionPhase(IBusinessObject businessObject)
        {
            base.ValidateTransactionPhase(businessObject);

            Item item = (Item)businessObject;

            if (!item.IsNew)
            {
                Item alternateItem = (Item)item.AlternateVersion;

                if (item.Status == BusinessObjectStatus.Modified && item.UnitId != alternateItem.UnitId)
                {
                    ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();
                    bool isExist = mapper.CheckItemExistenceInDocuments(item.Id.Value);

                    if (isExist)
                        throw new ClientException(ClientExceptionId.ItemUnitIdChangeError);
                }
                else if (item.Status == BusinessObjectStatus.Modified && item.VatRateId != alternateItem.VatRateId)
                {
                    ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();
                    bool isExist = mapper.CheckItemExistenceInDocuments(item.Id.Value);

                    if (isExist)
                        throw new ClientException(ClientExceptionId.ItemVatRateIdChangeError);
                }
            }
        }


        public XDocument GetItemsDetails(XDocument requestXml)
        {
            /*
            <root>
              <documentTypeId/>
              <source/>
              <contractorId/>
              <item/>
              <item/>
              <item/>
              <item/>
            </root>
            */

            Guid? contractorId = null;

            if (requestXml.Root.Element("contractorId") != null)
                contractorId = new Guid(requestXml.Root.Element("contractorId").Value);

            XElement source = null;

            if (requestXml.Root.Element("source") != null)
                source = requestXml.Root.Element("source").Element("source");

            Guid documentTypeId = new Guid(requestXml.Root.Element("documentTypeId").Value);

            List<Guid> items = new List<Guid>();

            foreach (var item in requestXml.Root.Elements("item"))
            {
                items.Add(new Guid(item.Attribute("id").Value));
            }

            bool lastPurchasePrice = false;

            DocumentType dt = DictionaryMapper.Instance.GetDocumentType(documentTypeId);

            if (dt.DocumentCategory == DocumentCategory.Purchase || dt.DocumentCategory == DocumentCategory.Order)
                lastPurchasePrice = true;

            ItemMapper mapper = (ItemMapper)this.Mapper;

            XDocument xml = mapper.GetItemsDetailsForDocument(lastPurchasePrice, documentTypeId, contractorId, items);

            if (lastPurchasePrice)
            {
                foreach (var itemXml in xml.Root.Elements())
                {
                    if (itemXml.Attribute("lastPurchasePrice") != null && itemXml.Attribute("netPrice") == null)
                        itemXml.Add(new XAttribute("netPrice", itemXml.Attribute("lastPurchasePrice").Value));
                }
            }

            if (//source != null && 
                //source.Attribute("type") != null &&
                //source.Attribute("type").Value == "order" &&
                dt.DocumentCategory == DocumentCategory.Order &&
                ConfigurationMapper.Instance.IsExternalSystemOrderPricesEnabled)
            {
                XDocument manufacturerXml = mapper.GetItemsManufacturerAndCode(items);

                foreach (XElement item in manufacturerXml.Root.Elements())
                {
                    if (item.Attribute("manufacturer") == null)
                        item.Add(new XAttribute("manufacturer", String.Empty));

                    if (item.Attribute("manufacturerCode") == null)
                        item.Add(new XAttribute("manufacturerCode", String.Empty));
                }

                //dodajemy nasz kod kontrahenta
                manufacturerXml.Root.Add(new XAttribute("contractorCode", ConfigurationMapper.Instance.ExternalSystemOrderPricesContractorCode));

                manufacturerXml.Root.Name = XName.Get("items");

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(ConfigurationMapper.Instance.ExternalSystemOrderPricesUri);
                req.Timeout = 20000;
                req.ContentType = "text/xml";
                req.Method = "POST";

                StreamWriter wr = new StreamWriter(req.GetRequestStream(), Encoding.UTF8);
                wr.Write(manufacturerXml.ToString(SaveOptions.DisableFormatting));
                wr.Flush();
                wr.Close();
                XDocument responseXml = null;
                Stream responseStream = null;

                try
                {
                    WebResponse response = req.GetResponse();

                    responseStream = response.GetResponseStream();
                    responseXml = XDocument.Load(new StreamReader(responseStream));
                    responseStream.Dispose();

                    //wywalamy netPrice bo zastapimy cena ktora dostalismy
                    foreach (var item in xml.Root.Elements())
                    {
                        if (item.Attribute("netPrice") != null)
                            item.Attribute("netPrice").Remove();

                        var manufacturerItem = manufacturerXml.Root.Elements().Where(e => e.Attribute("id").Value == item.Attribute("id").Value).First();

                        var foreignItem = responseXml.Root.Elements().Where(f => f.Attribute("manufacturer").Value == manufacturerItem.Attribute("manufacturer").Value &&
                            f.Attribute("manufacturerCode").Value == manufacturerItem.Attribute("manufacturerCode").Value).FirstOrDefault();

                        if (foreignItem == null || foreignItem.Attribute("price") == null || foreignItem.Attribute("price").Value == String.Empty)
                            item.Add(new XAttribute("netPrice", "0.00"));
                        else
                        {
                            item.Add(new XAttribute("netPrice", foreignItem.Attribute("price").Value));
                        }
                    }
                }
                catch (Exception)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:30");
                    //zerujemy ceny
                    foreach (var item in xml.Root.Elements())
                    {
                        if (item.Attribute("netPrice") != null)
                            item.Attribute("netPrice").Remove();

                        if (item.Attribute("initialNetPrice") != null)
                            item.Attribute("initialNetPrice").Value = "0.00";
                    }
                }
                finally
                {
                    if (responseStream != null)
                        responseStream.Dispose();

                    if (wr != null)
                        wr.Dispose();
                }
            }

            return xml;
        }

        /// <summary>
        /// Removes the item from equivalent group.
        /// </summary>
        /// <param name="requestXml">Client's request containing list of items id.</param>
        public void RemoveItemFromEquivalentGroup(string requestXml)
        {
            XDocument xml = XDocument.Parse(requestXml);
			SessionManager.VolatileElements.ClientRequest = xml;

            Item[] items = new Item[xml.Root.Elements().Count()];
            int i = 0;

            foreach (XElement element in xml.Root.Elements())
            {
                Item item = (Item)this.Mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(element.Attribute("id").Value));

                List<ItemRelation> relationsToRemove = new List<ItemRelation>();

                foreach (ItemRelation relation in item.Relations.Children)
                {
                    if (relation.ItemRelationTypeName == ItemRelationTypeName.Item_EquivalentGroup)
                        relationsToRemove.Add(relation);
                }

                foreach (ItemRelation relation in relationsToRemove)
                {
                    item.Relations.Remove(relation);
                }

                items[i++] = item;
            }

            this.SaveBusinessObjects(items);
        }


        public void RemoveItemFromEquivalent(string requestXml)
        {
            XDocument xml = XDocument.Parse(requestXml);
            SessionManager.VolatileElements.ClientRequest = xml;
            List<String> itemsId = new List<String>();
            List<String[,]> itemRelations = new List<String[,]>();
            List<Item> itemsToSave = new List<Item>();
            String[,] para;
            List<Item> items = new List<Item>();
            para = new String[1, 2];

            //relacje z xml
            foreach (XElement element in xml.Root.Elements())
            {

                para[0, 0] = element.Attribute("id").Value;
                if (element.Attribute("relatedItemId").Value != null)
                {
                    para[0, 1] = element.Attribute("relatedItemId").Value;
                }
                itemRelations.Add(para);
                para = new String[1, 2];
            }



            foreach (XElement element in xml.Root.Elements())
            {
                Item item = (Item)this.Mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(element.Attribute("id").Value));
                
                //Lista id, powielenie edycji id w tej samej transakcji powoduje błąd kernela
                if(!itemsId.Contains(item.Id.ToString()))
                {
                    itemsId.Add(item.Id.ToString());

                    List<ItemRelation> relationsToRemove = new List<ItemRelation>();
                    para[0, 0] = element.Attribute("id").Value;

                    foreach (ItemRelation relation in item.Relations.Children)
                    {
                        para[0, 1] = relation.RelatedObject.Id.ToString();
                        if (relation.ItemRelationTypeName == ItemRelationTypeName.Item_Equivalent)
                            foreach (String[,] itemRel in itemRelations)
                            {
                                if (para[0, 0].ToString().ToUpper() == itemRel[0, 0].ToString().ToUpper() && para[0, 1].ToString().ToUpper() == itemRel[0, 1].ToString().ToUpper())
                                    relationsToRemove.Add(relation);
                            }

                    }

                    foreach (ItemRelation relation in relationsToRemove)
                    {
                        item.Relations.Remove(relation);
                    }

                    items.Add(item);
                }
            }

            this.SaveBusinessObjects(items.ToArray());
        }

        /// <summary>
        /// Performs initial validation.
        /// </summary>
        /// <param name="requestXml">Client's request containing <see cref="BusinessObject"/>'s xml and its options.</param>
        protected override void PerformInitialValidation(XDocument requestXml)
        {
            string boType = ((XElement)requestXml.Root.FirstNode).Attribute("type").Value;
			BusinessObjectType type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), boType);

            if (!this.MapperTyped.SupportedBusinessObjectsTypes.Contains(type))
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + boType);
        }

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id. It appends modification user name.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to load.</param>
        /// <param name="id">The id of the <see cref="IBusinessObject"/> to load.</param>
        /// <returns>Loaded <see cref="BusinessObject"/></returns>
        internal override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            Item result = (Item)this.MapperTyped.LoadBusinessObject(BusinessObjectType.Item, id);
            ContractorMapper contractorMapper = new ContractorMapper();

            if (result.ModificationUserId.HasValue)
            {
                Contractor modificationUser =  contractorMapper.LoadBusinessObject(result.ModificationUserId.Value);
                result.ModificationUser = modificationUser.FullName;
            }

            if (result.CreationUserId.HasValue)
            {
                Contractor creationUser = contractorMapper.LoadBusinessObject(result.CreationUserId.Value);
                result.CreationUser = creationUser.FullName;
            }

            return result;
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="ItemCoordinator"/> and optionally releases the managed resources.
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

        public XDocument UpdateItemCataloguePrices(XDocument requestXml)
        {
            //Konfiguracja importera
            XElement configEntry = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "import.itemPrices").First().Value;
            
            //Lista itemField które są cennikami
            List<XElement> itemPrice = DictionaryMapper.Instance.GetItemFields().Root.Element("itemField").Elements("itemField").Where(f => f.GetTextValueOrNull("name").Substring(0, 6) == "Price_").ToList();
            String config_supportAttributePrice = configEntry.GetAtributeValueOrNull("supportAttributePrice");
            //Pole aktualizujące defaultPrice jeśli importujemy cenniki na atrybutach
            string setDefaultPrice;

            //Customowa procka jeśli cenniki nie są standartowe
            if (configEntry.Attribute("customProcedure") != null)
            {
                string customProcedure = configEntry.Attribute("customProcedure").ToString();
                XDocument updatedPrices = null;
                if (customProcedure != "")
                {

                    updatedPrices = this.Mapper.ExecuteStoredProcedure(StoredProcedure.custom_p_importPrices, true, requestXml);
                }
                return updatedPrices;
            }
            
            setDefaultPrice = configEntry.Descendants("StaticField").Elements("Field").Where(f => f.Attribute("setDefaultPrice").Value == "1").Select(f => f.Attribute("name").Value).FirstOrDefault();

            XDocument result = XDocument.Parse("<root/>");
            Boolean forceUpdate = false;
            if (requestXml.Root.Attribute("forceUpdate") != null && requestXml.Root.Attribute("forceUpdate").Value == "1")
                    forceUpdate = true;

            XDocument procedureRequestXml = XDocument.Parse("<root></root>");
            String identifierField = "code";
            String netPriceElementName = "netPrice";
            if (requestXml.Root.Attribute("identifierField") != null) identifierField = requestXml.Root.Attribute("identifierField").Value;
            if (requestXml.Root.Attribute("netPriceElementName") != null) netPriceElementName = requestXml.Root.Attribute("netPriceElementName").Value;
            //TODO - Tutaj pozwolę sobie na uproszczenie do 5 cen dla towaru
            List<string> itemCodes = new List<string>();
            foreach (XElement row in requestXml.Root.Elements("Row"))
            {
                if (row.Element(identifierField) != null)
                    itemCodes.Add(row.Element(identifierField).Value);
            }
            
            XDocument procedureResponseXml = this.MapperTyped.GetItemsByItemCode(itemCodes);

            List<Item> itemsList = new List<Item>();
            List<Item> updatedItems = new List<Item>();
            List<XElement> unchangedItems = new List<XElement>();
            if (procedureResponseXml != null)
            {
                List<Guid> ids = new List<Guid>();
                foreach (XElement item in procedureResponseXml.Root.Elements("item"))
                    if (item.Attribute("id") != null) ids.Add(new Guid(item.Attribute("id").Value));
                itemsList = (List<Item>)this.MapperTyped.LoadBusinessObjects<Item>(BusinessObjectType.Item, ids);

                foreach (XElement xmlItem in requestXml.Root.Elements("Row"))
                {
                    if (config_supportAttributePrice == null || config_supportAttributePrice != "true") //Warunek na konfigurację wgrywania cenników znajdujących się w atrybutach
                    {
                        /* Dodałem pętlę ze względu na powielające się towary o tym samym identyfikatorze jako kod producenta*/
                        foreach (var itemElem in itemsList.Where(it => xmlItem.Element(identifierField) != null && xmlItem.Element(netPriceElementName) != null && it.Attributes[ItemFieldName.Attribute_ManufacturerCode] != null &&
                             xmlItem.Element(identifierField).Value == it.Attributes[ItemFieldName.Attribute_ManufacturerCode].Value.Value))
                        {
                            Item item = itemElem;

                        //Item item = itemsList.Where(it => xmlItem.Element(identifierField) != null && xmlItem.Element(netPriceElementName) != null && it.Attributes[ItemFieldName.Attribute_ManufacturerCode] != null &&
                        //     xmlItem.Element(identifierField).Value == it.Attributes[ItemFieldName.Attribute_ManufacturerCode].Value.Value).FirstOrDefault();
                     
                            if (item != null)
                            {
                                item.DefaultPrice = decimal.Parse(xmlItem.Element(netPriceElementName).Value.Replace(".",","));
                                updatedItems.Add(item);
                            }
					        else
					        {
						        unchangedItems.Add(xmlItem);
					        }
                        }
 
                    }
                    else
	                {
                        //ZAKŁADAM IDENTYFIKACJE TOWARU PO KODZIE (CODE)
                        Item item = itemsList.Where(it => it.Code.Trim() == xmlItem.Element(identifierField).Value.Trim() ).FirstOrDefault();
                        if (item != null)
                        {
                            //To jest taki nie ładny fragment 
                            if (setDefaultPrice != null && xmlItem.Element(setDefaultPrice) != null)
                            {
                                item.DefaultPrice = decimal.Parse(xmlItem.Element(setDefaultPrice).Value.Replace(".",","));
                            }
                            
                            //ZA CIENKI JESTEM BY ZROBIĆ TO PROŚCIEJ WIĘC PĘTLA PO ATRYBUTACH TYPU CENA, WYSZUKANIE WARTOŚCI W XML`U Z CENAMI NA PODSTAWIE NAZW NODÓW
                            foreach (XElement iField in itemPrice)
                            {
                                if (xmlItem.Element(iField.Descendants("label").FirstOrDefault().Value.Replace("_","")).Value != null)
                                {
                                    //ATRYBUT ZMIENIAMY LUB DODAJEMY NOWY
                                    if (item.Attributes.Children.Where(a => a.ItemFieldName.ToString() == iField.Descendants("name").FirstOrDefault().Value).FirstOrDefault() != null)
                                    {
                                        item.Attributes.Children.Where(a => a.ItemFieldName.ToString() == iField.Descendants("name").FirstOrDefault().Value).FirstOrDefault().Value.Value =
                                                xmlItem.Element(iField.Descendants("label").FirstOrDefault().Value).Value.Replace(",", ".");
                                    }
                                    else
                                    {
                                        //TROCHE UPIERDLIWE ALE NOWY ATRYBUT POTRZEBUJE ITEMFIELDNAME KTÓRE JEST W ENUMACH... A JA CHCE MIEĆ GENERYCZNE ATRYBUTY A NIE W KODZIE
                                        ItemAttrValue iav;
                                        String path = "root/itemField/itemField[name='" + iField.Descendants("name").FirstOrDefault().Value + "']/id";
                                        Guid itemFieldId = new Guid( DictionaryMapper.Instance.GetItemFields().XPathSelectElement(path).Value.ToUpper());
                                        
                                        iav = item.Attributes.CreateNew(DictionaryMapper.Instance.GetItemField(itemFieldId).TypeName);
                                        iav.Value.Value = xmlItem.Element(iField.Descendants("label").FirstOrDefault().Value.Replace("_", "")).Value.Replace(",", ".");

                                    }
                                }
                            }
                            
                            updatedItems.Add(item);
                        }
                        else
                        {
                            unchangedItems.Add(xmlItem);
                        }
	                }


                }
            }

            if ( updatedItems.Count > 0 )
            {
                //if (unchangedItems.Count == 0 || forceUpdate)
                    SaveLargeQuantityOfBusinessObjects<Item>(false, updatedItems.ToArray());
                    //<root><updatedItems><item><code/><name/>  </item><updatedItems></root>

                XElement updatedItemsElement = new XElement("updatedItems");
                foreach (Item item in updatedItems)
                {
                    XElement updatedElement = new XElement("item");
                    updatedElement.Add(new XElement(identifierField, item.Code));
                    updatedElement.Add(new XElement("name", item.Name));
                    updatedItemsElement.Add(new XElement(updatedElement));
                }
                result.Root.Add(new XElement(updatedItemsElement));
            }
            if (unchangedItems.Count > 0)
            {
                XElement ignoredItemsElement = new XElement("ignoredItems");
                foreach (XElement item in unchangedItems)
                {
                    ignoredItemsElement.Add(new XElement(item));
                }
                result.Root.Add(new XElement(ignoredItemsElement));
            }

            return result;
        }
    }
}
