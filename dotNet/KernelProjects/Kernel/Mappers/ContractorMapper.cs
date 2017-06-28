using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class representing a mapper with methods necessary to operate on <see cref="Contractor"/>.
    /// </summary>
    public class ContractorMapper : Mapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorMapper"/> class.
        /// </summary>
        public ContractorMapper()
            : base()
        {}

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
						{ BusinessObjectType.Contractor, typeof(Contractor) },
						{ BusinessObjectType.Bank, typeof(Bank) },
						{ BusinessObjectType.Employee, typeof(Employee) },
						{ BusinessObjectType.ApplicationUser, typeof(ApplicationUser) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { return ContractorMapper.CachedSupportedBusinessObjectTypes; }
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

            switch (type)
            {
                case BusinessObjectType.Contractor:
                    bo = this.CreateNewContractor();
                    break;
                case BusinessObjectType.Bank:
                    bo = new Bank(null);
                    break;
                case BusinessObjectType.Employee:
                    bo = new Employee(null);
                    break;
                case BusinessObjectType.ApplicationUser:
                    bo = new ApplicationUser(null);
                    break;
                default:
                    throw new InvalidOperationException("ContractorMapper can only create contractors/banks/employees.");
            }

            bo.GenerateId();
            return bo;
        }

        public override void DeleteBusinessObject(BusinessObjectType type, Guid id)
        {
            try
            {
                this.ExecuteStoredProcedure(StoredProcedure.contractor_p_deleteContractor, false, "@contractorId", id);
            }
            catch (SqlException ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:120");
                if (ex.Number == 50000)
                    throw new ClientException(ClientExceptionId.ContractorRemovalError);
            }
        }

        public bool CheckContractorCodeExistence(XDocument xml)
        {
            XDocument retXml = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_checkContractorCodeExistence, true, xml);

            return Convert.ToBoolean(retXml.Root.Value, CultureInfo.InvariantCulture);
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
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getContractorData, true, "@contractorId", id);

            if (xdoc.Root.Element("contractor").Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ContractorNotFound);

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, id);

            return this.ConvertToBusinessObject(xdoc.Root.Element("contractor"), null);
        }

		/// <summary>
		/// Loads the <see cref="Contractor"/> with a specified Id.
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		public Contractor LoadBusinessObject(Guid id)
		{
			return (Contractor)this.LoadBusinessObject(BusinessObjectType.Contractor, id);
		}

        public int GetContractorsCount()
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getContractorsCount, true, null);

            int i = Convert.ToInt32(xml.Root.Value, CultureInfo.InvariantCulture);

            return i;
        }

        /// <summary>
        /// Creates a new <see cref="Contractor"/> using default settings.
        /// </summary>
        /// <returns>A new <see cref="Contractor"/>.</returns>
        private Contractor CreateNewContractor()
        {
            Contractor c = new Contractor(null, BusinessObjectType.Contractor);
            return c;
        }

        /// <summary>
        /// Converts Contractor table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Contractor"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertContractorFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("contractor") == null) //jezeli baza nie wczytala w ogole tabeli kontrahentow
            {
                outXml.Root.Element("contractor").Add(new XElement("id", id.ToUpperString()));
                return;
            }

            var mainContractor = from node in xml.Root.Element("contractor").Elements()
                                 where node.Element("id").Value == id.ToUpperString()
                                 select node;

            if (mainContractor.Count() > 0)
            {
                foreach (XElement element in mainContractor.ElementAt(0).Elements())
                {
                    outXml.Root.Element("contractor").Add(element); //auto-cloning
                }

                //set the proper type
                if (outXml.Root.Element("contractor").Attribute("type") == null)
                {
                    outXml.Root.Element("contractor").Add(new XAttribute("type", this.GetContractorType(outXml.Root.Element("contractor"))));
                }
            }
            else
            {
                outXml.Root.Element("contractor").Add(new XElement("id", id.ToUpperString()));
                outXml.Root.Element("contractor").Add(new XAttribute("type", "Contractor"));
            }
        }

        /// <summary>
        /// Converts Bank table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Contractor"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertBankFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("bank") != null)
            {
                var mainBank = from node in xml.Root.Element("bank").Elements()
                               where node.Element("contractorId").Value == id.ToUpperString()
                               select node;

                if (mainBank.Count() > 0)
                {
                    foreach (XElement element in mainBank.ElementAt(0).Elements())
                    {
                        if (element.Name.LocalName != "contractorId" && element.Name.LocalName != "version")
                            outXml.Root.Element("contractor").Add(element); //auto-cloning
                        else if (element.Name.LocalName == "version")
                            outXml.Root.Element("contractor").Add(new XElement("versionBank", element.Value));
                    }

                    outXml.Root.Element("contractor").Attribute("type").Value = "Bank";
                }
            }
        }

        private void ConvertApplicationUserFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("applicationUser") != null)
            {
                var mainApplicationUser = from node in xml.Root.Element("applicationUser").Elements()
                                          where node.Element("contractorId").Value == id.ToUpperString()
                                          select node;

                if (mainApplicationUser.Count() > 0)
                {
                    foreach (XElement element in mainApplicationUser.ElementAt(0).Elements())
                    {
                        if (element.Name.LocalName != "contractorId" && element.Name.LocalName != "version" && element.Name.LocalName != "restrictDatabaseId")
                            outXml.Root.Element("contractor").Add(element); //auto-cloning
                        else if (element.Name.LocalName == "version")
                            outXml.Root.Element("contractor").Add(new XElement("versionApplicationUser", element.Value));
						else if (element.Name.LocalName == "restrictDatabaseId")
							outXml.Root.Element("contractor").Add(new XElement("databaseId", element.Value));
					}

                    outXml.Root.Element("contractor").Attribute("type").Value = "ApplicationUser";
                }
            }
        }

        /// <summary>
        /// Converts Employee table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Contractor"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertEmployeeFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("employee") != null)
            {
                var mainEmployee = from node in xml.Root.Element("employee").Elements()
                                   where node.Element("contractorId").Value == id.ToUpperString()
                                   select node;

                if (mainEmployee.Count() > 0)
                {
                    foreach (XElement element in mainEmployee.ElementAt(0).Elements())
                    {
                        if (element.Name.LocalName != "contractorId" && element.Name.LocalName != "version")
                            outXml.Root.Element("contractor").Add(element); //auto-cloning
                        else if (element.Name.LocalName == "version")
                            outXml.Root.Element("contractor").Add(new XElement("versionEmployee", element.Value));
                    }

                    outXml.Root.Element("contractor").Attribute("type").Value = "Employee";
                }
            }
        }

        /// <summary>
        /// Converts ContractorAddress table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Contractor"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertAddressesFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("contractorAddress") != null)
            {
                XElement addresses = new XElement("addresses");
                outXml.Root.Element("contractor").Add(addresses);
                var elements = from node in xml.Root.Element("contractorAddress").Elements()
                               where node.Element("contractorId").Value == id.ToUpperString()
                               orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                               select node;

                foreach (XElement element in elements)
                {
                    XElement address = new XElement("address");

                    addresses.Add(address);

                    foreach (XElement addrElement in element.Elements())
                    {
                        if (addrElement.Name.LocalName != "contractorId")
                            address.Add(addrElement); //auto-cloning
                    }
                }
            }
        }

        /// <summary>
        /// Converts ContractorRelation table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Contractor"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertRelationsFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("contractorRelation") != null)
            {
                XElement relations = new XElement("relations");
                outXml.Root.Element("contractor").Add(relations);
                var elements = from node in xml.Root.Element("contractorRelation").Elements()
                               where node.Element("contractorId").Value == id.ToUpperString()
                               orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                               select node;

                foreach (XElement element in elements)
                {
                    XElement relation = new XElement("relation");

                    relations.Add(relation);

                    foreach (XElement relElement in element.Elements())
                    {
                        if (relElement.Name.LocalName != "contractorId" && relElement.Name.LocalName != "relatedContractorId")
                            relation.Add(relElement);
                        else if (relElement.Name.LocalName == "relatedContractorId")
                        {
                            XElement relatedContractorElement = new XElement("relatedContractor");
                            relation.Add(relatedContractorElement);
                            XElement contractorElement = new XElement("contractor");
                            relatedContractorElement.Add(contractorElement);

                            //entry element
                            var relatedContractor = from node in xml.Root.Element("contractor").Elements()
                                                    where node.Element("id").Value == relElement.Value
                                                    select node;

                            foreach (XElement contrElement in relatedContractor.ElementAt(0).Elements())
                            {
                                contractorElement.Add(contrElement); //auto-cloning
                            }

                            //set the proper type
                            if (contractorElement.Attribute("type") == null)
                            {
                                contractorElement.Add(new XAttribute("type", this.GetContractorType(contractorElement)));
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Gets the type of the contractor checking its flags.
        /// </summary>
        /// <param name="contractorRootElement">The contractor root element.</param>
        /// <returns>Type of <see cref="Contractor"/>.</returns>
        private string GetContractorType(XElement contractorRootElement)
        {
            string type = null;

            if (contractorRootElement.Element("isEmployee") != null && contractorRootElement.Element("isEmployee").Value == "1")
                type = "Employee";
            else if (contractorRootElement.Element("isBank") != null && contractorRootElement.Element("isBank").Value == "1")
                type = "Bank";
            else if (contractorRootElement.Attribute("type") != null && contractorRootElement.Attribute("type").Value == "ApplicationUser")
                type = "ApplicationUser";
            else
                type = "Contractor";

            return type;
        }

        /// <summary>
        /// Converts ContractorAccount table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Contractor"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertAccountsFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("contractorAccount") != null)
            {
                XElement accounts = new XElement("accounts");
                outXml.Root.Element("contractor").Add(accounts);
                var elements = from node in xml.Root.Element("contractorAccount").Elements()
                               where node.Element("contractorId").Value == id.ToUpperString()
                               orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                               select node;

                foreach (XElement element in elements)
                {
                    XElement account = new XElement("account");
                    accounts.Add(account);

                    foreach (XElement accElement in element.Elements())
                    {
                        if (accElement.Name.LocalName != "contractorId")
                            account.Add(accElement);
                    }
                }
            }
        }

        /// <summary>
        /// Converts ContractorAttrValue table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Contractor"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertAttributesFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (xml.Root.Element("contractorAttrValue") != null)
            {
                XElement attributes = new XElement("attributes");
                outXml.Root.Element("contractor").Add(attributes);
                var elements = from node in xml.Root.Element("contractorAttrValue").Elements()
                               where node.Element("contractorId").Value == id.ToUpperString()
                               orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                               select node;

                foreach (XElement element in elements)
                {
                    XElement attribute = new XElement("attribute");
                    attributes.Add(attribute);

                    foreach (XElement attrElement in element.Elements())
                    {
                        if (attrElement.Name.LocalName != "contractorId")
                        {
                            if (!VariableColumnName.IsVariableColumnName(attrElement.Name.LocalName))
                                attribute.Add(attrElement); //auto-cloning
                            else
                            {
                                ContractorField cf = DictionaryMapper.Instance.GetContractorField(new Guid(element.Element("contractorFieldId").Value));

                                string dataType = cf.Metadata.Element("dataType").Value;

                                if(dataType != "xml")
                                    attribute.Add(new XElement("value", BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(attrElement.Value, dataType)));
                                else
                                    attribute.Add(new XElement("value", attrElement.Elements()));
                            }
                        }
                    }
                }
            }
        }

        internal Contractor GetContractorByNip(string nip)
        {
            XDocument xml = new XDocument(new XElement("root"));
            xml.Root.Add(new XElement("nip", nip));

            xml = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getContractorByNip, true, xml);

            if (!xml.Root.HasElements)
                return null;
            else
            {
                xml = this.ConvertDBToBoXmlFormat(xml, new Guid(xml.Root.Element("contractor").Element("entry").Element("id").Value));
                return (Contractor)this.ConvertToBusinessObject(xml.Root.Element("contractor"), null);
            }
        }

        internal Contractor GetContractorByFullNameAndPostCode(string fullName, string postCode)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("fullName", fullName));
            xml.Root.Add(new XElement("postCode", postCode));

            xml = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getContractorByFullNameAndPostCode, true, xml);

            if (!xml.Root.HasElements)
                return null;
            else
            {
                xml = this.ConvertDBToBoXmlFormat(xml, new Guid(xml.Root.Element("contractor").Element("entry").Element("id").Value));
                return (Contractor)this.ConvertToBusinessObject(xml.Root.Element("contractor"), null);
            }
        }

        internal Contractor GetContractorByFullName(string fullName)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("fullName", fullName));

            xml = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getContractorByFullName, true, xml);

            if (!xml.Root.HasElements)
                return null;
            else
            {
                xml = this.ConvertDBToBoXmlFormat(xml, new Guid(xml.Root.Element("contractor").Element("entry").Element("id").Value));
                return (Contractor)this.ConvertToBusinessObject(xml.Root.Element("contractor"), null);
            }
        }
        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            XDocument convertedXml = XDocument.Parse("<root><contractor /></root>");

            this.ConvertContractorFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertBankFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertEmployeeFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertApplicationUserFromDbToBoXmlFormat(xml, id, convertedXml);
            
            this.ConvertAddressesFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertRelationsFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertAccountsFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertAttributesFromDbToBoXmlFormat(xml, id, convertedXml);

            this.ConvertGroupMembershipsFromDbToBoXmlFormat(xml, id, convertedXml, "contractor");

            return convertedXml;
        }

        /// <summary>
        /// Gets the contractor group memberships count.
        /// </summary>
        /// <param name="contractorGroupId">The contractor group id.</param>
        /// <returns>Number of memberships to the contractor group.</returns>
        public int GetContractorGroupMembershipsCount(Guid contractorGroupId)
        {
            XDocument retXml = this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getContractorGroupMembershipsCount, 
                true, "contractorGroupId", contractorGroupId);

            return Convert.ToInt32(retXml.Root.Value, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            if (!obj.IsNew)
            {
                this.ExecuteStoredProcedure(StoredProcedure.contractor_p_checkContractorVersion,
                        false, "@version", obj.Version);
            }
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
            Contractor contractor = (Contractor)obj;
            XDocument xml = XDocument.Parse("<root businessObjectId=\"\" mode=\"\" />");

            //update main contractor
            if (contractor.Status == BusinessObjectStatus.Modified || contractor.Status == BusinessObjectStatus.New
                || contractor.ForceSave == true)
            {
                xml.Root.Attribute("businessObjectId").Value = contractor.Id.ToUpperString();
                xml.Root.Attribute("mode").Value = contractor.Status == BusinessObjectStatus.New ? "insert" : "update";
                this.ExecuteStoredProcedure(StoredProcedure.contractor_p_updateContractorDictionary, false, xml);
            }

            //update related contractors
            foreach (ContractorRelation cr in contractor.Relations.Children)
            {
                Contractor c = (Contractor)cr.RelatedObject;

                if (c.Status == BusinessObjectStatus.Modified || c.Status == BusinessObjectStatus.New
                    || c.ForceSave == true)
                {
                    xml.Root.Attribute("businessObjectId").Value = c.Id.ToUpperString();
                    xml.Root.Attribute("mode").Value = c.Status == BusinessObjectStatus.New ? "insert" : "update";
                    this.ExecuteStoredProcedure(StoredProcedure.contractor_p_updateContractorDictionary, false, xml);
                }
            }
        }

        /// <summary>
        /// Creates communication xml for related contractors of the specified <see cref="Contractor"/>.
        /// </summary>
        /// <param name="contractor"><see cref="Contractor"/> that may contains the related contractors.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        private void CreateCommunicationXmlForRelatedContractors(Contractor contractor, Guid localTransactionId, Guid deferredTransactionId)
        {
            foreach (ContractorRelation cr in contractor.Relations.Children)
            {
                Contractor c = (Contractor)cr.RelatedObject;

                if (c.Status == BusinessObjectStatus.Modified || c.Status == BusinessObjectStatus.New
                    || c.ForceSave == true)
                {
                    this.CreateCommunicationXmlForVersionedBusinessObject(c, localTransactionId, deferredTransactionId, StoredProcedure.communication_p_createContractorPackage);
                }
            }
        }

        /// <summary>
        /// Creates communication xml for contractor relations of the specified <see cref="Contractor"/>.
        /// </summary>
        /// <param name="contractor"><see cref="Contractor"/> that may contains the contractor relations.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        private void CreateCommunicationXmlForContractorRelations(Contractor contractor, Guid localTransactionId, Guid deferredTransactionId)
        {
            XDocument commXml = null;

            if (contractor.Relations.AlternateVersion != null)
            {
                commXml = this.GenerateCommunicationXmlForRelations(contractor,
                     BusinessObjectHelper.ConvertToRelation<ICollection<ContractorRelation>, ContractorRelation>(contractor.Relations.Children),
                     BusinessObjectHelper.ConvertToRelation<ICollection<ContractorRelation>, ContractorRelation>(contractor.Relations.AlternateVersion.Children),
                     localTransactionId, deferredTransactionId);
            }
            else
            {
                commXml = this.GenerateCommunicationXmlForRelations(contractor,
                     BusinessObjectHelper.ConvertToRelation<ICollection<ContractorRelation>, ContractorRelation>(contractor.Relations.Children),
                     null, localTransactionId, deferredTransactionId);
            }

            if (commXml.Root.HasElements)
                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createContractorRelationPackage, false, commXml);
        }

        /// <summary>
        /// Creates communication xml for contractor group memberships of the specified <see cref="Contractor"/>.
        /// </summary>
        /// <param name="contractor"><see cref="Contractor"/> that may contains the contractor group memberships.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        private void CreateCommunicationXmlForContractorGroupMemberships(Contractor contractor, Guid localTransactionId, Guid deferredTransactionId)
        {
            XDocument commXml = null;

            if (contractor.GroupMemberships.AlternateVersion != null)
            {
                commXml = this.GenerateCommunicationXmlForRelations(contractor,
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ContractorGroupMembership>, ContractorGroupMembership>(contractor.GroupMemberships.Children),
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ContractorGroupMembership>, ContractorGroupMembership>(contractor.GroupMemberships.AlternateVersion.Children),
                     localTransactionId, deferredTransactionId);
            }
            else
            {
                commXml = this.GenerateCommunicationXmlForRelations(contractor,
                     BusinessObjectHelper.ConvertToDictionaryRelation<ICollection<ContractorGroupMembership>, ContractorGroupMembership>(contractor.GroupMemberships.Children),
                     null, localTransactionId, deferredTransactionId);
            }

            if (commXml.Root.HasElements)
                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createContractorGroupMembershipPackage, false, commXml);
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            Contractor contractor = (Contractor)obj;
            Guid localTransactionId = Guid.NewGuid();
            Guid deferredTransactionId = Guid.NewGuid();

            this.CreateCommunicationXmlForVersionedBusinessObject(contractor, localTransactionId, deferredTransactionId, StoredProcedure.communication_p_createContractorPackage);
            this.CreateCommunicationXmlForRelatedContractors(contractor, localTransactionId, deferredTransactionId);
            this.CreateCommunicationXmlForContractorRelations(contractor, localTransactionId, deferredTransactionId);
            this.CreateCommunicationXmlForContractorGroupMemberships(contractor, localTransactionId, deferredTransactionId);
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
