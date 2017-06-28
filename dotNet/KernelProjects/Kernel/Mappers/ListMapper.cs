using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons.Collections;
using Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class representing a mapper with methods necessary to operate on lists (e.g. contractors list, items list, documents list).
    /// </summary>
    public class ListMapper : Mapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ListMapper"/> class.
        /// </summary>
        public ListMapper()
            : base()
        { }

        /// <summary>
        /// Gets the documents list using parameters specified in client request.
        /// </summary>
        /// <param name="xml">Parameters for the stored procedure.</param>
        /// <returns>Xml containing documents list.</returns>
        public XDocument GetDocuments(XDocument xml)
        {
            if (xml.Root.Attribute("type") == null)
                throw new System.IO.InvalidDataException("Missing type element.");

            BusinessObjectType type;
            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), xml.Root.Attribute("type").Value, true);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:123");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + xml.Root.Attribute("type").Value);
            }

			if (this.SupportedBusinessObjectsTypes.Contains(type))
			{
				DatabaseMappingCache dbCache = BusinessObject.ClassDatabaseMappingCache[this.SupportedBusinessObjectsTypes[type]][0];
				if (dbCache.Attribute.List != StoredProcedure.Unknown)
				{
					return this.ExecuteStoredProcedure(dbCache.Attribute.List, true, xml);
				}
			}

			throw new ClientException(ClientExceptionId.UnsupportedBusinessObjectType, null, "objType:" + xml.Root.Attribute("type").Value);
		}

        /// <summary>
        /// Gets the contractors list using parameters specified in client request.
        /// </summary>
        /// <param name="xml">Parameters for the stored procedure.</param>
        /// <returns>Xml containing contractors list.</returns>
        public XDocument GetContractors(XDocument xml)
        {
            return this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getContractors, true, xml);
        }

        /// <summary>
        /// Gets the items list using parameters specified in client request.
        /// </summary>
        /// <param name="xml">Parameters for the stored procedure.</param>
        /// <returns>Xml containing items list.</returns>
        public XDocument GetItems(XDocument xml)
        {
            return this.ExecuteStoredProcedure(StoredProcedure.item_p_getItems, true, xml);
        }

        public XDocument GetProductionItems(XDocument xml)
        {//document_p_getProductionItems
            return this.ExecuteStoredProcedure(StoredProcedure.document_p_getProductionItems, true, xml);
        }

        /// <summary>
        /// Gets xml containing list of all file descriptors.
        /// </summary>
        /// <returns>Xml containing list of all file descriptors.</returns>
        public XDocument GetFileDescriptors()
        {
            return this.ExecuteStoredProcedure(StoredProcedure.repository_p_getFileDescriptors, true, null);
        }

        /// <summary>
        /// Gets the random contractor's id.
        /// </summary>
        /// <param name="amount">The amount of id to get.</param>
        /// <returns>List of random contractor's id.</returns>
        public XDocument GetRandomContractorsId(int amount)
        {
            XDocument xml = XDocument.Parse("<root amount=\"" + amount.ToString(CultureInfo.InvariantCulture) + "\" />");

            return this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getRandomContractors, true, xml);
        }

        /// <summary>
        /// Gets the random document lines.
        /// </summary>
        /// <param name="amount">The amount of document lines to get.</param>
        /// <returns>List of random document lines.</returns>
        public XDocument GetRandomDocumentLines(int amount)
        {
            XDocument xml = XDocument.Parse("<root amount=\"" + amount.ToString(CultureInfo.InvariantCulture) + "\" />");

            return this.ExecuteStoredProcedure(StoredProcedure.item_p_getRandomLines, true, xml);
        }

        /// <summary>
        /// Gets xml containing full data of all own companies.
        /// </summary>
        /// <returns>Xml containing full data of own companies.</returns>
        public XDocument GetOwnCompanies()
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getOwnCompanies, true, null);

            ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
            XDocument retXml = XDocument.Parse("<root />");

            var ownCompaniesId = from entry in xml.Root.Element("contractor").Elements()
                                 where entry.Element("isOwnCompany").Value == "1"
                                 select new Guid(entry.Element("id").Value);

            foreach (Guid id in ownCompaniesId)
            {
                XElement contractorElement = contractorMapper.ConvertDBToBoXmlFormat(xml, id).Root.Element("contractor");

                retXml.Root.Add(contractorElement);
            }

            return retXml;
        }

        /// <summary>
        /// Gets the random keywords collection for the specified business object type.
        /// </summary>
        /// <param name="type">The type of business object to get the keywords for.</param>
        /// <param name="amount">The amount of random keywords to get.</param>
        /// <returns>List of random keywords.</returns>
        public XDocument GetRandomBusinessObjectKeywords(BusinessObjectType type, int amount)
        {
            XDocument xml = XDocument.Parse("<root amount=\"" + amount.ToString(CultureInfo.InvariantCulture) + "\" />");

            StoredProcedure sp;

            if (type == BusinessObjectType.Item)
                sp = StoredProcedure.item_p_getRandomKeywords;
            else if (type == BusinessObjectType.Contractor)
                sp = StoredProcedure.contractor_p_getRandomKeywords;
            else
                throw new NotSupportedException("Object type not supported");

            xml = this.ExecuteStoredProcedure(sp, true, xml);

            return xml;
        }

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            throw new NotSupportedException();
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
            throw new NotSupportedException();
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            throw new NotSupportedException();
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            throw new NotSupportedException();
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
            CustomBusinessObject list = new CustomBusinessObject(new XElement(objectXml));
            
            if (objectXml.Element("id") != null)
            {
                list.Id = new Guid(objectXml.Element("id").Value);
                list.Version = list.Id;
            }
            
            return list;
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
            throw new NotSupportedException();
        }

        /// <summary>
        /// Creates communication xml for objects that are in the xml operations list.
        /// </summary>
        /// <param name="operations"></param>
        public override void CreateCommunicationXml(XDocument operations)
        {
            throw new NotImplementedException();
        }

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
						{ BusinessObjectType.CommercialDocument, typeof(Makolab.Fractus.Kernel.BusinessObjects.Documents.CommercialDocument) },
						{ BusinessObjectType.WarehouseDocument, typeof(Makolab.Fractus.Kernel.BusinessObjects.Documents.WarehouseDocument) },
						{ BusinessObjectType.FinancialDocument, typeof(Makolab.Fractus.Kernel.BusinessObjects.Documents.FinancialDocument) },
						{ BusinessObjectType.FinancialReport, typeof(Makolab.Fractus.Kernel.BusinessObjects.Finances.FinancialReport) },
						{ BusinessObjectType.ServiceDocument, typeof(Makolab.Fractus.Kernel.BusinessObjects.Service.ServiceDocument) },
						{ BusinessObjectType.ComplaintDocument, typeof(Makolab.Fractus.Kernel.BusinessObjects.Documents.ComplaintDocument) },
						{ BusinessObjectType.InventoryDocument, typeof(Makolab.Fractus.Kernel.BusinessObjects.Documents.InventoryDocument) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { return ListMapper.CachedSupportedBusinessObjectTypes; }
		}

		#endregion
	}
}
