using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Globalization;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Commons.Collections;
using System.IO;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Base class for all Mappers. Contains basic fields and methods that every mapper needs.
    /// </summary>
    public abstract class Mapper
    {
        public const string P_Id = "@id";

        /// <summary>
        /// Initializes a new instance of the <see cref="Mapper"/> class.
        /// </summary>
        protected Mapper()
        {
        }

        public abstract BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes { get; }

        public bool SupportsType(Type type)
        {
            return this.SupportedBusinessObjectsTypes.Contains(type);
        }

        public BusinessObjectType GetBusinessObjectTypeName(Type type)
        {
            return this.SupportedBusinessObjectsTypes.Contains(type) ? this.SupportedBusinessObjectsTypes[type] : BusinessObjectType.Other;
        }

        public Type GetType(BusinessObjectType typeName)
        {
            return this.SupportedBusinessObjectsTypes.Contains(typeName) ? this.SupportedBusinessObjectsTypes[typeName] : typeof(IBusinessObject);
        }

        /// <summary>
        /// Gets the proper mapper for the specified business object type.
        /// </summary>
        /// <param name="type">The type of business object.</param>
        /// <returns><see cref="Mapper"/> for the specified BusinessObjectType.</returns>
        public static Mapper GetMapperForSpecifiedBusinessObjectType(BusinessObjectType type)
        {
            Mapper mapper = null;

            switch (type)
            {
                case BusinessObjectType.CustomXmlList:
                    mapper = DependencyContainerManager.Container.Get<ListMapper>();
                    break;
                case BusinessObjectType.Bank:
                case BusinessObjectType.Contractor:
                case BusinessObjectType.Employee:
                case BusinessObjectType.ApplicationUser:
                    mapper = DependencyContainerManager.Container.Get<ContractorMapper>();
                    break;
                case BusinessObjectType.Item:
                    mapper = DependencyContainerManager.Container.Get<ItemMapper>();
                    break;
                case BusinessObjectType.FileDescriptor:
                    mapper = DependencyContainerManager.Container.Get<RepositoryMapper>();
                    break;
                case BusinessObjectType.CommercialDocument:
                case BusinessObjectType.WarehouseDocument:
                case BusinessObjectType.FinancialDocument:
                case BusinessObjectType.FinancialReport:
                case BusinessObjectType.Payment:
                case BusinessObjectType.ServiceDocument:
                case BusinessObjectType.ComplaintDocument:
                case BusinessObjectType.InventoryDocument:
                case BusinessObjectType.InventorySheet:
                    mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
                    break;
                case BusinessObjectType.Configuration:
                    mapper = DependencyContainerManager.Container.Get<ConfigurationMapper>();
                    break;
                case BusinessObjectType.ContractorField:
                case BusinessObjectType.ContractorRelationType:
                case BusinessObjectType.Country:
                case BusinessObjectType.Currency:
                case BusinessObjectType.DocumentField:
                case BusinessObjectType.DocumentType:
                case BusinessObjectType.IssuePlace:
                case BusinessObjectType.ItemField:
                case BusinessObjectType.ItemRelationAttrValueType:
                case BusinessObjectType.ItemRelationType:
                case BusinessObjectType.ItemType:
                case BusinessObjectType.MimeType:
                case BusinessObjectType.OfferStatus:
                case BusinessObjectType.PaymentMethod:
                case BusinessObjectType.Repository:
                case BusinessObjectType.Unit:
                case BusinessObjectType.UnitType:
                case BusinessObjectType.VatRate:
                case BusinessObjectType.JobPosition:
                case BusinessObjectType.VatRegister:
                case BusinessObjectType.FinancialRegister:
                case BusinessObjectType.ContainerType:
                case BusinessObjectType.ServicePlace:
                    mapper = DependencyContainerManager.Container.Get<DictionaryMapper>();
                    break;
                case BusinessObjectType.ShiftTransaction:
                case BusinessObjectType.Container:
                    mapper = DependencyContainerManager.Container.Get<WarehouseMapper>();
                    break;
                case BusinessObjectType.ServicedObject:
                    mapper = DependencyContainerManager.Container.Get<ServiceMapper>();
                    break;
            }

            return mapper;
        }

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public abstract void CheckBusinessObjectVersion(IBusinessObject obj);

        /// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public abstract IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml);

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id.
        /// </summary>
        /// <param name="type">Type of <see cref="BusinessObject"/> to load.</param>
        /// <param name="id"><see cref="IBusinessObject"/>'s id indicating which <see cref="BusinessObject"/> to load.</param>
        /// <returns>Loaded <see cref="IBusinessObject"/> object.</returns>
        public abstract IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id);

        /// <summary>
        /// Loads the <see cref="BusinessObject"/>s with a specified Ids.
        /// </summary>
        /// <typeparam name="T">Type of <see cref="BusinessObject"/> that implements <see cref="IBusinessObject"/> to load.</typeparam>
        /// <param name="type">Type of <see cref="BusinessObject"/> to load.</param>
        /// <param name="ids"><see cref="IBusinessObject"/>'s ids indicating which <see cref="BusinessObject"/>s to load.</param>
        /// <returns>Loaded <see cref="IBusinessObject"/> objects list.</returns>
        public List<T> LoadBusinessObjects<T>(BusinessObjectType type, List<Guid> ids) where T : IBusinessObject
        {
            List<T> result = new List<T>();
            foreach (Guid id in ids)
            {
                result.Add((T)this.LoadBusinessObject(type, id));
            }
            return result;
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public abstract void CreateCommunicationXml(IBusinessObject obj);

        /// <summary>
        /// Creates communication xml for objects that are in the xml operations list.
        /// </summary>
        /// <param name="obj">Xml operations list containing all objects changes.</param>
        public abstract void CreateCommunicationXml(XDocument operations);

        protected void CreateCommunicationXmlForVersionedBusinessObject(IVersionedBusinessObject businessObject, Guid localTransactionId, Guid deferredTransactionId, StoredProcedure communicationProcedure)
        {
            this.CreateCommunicationXmlForVersionedBusinessObject(businessObject, localTransactionId, deferredTransactionId, communicationProcedure, null);
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IVersionedBusinessObject"/> without his children.
        /// </summary>
        /// <param name="businessObject"><see cref="IVersionedBusinessObject"/> for which to generate the communication xml.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        /// <param name="communicationProcedure">StoredProcedure to generate the package.</param>
        protected void CreateCommunicationXmlForVersionedBusinessObject(IVersionedBusinessObject businessObject, Guid localTransactionId, Guid deferredTransactionId, StoredProcedure communicationProcedure, string packageName)
        {
            if (businessObject.Status == BusinessObjectStatus.Modified || businessObject.Status == BusinessObjectStatus.New
                || businessObject.ForceSave == true || businessObject.AlternateVersion.Status == BusinessObjectStatus.Modified)
            {
                XDocument commXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<root businessObjectId=\"{0}\" localTransactionId=\"{1}\" deferredTransactionId=\"{2}\" databaseId=\"{3}\" />",
                    businessObject.Id.ToUpperString(), localTransactionId.ToUpperString(), deferredTransactionId.ToUpperString(),
                    ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

                if (!String.IsNullOrEmpty(packageName))
                    commXml.Root.Add(new XAttribute("packageName", packageName));

                if (!businessObject.IsNew)
                    commXml.Root.Add(new XAttribute("previousVersion", businessObject.Version.ToUpperString()));

                this.ExecuteStoredProcedure(communicationProcedure, false, commXml);
            }
        }

        /// <summary>
        /// Deletes business object.
        /// </summary>
        /// <param name="type">Type of <see cref="BusinessObject"/> to delete.</param>
        /// <param name="id">Id of the object to delete.</param>
        public virtual void DeleteBusinessObject(BusinessObjectType type, Guid id)
        {
            throw new InvalidOperationException("This business object does not support delete operation.");
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public abstract XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id);

        /// <summary>
        /// Converts a <see cref="BusinessObject"/> from its xml to <see cref="BusinessObject"/> form.
        /// </summary>
        /// <param name="objectXml">Xml rootElement containing <see cref="IBusinessObject"/>.</param>
        /// <param name="options">Xml containing options for the object during save operation.</param>
        /// <returns>Converted <see cref="IBusinessObject"/>.</returns>
        public virtual IBusinessObject ConvertToBusinessObject(XElement objectXml, XElement options)
        {
            BusinessObjectType type;

            try
            {
                string name = null;

                if (objectXml.Attribute("type") != null)
                    name = objectXml.Attribute("type").Value;
                else
                    name = objectXml.Name.LocalName;

                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), name, true);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:124");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + objectXml.Attribute("type").Value);
            }

            IBusinessObject bo = this.CreateNewBusinessObject(type, null);
            bo.Deserialize(objectXml);

            return bo;
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public abstract void UpdateDictionaryIndex(IBusinessObject obj);

        /// <summary>
        /// Processes operations only for tables from <c>Repository</c> schema.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessRepositoryTables(XDocument operations)
        {
            XElement table = operations.Root.Element("fileDescriptor");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.repository_p_insertFileDescriptor, StoredProcedure.repository_p_updateFileDescriptor, null);
        }

        private void ProcessRepositoryTablesDeletes(XDocument operations)
        {
            XElement table = operations.Root.Element("fileDescriptor");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.repository_p_deleteFileDescriptor);
        }

        /// <summary>
        /// Processes operations only for tables from <c>Configuration</c> schema.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessConfigurationTables(XDocument operations)
        {
            XElement table = operations.Root.Element("configuration");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.configuration_p_insertConfiguration, StoredProcedure.configuration_p_updateConfiguration, null);
        }

        private void ProcessWarehouseTables(XDocument operations)
        {
            this.ProcessTables(operations, new Type[] {
				typeof(ShiftTransaction),
				typeof(Shift),
				typeof(ShiftAttrValue),
				typeof(ContainerShift),
				typeof(Container)
			});

            //XElement table = operations.Root.Element("shiftTransaction");

            //if (table != null)
            //    this.ProcessTable(table, StoredProcedure.warehouse_p_insertShiftTransaction, StoredProcedure.warehouse_p_updateShiftTransaction, null);

            //table = operations.Root.Element("shift");

            //if (table != null)
            //    this.ProcessTable(table, StoredProcedure.warehouse_p_insertShift, StoredProcedure.warehouse_p_updateShift, null);

            //table = operations.Root.Element("shiftAttrValue");

            //if (table != null)
            //    this.ProcessTable(table, StoredProcedure.warehouse_p_insertShiftAttrValue, StoredProcedure.warehouse_p_updateShiftAttrValue, null);

            //table = operations.Root.Element("containerShift");

            //if (table != null)
            //    this.ProcessTable(table, StoredProcedure.warehouse_p_insertContainerShift, StoredProcedure.warehouse_p_updateContainerShift, null);

            //table = operations.Root.Element("container");

            //if (table != null)
            //    this.ProcessTable(table, StoredProcedure.warehouse_p_insertContainer, StoredProcedure.warehouse_p_updateContainer, null);
        }

        private void ProcessWarehouseTablesDeletes(XDocument operations)
        {
            XElement table = null;

            table = operations.Root.Element("shiftAttrValue");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.warehouse_p_deleteShiftAttrValue);

            table = operations.Root.Element("shift");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.warehouse_p_deleteShift);
        }

        private void ProcessComplaintTablesDeletes(XDocument operations)
        {
            XElement table = null;

            table = operations.Root.Element("complaintDecision");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.complaint_p_deleteComplaintDecision);

            table = operations.Root.Element("complaintDocumentLine");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.complaint_p_deleteComplaintDocumentLine);
        }

        /// <summary>
        /// Processes operations only for tables from <c>Dictionary</c> schema.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessDictionaryTables(XDocument operations)
        {
            XElement table = operations.Root.Element("configurationKey");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertConfigurationKey, StoredProcedure.dictionary_p_updateConfigurationKey, null);

            table = operations.Root.Element("contractorField");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertContractorField, StoredProcedure.dictionary_p_updateContractorField, null);

            table = operations.Root.Element("contractorRelationType");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertContractorRelationType, StoredProcedure.dictionary_p_updateContractorRelationType, null);

            table = operations.Root.Element("country");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertCountry, StoredProcedure.dictionary_p_updateCountry, null);

            table = operations.Root.Element("currency");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertCurrency, StoredProcedure.dictionary_p_updateCurrency, null);

            table = operations.Root.Element("documentField");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertDocumentField, StoredProcedure.dictionary_p_updateDocumentField, null);

            table = operations.Root.Element("documentFieldRelation");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertDocumentFieldRelation, StoredProcedure.dictionary_p_updateDocumentFieldRelation, null);

            table = operations.Root.Element("documentType");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertDocumentType, StoredProcedure.dictionary_p_updateDocumentType, null);

            table = operations.Root.Element("issuePlace");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertIssuePlace, StoredProcedure.dictionary_p_updateIssuePlace, null);

            table = operations.Root.Element("itemField");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertItemField, StoredProcedure.dictionary_p_updateItemField, null);

            table = operations.Root.Element("itemRelationAttrValueType");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertItemRelationAttrValueType, StoredProcedure.dictionary_p_updateItemRelationAttrValueType, null);

            table = operations.Root.Element("itemRelationType");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertItemRelationType, StoredProcedure.dictionary_p_updateItemRelationType, null);

            table = operations.Root.Element("itemType");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertItemType, StoredProcedure.dictionary_p_updateItemType, null);

            table = operations.Root.Element("jobPosition");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertJobPosition, StoredProcedure.dictionary_p_updateJobPosition, null);

            table = operations.Root.Element("mimeType");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertMimeType, StoredProcedure.dictionary_p_updateMimeType, null);

            table = operations.Root.Element("paymentMethod");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertPaymentMethod, StoredProcedure.dictionary_p_updatePaymentMethod, null);

            table = operations.Root.Element("repository");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertRepository, StoredProcedure.dictionary_p_updateRepository, null);

            table = operations.Root.Element("unit");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertUnit, StoredProcedure.dictionary_p_updateUnit, null);

            table = operations.Root.Element("unitType");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertUnitType, StoredProcedure.dictionary_p_updateUnitType, null);

            table = operations.Root.Element("vatRate");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertVatRate, StoredProcedure.dictionary_p_updateVatRate, null);

            table = operations.Root.Element("shiftField");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertShiftField, StoredProcedure.dictionary_p_updateShiftField, null);

            table = operations.Root.Element("servicePlace");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.dictionary_p_insertServicePlace, StoredProcedure.dictionary_p_updateServicePlace, null);
        }

        /// <summary>
        /// Processes operations only for tables from <c>Contractor</c> schema.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessContractorTables(XDocument operations)
        {
            XElement table = operations.Root.Element("contractor");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.contractor_p_insertContractor, StoredProcedure.contractor_p_updateContractor, null);

            if ((table = operations.Root.Element("bank")) != null)
                this.ProcessTable(table, StoredProcedure.contractor_p_insertBank, StoredProcedure.contractor_p_updateBank, null);

            if ((table = operations.Root.Element("employee")) != null)
                this.ProcessTable(table, StoredProcedure.contractor_p_insertEmployee, StoredProcedure.contractor_p_updateEmployee, null);

            if ((table = operations.Root.Element("applicationUser")) != null)
                this.ProcessTable(table, StoredProcedure.contractor_p_insertApplicationUser, StoredProcedure.contractor_p_updateApplicationUser, null);

            if ((table = operations.Root.Element("contractorAccount")) != null)
                this.ProcessTable(table, StoredProcedure.contractor_p_insertContractorAccount, StoredProcedure.contractor_p_updateContractorAccount, null);

            if ((table = operations.Root.Element("contractorAddress")) != null)
                this.ProcessTable(table, StoredProcedure.contractor_p_insertContractorAddress, StoredProcedure.contractor_p_updateContractorAddress, null);

            if ((table = operations.Root.Element("contractorAttrValue")) != null)
                this.ProcessTable(table, StoredProcedure.contractor_p_insertContractorAttrValue, StoredProcedure.contractor_p_updateContractorAttrValue, null);

            if ((table = operations.Root.Element("contractorGroupMembership")) != null)
                this.ProcessRelationTable(table, StoredProcedure.contractor_p_insertContractorGroupMembership, StoredProcedure.contractor_p_updateContractorGroupMembership,
                    null, StoredProcedure.contractor_p_setContractorVersion);

            if ((table = operations.Root.Element("contractorRelation")) != null)
                this.ProcessRelationTable(table, StoredProcedure.contractor_p_insertContractorRelation, StoredProcedure.contractor_p_updateContractorRelation,
                    null, StoredProcedure.contractor_p_setContractorVersion);
        }

        private void ProcessContractorTablesDeletes(XDocument operations)
        {
            XElement table = null;

            if ((table = operations.Root.Element("contractorAccount")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.contractor_p_deleteContractorAccount);

            if ((table = operations.Root.Element("contractorAddress")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.contractor_p_deleteContractorAddress);

            if ((table = operations.Root.Element("contractorAttrValue")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.contractor_p_deleteContractorAttrValue);

            if ((table = operations.Root.Element("contractorGroupMembership")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.contractor_p_deleteContractorGroupMembership);

            if ((table = operations.Root.Element("contractorRelation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.contractor_p_deleteContractorRelation);
        }

        /// <summary>
        /// Processes operations only for tables from <c>Document</c> schema.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessDocumentTables(XDocument operations)
        {
            XElement table = operations.Root.Element("commercialDocumentHeader");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertCommercialDocumentHeader, StoredProcedure.document_p_updateCommercialDocumentHeader, null);

            if ((table = operations.Root.Element("warehouseDocumentHeader")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertWarehouseDocumentHeader, StoredProcedure.document_p_updateWarehouseDocumentHeader, null);

            if ((table = operations.Root.Element("commercialDocumentLine")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertCommercialDocumentLine, StoredProcedure.document_p_updateCommercialDocumentLine, null);

            if ((table = operations.Root.Element("warehouseDocumentLine")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertWarehouseDocumentLine, StoredProcedure.document_p_updateWarehouseDocumentLine, null);

            if ((table = operations.Root.Element("commercialDocumentVatTable")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertCommercialDocumentVatTable, StoredProcedure.document_p_updateCommercialDocumentVatTable, null);

            if ((table = operations.Root.Element("financialDocumentHeader")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertFinancialDocumentHeader, StoredProcedure.document_p_updateFinancialDocumentHeader, null);

            if ((table = operations.Root.Element("inventoryDocumentHeader")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertInventoryDocumentHeader, StoredProcedure.document_p_updateInventoryDocumentHeader, null);

            if ((table = operations.Root.Element("inventorySheet")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertInventorySheet, StoredProcedure.document_p_updateInventorySheet, null);

            if ((table = operations.Root.Element("inventorySheetLine")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertInventorySheetLine, StoredProcedure.document_p_updateInventorySheetLine, null);

            if ((table = operations.Root.Element("documentAttrValue")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertDocumentAttrValue, StoredProcedure.document_p_updateDocumentAttrValue, null);

            if ((table = operations.Root.Element("documentLineAttrValue")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertDocumentLineAttrValue, StoredProcedure.document_p_updateDocumentLineAttrValue, null);

            if ((table = operations.Root.Element("incomeOutcomeRelation")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertIncomeOutcomeRelation, StoredProcedure.document_p_updateIncomeOutcomeRelation, null);

            if ((table = operations.Root.Element("commercialWarehouseValuation")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertCommercialWarehouseValuation, StoredProcedure.document_p_updateCommercialWarehouseValuation, null);

            if ((table = operations.Root.Element("commercialWarehouseRelation")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertCommercialWarehouseRelation, StoredProcedure.document_p_updateCommercialWarehouseRelation, null);

            if ((table = operations.Root.Element("warehouseDocumentValuation")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertWarehouseDocumentValuation, StoredProcedure.document_p_updateWarehouseDocumentValuation, null);
        }

        private void ProcessComplaintTables(XDocument operations)
        {
            XElement table = operations.Root.Element("complaintDocumentHeader");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.complaint_p_insertComplaintDocumentHeader, StoredProcedure.complaint_p_updateComplaintDocumentHeader, null);

            if ((table = operations.Root.Element("complaintDocumentLine")) != null)
                this.ProcessTable(table, StoredProcedure.complaint_p_insertComplaintDocumentLine, StoredProcedure.complaint_p_updateComplaintDocumentLine, null);

            if ((table = operations.Root.Element("complaintDecision")) != null)
                this.ProcessTable(table, StoredProcedure.complaint_p_insertComplaintDecision, StoredProcedure.complaint_p_updateComplaintDecision, null);
        }

        private void ProcessDocumentTablesDeletes(XDocument operations)
        {
            XElement table = null;

            if ((table = operations.Root.Element("documentRelation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteDocumentRelation);

            if ((table = operations.Root.Element("documentLineAttrValue")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteDocumentLineAttrValue);

            if ((table = operations.Root.Element("incomeOutcomeRelation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteIncomeOutcomeRelation);

            if ((table = operations.Root.Element("commercialWarehouseValuation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteCommercialWarehouseValuation);

            if ((table = operations.Root.Element("commercialWarehouseRelation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteCommercialWarehouseRelation);

            if ((table = operations.Root.Element("warehouseDocumentValuation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteWarehouseDocumentValuation);

            if ((table = operations.Root.Element("commercialDocumentLine")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteCommercialDocumentLine);

            if ((table = operations.Root.Element("warehouseDocumentLine")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteWarehouseDocumentLine);

            if ((table = operations.Root.Element("commercialDocumentVatTable")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteCommercialDocumentVatTable);

            if ((table = operations.Root.Element("documentAttrValue")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteDocumentAttrValue);

            if ((table = operations.Root.Element("inventorySheetLine")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.document_p_deleteInventorySheetLine);
        }

        /// <summary>
        /// Processes operations only for tables from <c>Finance</c> schema.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessFinanceTables(XDocument operations)
        {
            XElement table = operations.Root.Element("payment");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.finance_p_insertPayment, StoredProcedure.finance_p_updatePayment, null);

            if ((table = operations.Root.Element("financialReport")) != null)
                this.ProcessTable(table, StoredProcedure.finance_p_insertFinancialReport, StoredProcedure.finance_p_updateFinancialReport, null);

            if ((table = operations.Root.Element("paymentSettlement")) != null)
                this.ProcessTable(table, StoredProcedure.finance_p_insertPaymentSettlement, StoredProcedure.finance_p_updatePaymentSettlement, null);

            if ((table = operations.Root.Element("documentRelation")) != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertDocumentRelation, StoredProcedure.document_p_updateDocumentRelation, null);
        }

        private void ProcessFinanceTablesDeletes(XDocument operations)
        {
            XElement table = null;

            if ((table = operations.Root.Element("paymentSettlement")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.finance_p_deletePaymentSettlement);

            if ((table = operations.Root.Element("payment")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.finance_p_deletePayment);
        }

        private void ProcessTables(XDocument operations, params Type[] types)
        {
            XElement table = null;

            foreach (Type type in types)
            {
                foreach (DatabaseMappingCache mapping in BusinessObject.ClassDatabaseMappingCache[type])
                {
                    if ((table = operations.Root.Element(mapping.Attribute.TableName)) != null)
                        this.ProcessTable(table, mapping.Attribute.Insert, mapping.Attribute.Update, null);
                }
            }
        }

        private void ProcessTablesDeletes(XDocument operations, params Type[] types)
        {
            XElement table = null;

            foreach (Type type in types)
            {
                foreach (DatabaseMappingCache mapping in BusinessObject.ClassDatabaseMappingCache[type])
                {
                    if ((table = operations.Root.Element(mapping.Attribute.TableName)) != null)
                        this.ProcessTable(table, null, null, mapping.Attribute.Delete);
                }
            }
        }

        /// <summary>
        /// Processes operations only for tables from <c>Item</c> schema.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessItemTables(XDocument operations, ref dynamic doubleDeletePreventHelper)
        {
            //this.ProcessTables(operations, new Type[] {
            //    typeof( Item);
            //});

            XElement table = operations.Root.Element("item");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.item_p_insertItem, StoredProcedure.item_p_updateItem, null);

            if ((table = operations.Root.Element("itemUnitRelation")) != null)
                this.ProcessRelationTable(table, StoredProcedure.item_p_insertItemUnitRelation, StoredProcedure.item_p_updateItemUnitRelation, null, StoredProcedure.item_p_setItemVersion);

            if ((table = operations.Root.Element("itemRelation")) != null)
                this.ProcessItemRelationTable(table, ref doubleDeletePreventHelper);

            if ((table = operations.Root.Element("itemRelationAttrValue")) != null)
                this.ProcessTable(table, StoredProcedure.item_p_insertItemRelationAttrValue, StoredProcedure.item_p_updateItemRelationAttrValue, null);

            if ((table = operations.Root.Element("itemAttrValue")) != null)
                this.ProcessTable(table, StoredProcedure.item_p_insertItemAttrValue, StoredProcedure.item_p_updateItemAttrValue, null);

            if ((table = operations.Root.Element("itemGroupMembership")) != null)
                this.ProcessRelationTable(table, StoredProcedure.item_p_insertItemGroupMembership, StoredProcedure.item_p_updateItemGroupMembership,
                    null, StoredProcedure.item_p_setItemVersion);
        }

        private void ProcessItemTablesDeletes(XDocument operations, ref dynamic doubleDeletePreventHelper)
        {
            XElement table = null;

            if ((table = operations.Root.Element("itemRelationAttrValue")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.item_p_deleteItemRelationAttrValue);

            if ((table = operations.Root.Element("itemUnitRelation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.item_p_deleteItemUnitRelation);

            if ((table = operations.Root.Element("itemRelation")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.item_p_deleteItemRelation, ref doubleDeletePreventHelper);

            if ((table = operations.Root.Element("itemAttrValue")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.item_p_deleteItemAttrValue);

            if ((table = operations.Root.Element("itemGroupMembership")) != null)
                this.ProcessTable(table, null, null, StoredProcedure.item_p_deleteItemGroupMembership);
        }

        /// <summary>
        /// Processes item relation table.
        /// </summary>
        /// <param name="table">Xml element containing item relation table.</param>
        private void ProcessItemRelationTable(XElement table, ref dynamic doubleDeletePreventHelper)
        {
            //CHYBA BŁĄD, nie zawsze jest tylko jedna relacja
            foreach (XElement entry in table.Elements())
            {
                XElement object1from = entry.Element("_object1from");
                XElement object1to = entry.Element("_object1to");
                XElement object2from = entry.Element("_object2from");
                XElement object2to = entry.Element("_object2to");

                if (object1from != null)
                {
                    this.ExecuteStoredProcedure(StoredProcedure.item_p_setItemVersion, false,
                    "@oldVersion", new Guid(object1from.Value), "@newVersion", new Guid(object1to.Value));
                }

                if (object2from != null && entry.Element("itemRelationTypeId") != null)
                {
                    string relationTypeId = entry.Element("itemRelationTypeId").Value;
                    StoredProcedure? sp = null;

                    ItemRelationType type = DictionaryMapper.Instance.GetItemRelationType(new Guid(relationTypeId));

                    switch (type.Metadata.Element("relatedObjectType").Value)
                    {
                        case "Item":
                            sp = StoredProcedure.item_p_setItemVersion;
                            break;
                        case "Contractor":
                            sp = StoredProcedure.contractor_p_setContractorVersion;
                            break;
                    }

                    this.ExecuteStoredProcedure(sp.Value, false, "@oldVersion", new Guid(object2from.Value), "@newVersion", new Guid(object2to.Value));
                }
            }
            this.ProcessTable(table, StoredProcedure.item_p_insertItemRelation, StoredProcedure.item_p_updateItemRelation, StoredProcedure.item_p_deleteItemRelation, ref doubleDeletePreventHelper);

        }

        /// <summary>
        /// Executes custom procedure.
        /// </summary>
        /// <param name="procedureName">Name of the stored procedure to execute.</param>
        /// <param name="firstParamName">The name of first parameter.</param>
        /// <param name="firstParamValue">The value of first parameter.</param>
        /// <returns>Result of the requested stored procedure.</returns>
        public XDocument ExecuteCustomProcedure(string procedureName, string firstParamName, Guid? firstParamValue)
        {
            SqlCommand command = SqlConnectionManager.Instance.Command;
            command.CommandText = procedureName;
            command.Parameters.Clear();
            XmlReader r = null;

            if (firstParamName != null)
            {
                SqlParameter param = command.Parameters.Add(firstParamName, SqlDbType.UniqueIdentifier);
                SqlGuid sqlGuid = new SqlGuid(firstParamValue.Value);
                param.SqlValue = sqlGuid;
            }

            r = command.ExecuteXmlReader();
            XDocument retXml = XDocument.Load(r);
            r.Close();

            return retXml;
        }

        /// <summary>
        /// Executes custom procedure.
        /// </summary>
        /// <param name="procedureName">Name of the stored procedure to execute.</param>
        /// <param name="parameterXml">The parameter as XML.</param>
        /// <returns>Result of the requested stored procedure.</returns>

        public XElement ExecuteCustomProcedure(string procedureName, XDocument parameterXml)
        {
            return this.ExecuteCustomProcedure(procedureName, parameterXml, null);
        }

        public XElement ExecuteCustomProcedure(string procedureName, string outputFormat, XDocument parameterXml)
        {
            return this.ExecuteCustomProcedure(procedureName, true, parameterXml, true, null, outputFormat);
        }

        public XElement ExecuteCustomProcedure(string procedureName, XDocument parameterXml, int? timeout)
        {
            return this.ExecuteCustomProcedure(procedureName, true, parameterXml, false, timeout);
        }

        public XElement ExecuteCustomProcedure(string procedureName, bool hasResult, XDocument parameterXml, bool skipUserId)
        {
            return this.ExecuteCustomProcedure(procedureName, hasResult, parameterXml, skipUserId, null);
        }
        public Stream ExecuteCustomProcedureStream(string procedureName, String parameter, String parmeterName)
         {

          Stream result = null;
          using (SqlConnection connection = new SqlConnection(SqlConnectionManager.Instance.Command.Connection.ConnectionString))
            {
                connection.Open();
                SqlCommand command = SqlConnectionManager.Instance.Command;
                
                    
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Clear();
                    command.Parameters.Add("@commercialDocumentHeaderId", SqlDbType.UniqueIdentifier).Value = new Guid(parameter);
                    using (SqlDataReader reader = command.ExecuteReader(CommandBehavior.SingleRow))
                    {
                        if (reader.Read())
                        {
                            int dataID = reader.GetOrdinal("Data");
                            if (reader[dataID] != DBNull.Value)
                            {
                                result = new MemoryStream(reader.GetSqlBinary(dataID).Value);
                            }
                        }
                    }
                
            }
            return result;
            }

        public void ExecuteCustomProcedureString(string procedureName, Guid parameter, String parmeterName)
        {
            //Wycena pozycji przychodowych na podstawie ceny ostatniego zakupu
            // Zrobiłem tak bo nie znam kernela a nie mamy obecnie kernelowca
            SqlCommand command = SqlConnectionManager.Instance.Command;
            command.CommandTimeout = ConfigurationMapper.Instance.GlobalSqlCommandTimeout;
            command.CommandText = procedureName;
            command.Parameters.Clear();
            command.Parameters.AddWithValue(parmeterName, parameter);
            command.ExecuteNonQuery();
        }


        public XElement ExecuteCustomProcedure(string procedureName, bool hasResult, XDocument parameterXml, bool skipUserId, int? timeout, string outputFormat = "xml")
        {
            SqlCommand command = SqlConnectionManager.Instance.Command;
            command.CommandTimeout = timeout ?? ConfigurationMapper.Instance.GlobalSqlCommandTimeout;
            command.CommandText = procedureName;
            command.Parameters.Clear();
            XmlReader r = null;
            SqlDataReader t;

            if (parameterXml != null)
            {
                if (!skipUserId)
                    parameterXml.Root.Add(new XAttribute("applicationUserId", SessionManager.User.UserId.ToUpperString()));

                SqlParameter param = command.Parameters.Add("@xmlVar", SqlDbType.Xml);
                r = parameterXml.CreateReader();
                SqlXml sqlXml = new SqlXml(r);
                r.Close();

                param.SqlValue = sqlXml;
            }

            if (hasResult)
            {
                //r = command.ExecuteXmlReader();
                //XDocument retXml = XDocument.Load(r);
                //r.Close();

                XDocument retXml = new XDocument();
                XDocument wrapperXml = XDocument.Parse("<root/>");

                switch (outputFormat)
                {
                    case "xml":
                        r = command.ExecuteXmlReader();
                        retXml = XDocument.Load(r);
                        r.Close();
                        break;
                    case "csv":
                        t = command.ExecuteReader();
                        wrapperXml.Element("root").SetValue(Csv.Load(t));
                        retXml = wrapperXml;
                        t.Close();
                        break;
                }

                if (timeout.HasValue)
                    command.ResetCommandTimeout();

                return retXml.Root;
            }
            else
            {
                command.ExecuteNonQuery();

                if (timeout.HasValue)
                    command.ResetCommandTimeout();

                return null;
            }
        }

        /// <summary>
        /// Processes operations only for tables from document.Series table.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        private void ProcessSeriesTable(XDocument operations)
        {
            XElement table = operations.Root.Element("series");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.document_p_insertSeries, StoredProcedure.document_p_insertSeries, null);
        }

        private void ProcessServiceTables(XDocument operations)
        {
            XElement table = operations.Root.Element("serviceHeader");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.service_p_insertServiceHeader, StoredProcedure.service_p_updateServiceHeader, null);

            table = operations.Root.Element("serviceHeaderEmployees");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.service_p_insertServiceHeaderEmployees, StoredProcedure.service_p_updateServiceHeaderEmployees, null);

            table = operations.Root.Element("serviceHeaderServicedObjects");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.service_p_insertServiceHeaderServicedObjects, StoredProcedure.service_p_updateServiceHeaderServicedObjects, null);

            table = operations.Root.Element("serviceHeaderServicePlace");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.service_p_insertServiceHeaderServicePlace, StoredProcedure.service_p_updateServiceHeaderServicePlace, null);

            table = operations.Root.Element("servicedObject");

            if (table != null)
                this.ProcessTable(table, StoredProcedure.service_p_insertServicedObject, StoredProcedure.service_p_updateServicedObject, null);
        }

        private void ProcessServiceTablesDeletes(XDocument operations)
        {
            XElement table = null;

            table = operations.Root.Element("serviceHeaderEmployees");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.service_p_deleteServiceHeaderEmployees);

            table = operations.Root.Element("serviceHeaderServicedObjects");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.service_p_deleteServiceHeaderServicedObjects);

            table = operations.Root.Element("serviceHeaderServicePlace");

            if (table != null)
                this.ProcessTable(table, null, null, StoredProcedure.service_p_deleteServiceHeaderServicePlace);
        }

        /// <summary>
        /// Executes operations list.
        /// </summary>
        /// <param name="operations">Xml document containing operations list.</param>
        public virtual void ExecuteOperations(XDocument operations)
        {
            dynamic doubleDeletePreventHelper = new List<string>();

            //deletes
            this.ProcessContractorTablesDeletes(operations);
            this.ProcessItemTablesDeletes(operations, ref doubleDeletePreventHelper);
            this.ProcessRepositoryTablesDeletes(operations);
            this.ProcessDocumentTablesDeletes(operations);
            this.ProcessServiceTablesDeletes(operations);
            this.ProcessFinanceTablesDeletes(operations);
            this.ProcessWarehouseTablesDeletes(operations);
            this.ProcessComplaintTablesDeletes(operations);

            //inserts & updates
            this.ProcessSeriesTable(operations);
            this.ProcessContractorTables(operations);
            this.ProcessItemTables(operations, ref doubleDeletePreventHelper);
            this.ProcessRepositoryTables(operations);
            this.ProcessDocumentTables(operations);
            this.ProcessComplaintTables(operations);
            this.ProcessServiceTables(operations);
            this.ProcessFinanceTables(operations);
            this.ProcessConfigurationTables(operations);
            this.ProcessDictionaryTables(operations);
            this.ProcessWarehouseTables(operations);
        }

        /// <summary>
        /// Converts generic group memberships table from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        /// <param name="groupPrefixName">Name of the group prefix and also main business object name, e.g. contractor, item.</param>
        protected void ConvertGroupMembershipsFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml, string groupPrefixName)
        {
            if (xml.Root.Element(groupPrefixName + "GroupMembership") != null)
            {
                XElement groupMemberships = new XElement("groupMemberships");
                outXml.Root.Element(groupPrefixName).Add(groupMemberships);
                var elements = from node in xml.Root.Element(groupPrefixName + "GroupMembership").Elements()
                               where node.Element(groupPrefixName + "Id").Value == id.ToUpperString()
                               select node;

                foreach (XElement element in elements)
                {
                    XElement groupMembership = new XElement("groupMembership");
                    groupMemberships.Add(groupMembership);

                    foreach (XElement grpElement in element.Elements())
                    {
                        if (grpElement.Name.LocalName != (groupPrefixName + "Id"))
                            groupMembership.Add(grpElement);
                    }
                }
            }
        }

        /// <summary>
        /// Process a relation table from xml operations list and changes version of the business objects if <c>object1from</c>... <c>object2to</c> nodes are present.
        /// </summary>
        /// <param name="table">Xml element containing operations for the relation table.</param>
        /// <param name="insertProcedure">Procedure that inserts rows in the table.</param>
        /// <param name="updateProcedure">Procedure that updates rows in the table.</param>
        /// <param name="deleteProcedure">Optional procedure that deletes rows in the table.</param>
        /// <param name="setVersionProcedure">Procedure that sets version of the <see cref="BusinessObject"/>.</param>
        private void ProcessRelationTable(XElement table, StoredProcedure? insertProcedure, StoredProcedure? updateProcedure, StoredProcedure? deleteProcedure, StoredProcedure setVersionProcedure)
        {
            this.ProcessTable(table, insertProcedure, updateProcedure, deleteProcedure);

            foreach (XElement entry in table.Elements())
            {
                XElement object1from = entry.Element("_object1from");
                XElement object1to = entry.Element("_object1to");

                XElement object2from = entry.Element("_object2from");
                XElement object2to = entry.Element("_object2to");

                if (object1from != null && object1to != null)
                {
                    this.ExecuteStoredProcedure(setVersionProcedure, false,
                        "@oldVersion", new Guid(object1from.Value), "@newVersion", new Guid(object1to.Value));
                }

                if (object2from != null && object2to != null)
                {
                    this.ExecuteStoredProcedure(setVersionProcedure, false,
                        "@oldVersion", new Guid(object2from.Value), "@newVersion", new Guid(object2to.Value));
                }
            }
        }

        /// <summary>
        /// Generates communication xml for <see cref="IBusinessObjectRelation"/>s.
        /// </summary>
        /// <param name="businessObject"><see cref="IVersionedBusinessObject"/> that may contains <see cref="IBusinessObjectRelation"/>.</param>
        /// <param name="relations">Container of the <see cref="IBusinessObjectRelation"/>s.</param>
        /// <param name="alternateRelations">Alternate container of the <see cref="IBusinessObjectRelation"/>s.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        /// <returns>Generated communication Xml.</returns>
        protected XDocument GenerateCommunicationXmlForRelations(IVersionedBusinessObject businessObject, ICollection<IBusinessObjectRelation> relations, ICollection<IBusinessObjectRelation> alternateRelations, Guid localTransactionId, Guid deferredTransactionId)
        {
            XDocument commXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<root localTransactionId=\"{0}\" deferredTransactionId=\"{1}\" databaseId=\"{2}\"></root>",
                    localTransactionId.ToUpperString(), deferredTransactionId.ToUpperString(),
                    ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

            //search for modified and new relations
            foreach (IBusinessObjectRelation rel in relations)
            {
                if (rel.Status == BusinessObjectStatus.Modified || rel.Status == BusinessObjectStatus.New)
                {
                    XElement entry = XElement.Parse(String.Format(CultureInfo.InvariantCulture, "<entry id=\"{0}\" />", rel.Id.ToUpperString()));
                    commXml.Root.Add(entry);

                    if (rel.UpgradeMainObjectVersion)
                    {
                        entry.Add(new XAttribute("_object1from", businessObject.Version.ToUpperString()));
                        entry.Add(new XAttribute("_object1to", businessObject.NewVersion.ToUpperString()));
                    }

                    if (rel.UpgradeRelatedObjectVersion)
                    {
                        entry.Add(new XAttribute("_object2from", rel.RelatedObject.Version.ToUpperString()));
                        entry.Add(new XAttribute("_object2to", ((IVersionedBusinessObject)rel.RelatedObject).NewVersion.ToUpperString()));
                    }

                    if (rel.Status == BusinessObjectStatus.Modified)
                        entry.Add(new XAttribute("previousVersion", rel.Version.ToUpperString()));
                }
            }

            //search for deleted relations
            if (businessObject.AlternateVersion != null)
            {
                foreach (IBusinessObjectRelation rel in alternateRelations)
                {
                    if (rel.Status == BusinessObjectStatus.Deleted)
                    {
                        XElement entry = XElement.Parse(String.Format(CultureInfo.InvariantCulture,
                            "<entry id=\"{0}\" version=\"{1}\" action=\"delete\" />", rel.Id.ToUpperString(), rel.Version.ToUpperString()));

                        commXml.Root.Add(entry);

                        if (rel.UpgradeMainObjectVersion)
                        {
                            entry.Add(new XAttribute("_object1from", businessObject.Version.ToUpperString()));
                            entry.Add(new XAttribute("_object1to", businessObject.NewVersion.ToUpperString()));
                        }

                        if (rel.UpgradeRelatedObjectVersion)
                        {
                            //current relation is attached to the OLD version so we have to switch to the new version via the AlternateVersion property
                            entry.Add(new XAttribute("_object2from", rel.RelatedObject.AlternateVersion.Version.ToUpperString()));
                            entry.Add(new XAttribute("_object2to", ((IVersionedBusinessObject)rel.RelatedObject.AlternateVersion).NewVersion.ToUpperString()));
                        }
                    }
                }
            }

            return commXml;
        }

        /// <summary>
        /// Generates communication xml for <see cref="IBusinessObjectDictionaryRelation"/>s.
        /// </summary>
        /// <param name="businessObject"><see cref="IVersionedBusinessObject"/> that may contains <see cref="IBusinessObjectRelation"/>.</param>
        /// <param name="relations">Container of the <see cref="IBusinessObjectDictionaryRelation"/>s.</param>
        /// <param name="alternateRelations">Alternate container of the <see cref="IBusinessObjectDictionaryRelation"/>s.</param>
        /// <param name="localTransactionId">Local transaction ID.</param>
        /// <param name="deferredTransactionId">Deferred transaction ID.</param>
        /// <returns>Generated communication Xml.</returns>
        protected XDocument GenerateCommunicationXmlForRelations(IVersionedBusinessObject businessObject, ICollection<IBusinessObjectDictionaryRelation> relations, ICollection<IBusinessObjectDictionaryRelation> alternateRelations, Guid localTransactionId, Guid deferredTransactionId)
        {
            XDocument commXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<root localTransactionId=\"{0}\" deferredTransactionId=\"{1}\" databaseId=\"{2}\"></root>",
                    localTransactionId.ToUpperString(), deferredTransactionId.ToUpperString(),
                    ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

            //search for modified and new relations
            foreach (IBusinessObjectDictionaryRelation rel in relations)
            {
                if (rel.Status == BusinessObjectStatus.Modified || rel.Status == BusinessObjectStatus.New)
                {
                    XElement entry = XElement.Parse(String.Format(CultureInfo.InvariantCulture, "<entry id=\"{0}\" />", rel.Id.ToUpperString()));
                    commXml.Root.Add(entry);

                    if (rel.UpgradeMainObjectVersion)
                    {
                        entry.Add(new XAttribute("_object1from", businessObject.Version.ToUpperString()));
                        entry.Add(new XAttribute("_object1to", businessObject.NewVersion.ToUpperString()));
                    }

                    if (rel.Status == BusinessObjectStatus.Modified)
                        entry.Add(new XAttribute("previousVersion", rel.Version.ToUpperString()));
                }
            }

            //search for deleted relations
            if (businessObject.AlternateVersion != null)
            {
                foreach (IBusinessObjectDictionaryRelation rel in alternateRelations)
                {
                    if (rel.Status == BusinessObjectStatus.Deleted)
                    {
                        XElement entry = XElement.Parse(String.Format(CultureInfo.InvariantCulture,
                            "<entry id=\"{0}\" version=\"{1}\" action=\"delete\" />", rel.Id.ToUpperString(), rel.Version.ToUpperString()));

                        if (rel.BOType == BusinessObjectType.ItemGroupMembership)
                            entry.Add(new XAttribute("itemId", ((ItemGroupMembership)rel).ItemId.ToUpperString()));

                        commXml.Root.Add(entry);

                        if (rel.UpgradeMainObjectVersion)
                        {
                            entry.Add(new XAttribute("_object1from", businessObject.Version.ToUpperString()));
                            entry.Add(new XAttribute("_object1to", businessObject.NewVersion.ToUpperString()));
                        }
                    }
                }
            }

            return commXml;
        }

        /// <summary>
        /// Process one table from xml operations list.
        /// </summary>
        /// <param name="tableElement">Xml element containing operations for one table.</param>
        /// <param name="insertProcedure">Procedure that inserts rows in the table.</param>
        /// <param name="updateProcedure">Procedure that updates rows in the table.</param>
        /// <param name="deleteProcedure">Optional procedure that deletes rows in the table.</param>
        protected void ProcessTable(XElement tableElement, StoredProcedure? insertProcedure, StoredProcedure? updateProcedure, StoredProcedure? deleteProcedure)
        {
            string tableName = tableElement.Name.LocalName;

            //document used for communicating with database
            XDocument document = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                "<root localTransactionId=\"{0}\" deferredTransactionId=\"{1}\" databaseId=\"{2}\"><{3}/></root>",
                SessionManager.VolatileElements.LocalTransactionId.ToUpperString(),
                SessionManager.VolatileElements.DeferredTransactionId.ToUpperString(),
                ConfigurationMapper.Instance.DatabaseId.ToUpperString(),
                tableName));

            //deletes
            if (deleteProcedure != null)
            {
                var deletes = from node in tableElement.Elements()
                              where node.Attribute("action").Value == "delete"
                              select node;

                if (deletes.Count() > 0)
                {
                    document.Root.Element(tableName).Add(deletes); //auto-cloning
                    this.ExecuteStoredProcedure(deleteProcedure.Value, false, document);
                }
            }

            //inserts
            if (insertProcedure != null)
            {
                var inserts = from node in tableElement.Elements()
                              where node.Attribute("action").Value == "insert"
                              select node;

                if (inserts.Count() > 0)
                {
                    //delete deletes
                    document.Root.Element(tableName).RemoveAll();
                    document.Root.Element(tableName).Add(inserts); //auto-cloning
                    this.ExecuteStoredProcedure(insertProcedure.Value, false, document);
                }
            }

            //updates
            if (updateProcedure != null)
            {
                var updates = from node in tableElement.Elements()
                              where node.Attribute("action").Value == "update"
                              select node;

                if (updates.Count() > 0)
                {
                    //delete inserts
                    document.Root.Element(tableName).RemoveAll();
                    document.Root.Element(tableName).Add(updates); //auto-cloning
                    this.ExecuteStoredProcedure(updateProcedure.Value, false, document);
                }
            }
        }

        /// <summary>
        /// Process one table from xml operations list.
        /// </summary>
        /// <param name="tableElement">Xml element containing operations for one table.</param>
        /// <param name="insertProcedure">Procedure that inserts rows in the table.</param>
        /// <param name="updateProcedure">Procedure that updates rows in the table.</param>
        /// <param name="deleteProcedure">Optional procedure that deletes rows in the table.</param>
        protected void ProcessTable(XElement tableElement, StoredProcedure? insertProcedure, StoredProcedure? updateProcedure, StoredProcedure? deleteProcedure, ref dynamic doubleDeletePreventHelper)
        {
            string tableName = tableElement.Name.LocalName;

            //document used for communicating with database
            XDocument document = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                "<root localTransactionId=\"{0}\" deferredTransactionId=\"{1}\" databaseId=\"{2}\"><{3}/></root>",
                SessionManager.VolatileElements.LocalTransactionId.ToUpperString(),
                SessionManager.VolatileElements.DeferredTransactionId.ToUpperString(),
                ConfigurationMapper.Instance.DatabaseId.ToUpperString(),
                tableName));

            //deletes
            if (deleteProcedure != null)
            {
                var deletes = from node in tableElement.Elements()
                              where node.Attribute("action").Value == "delete"
                              select node;

                if (deletes.Count() > 0)
                {
                    document.Root.Element(tableName).Add(deletes); //auto-cloning
                    this.ExecuteStoredProcedure(deleteProcedure.Value, false, document, ref doubleDeletePreventHelper);
                }
            }

            //inserts
            if (insertProcedure != null)
            {
                var inserts = from node in tableElement.Elements()
                              where node.Attribute("action").Value == "insert"
                              select node;

                if (inserts.Count() > 0)
                {
                    //delete deletes
                    document.Root.Element(tableName).RemoveAll();
                    document.Root.Element(tableName).Add(inserts); //auto-cloning
                    this.ExecuteStoredProcedure(insertProcedure.Value, false, document);
                }
            }

            //updates
            if (updateProcedure != null)
            {
                var updates = from node in tableElement.Elements()
                              where node.Attribute("action").Value == "update"
                              select node;

                if (updates.Count() > 0)
                {
                    //delete inserts
                    document.Root.Element(tableName).RemoveAll();
                    document.Root.Element(tableName).Add(updates); //auto-cloning
                    this.ExecuteStoredProcedure(updateProcedure.Value, false, document);
                }
            }
        }


        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="firstParamName">Parameter's name.</param>
        /// <param name="firstParamValue">Parameter's value.</param>
        /// <returns>Xml procedure's result.</returns>
        public XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue)
        {
            return this.ExecuteStoredProcedure(procedure, hasResult, firstParamName, firstParamValue, null);
        }

        public XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, int? timeout)
        {
            return this.ExecuteStoredProcedure(procedure, hasResult, firstParamName, firstParamValue, null, null, timeout);
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="firstParamName">First parameter's name.</param>
        /// <param name="firstParamValue">First parameter's value.</param>
        /// <param name="secondParamName">Second parameter's name.</param>
        /// <param name="secondParamValue">Second parameter's value.</param>
        /// <returns>Xml procedure's result.</returns>
        protected virtual XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, string secondParamName, Guid? secondParamValue)
        {
            return this.ExecuteStoredProcedure(procedure, hasResult, firstParamName, firstParamValue, secondParamName, secondParamValue, null);
        }

        protected virtual XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, string secondParamName, Guid? secondParamValue, int? timeout)
        {
            return this.ExecuteStoredProcedure(procedure, hasResult, firstParamName, firstParamValue, secondParamName, secondParamValue, null, null, null, null, timeout);
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="firstParamName">First parameter's name.</param>
        /// <param name="firstParamValue">First parameter's value.</param>
        /// <param name="secondParamName">Second parameter's name.</param>
        /// <param name="secondParamValue">Second parameter's value.</param>
        /// <returns>Xml procedure's result.</returns>
        protected virtual XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, string secondParamName, Guid? secondParamValue,
            string thirdParamName, Guid? thirdParamValue, string fourthParamName, Guid? fourthParamValue)
        {
            return this.ExecuteStoredProcedure(procedure, hasResult, firstParamName, firstParamValue, secondParamName, secondParamValue, thirdParamName,
                thirdParamValue, fourthParamName, fourthParamValue, null);
        }

        protected virtual XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, string secondParamName, Guid? secondParamValue,
            string thirdParamName, Guid? thirdParamValue, string fourthParamName, Guid? fourthParamValue, int? timeout)
        {
            return this.ExecuteStoredProcedure(procedure, hasResult, firstParamName, firstParamValue, secondParamName, secondParamValue, thirdParamName,
                thirdParamValue, fourthParamName, fourthParamValue, null, null, timeout);
        }

        protected virtual XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, string secondParamName, Guid? secondParamValue, string thirdParamName, Guid? thirdParamValue, string fourthParamName
            , Guid? fourthParamValue, string fifthParameterName, bool? fifthParameterValue)
        {
            return this.ExecuteStoredProcedure(procedure, hasResult, firstParamName, firstParamValue, secondParamName, secondParamValue, thirdParamName, thirdParamValue, fourthParamName, fourthParamValue, fifthParameterName, fifthParameterValue, null);
        }

        protected virtual XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, string secondParamName, Guid? secondParamValue,
            string thirdParamName, Guid? thirdParamValue, string fourthParamName, Guid? fourthParamValue, string fifthParameterName, bool? fifthParameterValue, int? timeout, SqlCommand customCommand = null)
        {
            SqlCommand command = SqlConnectionManager.Instance.Command;

            command.CommandTimeout = timeout ?? ConfigurationMapper.Instance.GlobalSqlCommandTimeout;

            command.CommandText = procedure.ToProcedureName();

            #region Parameters
            command.Parameters.Clear();

            if (firstParamName != null)
            {
                SqlParameter param = command.Parameters.Add(firstParamName, SqlDbType.UniqueIdentifier);
                SqlGuid sqlGuid = new SqlGuid(firstParamValue.Value);
                param.SqlValue = sqlGuid;
            }

            if (secondParamName != null)
            {
                SqlParameter param = command.Parameters.Add(secondParamName, SqlDbType.UniqueIdentifier);
                SqlGuid sqlGuid = new SqlGuid(secondParamValue.Value);
                param.SqlValue = sqlGuid;
            }

            if (thirdParamName != null)
            {
                SqlParameter param = command.Parameters.Add(thirdParamName, SqlDbType.UniqueIdentifier);
                SqlGuid sqlGuid = new SqlGuid(thirdParamValue.Value);
                param.SqlValue = sqlGuid;
            }

            if (fourthParamName != null)
            {
                SqlParameter param = command.Parameters.Add(fourthParamName, SqlDbType.UniqueIdentifier);
                SqlGuid sqlGuid = new SqlGuid(fourthParamValue.Value);
                param.SqlValue = sqlGuid;
            }

            if (fifthParameterName != null)
            {
                SqlParameter param = command.Parameters.Add(fifthParameterName, SqlDbType.Bit);
                SqlBoolean sqlBit = new SqlBoolean(fifthParameterValue.Value);
                param.SqlValue = sqlBit;
            }
            #endregion

            XDocument retXml = null;

            if (hasResult)
            {
                XmlReader r = command.ExecuteXmlReader();
                retXml = XDocument.Load(r);
                r.Close();
            }
            else
                command.ExecuteNonQuery();

            if (timeout.HasValue)
                command.ResetCommandTimeout();

            if (ConfigurationMapper.Instance.LogDatabaseCommunication)
                MapperLogger.LogOperation(procedure, hasResult, firstParamName, firstParamValue, secondParamName, secondParamValue,
                    thirdParamName, thirdParamValue, fourthParamName, fourthParamValue, retXml);

            return retXml;
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="firstParamName">First parameter's name.</param>
        /// <param name="firstParamValue">First parameter's value.</param>
        /// <returns>Xml procedure's result.</returns>
        protected virtual XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, string firstParamName, string firstParamValue)
        {
            SqlCommand command = SqlConnectionManager.Instance.Command;
            command.CommandText = procedure.ToProcedureName();
            command.Parameters.Clear();
            command.CommandTimeout = ConfigurationMapper.Instance.GlobalSqlCommandTimeout;

            if (firstParamName != null)
            {
                SqlParameter param = command.Parameters.Add(firstParamName, SqlDbType.NVarChar);
                param.SqlValue = new SqlString(firstParamValue);
            }

            XDocument retXml = null;

            if (hasResult)
            {
                XmlReader r = command.ExecuteXmlReader();
                retXml = XDocument.Load(r);
                r.Close();
            }
            else
                command.ExecuteNonQuery();


            if (ConfigurationMapper.Instance.LogDatabaseCommunication)
                MapperLogger.LogOperation(procedure, hasResult, firstParamName, firstParamValue, retXml);

            return retXml;
        }

        /// <summary>
        /// Gets the <see cref="DateTime"/> from database.
        /// </summary>
        /// <returns><see cref="DateTime"/> that is currently on the database server.</returns>
        public static DateTime GetDateTimeFromDatabase()
        {
            //TODO: tutaj jawnie jakos rozrozniac czy jestesmy w tescie jednostkowym czy release
            SqlCommand command = SqlConnectionManager.Instance.Command;

            if (command != null)
            {
                command.CommandText = StoredProcedure.document_p_getDate.ToProcedureName();
                command.Parameters.Clear();

                DateTime dt = (DateTime)command.ExecuteScalar();

                return dt.Round(DateTimeAccuracy.Second);
            }
            else
                return DateTime.Now;
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="procedure">Procedure to execute.</param>
        /// <returns>Xml procedure's result.</returns>
        protected XDocument ExecuteStoredProcedure(StoredProcedure procedure)
        {
            return this.ExecuteStoredProcedure(procedure, true, null, null, null, null);
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="xml">Optional Xml parameter.</param>
        public XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, XDocument xml, int? timeout = null)
        {
            return this.ExecuteStoredProcedure(SessionManager.User, procedure, hasResult, xml, timeout);
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="xml">Optional Xml parameter.</param>
        public XDocument ExecuteStoredProcedure(StoredProcedure procedure, bool hasResult, XDocument xml, ref dynamic doubleDeletePreventHelper)
        {
            return this.ExecuteStoredProcedure(SessionManager.User, procedure, hasResult, xml, null, ref doubleDeletePreventHelper);
        }

        public virtual XDocument ExecuteStoredProcedureWithNoParams(StoredProcedure procedure, bool hasResult)
        {
            SqlCommand command = SqlConnectionManager.Instance.Command;
            command.CommandText = procedure.ToProcedureName();
            command.Parameters.Clear();
            command.CommandTimeout = ConfigurationMapper.Instance.GlobalSqlCommandTimeout;

            XmlReader r = null;
            XDocument retXml = null;

            if (hasResult)
            {
                r = command.ExecuteXmlReader();
                retXml = XDocument.Load(r);
                r.Close();
            }
            else
                command.ExecuteNonQuery();

            if (ConfigurationMapper.Instance.LogDatabaseCommunication)
                MapperLogger.LogOperation(procedure, hasResult, null, retXml);

            return retXml;
        }

        public XDocument ExecuteStoredProcedure(User user, Guid? branchId, StoredProcedure procedure, bool hasResult, XDocument xml, int? timeout = null)
        {
            return this.ExecuteStoredProcedure(user, branchId, null, procedure, hasResult, xml, timeout);
        }

        public XDocument ExecuteStoredProcedure(User user, Guid? branchId, StoredProcedure procedure, bool hasResult, XDocument xml, int? timeout, ref dynamic doubleDeletePreventHelper)
        {
            return this.ExecuteStoredProcedure(user, branchId, null, procedure, hasResult, xml, timeout, ref doubleDeletePreventHelper);
        }

        public XDocument ExecuteStoredProcedure(User user, Guid? branchId, Guid? userProfileId, StoredProcedure procedure, bool hasResult, XDocument xml, int? timeout, ref dynamic doubleDeletePreventHelper)
        {
            SqlCommand command = SqlConnectionManager.Instance.Command;
            command.CommandTimeout = timeout ?? ConfigurationMapper.Instance.GlobalSqlCommandTimeout;
            command.CommandText = procedure.ToProcedureName();
            command.Parameters.Clear();

            if (xml == null)
                xml = XDocument.Parse("<root/>");

            if (user != null)
            {
                xml.Root.Add(new XAttribute("applicationUserId", user.UserId.ToUpperString()));
                xml.Root.Add(new XAttribute("applicationUserName", user.UserName));
            }

            if (branchId != null)
                xml.Root.Add(new XAttribute("branchId", branchId.ToUpperString()));

            if (userProfileId != null)
                xml.Root.Add(new XAttribute("userProfileId", userProfileId.ToUpperString()));

            if ("item.p_deleteItemRelation" == procedure.ToProcedureName())
            {
                if ((doubleDeletePreventHelper as List<string>).Contains(xml.Root.Element("itemRelation").Element("entry").Element("id").Value))
                {
                    return null;
                }

                (doubleDeletePreventHelper as List<string>).Add(xml.Root.Element("itemRelation").Element("entry").Element("id").Value);
            }

            XDocument xmlTemporaryFix = xml;
            if ("finance.p_updatePayment" == procedure.ToProcedureName())
            {
                // Constraints: required _version i version
                if (xml.Root.Element("payment").Element("entry").Element("_version") == null || xml.Root.Element("payment").Element("entry").Element("version") == null)
                {
                    KernelHelpers.FastTest.Fail("Constraint fail - " + @"if (xml.Root.Element(""payment"").Element(""entry"").Element(""_version"") != null || xml.Root.Element(""payment"").Element(""entry"").Element(""version"") != null)");
                    throw new InvalidOperationException("Constraint fail - " + @"if (xml.Root.Element(""payment"").Element(""entry"").Element(""_version"") != null || xml.Root.Element(""payment"").Element(""entry"").Element(""version"") != null)");
                }

                //Temporary flip version with _version (Czekam na decyzję czarka (ostatecznie może tak zostać jak jest) :) - dzięki za komentarz, ze moze sie cos wy***ac :))
                //Po nowym debugu okazalo sie, ze jest jeszcze inaczej niz bylo wczesniej...
                //Przydałaby sie zmiana by procka korzystała z _versions przy robieniu update - wydaje się to logiczne...

                string flipHelper = xml.Root.Element("payment").Element("entry").Element("_version").Value;
                xmlTemporaryFix.Root.Element("payment").Element("entry").Element("_version").Value = xmlTemporaryFix.Root.Element("payment").Element("entry").Element("version").Value;
                xmlTemporaryFix.Root.Element("payment").Element("entry").Element("version").Value = flipHelper;
            }

            SqlParameter param = command.Parameters.Add("@xmlVar", SqlDbType.Xml);
            XmlReader r = xmlTemporaryFix.CreateReader();
            SqlXml sqlXml = new SqlXml(r);
            r.Close();
            param.SqlValue = sqlXml;
            XDocument retXml = null;

            if (hasResult)
            {
                r = command.ExecuteXmlReader();
                retXml = XDocument.Load(r);
                r.Close();
            }
            else
                command.ExecuteNonQuery();

            if (timeout.HasValue)
            {
                command.ResetCommandTimeout();
            }

            if (user != null)
            {
                xml.Root.Attribute("applicationUserId").Remove();
                xml.Root.Attribute("applicationUserName").Remove();
            }

            if (ConfigurationMapper.Instance.LogDatabaseCommunication)
                MapperLogger.LogOperation(procedure, hasResult, xml, retXml);

            return retXml;
        }

        public XDocument ExecuteStoredProcedure(User user, Guid? branchId, Guid? userProfileId, StoredProcedure procedure, bool hasResult, XDocument xml, int? timeout = null, SqlCommand customCommand = null)
        {
            SqlCommand command = customCommand ?? SqlConnectionManager.Instance.Command;
            command.CommandTimeout = timeout ?? ConfigurationMapper.Instance.GlobalSqlCommandTimeout;
            command.CommandText = procedure.ToProcedureName();
            command.Parameters.Clear();

            if (xml == null)
                xml = XDocument.Parse("<root/>");
            //Po commicie Arka pojawił sie błąd podwójnego wstawiania tego atrybutu, co tu więcej pisać...
            if (user != null && xml.Root.Attribute("applicationUserId") == null)
            {
                xml.Root.Add(new XAttribute("applicationUserId", user.UserId.ToUpperString()));
                xml.Root.Add(new XAttribute("applicationUserName", user.UserName));
            }

            if (branchId != null)
                xml.Root.Add(new XAttribute("branchId", branchId.ToUpperString()));

            if (userProfileId != null)
                xml.Root.Add(new XAttribute("userProfileId", userProfileId.ToUpperString()));

            //BZDURA!! Błąd który wywracał wersje był przy okazji innej twojej poprawki i tam należało naprawić a nie dodawać "TemporaryFix"!!!!
            //XDocument xmlTemporaryFix = xml;
            //if ("finance.p_updatePayment" == procedure.ToProcedureName())
            //{
            //    // Constraints: required _version i version
            //    if (xml.Root.Element("payment").Element("entry").Element("_version") == null || xml.Root.Element("payment").Element("entry").Element("version") == null)
            //    {
            //        KernelHelpers.FastTest.Fail("Constraint fail - " + @"if (xml.Root.Element(""payment"").Element(""entry"").Element(""_version"") != null || xml.Root.Element(""payment"").Element(""entry"").Element(""version"") != null)");
            //        throw new InvalidOperationException("Constraint fail - " + @"if (xml.Root.Element(""payment"").Element(""entry"").Element(""_version"") != null || xml.Root.Element(""payment"").Element(""entry"").Element(""version"") != null)");
            //    }

            //    //Temporary flip version with _version (Czekam na decyzję czarka (ostatecznie może tak zostać jak jest) :) - dzięki za komentarz, ze moze sie cos wy***ac :))
            //    //Po nowym debugu okazalo sie, ze jest jeszcze inaczej niz bylo wczesniej...
            //    //Przydałaby sie zmiana by procka korzystała z _versions przy robieniu update - wydaje się to logiczne...

            //    string flipHelper = xml.Root.Element("payment").Element("entry").Element("_version").Value;
            //    xmlTemporaryFix.Root.Element("payment").Element("entry").Element("_version").Value = xmlTemporaryFix.Root.Element("payment").Element("entry").Element("version").Value;
            //    xmlTemporaryFix.Root.Element("payment").Element("entry").Element("version").Value = flipHelper;
            //}

            SqlParameter param = command.Parameters.Add("@xmlVar", SqlDbType.Xml);
            XmlReader r = xml.CreateReader();
            SqlXml sqlXml = new SqlXml(r);
            r.Close();
            param.SqlValue = sqlXml;
            XDocument retXml = null;

            if (hasResult)
            {
                r = command.ExecuteXmlReader();
                retXml = XDocument.Load(r);
                r.Close();
            }
            else
                command.ExecuteNonQuery();

            if (timeout.HasValue)
            {
                command.ResetCommandTimeout();
            }

            if (user != null)
            {
                xml.Root.Attribute("applicationUserId").Remove();
                xml.Root.Attribute("applicationUserName").Remove();
            }

            if (ConfigurationMapper.Instance.LogDatabaseCommunication)
                MapperLogger.LogOperation(procedure, hasResult, xml, retXml);

            return retXml;
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="user">The user that executes the procedure.</param>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="xml">Optional Xml parameter.</param>
        /// <returns></returns>
        public virtual XDocument ExecuteStoredProcedure(User user, StoredProcedure procedure, bool hasResult, XDocument xml, int? timeout = null)
        {
            return this.ExecuteStoredProcedure(user, null, procedure, hasResult, xml, timeout);
        }

        /// <summary>
        /// Executes SQL stored procedure.
        /// </summary>
        /// <param name="user">The user that executes the procedure.</param>
        /// <param name="procedure">Procedure to execute.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result.</param>
        /// <param name="xml">Optional Xml parameter.</param>
        /// <returns></returns>
        public virtual XDocument ExecuteStoredProcedure(User user, StoredProcedure procedure, bool hasResult, XDocument xml, int? timeout, ref dynamic doubleDeletePreventHelper)
        {
            return this.ExecuteStoredProcedure(user, null, procedure, hasResult, xml, timeout, ref doubleDeletePreventHelper);
        }



        public StoredProcedure procedure { get; set; }
    }
}
