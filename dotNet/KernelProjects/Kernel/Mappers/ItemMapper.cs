using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class representing a mapper with methods necessary to operate on <see cref="Item"/>.
    /// </summary>
    public class ItemMapper : Mapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ItemMapper"/> class.
        /// </summary>
        public ItemMapper()
            : base()
        { }

		#region Supported types

		private static BidiDictionary<BusinessObjectType, Type> cachedSupportedBusinessObjectTypes;

		private static BidiDictionary<BusinessObjectType, Type> CachedSupportedBusinessObjectTypes
		{
			get
			{
				if (cachedSupportedBusinessObjectTypes == null)
				{
					cachedSupportedBusinessObjectTypes = new BidiDictionary<BusinessObjectType, Type>()
					{
						{ BusinessObjectType.Item, typeof(Item) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { return ItemMapper.CachedSupportedBusinessObjectTypes; }
		}

		#endregion
		
		/// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            IBusinessObject bo = null;

			if (type == BusinessObjectType.Item)
				bo = new Item(null);
			else
				throw new InvalidOperationException("ItemMapper can only create items.");

            bo.GenerateId();
            return bo;
        }

        public override void DeleteBusinessObject(BusinessObjectType type, Guid id)
        {
            try
            {
                this.ExecuteStoredProcedure(StoredProcedure.item_p_deleteItem, false, "@itemId", id);
            }
            catch (SqlException ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:122");
                if (ex.Number == 50000)
                    throw new ClientException(ClientExceptionId.ItemRemovalError);
            }
        }

        public bool CheckItemCodeExistence(XDocument xml)
        {
            XDocument retXml = this.ExecuteStoredProcedure(StoredProcedure.item_p_checkItemCodeExistence, true, xml);

            return Convert.ToBoolean(retXml.Root.Value, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Gets the name of the item.
        /// </summary>
        /// <param name="id">The item id.</param>
        /// <returns>Name of the item.</returns>
        public string GetItemName(Guid id)
        {
            return this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemName, true, "@id", id).Root.Value;
        }

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id.
        /// </summary>
        /// <param name="type">Type of <see cref="BusinessObject"/> to load.</param>
        /// <param name="id"><see cref="IBusinessObject"/>'s id indicating which <see cref="BusinessObject"/> to load.</param>
        /// <returns>
        /// Loaded <see cref="IBusinessObject"/> object.
        /// </returns>
        public override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemData, true, "@itemId", id);

            if (xdoc.Root.Element("item").Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, id);

            return this.ConvertToBusinessObject(xdoc.Root.Element("item"), null);
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            XDocument convertedXml = XDocument.Parse("<root><item /></root>");

            this.ConvertItemFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertItemAttributesFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertItemUnitRelationsFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertItemRelationsFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertGroupMembershipsFromDbToBoXmlFormat(xml, id, convertedXml, "item");

            return convertedXml;
        }

        public void UnblockItems()
        {
            this.ExecuteStoredProcedureWithNoParams(StoredProcedure.item_p_unblockItems, false);
        }

        public XElement BlockItems(XElement xml)
        {
            if (xml == null || !xml.HasElements)
                return null;

            /*
                wejscie: 
                <root> 
                  <entry itemId="..." warehouseId="..." /> 
                  ...[tutaj kolekcja entry]... 
                </root> 

                wyjscie: 
                <root> 
                  <entry itemId="..." warehouseId="..." alreadyBlocked="1" /> 
                </root> 

                lub 

                <root> 
                  <entry itemId="..." warehouseId="..." quantity="..." /> 
                </root> 
             */

            XDocument xdoc = new XDocument(new XElement(xml));

            return this.ExecuteStoredProcedure(StoredProcedure.item_p_blockItem, true, xdoc).Root;
        }

        /// <summary>
        /// Converts Item table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Item"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertItemFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            var mainItem = from node in xml.Root.Element("item").Elements()
                           where node.Element("id").Value == id.ToUpperString()
                           select node;

            foreach (XElement element in mainItem.ElementAt(0).Elements())
            {
                outXml.Root.Element("item").Add(element); //auto-cloning
            }

            if (outXml.Root.Element("item").Attribute("type") == null)
            {
                outXml.Root.Element("item").Add(new XAttribute("type", "Item"));
            }
        }

        /// <summary>
        /// Converts ItemAttrValue table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the currently processed <see cref="Item"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertItemAttributesFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("itemAttrValue") != null)
            {
                XElement attributes = new XElement("attributes");
                outXml.Root.Element("item").Add(attributes);

                var elements = from node in xml.Root.Element("itemAttrValue").Elements()
                               where node.Element("itemId").Value == id.ToUpperString()
                               orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                               select node;

                foreach (XElement element in elements)
                {
                    XElement attribute = new XElement("attribute");
                    attributes.Add(attribute);

                    foreach (XElement attrElement in element.Elements())
                    {
                        if (attrElement.Name.LocalName != "itemId")
                        {
                            if (!VariableColumnName.IsVariableColumnName(attrElement.Name.LocalName))
                                attribute.Add(attrElement);
                            else
                            {
                                ItemField cf = DictionaryMapper.Instance.GetItemField(new Guid(element.Element("itemFieldId").Value));

                                string dataType = cf.Metadata.Element("dataType").Value;

                                if (dataType != "xml")
                                    attribute.Add(new XElement(XmlName.Value, BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(attrElement.Value, dataType)));
                                else
                                    attribute.Add(new XElement(XmlName.Value, attrElement.Elements()));
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Converts ItemUnitRelation table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the currently processed <see cref="Item"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertItemUnitRelationsFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("itemUnitRelation") != null)
            {
                XElement unitRelations = new XElement("unitRelations");
                outXml.Root.Element("item").Add(unitRelations);

                var elements = from node in xml.Root.Element("itemUnitRelation").Elements()
                               where node.Element("itemId").Value == id.ToUpperString()
                               select node;

                foreach (XElement element in elements)
                {
                    XElement unitRelation = new XElement("unitRelation");
                    unitRelations.Add(unitRelation);

                    foreach (XElement relElement in element.Elements())
                    {
                        if (relElement.Name.LocalName != "itemId")
                            unitRelation.Add(relElement);
                    }
                }
            }
        }

        /// <summary>
        /// Gets the item group memberships count.
        /// </summary>
        /// <param name="contractorGroupId">The item group id.</param>
        /// <returns>Number of memberships to the item group.</returns>
        public int GetItemGroupMembershipsCount(Guid itemGroupId)
        {
            XDocument retXml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemGroupMembershipsCount,
                true, "@itemGroupId", itemGroupId);

            return Convert.ToInt32(retXml.Root.Value, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Converts ItemRelation table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the currently processed <see cref="Item"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertItemRelationsFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("itemRelation") != null)
            {
                XElement relations = new XElement("relations");
                outXml.Root.Element("item").Add(relations);

                var elements = from node in xml.Root.Element("itemRelation").Elements()
                               where node.Element("itemId").Value == id.ToUpperString()
                               orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                               select node;

                foreach (XElement element in elements)
                {
                    XElement relation = new XElement("relation");
                    relations.Add(relation);

                    foreach (XElement relElement in element.Elements())
                    {
                        if (relElement.Name.LocalName != "itemId" && relElement.Name.LocalName != "relatedObjectId")
                            relation.Add(relElement);
                    }

                    XElement relatedObject = new XElement("relatedObject");
                    relation.Add(relatedObject);

                    //get and nest the related object
                    Guid itemRelationTypeId = new Guid(relation.Element("itemRelationTypeId").Value);

                    ItemRelationType relType = DictionaryMapper.Instance.GetItemRelationType(itemRelationTypeId);
                    string relatedObjectType = relType.Metadata.Element("relatedObjectType").Value;
                    string relatedObjectId = element.Element("relatedObjectId").Value;

                    switch (relatedObjectType)
                    {
                        case "Contractor":
                            relatedObject.Add(from node in xml.Root.Element("contractor").Elements()
                                              where node.Element("id").Value == relatedObjectId
                                              select node);

                            XElement contractorElement = (XElement)relatedObject.FirstNode;
                            contractorElement.Name = XName.Get("contractor", String.Empty);

                            if (contractorElement.Element("isEmployee").Value == "1")
                                contractorElement.Add(new XAttribute("type", "Employee"));
                            else if (contractorElement.Element("isBank").Value == "1")
                                contractorElement.Add(new XAttribute("type", "Bank"));
                            else
                                contractorElement.Add(new XAttribute("type", "Contractor"));
                            break;
                        case "Item":
                            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemData, true, "@itemId", relatedObjectId);

                            relatedObject.Add(from node in xdoc.Root.Element("item").Elements()
                                              where node.Element("id").Value == relatedObjectId
                                              select node);
                            
                            XElement itemElement = (XElement)relatedObject.FirstNode;
                            itemElement.Name = XName.Get("item", String.Empty);
                            itemElement.Add(new XAttribute("type", "Item"));
                            break;
                        case "CustomXmlList":
                            string procName = relType.Metadata.Element("procedureName").Value;
                            StoredProcedure sp = (StoredProcedure)Enum.Parse(typeof(StoredProcedure), procName);

                            if (sp == StoredProcedure.item_p_getItemEquivalents)
                            {
                                XElement eqXml = this.GetItemEquivalents(id, new Guid(relatedObjectId));

                                eqXml.Add(new XElement("id", relatedObjectId));
                                eqXml.Add(new XElement("version", relatedObjectId));
                                relatedObject.Add(new XElement("customXmlList", eqXml.Elements())); //cloning
                            }
                            break;
                    }

                    //add attributes
                    XElement relationAttributes = this.ConvertItemRelationAttributesFromDbToBoXmlFormat(xml, new Guid(relation.Element("id").Value));
                    relation.Add(relationAttributes);
                }
            }
        }

        public XElement GetItemEquivalents(Guid itemId, Guid groupId)
        {
            XDocument custXml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemEquivalents, true, "@itemId", itemId, "@groupId", groupId);

            return custXml.Root;
        }

        /// <summary>
        /// Converts ItemRelationAttrValue table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="itemRelationId">Id of the <see cref="ItemRelation"/> to search for attributes.</param>
        /// <returns>An &lt;relationAttributes&gt; node containing relation's attributes.</returns>
        private XElement ConvertItemRelationAttributesFromDbToBoXmlFormat(XDocument xml, Guid itemRelationId)
        {
            XElement relationAttributes = new XElement("relationAttributes");

            var attribs = from node in xml.Root.Element("itemRelationAttrValue").Elements()
                          where node.Element("itemRelationId").Value == itemRelationId.ToUpperString()
                          orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                          select node;

            foreach (XElement entry in attribs)
            {
                XElement relationAttribute = new XElement("relationAttribute");
                relationAttributes.Add(relationAttribute);

                foreach (XElement attrElement in entry.Elements())
                {
                    if (attrElement.Name.LocalName != "itemRelationId")
                    {
                        if (!VariableColumnName.IsVariableColumnName(attrElement.Name.LocalName))
                            relationAttribute.Add(attrElement); //auto-cloning
                        else
                        {
                            ItemRelationAttrValueType cf = DictionaryMapper.Instance.GetItemRelationAttrValueType(new Guid(entry.Element("itemRAVTypeId").Value));

                            string dataType = cf.Metadata.Element("dataType").Value;

                            if (dataType != "xml")
                                relationAttribute.Add(new XElement("value", BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(attrElement.Value, dataType)));
                            else
                                relationAttribute.Add(new XElement("value", attrElement.Elements()));
                        }
                    }
                }
            }

            return relationAttributes;
        }

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            if (!obj.IsNew)
            {
                this.ExecuteStoredProcedure(StoredProcedure.item_p_checkItemVersion,
                        false, "@version", obj.Version);
            }
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            Item item = (Item)obj;
            Guid localTransactionId = SessionManager.VolatileElements.LocalTransactionId.Value;
            Guid deferredTransactionId = SessionManager.VolatileElements.DeferredTransactionId.Value;

            this.CreateCommunicationXmlForVersionedBusinessObject(item, localTransactionId, deferredTransactionId, StoredProcedure.communication_p_createItemPackage);
            this.CreateCommunicationXmlForRelatedVersionedItems(item, localTransactionId, deferredTransactionId);
            this.CreateCommunicationXmlForItemRelations(item, localTransactionId, deferredTransactionId);
            this.CreateCommunicationXmlForItemUnitRelations(item, localTransactionId, deferredTransactionId);
            this.CreateCommunicationXmlForItemGroupMemberships(item, localTransactionId, deferredTransactionId);
        }

        /// <summary>
        /// Creates communication xml for item relations of the specified <see cref="Item"/>.
        /// </summary>
        /// <param name="item"><see cref="Item"/> that may contains the item relations.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        private void CreateCommunicationXmlForItemRelations(Item item, Guid localTransactionId, Guid deferredTransactionId)
        {
            XDocument commXml = null;

            if (item.Relations.AlternateVersion != null)
            {
                commXml = this.GenerateCommunicationXmlForRelations(item,
                     BusinessObjectHelper.ConvertToRelation<ICollection<ItemRelation>, ItemRelation>(item.Relations.Children),
                     BusinessObjectHelper.ConvertToRelation<ICollection<ItemRelation>, ItemRelation>(item.Relations.AlternateVersion.Children),
                     localTransactionId, deferredTransactionId);
            }
            else
            {
                commXml = this.GenerateCommunicationXmlForRelations(item,
                     BusinessObjectHelper.ConvertToRelation<ICollection<ItemRelation>, ItemRelation>(item.Relations.Children),
                     null, localTransactionId, deferredTransactionId);
            }

            if (commXml.Root.HasElements)
                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createItemRelationPackage, false, commXml);
        }

        /// <summary>
        /// Creates communication xml for item unit relations of the specified <see cref="Item"/>.
        /// </summary>
        /// <param name="item"><see cref="Item"/> that may contains the item unit relations.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        private void CreateCommunicationXmlForItemUnitRelations(Item item, Guid localTransactionId, Guid deferredTransactionId)
        {
            XDocument commXml = null;

            if (item.Relations.AlternateVersion != null)
            {
                commXml = this.GenerateCommunicationXmlForRelations(item,
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ItemUnitRelation>, ItemUnitRelation>(item.UnitRelations.Children),
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ItemUnitRelation>, ItemUnitRelation>(item.UnitRelations.AlternateVersion.Children),
                     localTransactionId, deferredTransactionId);
            }
            else
            {
                commXml = this.GenerateCommunicationXmlForRelations(item,
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ItemUnitRelation>, ItemUnitRelation>(item.UnitRelations.Children),
                     null, localTransactionId, deferredTransactionId);
            }

            if (commXml.Root.HasElements)
                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createItemUnitRelationPackage, false, commXml);
        }

        public bool CheckItemExistenceInDocuments(Guid itemId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_checkItemExistenceInDocuments, true, "@itemId", itemId);

            return Convert.ToBoolean(xml.Root.Value, CultureInfo.InvariantCulture);
        }

        public XDocument GetItemsByNamufacturerAndCode(XDocument inputXml)
        {
            /*
            <root> 
              <item manufacturer=".." manufacturerCode=".." /> 
              <item manufacturer=".." manufacturerCode=".." /> 
              <item manufacturer=".." manufacturerCode=".." /> 
            ... 
            </root> 
            */

            return this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsByManufacturerAndCode, true, inputXml);
        }

        public XElement GetItemsFiscalNames(ICollection<Guid> itemsId)
        {
            if (itemsId == null || itemsId.Count == 0)
                return null;

            XDocument xml = XDocument.Parse("<root/>");

            foreach (Guid itemId in itemsId)
                xml.Root.Add(new XElement("item", new XAttribute("id", itemId.ToUpperString())));

            xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getFiscalNames, true, xml);

            return xml.Root;
        }

        public XElement GetItemsGroups(ICollection<Guid> items)
        {
            /*
                <root> 
                  <item id="GUID"> 
                    <itemGroupId>...</itemGroupId> 
                    <itemGroupId>...</itemGroupId> 
                  </item> 
                  <item id="GUID"> 
                    <itemGroupId>...</itemGroupId> 
                    <itemGroupId>...</itemGroupId> 
                    <itemGroupId>...</itemGroupId> 
                  </item 
                ... 
                </root> 
            */
            XDocument xml = new XDocument(new XElement("root"));

            foreach (var g in items)
                xml.Root.Add(new XElement("item", new XAttribute("id", g.ToUpperString())));

            xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsGroups, true, xml);

            return xml.Root;
        }

        public int GetItemsCount()
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsCount, true, null);

            int i = Convert.ToInt32(xml.Root.Value, CultureInfo.InvariantCulture);

            return i;
        }

        /// <summary>
        /// Creates communication xml for related versioned items of the specified <see cref="Item"/>.
        /// </summary>
        /// <param name="item"><see cref="Item"/> that may contains the related items.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        private void CreateCommunicationXmlForRelatedVersionedItems(Item item, Guid localTransactionId, Guid deferredTransactionId)
        {
            foreach (ItemRelation relation in item.Relations.Children)
            {
                IVersionedBusinessObject related = relation.RelatedObject as IVersionedBusinessObject;

                if (related != null && (related.Status == BusinessObjectStatus.Modified || related.Status == BusinessObjectStatus.New
                    || related.ForceSave == true))
                {
                    ItemRelationType relationType = DictionaryMapper.Instance.GetItemRelationType(relation.ItemRelationTypeId);

                    string relatedObjectType = relationType.Metadata.Element("relatedObjectType").Value;

                    switch (relatedObjectType)
                    {
                        case "Item":
                            this.CreateCommunicationXmlForVersionedBusinessObject(related, localTransactionId, deferredTransactionId, StoredProcedure.communication_p_createItemPackage);
                            break;
                        case "Contractor":
                            this.CreateCommunicationXmlForVersionedBusinessObject(related, localTransactionId, deferredTransactionId, StoredProcedure.communication_p_createContractorPackage);
                            break;
                    }
                }
            }
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
            Item item = (Item)obj;
            XDocument xml = XDocument.Parse("<root businessObjectId=\"\" mode=\"\" />");

            //update main contractor
            if (item.Status == BusinessObjectStatus.Modified || item.Status == BusinessObjectStatus.New
                || item.ForceSave == true)
            {
                xml.Root.Attribute("businessObjectId").Value = item.Id.ToUpperString();
                xml.Root.Attribute("mode").Value = item.Status == BusinessObjectStatus.New ? "insert" : "update";
				this.ExecuteStoredProcedure(StoredProcedure.item_p_updateItemDictionary, false, xml
					, ConfigurationMapper.Instance.UpdateDictionaryIndexTimeout);
            }

            //update related items
            foreach (ItemRelation relation in item.Relations.Children)
            {
                IVersionedBusinessObject bo = relation.RelatedObject as IVersionedBusinessObject;

                if (bo != null && (bo.Status == BusinessObjectStatus.Modified || bo.Status == BusinessObjectStatus.New
                    || bo.ForceSave == true))
                {
                    xml.Root.Attribute("businessObjectId").Value = bo.Id.ToUpperString();
                    xml.Root.Attribute("mode").Value = bo.Status == BusinessObjectStatus.New ? "insert" : "update";

                    ItemRelationType relationType = DictionaryMapper.Instance.GetItemRelationType(relation.Id.Value);

                    string relatedObjectType = relationType.Metadata.Element("relatedObjectType").Value;

                    switch (relatedObjectType)
                    {
                        case "Item":
                            this.ExecuteStoredProcedure(StoredProcedure.item_p_updateItemDictionary, false, xml
								, ConfigurationMapper.Instance.UpdateDictionaryIndexTimeout);
                            break;
                        case "Contractor":
							this.ExecuteStoredProcedure(StoredProcedure.contractor_p_updateContractorDictionary, false, xml
								, ConfigurationMapper.Instance.UpdateDictionaryIndexTimeout);
                            break;
                    }
                }
            }
        }

        /// <summary>
        /// Creates communication xml for contractor group memberships of the specified <see cref="Item"/>.
        /// </summary>
        /// <param name="item"><see cref="Item"/> that may contains the item group memberships.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        private void CreateCommunicationXmlForItemGroupMemberships(Item item, Guid localTransactionId, Guid deferredTransactionId)
        {
            XDocument commXml = null;

            if (item.GroupMemberships.AlternateVersion != null)
            {
                commXml = this.GenerateCommunicationXmlForRelations(item,
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ItemGroupMembership>, ItemGroupMembership>(item.GroupMemberships.Children),
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ItemGroupMembership>, ItemGroupMembership>(item.GroupMemberships.AlternateVersion.Children),
                     localTransactionId, deferredTransactionId);
            }
            else
            {
                commXml = this.GenerateCommunicationXmlForRelations(item,
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ItemGroupMembership>, ItemGroupMembership>(item.GroupMemberships.Children),
                     null, localTransactionId, deferredTransactionId);
            }

            if (commXml.Root.HasElements)
                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createItemGroupMembershipPackage, false, commXml);
        }

        /// <summary>
        /// Converts a <see cref="BusinessObject"/> from its xml to <see cref="BusinessObject"/> form.
        /// </summary>
        /// <param name="objectXml">Xml rootElement containing <see cref="IBusinessObject"/>.</param>
        /// <param name="options">Xml containing options for the object during save operation.</param>
        /// <returns>
        /// Converted <see cref="IBusinessObject"/>.
        /// </returns>
        public override IBusinessObject ConvertToBusinessObject(XElement objectXml, XElement options)
        {
            Item i = (Item)this.CreateNewBusinessObject(BusinessObjectType.Item, null);
            i.Deserialize(objectXml);

            return i;
        }

        public XDocument GetItemsManufacturerAndCode(ICollection<Guid> items)
        {
            XDocument xml = XDocument.Parse("<root/>");

            foreach (var id in items)
            {
                xml.Root.Add(new XElement("item", new XAttribute("id", id.ToUpperString())));
            }

            return this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsManufacturerAndCode, true, xml);
        }

        public XDocument GetItemsDetailsForDocument(bool getLastPurchasePrice, Guid? documentTypeId, Guid? contractorId, ICollection<Guid> items)
        {
            XDocument xml = XDocument.Parse("<root/>");

            if (contractorId != null)
                xml.Root.Add(new XAttribute("contractorId", contractorId.ToUpperString()));

			if (documentTypeId != null)
				xml.Root.Add(new XAttribute("documentTypeId", documentTypeId.ToUpperString()));

            if (getLastPurchasePrice)
                xml.Root.Add(new XAttribute("lastPurchasePrice", "1"));
            else
                xml.Root.Add(new XAttribute("lastPurchasePrice", "0"));

            foreach (var id in items)
            {
                xml.Root.Add(new XElement("item", new XAttribute("id", id.ToUpperString())));
            }

            xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsDetailsForDocument, true, xml);

            return xml;
        }

        public XDocument GetItemsDetailsForDocumentByItemCode(bool getLastPurchasePrice, Guid? contractorId, ICollection<string> itemsCodes)
        {
            XDocument xml = XDocument.Parse("<root/>");

            if (contractorId != null)
                xml.Root.Add(new XAttribute("contractorId", contractorId.ToUpperString()));

            if (getLastPurchasePrice)
                xml.Root.Add(new XAttribute("lastPurchasePrice", "1"));
            else
                xml.Root.Add(new XAttribute("lastPurchasePrice", "0"));

            foreach (var itemCode in itemsCodes)
            {
                xml.Root.Add(new XElement("item", new XAttribute("code", itemCode)));
            }

            xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsDetailsForDocumentByItemCode, true, xml);

            return xml;
        }

        public XDocument GetItemsByItemCode(ICollection<string> itemsCodes)
        {
            XDocument xml = XDocument.Parse("<root/>");

            foreach (var itemCode in itemsCodes)
            {
                xml.Root.Add(new XElement("item", new XAttribute("code", itemCode)));
            }

            xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsByItemCode, true, xml);

            return xml;
        }

        /// <summary>
        /// Creates communication xml for objects that are in the xml operations list.
        /// </summary>
        /// <param name="operations"></param>
        public override void CreateCommunicationXml(XDocument operations)
        {
            throw new NotImplementedException();
        }
    }
}
