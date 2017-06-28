using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Xml.Linq;
using System.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using System.IO;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Class that coordinates business logic of all lists.
    /// </summary>
    public class ListCoordinator : TypedCoordinator<ListMapper>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ListCoordinator"/> class.
        /// </summary>
        public ListCoordinator() : this(true, true)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ListCoordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        public ListCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<ListMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:31");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        /// <summary>
        /// Gets the documents list using parameters specified in client request.
        /// </summary>
        /// <param name="requestXml">Client parameters for the list.</param>
        /// <returns>Xml containing documents list.</returns>
        public XDocument GetDocuments(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;

            try
            {
                return ((ListMapper)this.Mapper).GetDocuments(requestXml);
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:32");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }

        /// <summary>
        /// Executes custom procedure.
        /// </summary>
        /// <param name="procedureName">Name of the stored procedure to execute.</param>
        /// <param name="parameterXml">The parameter as XML in string datatype.</param>
        /// <returns>Result of the requested stored procedure.</returns>
        public string ExecuteCustomProcedure(string procedureName, string parameterXml, string outputFormat = "xml")
        {
            XDocument clientRequest = XDocument.Parse("<executeCustomProcedure><procedureName/><parameterXml/></executeCustomProcedure>");

            clientRequest.Root.Element("procedureName").Value = procedureName;

            XDocument paramXml = null;

            if (!String.IsNullOrEmpty(parameterXml))
            {
                paramXml = XDocument.Parse(parameterXml);
                clientRequest.Root.Element("parameterXml").Add(paramXml.Root);
            }

            SessionManager.VolatileElements.ClientRequest = clientRequest;

			//Extract timeout (int - number of seconds for procedure to execute) from parameterXml
			XAttribute timeoutAttr = paramXml != null ? paramXml.Root.Attribute(XmlName.Timeout) : null;
			string timeoutParam = timeoutAttr != null ? timeoutAttr.Value : null;
			int? timeout = null;
			if (timeoutParam != null)
			{
				timeout = Convert.ToInt32(timeoutParam);
				//it is meaningless to Db Stored Procedure
				timeoutAttr.Remove();
			}

            try
            {
                if (outputFormat == "xml")
                    return ((ListMapper)this.Mapper).ExecuteCustomProcedure(procedureName, outputFormat, paramXml).ToString(SaveOptions.DisableFormatting);
                else
                    return ((ListMapper)this.Mapper).ExecuteCustomProcedure(procedureName, outputFormat, paramXml).Value;//.ToString(SaveOptions.DisableFormatting);
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:33");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }

        public void ExecuteCustomProcedureString(string procedureName, Guid guidParameter,String parameterName)
        {
            //Wycena pozycji przychodowych na podstawie ceny ostatniego zakupu
            // Zrobiłem tak bo nie znam kernela a nie mamy obecnie kernelowca
            try
            {
                ((ListMapper)this.Mapper).ExecuteCustomProcedureString(procedureName,guidParameter, parameterName);
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:34");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
            
        }

        public Stream ExecuteCustomProcedureStream(string procedureName, string parameter, String parameterName)
        {
            Stream result = null;
            try
            {
                result = ((ListMapper)this.Mapper).ExecuteCustomProcedureStream(procedureName, parameter, parameterName);
            }
            catch (SqlException sqle)
            {
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
            return result;
        }


        /// <summary>
        /// Gets the contractors list using parameters specified in client request.
        /// </summary>
        /// <param name="requestXml">Client parameters for the list.</param>
        /// <returns>Xml containing contractors list.</returns>
        public XDocument GetContractors(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;

            try
            {
                return ((ListMapper)this.Mapper).GetContractors(requestXml);
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:35");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }

        /// <summary>
        /// Gets the items list using parameters specified in client request.
        /// </summary>
        /// <param name="requestXml">Client parameters for the list.</param>
        /// <returns>Xml containing items list.</returns>
        public XDocument GetItems(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;

            try
            {
                return ((ListMapper)this.Mapper).GetItems(requestXml);
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:36");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }

        public XDocument GetProductionItems(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;

            try
            {
                return ((ListMapper)this.Mapper).GetProductionItems(requestXml);
            }
            catch (SqlException sqle)
            {
                //RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:36");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }
        /// <summary>
        /// Gets all dictionaries with filtered language version.
        /// </summary>
        /// <returns>Xml containing dictionaries</returns>
        public XDocument GetDictionaries()
        {
            try
            {
                return DictionaryMapper.Instance.GetDictionaries();
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:37");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }

        /// <summary>
        /// Gets xml containing full data of all own companies.
        /// </summary>
        /// <returns>Xml containing full data of own companies.</returns>
        public XDocument GetOwnCompanies()
        {
            try
            {
                return ((ListMapper)this.Mapper).GetOwnCompanies();
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:39");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }

        /// <summary>
        /// Gets the random contractors.
        /// </summary>
        /// <param name="amount">The amount of contractors to get.</param>
        /// <returns>List of random contractor's full data.</returns>
        public XDocument GetRandomContractors(int amount)
        {
            XDocument xml = ((ListMapper)this.Mapper).GetRandomContractorsId(amount);

            XDocument retXml = XDocument.Parse("<root></root>");

            using (ContractorCoordinator contractorCoordinator = new ContractorCoordinator(false, false))
            {
                foreach (XElement contractorId in xml.Root.Elements())
                {
                    XElement contractorElement = contractorCoordinator.LoadBusinessObject(BusinessObjectType.Contractor, new System.Guid(contractorId.Attribute("id").Value)).Serialize();
                    retXml.Root.Add(contractorElement);
                }
            }

            return retXml;
        }

        /// <summary>
        /// Gets the random keywords collection for the specified business object type.
        /// </summary>
        /// <param name="type">The type of business object to get the keywords for.</param>
        /// <param name="amount">The amount of random keywords to get.</param>
        /// <returns>List of random item keywords.</returns>
        public XDocument GetRandomBusinessObjectKeywords(BusinessObjectType type, int amount)
        {
            return ((ListMapper)this.Mapper).GetRandomBusinessObjectKeywords(type, amount);
        }

        /// <summary>
        /// Gets the random warehouse document lines.
        /// </summary>
        /// <param name="amount">The amount of warehouse document lines to get.</param>
        /// <returns>List of random document lines.</returns>
        public XDocument GetRandomWarehouseDocumentLines(int amount)
        {
            XDocument xml = ((ListMapper)this.Mapper).GetRandomDocumentLines(amount);

            Random r = new Random();

            foreach (XElement line in xml.Root.Elements())
            {
                line.Element("itemName").Remove();
                line.Element("itemVersion").Remove();

                line.Add(new XElement("quantity", r.Next(50) + 1));
                line.Add(new XElement("price", r.Next(100) + 1));
                line.Add(new XElement("value", r.Next(50) + 1));
                line.Add(new XElement("direction", -1));
                line.Add(new XElement("warehouseId", "A4CCB6BE-ED7F-4B39-8F6F-7A492D71CD45")); //TODO: zrobic wczytywanie domyslnego magazynu skads
                line.Add(new XElement("unitId", "2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C")); //TODO: zrobic wczytywanie domyslnej jednostki
            }

            return xml;
        }

        public override XDocument LoadBusinessObjectForPrinting(XDocument requestXml, string customLabelsLanguage)
        {
            if (requestXml.Root.Element("storedProcedure") != null)
            {
                DictionaryMapper.Instance.CheckForChanges();
                XDocument retXml = DependencyContainerManager.Container.Get<DocumentMapper>().LoadBusinessObjectForPrinting(requestXml.Root.Element("storedProcedure").Value, requestXml.Root.Element("id").Value);

                BusinessObjectHelper.GetPrintXml(retXml, customLabelsLanguage);
                return retXml;
            }
            else
                return base.LoadBusinessObjectForPrinting(requestXml, customLabelsLanguage);
        }

        /// <summary>
        /// Gets the random commercial document lines.
        /// </summary>
        /// <param name="amount">The amount of commercial document lines to get.</param>
        /// <returns>List of random document lines.</returns>
        public XDocument GetRandomCommercialDocumentLines(int amount)
        {
            XDocument xml = ((ListMapper)this.Mapper).GetRandomDocumentLines(amount);

            Random r = new Random();

            Guid warehouseId = DictionaryMapper.Instance.GetFirstWarehouseByBranchId(SessionManager.User.BranchId).Id.Value;

            foreach (XElement line in xml.Root.Elements())
            {
                line.Add(new XElement("quantity", r.Next(3) + 1));
                line.Add(new XElement("netPrice", r.Next(100) + 1));
                line.Add(new XElement("grossPrice", r.Next(50) + 1));
                line.Add(new XElement("initialNetPrice", r.Next(50) + 1));
                line.Add(new XElement("initialGrossPrice", r.Next(50) + 1));
                line.Add(new XElement("discountRate", r.Next(50) + 1));
                line.Add(new XElement("discountNetValue", r.Next(50) + 1));
                line.Add(new XElement("discountGrossValue", r.Next(50) + 1));
                line.Add(new XElement("initialNetValue", r.Next(50) + 1));
                line.Add(new XElement("initialGrossValue", r.Next(50) + 1));
                line.Add(new XElement("netValue", r.Next(50) + 1));
                line.Add(new XElement("grossValue", r.Next(50) + 1));
                line.Add(new XElement("vatValue", r.Next(50) + 1));
                line.Add(new XElement("warehouseId", warehouseId.ToUpperString()));
                line.Add(new XElement("vatRateId", "F8D50E4D-066E-4F0A-BD58-C2BC708BEB0F")); //TODO: pobieranie domyslnej stawki VAT dla towaru
                line.Add(new XElement("unitId", "2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C")); //TODO: pobieranie domyslnej jednostki dla towaru
                line.Add(new XElement("commercialWarehouseRelations"));
                line.Add(new XElement("commercialWarehouseValuations"));
            }

            return xml;
        }

        /// <summary>
        /// Gets xml containing list of all file descriptors.
        /// </summary>
        /// <returns>Xml containing list of all file descriptors.</returns>
        public XDocument GetFileDescriptors()
        {
            try
            {
                return ((ListMapper)this.Mapper).GetFileDescriptors();
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:40");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Custom, this.CanCommitTransaction);
                throw;
            }
        }

        public XDocument GetPermissionProfiles()
        {
            XDocument xml = XDocument.Parse("<root></root>");

            ICollection<Configuration> profiles = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "permissions.profiles.*");

            foreach (Configuration conf in profiles)
            {
                XElement profile = new XElement("permissionProfile");
                profile.Add(new XAttribute("id", conf.Key.Substring(21)));
                profile.Add(new XAttribute("label", BusinessObjectHelper.GetXmlLabelInUserLanguage(conf.Value.Element("labels")).Value));
                xml.Root.Add(profile);
            }

            return xml;
        }

        /// <summary>
        /// Gets the templates of all document types.
        /// </summary>
        /// <returns>Templates list.</returns>
        public XDocument GetTemplates()
        {
            XDocument xml = XDocument.Parse("<root><warehouseDocument/><salesDocument/><purchaseDocument/><orderDocument/><financialDocument/><salesOrderDocument/><item/><contractor/><serviceDocument/><complaintDocument/><inventoryDocument/><technologyDocument/><productionOrderDocument/></root>");

            BusinessObjectType[] types = new BusinessObjectType[] { BusinessObjectType.WarehouseDocument, 
                BusinessObjectType.CommercialDocument, BusinessObjectType.FinancialDocument,
                BusinessObjectType.Item, BusinessObjectType.Contractor, BusinessObjectType.ServiceDocument,
                BusinessObjectType.ComplaintDocument, BusinessObjectType.InventoryDocument};

            DictionaryMapper.Instance.CheckForChanges();

            foreach (BusinessObjectType type in types)
            {
                if (!ConfigurationMapper.Instance.Templates.ContainsKey(type))
                    continue;

                foreach (string templateName in ConfigurationMapper.Instance.Templates[type].Keys)
                {
                    XElement fullTemplate = ConfigurationMapper.Instance.Templates[type][templateName];

                    if (fullTemplate.Element("visible") != null && fullTemplate.Element("visible").Value.ToUpperInvariant() == "FALSE")
                        continue;


                    XElement labelsElement =  fullTemplate.Element("labels");
                    string Lang = fullTemplate.Element("labels").Elements().Aggregate("", (b, node) => b += ";"+ node.Value.ToString() );

                    XElement template = new XElement("template",
                        new XAttribute("id", templateName),
                        new XAttribute("label", BusinessObjectHelper.GetXmlLabelInUserLanguage(fullTemplate.Element("labels")).Value),
                        new XAttribute("labelEn", Lang), //preferredLang.FirstOrDefault().ToString()
                        new XAttribute("icon", fullTemplate.Element("icon").Value));

                    if (fullTemplate.Element("isDefault") != null && fullTemplate.Element("isDefault").Value.ToUpperInvariant() == "TRUE")
                        template.Add(new XAttribute("isDefault", "true"));

                    DocumentCategory? dc = null;
                    XElement documentTypeIdElement = ((XElement)fullTemplate.FirstNode).Element("documentTypeId");

                    if (documentTypeIdElement != null)
                    {
                        template.Add(new XAttribute("documentTypeId", documentTypeIdElement.Value));
                        Guid documentTypeId = new Guid(documentTypeIdElement.Value);
						DocumentType dt = DictionaryMapper.Instance.GetDocumentType(documentTypeId);
						if (dt == null)
							throw new ArgumentException(String.Format("Invalid documentTypeId: {0} in template: {1}", documentTypeId.ToUpperString(), templateName));
                        dc = dt.DocumentCategory;
                    }

                    if (dc == DocumentCategory.Sales)
                        xml.Root.Element("salesDocument").Add(template);
                    else if (dc == DocumentCategory.Purchase)
                        xml.Root.Element("purchaseDocument").Add(template);
                    else if (dc == DocumentCategory.Warehouse)
                        xml.Root.Element("warehouseDocument").Add(template);
                    else if (dc == DocumentCategory.Order || dc == DocumentCategory.Reservation)
                        xml.Root.Element("orderDocument").Add(template);
                    else if (dc == DocumentCategory.Financial)
                        xml.Root.Element("financialDocument").Add(template);
                    else if (dc == DocumentCategory.Service)
                        xml.Root.Element("serviceDocument").Add(template);
                    else if (dc == DocumentCategory.Complaint)
                        xml.Root.Element("complaintDocument").Add(template);
                    else if (dc == DocumentCategory.Inventory)
                        xml.Root.Element("inventoryDocument").Add(template);
                    else if (dc == DocumentCategory.SalesOrder)
                        xml.Root.Element("salesOrderDocument").Add(template);
                    else if (dc == DocumentCategory.Technology)
                        xml.Root.Element("technologyDocument").Add(template);
                    else if (dc == DocumentCategory.ProductionOrder)
                        xml.Root.Element("productionOrderDocument").Add(template);
                    else if (dc == null)
                        xml.Root.Element(type.ToString().Decapitalize()).Add(template);
                }
            }

            return xml;
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="Coordinator"/> and optionally releases the managed resources.
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
