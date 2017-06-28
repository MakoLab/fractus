using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
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
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.MethodInputParameters;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class representing a mapper with methods necessary to operate on documents.
    /// </summary>
    public class DocumentMapper : Mapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentMapper"/> class.
        /// </summary>
        public DocumentMapper()
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
						{ BusinessObjectType.CommercialDocument, typeof(CommercialDocument) },
						{ BusinessObjectType.CommercialDocumentLine, typeof(CommercialDocumentLine) },
						{ BusinessObjectType.WarehouseDocument, typeof(WarehouseDocument) },
						{ BusinessObjectType.WarehouseDocumentLine, typeof(WarehouseDocumentLine) },
						{ BusinessObjectType.Payment, typeof(Payment) },
						{ BusinessObjectType.PaymentSettlement, typeof(PaymentSettlement) },
						{ BusinessObjectType.FinancialDocument, typeof(FinancialDocument) },
						{ BusinessObjectType.FinancialReport, typeof(FinancialReport) },
						{ BusinessObjectType.ServiceDocument, typeof(ServiceDocument) },
						{ BusinessObjectType.ComplaintDocument, typeof(ComplaintDocument) },
						{ BusinessObjectType.InventoryDocument, typeof(InventoryDocument) },
						{ BusinessObjectType.InventorySheet, typeof(InventorySheet) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { return DocumentMapper.CachedSupportedBusinessObjectTypes; }
		}

		#endregion

		/// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            if (!obj.IsNew)
            {
                if (obj.BOType == BusinessObjectType.CommercialDocument)
                    this.CheckCommercialDocumentVersion(obj.Version.Value);
                else if (obj.BOType == BusinessObjectType.WarehouseDocument)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_checkWarehouseDocumentVersion, false, "@version", obj.Version);
                else if (obj.BOType == BusinessObjectType.FinancialReport)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_checkFinancialReportVersion, false, "@version", obj.Version);
                else if (obj.BOType == BusinessObjectType.FinancialDocument)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_checkFinancialDocumentVersion, false, "@version", obj.Version);
                else if (obj.BOType == BusinessObjectType.Payment)
                    this.ExecuteStoredProcedure(StoredProcedure.finance_p_checkPaymentVersion, false, "@version", obj.Version);
                else if (obj.BOType == BusinessObjectType.ServiceDocument)
                    this.ExecuteStoredProcedure(StoredProcedure.service_p_checkServiceVersion, false, "@version", ((ServiceDocument)obj).VersionService);
                else if (obj.BOType == BusinessObjectType.ComplaintDocument)
                    this.ExecuteStoredProcedure(StoredProcedure.complaint_p_checkComplaintDocumentVersion, false, "@version", obj.Version);
                else if (obj.BOType == BusinessObjectType.InventoryDocument)
                    this.CheckInventoryDocumentVersion(obj.Version.Value);
                else if (obj.BOType == BusinessObjectType.InventorySheet)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_checkInventorySheetVersion, false, "@version", obj.Version);
            }
        }

        public void CheckInventoryDocumentVersion(Guid version)
        {
            this.ExecuteStoredProcedure(StoredProcedure.document_p_checkInventoryDocumentVersion, false, "@version", version);
        }

        public void CheckCommercialDocumentVersion(Guid version)
        {
            this.ExecuteStoredProcedure(StoredProcedure.document_p_checkCommercialDocumentVersion, false, "@version", version);
        }

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
                case BusinessObjectType.CommercialDocument:
                    bo = new CommercialDocument();
                    break;
                case BusinessObjectType.WarehouseDocument:
                    bo = new WarehouseDocument();
                    break;
                case BusinessObjectType.WarehouseDocumentLine:
                    bo = new WarehouseDocumentLine(null);
                    break;
                case BusinessObjectType.CommercialDocumentLine:
                    bo = new CommercialDocumentLine(null);
                    break;
                case BusinessObjectType.Payment:
                    bo = new Payment(null);
                    break;
                case BusinessObjectType.PaymentSettlement:
                    bo = new PaymentSettlement(null);
                    break;
                case BusinessObjectType.FinancialDocument:
                    bo = new FinancialDocument();
                    break;
                case BusinessObjectType.FinancialReport:
                    bo = new FinancialReport();
                    break;
                case BusinessObjectType.ServiceDocument:
                    bo = new ServiceDocument();
                    break;
                case BusinessObjectType.ComplaintDocument:
                    bo = new ComplaintDocument();
                    break;
                case BusinessObjectType.InventoryDocument:
                    bo = new InventoryDocument();
                    break;
                case BusinessObjectType.InventorySheet:
                    bo = new InventorySheet(null);
                    break;
                default:
                    throw new InvalidOperationException("DocumentMapper can only create documents.");
            }

            bo.GenerateId();
            return bo;
        }

        internal void AppendProductionOrderLineLabels(CommercialDocument document)
        {
            XDocument xml = new XDocument(new XElement("root"));

            foreach (var line in document.Lines)
            {
                foreach (var attr in line.Attributes)
                {
                    if (attr.DocumentFieldName == DocumentFieldName.LineAttribute_ProductionTechnologyName)
                    {
                        xml.Root.Add(new XElement("technology", new XAttribute("id", attr.Value.Value)));
                        break;
                    }
                }
            }

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getTechnologiesNames, true, xml);

            foreach (var line in document.Lines)
            {
                foreach (var attr in line.Attributes)
                {
                    if (attr.DocumentFieldName == DocumentFieldName.LineAttribute_ProductionTechnologyName)
                    {
                        var t = xml.Root.Elements().Where(x => x.Attribute("id").Value == attr.Value.Value).FirstOrDefault();

                        if (t != null)
                            attr.Label = t.Attribute("technologyName").Value;
                        break;
                    }
                }
            }
        }

        /// <summary>
        /// Determines whether an income warehouse document has relation with outcomes.
        /// </summary>
        /// <param name="documentId">The income warehouse document id to check.</param>
        /// <returns><c>true</c> if the income warehouse document has relation with outcomes; otherwise, <c>false</c>.</returns>
        public bool HasIncomeWarehouseDocumentAnyOutcomeRelation(Guid documentId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_hasIncomeAnyOutcome, true, "@id", documentId);

            return Boolean.Parse(xml.Root.Value);
        }

        internal void DeleteIncomeOutcomeRelations(WarehouseDocument document)
        {
            ValuationMethod vm = DictionaryMapper.Instance.GetWarehouse(document.WarehouseId).ValuationMethod;

            if (vm == ValuationMethod.Fifo)
            {
                //kasowanie musi byc "twarde" bo potem fifo musi wziasc pod uwage te skasowane dostawy
                XDocument xml = XDocument.Parse("<root/>");
                xml.Root.Add(new XAttribute("localTransactionId", SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));
                xml.Root.Add(new XAttribute("deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));
                xml.Root.Add(new XAttribute("databaseId", ConfigurationMapper.Instance.DatabaseId.ToUpperString()));
                xml.Root.Add(new XElement("warehouseDocumentHeaderId", document.Id.ToUpperString()));

                this.ExecuteStoredProcedure(StoredProcedure.document_p_deleteIncomeOutcomeRelations, false, xml);

                foreach (WarehouseDocumentLine line in document.Lines.Children)
                {
                    line.IncomeOutcomeRelations.RemoveAll();
                }
            }
            else if (vm == ValuationMethod.DeliverySelection)
            {
                XDocument xml = XDocument.Parse("<root/>");
                xml.Root.Add(new XAttribute("localTransactionId", SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));
                xml.Root.Add(new XAttribute("deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));
                xml.Root.Add(new XAttribute("databaseId", ConfigurationMapper.Instance.DatabaseId.ToUpperString()));
                xml.Root.Add(new XElement("warehouseDocumentHeaderId", document.Id.ToUpperString()));

                this.ExecuteStoredProcedure(StoredProcedure.document_p_deleteIncomeOutcomeRelations, false, xml);

                foreach (WarehouseDocumentLine line in document.Lines.Children)
                {
                    foreach (IncomeOutcomeRelation rel in line.IncomeOutcomeRelations.Children)
                    {
                        rel.GenerateId();
                        rel.Version = null;
                        rel.OutcomeDate = null;
                    }
                }
            }

            //kasujemy to tez zeby w ogole nie bylo sladu bo procedura p_deleteIncomeOutcomeRelations tworzy tez paczki
            if (document.AlternateVersion != null)
            {
                WarehouseDocument alternateDocument = document.AlternateVersion as WarehouseDocument;

                foreach (WarehouseDocumentLine altLine in alternateDocument.Lines.Children)
                {
                    if (altLine.IncomeOutcomeRelations != null)
                        altLine.IncomeOutcomeRelations.RemoveAll();
                }
            }
        }

        /// <summary>
        /// Determines whether an outcome warehouse document has relation with commercial documents (sales and purchase only).
        /// </summary>
        /// <param name="documentId">The outcome warehouse document id to check.</param>
        /// <returns><c>true</c> if the outcome warehouse document has relation with commercial documents; otherwise, <c>false</c>.</returns>
        public bool HasOutcomeDocumentAnyCommercialRelation(Guid documentId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_hasOutcomeAnyCommercialRelation, true, "@id", documentId);

            return Boolean.Parse(xml.Root.Value);
        }

        /// <summary>
        /// Updates the warehouse stock.
        /// </summary>
        /// <param name="requests">Collection of objects defining what item on what warehouse to update stock and containing differential quantity.</param>
        internal void UpdateStock(UpdateStockRequest request)
        {
            if (request != null)
            {
                try
                {
                    this.ExecuteStoredProcedure(request.UpdateStockProcedure, false, request.RequestXml);
                }
                catch (SqlException ex)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:121");
                    if (ex.Number == 50000)
                    {
                        string itemName = ex.Message.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries)[0];
                        string count = itemName.Substring(itemName.LastIndexOf('@') + 1);
                        itemName = itemName.Substring(0, itemName.LastIndexOf('@'));
                        throw new ClientException(ClientExceptionId.BlockedItemError, null, "itemName:" + itemName, "count:" + count);
                    }
                    else
                        throw;
                }

                this.CreateUpdateStockPackage(request.CommunicationXml);
            }
        }

        private void CreateUpdateStockPackage(XDocument xml)
        {
            if (xml.Root.HasElements)
            {
                if (xml.Root.Attribute("localTransactionId") == null)
                    xml.Root.Add(new XAttribute("localTransactionId", SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));

                if (xml.Root.Attribute("deferredTransactionId") == null)
                    xml.Root.Add(new XAttribute("deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));

                if (xml.Root.Attribute("databaseId") == null)
                    xml.Root.Add(new XAttribute("databaseId", ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createWarehouseStockPackage, false, xml);
            }
        }

        public XElement LoadWarehouseDocumentDbXml(Guid id)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.document_p_getWarehouseDocumentData, true, "@warehouseDocumentHeaderId", id);

            if (xdoc.Root.Element("warehouseDocumentHeader").Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            return xdoc.Root;
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
            string mainObjectNodeName = null;
			bool loadWmsData = type == BusinessObjectType.WarehouseDocument && ConfigurationMapper.Instance.IsWmsEnabled;
            XDocument dbXmlDoc = XDocument.Parse("<root/>");
			XDocument xdoc = null;
			bool loaded = false;

			if (this.SupportedBusinessObjectsTypes.Contains(type))
			{
				Type classType = this.SupportedBusinessObjectsTypes[type];
				XmlSerializationCache xmlSerCachce = BusinessObject.ClassXmlSerializationCache[classType];
				foreach (DatabaseMappingCache dbCache in BusinessObject.ClassDatabaseMappingCache[classType])
				{
					if (dbCache.Attribute.GetData != StoredProcedure.Unknown)
					{
						xdoc = this.ExecuteStoredProcedure(dbCache.Attribute.GetData, true, dbCache.Attribute.GetDataParamName, id);

						if (xdoc.Root.Element(dbCache.Attribute.TableName).Elements().Count() == 0)
							throw new ClientException(ClientExceptionId.ObjectNotFound);

						dbXmlDoc.Root.Add(xdoc.Root.Elements());
						loaded = true;
					}
				}
				mainObjectNodeName = xmlSerCachce.Attribute.RootXmlField ?? xmlSerCachce.Attribute.XmlField;
			}

			if (!loaded)
				throw new InvalidOperationException("Incorrect BusinessObjectType.");

            xdoc = this.ConvertDBToBoXmlFormat(dbXmlDoc, id);

            IBusinessObject bo = this.ConvertToBusinessObject(xdoc.Root.Element(mainObjectNodeName), null);

			#region Load Wms Data
			if (loadWmsData)
            {
                WarehouseDocument whDoc = (WarehouseDocument)bo;

                if (DictionaryMapper.Instance.GetWarehouse(whDoc.WarehouseId).ValuationMethod == ValuationMethod.DeliverySelection)
                {
                    WarehouseMapper whMapper = DependencyContainerManager.Container.Get<WarehouseMapper>();
                    ShiftTransaction st = whMapper.GetShiftForWarehouseDocument(id);
                    whDoc.ShiftTransaction = st;
                }
			}
			#endregion

			#region Copy ExchangeRate data to Financial Document Header

			if (type == BusinessObjectType.FinancialDocument)
			{
				FinancialDocument financialDocument = (FinancialDocument)bo;
				if (financialDocument != null && financialDocument.Payments.Children.Count > 0)
				{
					Payment firstPayment = financialDocument.Payments.Children.First();
					financialDocument.ExchangeDate = firstPayment.ExchangeDate;
					financialDocument.ExchangeRate = firstPayment.ExchangeRate;
					financialDocument.ExchangeScale = firstPayment.ExchangeScale;
				}
			}

			#endregion

			return bo;
        }

        public Guid? GetOpenedFinancialReportId(Guid financialRegisterId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("financialRegisterId", financialRegisterId.ToUpperString()));
            xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_getOpenedFinancialReportId, true, xml);

            if (xml.Root.Value.Length > 0)
                return new Guid(xml.Root.Value);
            else
                return null;
        }

		public string GetFinancialReportStatusById(Guid financialReportId)
		{
			XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_getFinancialReportStatusById, true, "financialReportId", financialReportId);

			XElement idElement = xml.Root.Element(XmlName.Id);
			XAttribute objectExportedAttr = idElement == null ? null : idElement.Attribute(XmlName.ObjectExported);
			return objectExportedAttr == null ? null : objectExportedAttr.Value;
		}

		/// <summary>
		/// Wczytuje <see cref="CommercialDocument "/> po OppositeDocumentId
		/// </summary>
		internal CommercialDocument GetCommercialDocumentByOppositeId(Guid oppositeId)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.document_p_getCommercialDocumentByOppositeDocumentId, true, "@oppositeId", oppositeId);

			return this.ConvertCommercialDocumentFromDBToBO(xdoc);
        }

		/// <summary>
		/// Wczytuje <see cref="CommercialDocument "/> po commercialDocumentLineId
		/// </summary>
		internal CommercialDocument GetCommercialDocumentByLineId(Guid commercialDocumentLineId)
		{
			XDocument xdoc = this.ExecuteStoredProcedure
				(StoredProcedure.document_p_getCommercialDocumentDataByLineId, 
				true, Mapper.P_Id, commercialDocumentLineId);
			return this.ConvertCommercialDocumentFromDBToBO(xdoc);
		}

		/// <summary>
		/// Converts <see cref="CommercialDocument "/> from db format to BO
		/// </summary>
		/// <param name="dbFormat">xml returned by Stored Procedure</param>
		/// <returns><see cref="CommercialDocument "/> object</returns>
		private CommercialDocument ConvertCommercialDocumentFromDBToBO(XDocument dbFormat)
		{
			if (dbFormat.Root.Element(XmlName.CommercialDocumentHeader).Elements().Count() == 0)
				return null;

			dbFormat = this.ConvertDBToBoXmlFormat(dbFormat, 
				new Guid(dbFormat.Root.Element(XmlName.CommercialDocumentHeader).Element(XmlName.Entry).Element(XmlName.Id).Value));

			return (CommercialDocument)this.ConvertToBusinessObject(dbFormat.Root.Element(XmlName.CommercialDocument), null);
		}

        internal WarehouseDocument GetIncomeShiftByOutcomeId(Guid outcomeShiftId)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.document_p_getIncomeShiftByOutcomeId, true, "@outcomeShiftId", outcomeShiftId);

            if (xdoc.Root.Element("warehouseDocumentHeader").Elements().Count() == 0)
                return null;

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, new Guid(xdoc.Root.Element("warehouseDocumentHeader").Element("entry").Element("id").Value));

            return (WarehouseDocument)this.ConvertToBusinessObject(xdoc.Root.Element("warehouseDocument"), null);
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            Guid localTransactionId = SessionManager.VolatileElements.LocalTransactionId.Value;
            Guid deferredTransactionId = SessionManager.VolatileElements.DeferredTransactionId.Value;

            IVersionedBusinessObject versionedObject = (IVersionedBusinessObject)obj;

			StoredProcedure storedProcedure = StoredProcedure.Unknown;
			switch (obj.BOType)
			{
				case BusinessObjectType.CommercialDocument: storedProcedure = StoredProcedure.communication_p_createCommercialDocumentPackage; break;
				case BusinessObjectType.WarehouseDocument: storedProcedure = StoredProcedure.communication_p_createWarehouseDocumentPackage; break;
				case BusinessObjectType.FinancialDocument: storedProcedure = StoredProcedure.communication_p_createFinancialDocumentPackage; break;
				case BusinessObjectType.FinancialReport: storedProcedure = StoredProcedure.communication_p_createFinancialReportPackage; break;
				case BusinessObjectType.Payment: storedProcedure = StoredProcedure.communication_p_createPaymentPackage; break;
				case BusinessObjectType.ComplaintDocument: storedProcedure = StoredProcedure.communication_p_createComplaintDocumentPackage; break;
				case BusinessObjectType.InventoryDocument: storedProcedure = StoredProcedure.communication_p_createInventoryDocumentPackage; break;
			}

            if (obj.BOType == BusinessObjectType.CommercialDocument)
            {
                string packageName = DictionaryMapper.Instance.GetDocumentType(((CommercialDocument)obj).DocumentTypeId).CommercialDocumentOptions.CommunicationPackageName;
                this.CreateCommunicationXmlForVersionedBusinessObject(versionedObject, localTransactionId, deferredTransactionId, storedProcedure, packageName);
            }
            else if (storedProcedure != StoredProcedure.Unknown)
                this.CreateCommunicationXmlForVersionedBusinessObject(versionedObject, localTransactionId, deferredTransactionId, storedProcedure);
        }

        public decimal GetContractorDealing(Guid contractorId, DateTime date)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("contractorId", contractorId.ToUpperString()), new XElement("date", date.ToIsoString()));

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getContractorDealing, true, xml);

            return Convert.ToDecimal(xml.Root.Value, CultureInfo.InvariantCulture);
        }

		/// <summary>
		/// Zwraca również korekty anulowane
		/// </summary>
		/// <param name="correctiveDocumentId"></param>
		/// <returns></returns>
        public ICollection<Guid> GetPreviousCommercialCorrectiveDocumentsId(Guid correctiveDocumentId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getPreviousCommercialCorrectiveDocuments, true, "commercialDocumentHeaderId", correctiveDocumentId);

            List<Guid> retCollection = new List<Guid>();

            foreach (XElement idElement in xml.Root.Elements())
            {
                retCollection.Add(new Guid(idElement.Attribute("id").Value));
            }

            return retCollection;
        }

        public XDocument GetAllWarehouseCorrectiveLines(Guid warehouseDocumentHeaderId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getAllWarehouseCorrectiveLines, true, "@warehouseDocumentHeaderId", warehouseDocumentHeaderId);
            return xml;
        }

        public XElement GetSalesOrderSettledAmount(Guid commercialDocumentHeaderId)
        {
            /*
                <root>
                  <vatRate id="F8D50E4D-066E-4F0A-BD58-C2BC708BEB0F" netValue="1510.00" grossValue="1842.20" vatValue="332.20" />
                  <vatRate id="[id stawki vat]" netValue="1510.00" grossValue="1842.20" vatValue="332.20" />
                </root>
             */
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getSalesOrderSettledAmount, true, "@commercialDocumentHeaderId", commercialDocumentHeaderId);

            return xml.Root;
        }

        public ICollection<Guid> GetCommercialCorrectiveDocumentsId(Guid correctedDocumentId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getCommercialCorrectiveDocuments, true, "commercialDocumentHeaderId", correctedDocumentId);

            List<Guid> retCollection = new List<Guid>();

            foreach (XElement idElement in xml.Root.Elements())
            {
                retCollection.Add(new Guid(idElement.Attribute("id").Value));
            }

            return retCollection;
        }

        public ICollection<Guid> GetPreviousWarehouseCorrectiveDocumentsId(Guid correctiveDocumentId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getPreviousWarehouseCorrectiveDocuments, true, "@warehouseDocumentHeaderId", correctiveDocumentId);

            List<Guid> retCollection = new List<Guid>();

            foreach (XElement idElement in xml.Root.Elements())
            {
                retCollection.Add(new Guid(idElement.Attribute("id").Value));
            }

            return retCollection;
        }

        public ICollection<Guid> GetWarehouseCorrectiveDocumentsId(Guid correctedDocumentId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getWarehouseCorrectiveDocuments, true, "@warehouseDocumentHeaderId", correctedDocumentId);

            List<Guid> retCollection = new List<Guid>();

            foreach (XElement idElement in xml.Root.Elements())
            {
                retCollection.Add(new Guid(idElement.Attribute("id").Value));
            }

            return retCollection;
        }

        /// <summary>
        /// Creates communication xml for <see cref="IBusinessObject"/>s that are considered to be a relation between two document business objects. Such relations dont rise documents' version if they are modified.
        /// </summary>
        /// <param name="relations">Container of the <see cref="IBusinessObject"/>s.</param>
        /// <param name="alternateRelations">Alternate container of the <see cref="IBusinessObject"/>s.</param>
        public void CreateCommunicationXmlForDocumentRelations(XDocument operations)
        {
			DocumentRelationType[] skipDocumentRelationTypes = new DocumentRelationType[] { 
				DocumentRelationType.ServiceToInternalOutcome
				, DocumentRelationType.ServiceToInvoice
				, DocumentRelationType.ServiceToOutcomeShift 
			};

            Guid localTransactionId = SessionManager.VolatileElements.LocalTransactionId.Value;
            Guid deferredTransactionId = SessionManager.VolatileElements.DeferredTransactionId.Value;

            Dictionary<string, StoredProcedure> dctTableNameToProcedure = new Dictionary<string, StoredProcedure>();
            dctTableNameToProcedure.Add("incomeOutcomeRelation", StoredProcedure.communication_p_createIncomeOutcomeRelationPackage);
            dctTableNameToProcedure.Add("commercialWarehouseRelation", StoredProcedure.communication_p_createCommercialWarehouseRelationPackage);
            dctTableNameToProcedure.Add("commercialWarehouseValuation", StoredProcedure.communication_p_createCommercialWarehouseValuationPackage);
            dctTableNameToProcedure.Add("documentRelation", StoredProcedure.communication_p_createDocumentRelationPackage);

            foreach (string tableName in dctTableNameToProcedure.Keys)
            {
				bool isDocumentRelation = tableName == "documentRelation";

                XDocument commXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                        "<root localTransactionId=\"{0}\" deferredTransactionId=\"{1}\" databaseId=\"{2}\"></root>",
                        localTransactionId.ToUpperString(), deferredTransactionId.ToUpperString(),
                        ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

                //jezeli tabela istnieje
                if (operations.Root.Element(tableName) != null && operations.Root.Element(tableName).Elements().Count() > 0)
                {
                    var tableEntries = operations.Root.Element(tableName).Elements();

					foreach (XElement operationEntry in tableEntries)
                    {
						#region Skip relations with service documents
						//Skip relations with servicedocument
						if (isDocumentRelation)
						{
							XElement relationTypeElement = operationEntry.Element("relationType");
							if (relationTypeElement != null)
							{
								DocumentRelationType documentRelationType 
									= (DocumentRelationType)Enum.Parse(typeof(DocumentRelationType), relationTypeElement.Value);
								if (skipDocumentRelationTypes.Contains(documentRelationType))
								{
									continue;
								}
							}
						}
						#endregion

						XElement entry = new XElement("entry", new XAttribute("id", operationEntry.Element("id").Value));

                        if (operationEntry.Attribute("action") != null)
                        {
                            if (operationEntry.Attribute("action").Value == "update")
                                entry.Add(new XAttribute("previousVersion", operationEntry.Element("version").Value));
                            else if (operationEntry.Attribute("action").Value == "delete")
                            {
                                entry.Add(new XAttribute("version", operationEntry.Element("version").Value));
                                entry.Add(new XAttribute("action", "delete"));
                            }
                        }

                        commXml.Root.Add(entry);
					}

					if (commXml.Root.HasElements)
					{
						this.ExecuteStoredProcedure(dctTableNameToProcedure[tableName], false, commXml);
					}
                }
            }
        }

		//TODO przydałoby się zrobić to generycznie w oparciu o atrybuty klas
        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            //find what's the type of the main object
            string mainTableName = (from node in xml.Root.Descendants()
                                    where node.Name.LocalName == "entry" &&
                                    node.Element("id") != null &&
                                    node.Element("id").Value == id.ToUpperString()
                                    select node.Parent.Name.LocalName).ElementAt(0);

            bool isServiceDocument = false;

            //sprawdzamy czy to moze service jest...
            if (xml.Root.Element("serviceHeader") != null)
            {
                XElement srv = xml.Root.Element("serviceHeader").Elements().Where(s => s.Element("commercialDocumentHeaderId").Value == id.ToUpperString()).FirstOrDefault();

                if (srv != null)
                    isServiceDocument = true;
            }

            string mainObjectName = null;
            bool hasLines = false;
            bool hasAttributes = false;
            bool hasPayments = false;
            bool hasVatTable = false;
            bool isDocument = false;
            bool isOnePayment = false;
            bool hasDocumentRelations = false;
            bool hasSheets = false;
            bool isSingleSheet = false;
			string mainObjectNameSuffix = "Id";

            if (mainTableName == "commercialDocumentHeader")
            {
                mainObjectName = "commercialDocument";
                isDocument = true;
                hasLines = true;
                hasAttributes = true;
                hasPayments = true;
                hasVatTable = true;
                hasDocumentRelations = true;
            }
            else if (mainTableName == "warehouseDocumentHeader")
            {
                mainObjectName = "warehouseDocument";
                isDocument = true;
                hasLines = true;
                hasAttributes = true;
                hasDocumentRelations = true;
            }
            else if (mainTableName == "financialDocumentHeader")
            {
                mainObjectName = "financialDocument";
                isDocument = true;
                hasAttributes = true;
                hasPayments = true;
                hasDocumentRelations = true;
            }
            else if (mainTableName == "financialReport")
            {
                isDocument = true;
                mainObjectName = mainTableName;
            }
            else if (mainTableName == "payment")
            {
                mainObjectName = mainTableName;
                isOnePayment = true;
            }
            else if (mainTableName == "complaintDocumentHeader")
            {
                mainObjectName = "complaintDocument";
                isDocument = true;
                hasLines = true;
                hasDocumentRelations = true;
                hasAttributes = true;
            }
            else if (mainTableName == "inventoryDocumentHeader")
            {
                mainObjectName = "inventoryDocument";
                isDocument = true;
                hasDocumentRelations = true;
                hasAttributes = true;
                hasSheets = true;
            }
            else if (mainTableName == "inventorySheet")
            {
                mainObjectName = mainTableName;
                isSingleSheet = true;
            }
			else if (mainTableName == "offer")
			{
				mainObjectName = "offerDocument";
				isDocument = true;
				hasLines = true;
				hasAttributes = true;
			}

            XDocument convertedXml = XDocument.Parse("<root/>");

            if (isDocument)
                this.ConvertMainDocumentFromDbToBoXmlFormat(xml, id, mainObjectName, mainTableName, convertedXml);

            if (isOnePayment)
                this.ConvertOnePaymentFromDbToBoXmlFormat(xml, id, convertedXml);

            if (isSingleSheet)
                this.ConvertSingleSheetFromDbToBoXmlFormat(xml, id, convertedXml);

            //set the proper type
            if (convertedXml.Root.Element(mainObjectName).Attribute("type") == null)
            {
                convertedXml.Root.Element(mainObjectName).Add(new XAttribute("type", mainObjectName.Capitalize()));
            }

			if (hasLines)
			{
				string lineName = mainTableName == "offer" ? "offerLine" : mainObjectName + "Line";
				this.ConvertMainDocumentLinesFromDbToBoXmlFormat(xml, id, mainObjectName, convertedXml, "lines", lineName, mainTableName + mainObjectNameSuffix, "line");
			}

            if(hasSheets)
                this.ConvertMainDocumentLinesFromDbToBoXmlFormat(xml, id, mainObjectName, convertedXml, "sheets", "inventorySheet", mainObjectName + "HeaderId", "sheet");

            if (hasAttributes)
                this.ConvertMainDocumentAttributesFromDbToBoXmlFormat(xml, id, mainObjectName, convertedXml);

            if (hasPayments)
                this.ConvertMainDocumentPaymentsFromDbToBoXmlFormat(xml, id, mainObjectName, convertedXml);

            if (hasVatTable)
                this.ConvertCommercialDocumentVatTableEntriesFromDbToBoXmlFormat(xml, id, convertedXml);

            if (isServiceDocument)
                this.ConvertCommercialDocumentToServiceDocument(xml, id, convertedXml);

            if (hasDocumentRelations)
            {
                XElement relations = this.ConvertDocumentRelationsFromDbToBoXmlFormat(xml, id);
                ((XElement)convertedXml.Root.FirstNode).Add(relations);
            }

            return convertedXml;
        }

        private void ConvertCommercialDocumentToServiceDocument(XDocument xml, Guid id, XDocument outXml)
        {
            XElement documentElement = outXml.Root.Element("commercialDocument");
            documentElement.Name = "serviceDocument";
            documentElement.Attribute("type").Value = "ServiceDocument";

            //przetwarzamy przedluzenie naglowka
            var serviceHeader = xml.Root.Element("serviceHeader").Elements()
                .Where(w => w.Element("commercialDocumentHeaderId").Value == id.ToUpperString()).FirstOrDefault();

            if (serviceHeader != null)
            {
                foreach (XElement column in serviceHeader.Elements())
                {
                    if (column.Name.LocalName == "version")
                        documentElement.Add(new XElement("versionService", column.Value));
                    if (column.Name.LocalName == "creationDate")
                        documentElement.Add(new XElement("creationDateService", column.Value));
                    else if (column.Name.LocalName != "commercialDocumentHeaderId")
                        documentElement.Add(column);
                }
            }

            //przetwarzamy kolekcje
            this.ConvertGenericDocumentCollection(xml, id, documentElement, "serviceHeaderEmployees", "serviceHeaderId", "serviceDocumentEmployees", "serviceDocumentEmployee", "ordinalNumber");
            this.ConvertGenericDocumentCollection(xml, id, documentElement, "serviceHeaderServicedObjects", "serviceHeaderId", "serviceDocumentServicedObjects", "serviceDocumentServicedObject", "ordinalNumber");
            this.ConvertGenericDocumentCollection(xml, id, documentElement, "serviceHeaderServicePlace", "serviceHeaderId", "serviceDocumentServicePlaces", "serviceDocumentServicePlace", "ordinalNumber");
        }

        private void ConvertGenericDocumentCollection(XDocument xml, Guid id, XElement documentElement, string tableName, string parentDocumentIdColumnName, string collectionName, string singleElementName, string orderColumn)
        {
            XElement serviceHeaderEmployees = new XElement(collectionName);
            documentElement.Add(serviceHeaderEmployees);

            var employees = xml.Root.Element(tableName).Elements()
                .Where(e => e.Element(parentDocumentIdColumnName).Value == id.ToUpperString());

            if (!String.IsNullOrEmpty(orderColumn))
                employees = employees.OrderBy(o => Convert.ToInt32(o.Element(orderColumn).Value, CultureInfo.InvariantCulture));

            foreach (XElement employee in employees)
            {
                XElement e = new XElement(singleElementName);
                serviceHeaderEmployees.Add(e);

                foreach (XElement column in employee.Elements())
                {
                    if (column.Name.LocalName != parentDocumentIdColumnName)
                        e.Add(column);
                }
            }
        }

        /// <summary>
        /// Converts main <see cref="CommercialDocument"/> VAT table entries from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Document"/>.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertCommercialDocumentVatTableEntriesFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            if (outXml.Root.Element("commercialDocument").Element("vatTable") == null)
                outXml.Root.Element("commercialDocument").Add(new XElement("vatTable"));

            var documentVatTableEntries = from node in xml.Root.Element("commercialDocumentVatTable").Elements()
                                          where node.Element("commercialDocumentHeaderId") != null &&
                                          node.Element("commercialDocumentHeaderId").Value == id.ToUpperString()
                                          orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                                          select node;

            foreach (XElement entry in documentVatTableEntries)
            {
                XElement vtEntry = new XElement("vtEntry");
                outXml.Root.Element("commercialDocument").Element("vatTable").Add(vtEntry);

                foreach (XElement element in entry.Elements())
                {
                    if (element.Name.LocalName != "commercialDocumentHeaderId")
                    {
                        vtEntry.Add(element); //auto-cloning
                    }
                }
            }
        }

        /// <summary>
        /// Converts main <see cref="Document"/> attributes from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Document"/>.</param>
        /// <param name="mainObjectNodeName">Node name of the main object in <c>camelCase</c> notation.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertMainDocumentPaymentsFromDbToBoXmlFormat(XDocument xml, Guid id, string mainObjectNodeName, XDocument outXml)
        {
            string mainObjectColumnName = mainObjectNodeName + "HeaderId";

            if (outXml.Root.Element(mainObjectNodeName).Element("payments") != null)
                outXml.Root.Element(mainObjectNodeName).Element("payments").Remove();

            var documentPayments = from node in xml.Root.Element("payment").Elements()
                                   where node.Element(mainObjectColumnName) != null &&
                                   node.Element(mainObjectColumnName).Value == id.ToUpperString()
                                   orderby Convert.ToInt32(node.Element("ordinalNumber").Value, CultureInfo.InvariantCulture) ascending
                                   select node;

            XElement payments = this.ConvertPaymentsFromDbToBoXmlFormat(xml, documentPayments);
            outXml.Root.Element(mainObjectNodeName).Add(payments);
        }

        private XElement ConvertPaymentsFromDbToBoXmlFormat(XDocument xml, IEnumerable<XElement> paymentsEntries)
        {
            XElement payments = new XElement("payments");

            ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();

            foreach (XElement entry in paymentsEntries)
            {
                XElement payment = new XElement("payment");
                payments.Add(payment);

                foreach (XElement element in entry.Elements())
                {
                    if (element.Name.LocalName != "contractorId")
                    {
                        payment.Add(element); //auto-cloning
                    }
                    else if (element.Name.LocalName == "contractorId")
                    {
                        //convert the contractor
                        XElement contractor = contractorMapper.ConvertDBToBoXmlFormat(xml, new Guid(element.Value)).Root.Element("contractor");
						
                        if (contractor.Attribute("type") == null)
                            contractor.Add(new XAttribute("type", "Contractor"));
                        
						payment.Add(new XElement("contractor", contractor));
                    }
                }

                this.ConvertPaymentSettlementsFromDbToBoXmlFormat(xml, payment);
            }

            return payments;
        }

        private void ConvertPaymentSettlementsFromDbToBoXmlFormat(XDocument xml, XElement payment)
        {
            if (xml.Root.Element("paymentSettlement") == null)
                return;

            XElement paymentSettlementsElement = null;

            if ((paymentSettlementsElement = payment.Element("settlements")) == null)
            {
                paymentSettlementsElement = new XElement("settlements");
                payment.Add(paymentSettlementsElement);
            }

            string paymentId = payment.Element("id").Value;

            var paymentSettlements = xml.Root.Element("paymentSettlement").Elements().Where(p => p.Element("incomePaymentId").Value == paymentId || p.Element("outcomePaymentId").Value == paymentId);

            foreach (XElement paymentSettlementEntry in paymentSettlements)
            {
                XElement paymentSettlement = new XElement("settlement");
                paymentSettlementsElement.Add(paymentSettlement);

                foreach (XElement column in paymentSettlementEntry.Elements())
                {
                    if (column.Name.LocalName != "incomePaymentId"
                        && column.Name.LocalName != "outcomePaymentId")
                        paymentSettlement.Add(column);
                    else if ((column.Name.LocalName == "incomePaymentId" || column.Name.LocalName == "outcomePaymentId") && column.Value != paymentId)
                    {
                        XElement relatedPayment = xml.Root.Element("payment").Elements().Where(x => x.Element("id").Value == column.Value).FirstOrDefault();

                        if (relatedPayment == null)
                            paymentSettlement.Add(new XElement("relatedPayment", new XElement("payment", new XElement("id", column.Value))));
                        else
                        {
                            paymentSettlement.Add(new XElement("relatedPayment", new XElement("payment", relatedPayment.Elements())));
                        }
                    }
                }
            }
        }

        private XElement ConvertDocumentRelationsFromDbToBoXmlFormat(XDocument xml, Guid id)
        {
            XElement relations = new XElement("relations");

            XElement documentRelationTable = xml.Root.Element("documentRelation");

            if (documentRelationTable != null)
            {
                foreach (XElement entry in documentRelationTable.Elements())
                {
                    XElement firstCommercialDocumentHeaderId = entry.Element("firstCommercialDocumentHeaderId");
                    XElement secondCommercialDocumentHeaderId = entry.Element("secondCommercialDocumentHeaderId");
                    XElement firstWarehouseDocumentHeaderId = entry.Element("firstWarehouseDocumentHeaderId");
                    XElement secondWarehouseDocumentHeaderId = entry.Element("secondWarehouseDocumentHeaderId");
                    XElement firstFinancialDocumentHeaderId = entry.Element("firstFinancialDocumentHeaderId");
                    XElement secondFinancialDocumentHeaderId = entry.Element("secondFinancialDocumentHeaderId");
                    XElement firstComplaintDocumentHeaderId = entry.Element("firstComplaintDocumentHeaderId");
                    XElement secondComplaintDocumentHeaderId = entry.Element("secondComplaintDocumentHeaderId");
                    XElement firstInventoryDocumentHeaderId = entry.Element("firstInventoryDocumentHeaderId");
                    XElement secondInventoryDocumentHeaderId = entry.Element("secondInventoryDocumentHeaderId");

                    if (firstCommercialDocumentHeaderId != null && new Guid(firstCommercialDocumentHeaderId.Value) == id ||
                        secondCommercialDocumentHeaderId != null && new Guid(secondCommercialDocumentHeaderId.Value) == id ||
                        firstWarehouseDocumentHeaderId != null && new Guid(firstWarehouseDocumentHeaderId.Value) == id ||
                        secondWarehouseDocumentHeaderId != null && new Guid(secondWarehouseDocumentHeaderId.Value) == id ||
                        firstFinancialDocumentHeaderId != null && new Guid(firstFinancialDocumentHeaderId.Value) == id ||
                        secondFinancialDocumentHeaderId != null && new Guid(secondFinancialDocumentHeaderId.Value) == id ||
                        firstComplaintDocumentHeaderId != null && new Guid(firstComplaintDocumentHeaderId.Value) == id ||
                        secondComplaintDocumentHeaderId != null && new Guid(secondComplaintDocumentHeaderId.Value) == id ||
                        firstInventoryDocumentHeaderId != null && new Guid(firstInventoryDocumentHeaderId.Value) == id ||
                        secondInventoryDocumentHeaderId != null && new Guid(secondInventoryDocumentHeaderId.Value) == id)
                    {
                        //znalezlismy jakas relacje tego dokuemntu
                        XElement relation = new XElement("relation");
                        relations.Add(relation);
                        relation.Add(entry.Element("id"));
                        relation.Add(entry.Element("version"));
                        relation.Add(entry.Element("relationType"));

                        XElement relatedDocument = null;

                        if (firstCommercialDocumentHeaderId != null && new Guid(firstCommercialDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("commercialDocument", new XElement("id", firstCommercialDocumentHeaderId.Value), new XAttribute("type", "CommercialDocument"));
                        else if (secondCommercialDocumentHeaderId != null && new Guid(secondCommercialDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("commercialDocument", new XElement("id", secondCommercialDocumentHeaderId.Value), new XAttribute("type", "CommercialDocument"));
                        else if (firstWarehouseDocumentHeaderId != null && new Guid(firstWarehouseDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("warehouseDocument", new XElement("id", firstWarehouseDocumentHeaderId.Value), new XAttribute("type", "WarehouseDocument"));
                        else if (secondWarehouseDocumentHeaderId != null && new Guid(secondWarehouseDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("warehouseDocument", new XElement("id", secondWarehouseDocumentHeaderId.Value), new XAttribute("type", "WarehouseDocument"));
                        else if (firstFinancialDocumentHeaderId != null && new Guid(firstFinancialDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("financialDocument", new XElement("id", firstFinancialDocumentHeaderId.Value), new XAttribute("type", "FinancialDocument"));
                        else if (secondFinancialDocumentHeaderId != null && new Guid(secondFinancialDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("financialDocument", new XElement("id", secondFinancialDocumentHeaderId.Value), new XAttribute("type", "FinancialDocument"));
                        else if (firstComplaintDocumentHeaderId != null && new Guid(firstComplaintDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("complaintDocument", new XElement("id", firstComplaintDocumentHeaderId.Value), new XAttribute("type", "ComplaintDocument"));
                        else if (secondComplaintDocumentHeaderId != null && new Guid(secondComplaintDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("complaintDocument", new XElement("id", secondComplaintDocumentHeaderId.Value), new XAttribute("type", "ComplaintDocument"));
                        else if (firstInventoryDocumentHeaderId != null && new Guid(firstInventoryDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("inventoryDocument", new XElement("id", firstInventoryDocumentHeaderId.Value), new XAttribute("type", "InventoryDocument"));
                        else if (secondInventoryDocumentHeaderId != null && new Guid(secondInventoryDocumentHeaderId.Value) != id)
                            relatedDocument = new XElement("inventoryDocument", new XElement("id", secondInventoryDocumentHeaderId.Value), new XAttribute("type", "InventoryDocument"));

                       relation.Add(new XElement("relatedDocument", relatedDocument));
                    }
                }
            }

            return relations;
        }

        /// <summary>
        /// Converts main <see cref="Document"/> attributes from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Document"/>.</param>
        /// <param name="mainObjectNodeName">Node name of the main object in <c>camelCase</c> notation.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertMainDocumentAttributesFromDbToBoXmlFormat(XDocument xml, Guid id, string mainObjectNodeName, XDocument outXml)
        {
            string mainObjectColumnName =  mainObjectNodeName == "offerDocument" ? "offerId" : mainObjectNodeName + "HeaderId";

            if (outXml.Root.Element(mainObjectNodeName).Element("attributes") == null)
                outXml.Root.Element(mainObjectNodeName).Add(new XElement("attributes"));

            var documentAttributes = from node in xml.Root.Element("documentAttrValue").Elements()
                                     where node.Element(mainObjectColumnName) != null &&
                                     node.Element(mainObjectColumnName).Value == id.ToUpperString()
                                     orderby Convert.ToInt32(node.Element("order").Value, CultureInfo.InvariantCulture) ascending
                                     select node;

            foreach (XElement entry in documentAttributes)
            {
                XElement attribute = new XElement("attribute");
                outXml.Root.Element(mainObjectNodeName).Element("attributes").Add(attribute);

				foreach (XElement attrElement in entry.Elements())
                {
                    if (attrElement.Name.LocalName != mainObjectColumnName)
                    {
						if (!VariableColumnName.IsVariableColumnName(attrElement.Name.LocalName))
                            attribute.Add(attrElement); //auto-cloning
                        else
                        {
							DocumentField cf = DictionaryMapper.Instance.GetDocumentField(new Guid(entry.Element(XmlName.DocumentFieldId).Value));

							string dataType = cf.DataType;

							if (dataType != DataType.Xml)
								attribute.Add(new XElement(XmlName.Value, BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(attrElement.Value, dataType)));
                            else
								attribute.Add(new XElement(XmlName.Value, attrElement.Elements()));
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Converts main <see cref="Document"/> lines from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Document"/>.</param>
        /// <param name="mainObjectNodeName">Node name of the main object in <c>camelCase</c> notation.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertMainDocumentLinesFromDbToBoXmlFormat(XDocument xml, Guid id, string mainObjectNodeName, XDocument outXml, string xmlCollectionNodeName, string linesTableName, string mainObjectColumnName, string xmlLineName)
        {
            if (outXml.Root.Element(mainObjectNodeName).Element(xmlCollectionNodeName) != null)
                outXml.Root.Element(mainObjectNodeName).Element(xmlCollectionNodeName).Remove();

            var mainDocument = from node in xml.Root.Element(linesTableName).Elements()
                               where node.Element(mainObjectColumnName).Value == id.ToUpperString()
                               orderby Convert.ToInt32(node.Element("ordinalNumber").Value, CultureInfo.InvariantCulture) ascending
                               select node;

            XElement lines = this.ConvertLinesFromDbToBoXmlFormat(xml, mainDocument, mainObjectNodeName, mainObjectColumnName, xmlCollectionNodeName, xmlLineName);
            outXml.Root.Element(mainObjectNodeName).Add(lines);
        }

        private XElement ConvertLinesFromDbToBoXmlFormat(XDocument xml, IEnumerable<XElement> lines, string mainObjectNodeName, string mainObjectColumnName, string xmlCollectionName, string xmlLineName)
        {
            XElement retXml = new XElement(xmlCollectionName);

            foreach (XElement entry in lines)
            {
                XElement line = new XElement(xmlLineName);
                retXml.Add(line);

                foreach (XElement element in entry.Elements())
                {
                    if (element.Name.LocalName == "correctedCommercialDocumentLineId")
                    {
                        line.Add(new XElement("correctedLine", new XElement("line", new XElement("id", element.Value))));
                    }
                    else if (element.Name.LocalName == "correctedWarehouseDocumentLineId")
                    {
                        line.Add(new XElement("correctedLine", new XElement("line", new XElement("id", element.Value))));
                    }
                    else if (element.Name.LocalName == "initialWarehouseDocumentLineId")
                    {
                        line.Add(new XElement("initialLine", new XElement("line", new XElement("id", element.Value))));
                    }
                    else if (element.Name.LocalName == "initialIncomeWarehouseDocumentLineId")
                    {
                        line.Add(new XElement("initialIncomeLine", new XElement("line", new XElement("id", element.Value))));
                    }
                    else if (element.Name.LocalName != mainObjectColumnName)
                    {
                        line.Add(element); //auto-cloning
                    }
                }

                //convert incomeOutcomeRelations
                if (mainObjectNodeName == "warehouseDocument")
                    this.ConvertIncomeOutcomeRelations(xml, line);
                else if (mainObjectNodeName == "complaintDocument")
                    this.ConvertComplaintDecisions(xml, line);

                this.ConvertCommercialWarehouseValuations(xml, line);
                this.ConvertCommercialWarehouseRelations(xml, line);
                this.ConvertDocumentLineAttributes(xml, line);
            }

            return retXml;
        }

        /// <summary>
        /// Converts the commercial warehouse valuations for both commercial and warehouse document lines.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="line">The line.</param>
        private void ConvertCommercialWarehouseValuations(XDocument xml, XElement line)
        {
            if (xml.Root.Element("commercialWarehouseValuation") == null)
                return;

            string lineId = line.Element("id").Value;

            XElement commercialWarehouseValuations = new XElement("commercialWarehouseValuations");
            line.Add(commercialWarehouseValuations);

            var relations = from entry in xml.Root.Element("commercialWarehouseValuation").Elements()
                            where (entry.Element("commercialDocumentLineId") != null && entry.Element("commercialDocumentLineId").Value == lineId)
                            || (entry.Element("warehouseDocumentLineId") != null && entry.Element("warehouseDocumentLineId").Value == lineId)
                            select entry;

            foreach (XElement relation in relations)
            {
                XElement commercialWarehouseValuation = XElement.Parse("<commercialWarehouseValuation><id/><quantity/><price/><value/><version/></commercialWarehouseValuation>");
                commercialWarehouseValuations.Add(commercialWarehouseValuation);

                commercialWarehouseValuation.Element("id").Value = relation.Element("id").Value;
                commercialWarehouseValuation.Element("quantity").Value = relation.Element("quantity").Value;
                commercialWarehouseValuation.Element("price").Value = relation.Element("price").Value;
                commercialWarehouseValuation.Element("value").Value = relation.Element("value").Value;
                commercialWarehouseValuation.Element("version").Value = relation.Element("version").Value;

                if (relation.Element("warehouseDocumentLineId") != null && relation.Element("warehouseDocumentLineId").Value == lineId && relation.Element("commercialDocumentLineId") != null)
                    commercialWarehouseValuation.Add(new XElement("relatedLine", new XElement("line", new XElement("id", relation.Element("commercialDocumentLineId").Value))));
                else if (relation.Element("commercialDocumentLineId") != null && relation.Element("commercialDocumentLineId").Value == lineId && relation.Element("warehouseDocumentLineId") != null)
                    commercialWarehouseValuation.Add(new XElement("relatedLine", new XElement("line", new XElement("id", relation.Element("warehouseDocumentLineId").Value))));
            }
        }

        private void ConvertCommercialWarehouseRelations(XDocument xml, XElement line)
        {
            if (xml.Root.Element("commercialWarehouseRelation") == null)
                return;

            string lineId = line.Element("id").Value;

            XElement commercialWarehouseRelations = new XElement("commercialWarehouseRelations");
            line.Add(commercialWarehouseRelations);

            var relations = from entry in xml.Root.Element("commercialWarehouseRelation").Elements()
                            where entry.Element("commercialDocumentLineId").Value == lineId
                            || entry.Element("warehouseDocumentLineId").Value == lineId
                            select entry;

            foreach (XElement relation in relations)
            {
                XElement commercialWarehouseRelation = XElement.Parse("<commercialWarehouseRelation><id/><quantity/><isValuated/><value/><isOrderRelation/><isCommercialRelation/><version/></commercialWarehouseRelation>");
                commercialWarehouseRelations.Add(commercialWarehouseRelation);

                commercialWarehouseRelation.Element("id").Value = relation.Element("id").Value;
                commercialWarehouseRelation.Element("quantity").Value = relation.Element("quantity").Value;
                commercialWarehouseRelation.Element("isValuated").Value = relation.Element("isValuated").Value;
                commercialWarehouseRelation.Element("value").Value = relation.Element("value").Value;
                commercialWarehouseRelation.Element("isOrderRelation").Value = relation.Element("isOrderRelation").Value;
                commercialWarehouseRelation.Element("isCommercialRelation").Value = relation.Element("isCommercialRelation").Value;
                commercialWarehouseRelation.Element("version").Value = relation.Element("version").Value;

                if (relation.Element("warehouseDocumentLineId") != null && relation.Element("warehouseDocumentLineId").Value == lineId && relation.Element("commercialDocumentLineId") != null)
                    commercialWarehouseRelation.Add(new XElement("relatedLine", new XElement("line", new XElement("id", relation.Element("commercialDocumentLineId").Value))));
                else if (relation.Element("commercialDocumentLineId") != null && relation.Element("commercialDocumentLineId").Value == lineId && relation.Element("warehouseDocumentLineId") != null)
                    commercialWarehouseRelation.Add(new XElement("relatedLine", new XElement("line", new XElement("id", relation.Element("warehouseDocumentLineId").Value))));
            }
        }

        private void ConvertDocumentLineAttributes(XDocument xml, XElement line)
        {
            if (xml.Root.Element("documentLineAttrValue") == null)
                return;

            string lineId = line.Element("id").Value;

            XElement attributes = new XElement("attributes");
            line.Add(attributes);

            var entries = from entry in xml.Root.Element("documentLineAttrValue").Elements()
						  where (entry.GetTextValueOrNull("commercialDocumentLineId") == lineId)
                          || (entry.GetTextValueOrNull("warehouseDocumentLineId") == lineId)
                          orderby Convert.ToInt32(entry.Element("order").Value, CultureInfo.InvariantCulture) ascending
                          select entry;

            foreach (XElement entry in entries)
            {
                XElement attribute = new XElement("attribute");
                attributes.Add(attribute);

                foreach (XElement attrElement in entry.Elements())
                {
                    if (!VariableColumnName.IsVariableColumnName(attrElement.Name.LocalName))
                        attribute.Add(attrElement); //auto-cloning
                    else
                    {
                        DocumentField cf = DictionaryMapper.Instance.GetDocumentField(new Guid(entry.Element("documentFieldId").Value));

                        string dataType = cf.Metadata.Element("dataType").Value;

                        if (dataType != "xml")
                            attribute.Add(new XElement("value", BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(attrElement.Value, dataType)));
                        else
                            attribute.Add(new XElement("value", attrElement.Elements()));
                    }
                }
            }
        }

        private void ConvertComplaintDecisions(XDocument xml, XElement line)
        {
            string lineId = line.Element("id").Value;

            XElement complaintDecisions = new XElement("complaintDecisions");
            line.Add(complaintDecisions);

            var entries = from entry in xml.Root.Element("complaintDecision").Elements()
                          where (entry.Element("complaintDocumentLineId") != null && entry.Element("complaintDocumentLineId").Value == lineId)
                          orderby Convert.ToInt32(entry.Element("order").Value, CultureInfo.InvariantCulture) ascending
                          select entry;

            foreach (XElement entry in entries)
            {
                XElement complaintDecision = new XElement("complaintDecision");
                complaintDecisions.Add(complaintDecision);

                complaintDecision.Add(entry.Elements()); //dodajemy kazda kolumne jak leci
            }
        }

        /// <summary>
        /// Converts the income outcome relations for warehouse document line.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="line">The line.</param>
        private void ConvertIncomeOutcomeRelations(XDocument xml, XElement line)
        {
            string lineId = line.Element("id").Value;

            XElement incomeOutcomeRelations = new XElement("incomeOutcomeRelations");
            line.Add(incomeOutcomeRelations);

            var relations = from entry in xml.Root.Element("incomeOutcomeRelation").Elements()
                            where entry.Element("incomeWarehouseDocumentLineId").Value == lineId
                            || entry.Element("outcomeWarehouseDocumentLineId").Value == lineId
                            select entry;

            foreach (XElement relation in relations)
            {
                XElement incomeOutcomeRelation = XElement.Parse("<incomeOutcomeRelation><id/><quantity/><incomeDate/><version/><relatedLine><line><id></id></line></relatedLine></incomeOutcomeRelation>");
                incomeOutcomeRelations.Add(incomeOutcomeRelation);

                incomeOutcomeRelation.Element("id").Value = relation.Element("id").Value;
                incomeOutcomeRelation.Element("quantity").Value = relation.Element("quantity").Value;
                incomeOutcomeRelation.Element("incomeDate").Value = relation.Element("incomeDate").Value;
                incomeOutcomeRelation.Element("version").Value = relation.Element("version").Value;

                if (relation.Element("incomeWarehouseDocumentLineId").Value == lineId)
                {
                    incomeOutcomeRelation.Element("relatedLine").Element("line").Element("id").Value = relation.Element("outcomeWarehouseDocumentLineId").Value;
                    incomeOutcomeRelation.Add(new XAttribute("direction", (int)WarehouseDirection.Income));
                }
                else
                {
                    incomeOutcomeRelation.Element("relatedLine").Element("line").Element("id").Value = relation.Element("incomeWarehouseDocumentLineId").Value;
                    incomeOutcomeRelation.Add(new XAttribute("direction", (int)WarehouseDirection.Outcome));
                }
            }
        }

        private void ConvertSingleSheetFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            XElement sheet = xml.Root.Element("inventorySheet").Elements().Where(e => e.Element("id").Value == id.ToUpperString()).First();

            XElement inventorySheet = new XElement("inventorySheet", new XAttribute("type", "InventorySheet"));
            outXml.Root.Add(inventorySheet);
            inventorySheet.Add(sheet.Elements());

            var lines = this.ConvertLinesFromDbToBoXmlFormat(xml, xml.Root.Element("inventorySheetLine").Elements().OrderBy(l => Convert.ToInt32(l.Element("ordinalNumber").Value, CultureInfo.InvariantCulture)), "inventorySheet", "inventorySheetId", "lines", "line");

            if (lines != null)
                inventorySheet.Add(lines);
        }

        private void ConvertOnePaymentFromDbToBoXmlFormat(XDocument xml, Guid id, XDocument outXml)
        {
            string paymentId = id.ToUpperString();
            XElement payments = this.ConvertPaymentsFromDbToBoXmlFormat(xml, xml.Root.Element("payment").Elements().Where(x => x.Element("id").Value == paymentId));
            outXml.Root.RemoveAll();
            outXml.Root.Add(payments.FirstNode);
        }

        private XElement ConvertDocumentFromDbToBoXmlFormat(XDocument xml, Guid id, string mainObjectNodeName, string mainObjectTableName)
        {
            var mainDocument = from node in xml.Root.Element(mainObjectTableName).Elements()
                               where node.Element("id").Value == id.ToUpperString()
                               select node;

            ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();

            XElement xmlConstantDataElement = null;

            XElement retDocument = new XElement(mainObjectNodeName);

            foreach (XElement element in mainDocument.ElementAt(0).Elements())
            {
                if (element.Name.LocalName != "contractorId"
                    && element.Name.LocalName != "receivingPersonContractorId"
                    && element.Name.LocalName != "issuerContractorId"
                    && element.Name.LocalName != "issuingPersonContractorId"
                    && element.Name.LocalName != "contractorAddressId"
                    && element.Name.LocalName != "issuerContractorAddressId"
                    && element.Name.LocalName != "xmlConstantData"
                    && element.Name.LocalName != "number"
                    && element.Name.LocalName != "fullNumber"
                    && element.Name.LocalName != "numberSettingId"
                    && element.Name.LocalName != "creatingApplicationUserId"
                    && element.Name.LocalName != "closingApplicationUserId"
                    && element.Name.LocalName != "openingApplicationUserId"
                    && element.Name.LocalName != "amount"
                    && element.Name.LocalName != "financialReportId")
                {
                    retDocument.Add(element); //auto-cloning
                }
                else if (element.Name.LocalName == "number" || element.Name.LocalName == "fullNumber" || element.Name.LocalName == "numberSettingId")
                {
                    XElement numberElement = retDocument.Element("number");

                    if (numberElement == null)
                    {
                        numberElement = new XElement("number");
                        retDocument.Add(numberElement);
                    }

                    numberElement.Add(element);
                }
                else if (element.Name.LocalName == "financialReportId")
                {
                    XElement report = this.ConvertDocumentFromDbToBoXmlFormat(xml, new Guid(element.Value), "financialReport", "financialReport");
                    retDocument.Add(new XElement("financialReport", report));
                }
                else if (element.Name.LocalName == "contractorAddressId")
                {
                    //assumed that contractor will be converted first so the mainObjectNodeName/contractor will be already created
                    retDocument.Element("contractor").Add(new XElement("addressId", element.Value));
                }
                else if (element.Name.LocalName == "amount")
                {
                    if (mainObjectTableName == "financialDocumentHeader")
                    {
                        decimal val = Convert.ToDecimal(element.Value, CultureInfo.InvariantCulture);
                        val = Math.Abs(val);
                        retDocument.Add(new XElement("amount", val.ToString(CultureInfo.InvariantCulture)));
                    }
                    else
                        retDocument.Add(element); //auto-cloning
                }
                else if (element.Name.LocalName == "xmlConstantData")
                {
                    xmlConstantDataElement = new XElement(element);
                }
                else if (element.Name.LocalName == "issuerContractorAddressId")
                {
                    retDocument.Element("issuer").Add(new XElement("addressId", element.Value));
                }
                else //contractors
                {
                    //convert the contractor
                    XElement contractor = contractorMapper.ConvertDBToBoXmlFormat(xml, new Guid(element.Value)).Root.Element("contractor");

                    string boNodeName = null;

                    switch (element.Name.LocalName)
                    {
                        case "contractorId":
                            boNodeName = "contractor";
                            break;
                        case "receivingPersonContractorId":
                            boNodeName = "receivingPerson";
                            break;
                        case "issuerContractorId":
                            boNodeName = "issuer";
                            break;
                        case "issuingPersonContractorId":
                            boNodeName = "issuingPerson";
                            break;
                        case "creatingApplicationUserId":
                            boNodeName = "creatingUser";
                            break;
                        case "closingApplicationUserId":
                            boNodeName = "closingUser";
                            break;
                        case "openingApplicationUserId":
                            boNodeName = "openingUser";
                            break;
                    }

                    retDocument.Add(new XElement(boNodeName, contractor));
                }
            }
            
            this.RestoreConstantData(retDocument, xmlConstantDataElement);

            //set the proper type
            if (retDocument.Attribute("type") == null)
            {
                retDocument.Add(new XAttribute("type", mainObjectNodeName.Capitalize()));
            }

            return retDocument;
        }

        /// <summary>
        /// Converts main <see cref="Document"/> from database xml format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Full xml with all tables in database format.</param>
        /// <param name="id">Id of the main <see cref="Document"/>.</param>
        /// <param name="mainObjectNodeName">Node name of the main object in <c>camelCase</c> notation.</param>
        /// <param name="outXml">Output xml in <see cref="BusinessObject"/>'s xml format.</param>
        private void ConvertMainDocumentFromDbToBoXmlFormat(XDocument xml, Guid id, string mainObjectNodeName, string mainObjectTableName, XDocument outXml)
        {
            XElement doc = this.ConvertDocumentFromDbToBoXmlFormat(xml, id, mainObjectNodeName, mainObjectTableName);
            outXml.Root.Add(doc);
        }

        /// <summary>
        /// Restores the constant data to the business object xml.
        /// </summary>
        /// <param name="outXml">Output full xml in BO format.</param>
        /// <param name="constantData">Xml element with constant data.</param>
        private void RestoreConstantData(XElement mainDocument, XElement constantData)
        {
            if (constantData == null || constantData.Element("constant") == null)
                return;

            foreach (XElement element in constantData.Element("constant").Elements())
            {
                if (element.Name.LocalName == "contractor" || element.Name.LocalName == "receivingPerson" ||
                    element.Name.LocalName == "issuer" || element.Name.LocalName == "issuingPerson")
                {
                    foreach (XElement contractorElement in element.Elements())
                    {
						XElement contractorFieldSourceElement = mainDocument.Element(element.Name).Element("contractor").Element(contractorElement.Name);
						if (contractorFieldSourceElement != null)
						{
							string contractorElementName = contractorElement.Name.LocalName;
							if (contractorElementName != "addresses"
								&& contractorElementName != XmlName.Accounts && contractorElementName != XmlName.Attributes)
							{
								contractorFieldSourceElement.Value = contractorElement.Value;
							}
							else if (contractorElementName == XmlName.Attributes)
							{
								foreach(XElement contractorAttributeElement in contractorElement.Elements())
								{
									XElement prvAttrElement = contractorFieldSourceElement.Elements(XmlName.Attribute)
										.Where(el => el.Element(XmlName.ContractorFieldId).Value 
											== contractorAttributeElement.Element(XmlName.ContractorFieldId).Value).FirstOrDefault();
									if (prvAttrElement != null)
									{
										prvAttrElement.ReplaceWith(contractorAttributeElement);
									}
									else
									{
										contractorFieldSourceElement.Add(contractorAttributeElement);
									}
								}
							}
							else
							{
								contractorFieldSourceElement.Remove();
								mainDocument.Element(element.Name).Element("contractor").Add(contractorElement); //replace the addresses
							}
						}
						else
						{
							mainDocument.Element(element.Name).Element("contractor").Add(contractorElement);
						}
                    }
                }
            }
        }

        internal GetFinancialReportValidationDatesResponse GetFinancialReportValidationDates(Guid financialRegisterId, DateTime creationDate, Guid financialReportId, bool isNew)
        {
            XDocument xml = XDocument.Parse("<root/>");
			if (isNew)
			{
				xml.Root.Add(new XAttribute("isNew", "1"));
			}
            xml.Root.Add(new XElement("financialRegisterId", financialRegisterId.ToUpperString()));
            xml.Root.Add(new XElement("financialReportId", financialReportId.ToUpperString()));
            xml.Root.Add(new XElement("creationDate", creationDate.ToIsoString()));
            xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_getFinancialReportValidationDates, true, xml);
            GetFinancialReportValidationDatesResponse response = new GetFinancialReportValidationDatesResponse();

            if (xml.Root.Element("previousFinancialReportClosureDate") != null)
                response.PreviousFinancialReportClosureDate = DateTime.Parse(xml.Root.Element("previousFinancialReportClosureDate").Value, CultureInfo.InvariantCulture);

            if (xml.Root.Element("nextFinancialReportOpeningDate") != null)
                response.NextFinancialReportOpeningDate = DateTime.Parse(xml.Root.Element("nextFinancialReportOpeningDate").Value, CultureInfo.InvariantCulture);

            if (xml.Root.Element("greatestIssueDateOnFinancialDocument") != null)
                response.GreatestIssueDateOnFinancialDocument = DateTime.Parse(xml.Root.Element("greatestIssueDateOnFinancialDocument").Value, CultureInfo.InvariantCulture);

            return response;
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
            IBusinessObject bo = base.ConvertToBusinessObject(objectXml, options);

            if (options != null)
            {
                Document document = (Document)bo;
                foreach (XElement xmlOption in options.Elements())
                {
                    if (xmlOption.Attribute("selected") != null && xmlOption.Attribute("selected").Value == "0")
                        continue;

					if (xmlOption.Name.LocalName == DocumentOptionName.GenerateDocument)
						document.DocumentOptions.Add(new GenerateDocumentOption(xmlOption));
					else if (xmlOption.Name.LocalName == DocumentOptionName.RealizeOrder)
						document.DocumentOptions.Add(new RealizeOrderOption());
					else if (xmlOption.Name.LocalName == DocumentOptionName.DisableRemoteOrderSending)
						document.DocumentOptions.Add(new DisableRemoteOrderSendingOption());
					else if (xmlOption.Name.LocalName == DocumentOptionName.CloseProcess)
						document.DocumentOptions.Add(new CloseProcessOption());
					else if (xmlOption.Name.LocalName == DocumentOptionName.UpdateItemsDefaultPrice)
						document.DocumentOptions.Add(new UpdateItemsDefaultPriceOption());
                }
            }

            //deserializacja shifttransakcji
            if (objectXml.Parent != null && objectXml.Parent.Element("shiftTransaction") != null)
            {
                WarehouseMapper whMapper = DependencyContainerManager.Container.Get<WarehouseMapper>();
                XElement stElement = objectXml.Parent.Element("shiftTransaction");
                ShiftTransaction st = (ShiftTransaction)whMapper.ConvertToBusinessObject(stElement, null);

                CommercialDocument commercialDocument = bo as CommercialDocument;
                WarehouseDocument warehouseDocument = bo as WarehouseDocument;

                if (commercialDocument != null)
                    commercialDocument.ShiftTransaction = st;
                else
                    warehouseDocument.ShiftTransaction = st;
            }

            if (objectXml.Parent != null && objectXml.Parent.Element("allocations") != null)
            {
                IAllocationOwner shiftsOwner = bo as IAllocationOwner;

                if (shiftsOwner != null)
                    shiftsOwner.AllocationCollection = new AllocationCollection(objectXml.Parent.Element("allocations"));
            }

            return bo;
        }

        public void DeleteDraft(Guid draftId)
        {
            this.ExecuteStoredProcedure(StoredProcedure.document_p_deleteDraft, true, new XDocument(new XElement("root", new XElement("id", draftId.ToUpperString()))));
        }

        public string GetDocumentContractorFullName(Guid commercialDocumentHeaderId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getDocumentContractorFullName, true, "@commercialDocumentHeaderId", commercialDocumentHeaderId);

            if (xml.Root.Value == String.Empty)
                return null;
            else
                return xml.Root.Value;
        }

        internal ICollection<GetHeadersIdForWarehouseLinesResponse> GetHeadersIdForWarehouseLines(ICollection<Guid> linesId)
        {
            XDocument xml = XDocument.Parse("<root/>");

            foreach (Guid id in linesId)
            {
                xml.Root.Add(new XElement("line", new XAttribute("id", id.ToUpperString())));
            }

            if (xml.Root.HasElements)
                xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getHeaderIdForWarehouseLines, true, xml);

            List<GetHeadersIdForWarehouseLinesResponse> response = new List<GetHeadersIdForWarehouseLinesResponse>();

            foreach (XElement line in xml.Root.Elements())
            {
                response.Add(new GetHeadersIdForWarehouseLinesResponse(line));
            }

            return response;
        }

        internal CalculateReportBalanceResponse CalculateReportBalance(Guid financialReportId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("financialReportId", financialReportId.ToUpperString()));
            xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_calculateReportBalance, true, xml);

            CalculateReportBalanceResponse response = new CalculateReportBalanceResponse();
            response.IncomeAmount = Convert.ToDecimal(xml.Root.Element("incomeAmount").Value, CultureInfo.InvariantCulture);
            response.OutcomeAmount = Convert.ToDecimal(xml.Root.Element("outcomeAmount").Value, CultureInfo.InvariantCulture);

            return response;
        }

        public void CreateShiftCorrection(Guid correctiveWarehouseDocumentHeaderId, Guid shiftTransactionId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("correctiveWarehouseDocumentHeaderId", correctiveWarehouseDocumentHeaderId.ToUpperString()));
            xml.Root.Add(new XElement("shiftTransactionId", shiftTransactionId.ToUpperString()));

            this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_createIncomeShiftCorrection, false, xml);
        }

        public decimal CalculateReportInitialBalance(Guid financialRegisterId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("financialRegisterId", financialRegisterId.ToUpperString()));
            xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_calculateReportInitialBalance, true, xml);
            return Convert.ToDecimal(xml.Root.Value, CultureInfo.InvariantCulture);
        }

        public bool AreLaterCorrectionExist(Guid documentId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_checkForLaterCorrectionsExistence, true, "@documentId", documentId);

            return Convert.ToBoolean(xml.Root.Value, CultureInfo.InvariantCulture);
        }

        public ICollection<Guid> GetRelatedFinancialDocumentsId(Guid commercialDocumentHeaderId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("commercialDocumentHeaderId", commercialDocumentHeaderId.ToUpperString()));

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getRelatedFinancialDocumentsId, true, xml);

            List<Guid> identifiers = new List<Guid>();

            foreach (XElement id in xml.Root.Elements())
                identifiers.Add(new Guid(id.Value));

            return identifiers;
        }

        public XDocument GetNextFinancialReportsId(Guid startingReportId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("financialReportId", startingReportId.ToUpperString()));

            return this.ExecuteStoredProcedure(StoredProcedure.finance_p_getNextFinancialReportsId, true, xml);
        }

		public decimal GetFinancialReportBalance(Guid financialReportId)
		{			
			XDocument tmpResult = this.GetRegistersOpenReports();

			decimal result = tmpResult.Root.Elements()
				.Where(el => el.Attribute(XmlName.FinancialRegisterId) != null && new Guid(el.Attribute(XmlName.FinancialRegisterId).Value) == financialReportId)
				.Select(el => el.Attribute(XmlName.Balance) != null ? Convert.ToDecimal(el.Attribute(XmlName.Balance).Value, CultureInfo.InvariantCulture) : 0)
				.FirstOrDefault();

			return result;
		}

		internal XDocument GetRegistersOpenReports()
		{
			XDocument input = XDocument.Parse(String.Format("<root><branchId>{0}</branchId></root>", SessionManager.User.BranchId));
			return this.ExecuteStoredProcedure(StoredProcedure.finance_p_getRegistersOpenReports, true, input);
		}

        internal void DeleteDocumentAccountingData(Document document)
        {
            if (!ConfigurationMapper.Instance.IsHeadquarter || document.Status != BusinessObjectStatus.Modified) return;

            XDocument xml = new XDocument(new XElement("root"));

            if (document.BOType == BusinessObjectType.CommercialDocument)
                xml.Root.Add(new XElement("commercialDocumentHeaderId", document.Id.ToUpperString()));
            else if (document.BOType == BusinessObjectType.FinancialDocument)
                xml.Root.Add(new XElement("financialDocumentHeaderId", document.Id.ToUpperString()));
            else if (document.BOType == BusinessObjectType.WarehouseDocument)
                xml.Root.Add(new XElement("warehouseDocumentHeaderId", document.Id.ToUpperString()));
            else
                return;

            this.ExecuteStoredProcedure(StoredProcedure.accounting_p_deleteAccountingDocumentData, false, xml);
        }

        internal void UpdateDocumentInfoOnPayments(Document document)
        {
            string symbol = document.Symbol;
            string issueDate = document.IssueDate.ToIsoString().Substring(0, 10);
            string branchSymbol = DictionaryMapper.Instance.GetBranch(SessionManager.User.BranchId).Symbol;

            string documentInfo = String.Format(CultureInfo.InvariantCulture, "{0};[fullNumber];{1};{2}", symbol, issueDate, branchSymbol);

            XDocument xml = XDocument.Parse("<root/>");

            Payments paymentsCollection = null;

            if (document.BOType == BusinessObjectType.CommercialDocument)
            {
                xml.Root.Add(new XElement("commercialDocumentHeaderId", document.Id.ToUpperString()));
                paymentsCollection = ((CommercialDocument)document).Payments;
            }
            else if (document.BOType == BusinessObjectType.FinancialDocument)
            {
                xml.Root.Add(new XElement("financialDocumentHeaderId", document.Id.ToUpperString()));
                FinancialDocument fDoc = (FinancialDocument)document;
                paymentsCollection = fDoc.Payments;

                if (fDoc.RelatedCommercialDocument != null)
                {
                    xml.Root.Add(new XElement("relatedCommercialDocumentHeaderId", fDoc.RelatedCommercialDocument.Id.ToUpperString()));
                    xml.Root.Add(new XElement("description", SessionManager.PaymentForDocumentLabel));
                }
            }
            else
                throw new NotSupportedException("Only CommercialDocument and FinancialDocument are supported");

            xml.Root.Add(new XElement("documentInfo", documentInfo));

            XElement payments = new XElement("payments");
            xml.Root.Add(payments);

            foreach (Payment pt in paymentsCollection.Children.Where(p => p.Status == BusinessObjectStatus.New))
            {
                payments.Add(new XElement("id", pt.Id.ToUpperString()));
            }

            if (xml.Root.Element("payments").HasElements)
                this.ExecuteStoredProcedure(StoredProcedure.finance_p_updateDocumentInfoOnPayments, false, xml);
        }

        internal ICollection<Payment> GetPaymentsById(IEnumerable<Guid> idCollection)
        {
            if (idCollection == null)
                return null;

            XDocument xml = XDocument.Parse("<root/>");

            foreach (Guid id in idCollection)
                xml.Root.Add(new XElement("id", id.ToUpperString()));

            if (!xml.Root.HasElements)
                return null;

            xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_getPaymentsById, true, xml);

            List<Payment> payments = new List<Payment>();

            XElement paymentsElement = this.ConvertPaymentsFromDbToBoXmlFormat(xml, xml.Root.Element("payment").Elements());

            foreach (XElement paymentElement in paymentsElement.Elements())
            {
                Payment p = new Payment(null);
                p.Deserialize(paymentElement);
               
                payments.Add(p);
            }

            return payments;
        }

        public bool CheckReportExistence(Guid financialRegisterId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("financialRegisterId", financialRegisterId.ToUpperString()));
            xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_checkReportExistence, true, xml);
            return Convert.ToBoolean(xml.Root.Value, CultureInfo.InvariantCulture);
        }

        internal XElement GetFinancialReportsDate(Guid financialRegisterId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("financialRegisterId", financialRegisterId.ToUpperString()));
            xml = this.ExecuteStoredProcedure(StoredProcedure.finance_p_getFinancialReportsDate, true, xml);
            return xml.Root;
        }

        public ICollection<Guid> GetRelatedWarehouseDocumentsId(Guid commercialDocumentHeaderId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getRelatedWarehouseDocumentsId, true, "@commercialDocumentHeaderId", commercialDocumentHeaderId);

            List<Guid> ids = new List<Guid>();

            foreach (XElement id in xml.Root.Elements())
            {
                ids.Add(new Guid(id.Value));
            }

            return ids;
        }

        internal void UpdateReservationAndOrderStock(WarehouseDocument document)
        {
            XDocument operations = XDocument.Parse("<root><warehouseDocumentLine></warehouseDocumentLine></root>");
            XElement table = operations.Root.Element("warehouseDocumentLine");
            XDocument commXml = XDocument.Parse("<root/>");

            foreach (WarehouseDocumentLine line in document.Lines.Children.Where(l => l.CommercialWarehouseRelations.Children.Where(r => r.IsOrderRelation).FirstOrDefault() != null))
            {
                if (line.Status == BusinessObjectStatus.New || line.Status == BusinessObjectStatus.Modified)
                {
                    if (table.Elements().Where(x => x.Element("itemId").Value == line.ItemId.ToUpperString() && x.Element("warehouseId").Value == line.WarehouseId.ToUpperString()).FirstOrDefault() == null)
                    {
                        Guid? warehouseId = ((CommercialDocumentLine)line.CommercialWarehouseRelations.Children.Where(r => r.IsOrderRelation).First().RelatedLine).WarehouseId;

						if (warehouseId.HasValue)
						{
							table.Add(new XElement("entry", new XElement("itemId", line.ItemId.ToUpperString()), new XElement("warehouseId", warehouseId.ToUpperString()), new XElement("unitId", line.UnitId.ToUpperString())));
							commXml.Root.Add(new XElement("entry", new XElement("itemId", line.ItemId.ToUpperString()), new XElement("warehouseId", warehouseId.ToUpperString()), new XElement("unitId", line.UnitId.ToUpperString())));
						}
                    }
                }
            }

            if (document.AlternateVersion != null)
            {
                WarehouseDocument alternateDocument = (WarehouseDocument)document.AlternateVersion;

                foreach (WarehouseDocumentLine line in alternateDocument.Lines.Children.Where(l => l.CommercialWarehouseRelations.Children.Where(r => r.IsOrderRelation).FirstOrDefault() != null))
                {
                    if (line.Status == BusinessObjectStatus.Deleted &&
                        table.Elements().Where(x => x.Element("itemId").Value == line.ItemId.ToUpperString() && x.Element("warehouseId").Value == line.WarehouseId.ToUpperString()).FirstOrDefault() == null)
                    {
                        Guid? warehouseId = ((CommercialDocumentLine)line.CommercialWarehouseRelations.Children.Where(r => r.IsOrderRelation).First().RelatedLine).WarehouseId;

						if (warehouseId.HasValue)
						{
							table.Add(new XElement("entry",
								new XElement("itemId", line.ItemId.ToUpperString()),
								new XElement("warehouseId", warehouseId.ToUpperString()),
								new XElement("unitId", line.UnitId.ToUpperString())));
							commXml.Root.Add(new XElement("entry",
								new XElement("itemId", line.ItemId.ToUpperString()),
								new XElement("warehouseId", warehouseId.ToUpperString()),
								new XElement("unitId", line.UnitId.ToUpperString())));
						}
                    }

                    WarehouseDocumentLine newLine = line.AlternateVersion as WarehouseDocumentLine; //ze starej wersji idziemy do nowej

                    if (newLine != null && newLine.Direction == 0)
                    {
                        if (table.Elements().Where(x => x.Element("itemId").Value == line.ItemId.ToUpperString() && x.Element("warehouseId").Value == line.WarehouseId.ToUpperString()).FirstOrDefault() == null)
                        {
							Guid? warehouseId = ((CommercialDocumentLine)line.CommercialWarehouseRelations.Children.Where(r => r.IsOrderRelation).First().RelatedLine).WarehouseId;

							if (warehouseId.HasValue)
							{
								table.Add(new XElement("entry", new XElement("itemId", line.ItemId.ToUpperString()), new XElement("warehouseId", warehouseId.ToUpperString()), new XElement("unitId", line.UnitId.ToUpperString())));
								commXml.Root.Add(new XElement("entry", new XElement("itemId", line.ItemId.ToUpperString()), new XElement("warehouseId", warehouseId.ToUpperString()), new XElement("unitId", line.UnitId.ToUpperString())));
							}
                        }
                    }
                }
            }

            if (operations.Root.Element("warehouseDocumentLine").HasElements)
            {
                WarehouseDirection direction = document.WarehouseDirection;

				//OutcomeShift - gdyż MM- też może realizować rezerwację
				if (direction == WarehouseDirection.Outcome || direction == WarehouseDirection.OutcomeShift)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_updateReservationStock, false, operations);
                else if (direction == WarehouseDirection.Income)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_updateOrderStock, false, operations);

                this.CreateUpdateStockPackage(commXml);
            }
        }

        internal WarehouseDocumentLine GetWarehouseDocumentLineAfterCorrection(WarehouseDocumentLine line, WarehouseDirection direction)
        {
            StoredProcedure sp = StoredProcedure.document_p_getOutcomeLineAfterCorrection;

            if (direction == WarehouseDirection.Income)
                sp = StoredProcedure.document_p_getIncomeLineAfterCorrection;

            XDocument xml = this.ExecuteStoredProcedure(sp, true, "@warehouseDocumentLineId", line.Id.Value);

            if (xml.Root.HasElements)
            {
                XElement lines = this.ConvertLinesFromDbToBoXmlFormat(xml, xml.Root.Element("warehouseDocumentLine").Elements(), "warehouseDocument", "warehouseDocumentHeaderId", "lines", "line");

                WarehouseDocumentLine correctedLine = new WarehouseDocumentLine(null);
                correctedLine.Deserialize(lines.Element("line"));
                correctedLine.ItemName = line.ItemName;
                correctedLine.ItemCode = line.ItemCode;
                return correctedLine;
            }
            else if (xml.Root.Attribute("wasCorrected") != null)
                return line;
            else
                return null;
        }

        public ICollection<GetDocumentCostResponse> GetDocumentCost(Guid commercialDocumentHeaderId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getDocumentCost, true, "@commercialDocumentHeaderId", commercialDocumentHeaderId);

            List<GetDocumentCostResponse> list = new List<GetDocumentCostResponse>();

            foreach (XElement line in xml.Root.Elements())
                list.Add(new GetDocumentCostResponse(line));

            return list;
        }

        internal void UpdateReservationAndOrderStock(CommercialDocumentBase document)
        {
            XDocument operations = XDocument.Parse("<root><commercialDocumentLine></commercialDocumentLine></root>");
            XElement table = operations.Root.Element("commercialDocumentLine");
            XDocument commXml = XDocument.Parse("<root/>");

            this.AddItemsToItemTypesCache(document);
            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            foreach (CommercialDocumentLine line in document.Lines.Children)
            {
                Guid itemTypeId = cache[line.ItemId];
                ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                if (!itemType.IsWarehouseStorable)
                    continue;

                table.Add(new XElement("entry",
                    new XElement("itemId", line.ItemId.ToUpperString()),
                    new XElement("warehouseId", line.WarehouseId.ToUpperString()),
                    new XElement("unitId", line.UnitId.ToUpperString())));
                commXml.Root.Add(new XElement("entry", 
                    new XElement("itemId", line.ItemId.ToUpperString()), 
                    new XElement("warehouseId", line.WarehouseId.ToUpperString()), 
                    new XElement("unitId", line.UnitId.ToUpperString())));
            }

            if (document.AlternateVersion != null)
            {
                CommercialDocumentBase alternateDocument = (CommercialDocumentBase)document.AlternateVersion;

                foreach (CommercialDocumentLine line in alternateDocument.Lines.Children)
                {
                    if (line.Status == BusinessObjectStatus.Deleted)
                    {
                        table.Add(new XElement("entry", new XElement("itemId", line.ItemId.ToUpperString()), new XElement("warehouseId", line.WarehouseId.ToUpperString()), new XElement("unitId", line.UnitId.ToUpperString())));
                        commXml.Root.Add(new XElement("entry", new XElement("itemId", line.ItemId.ToUpperString()), new XElement("warehouseId", line.WarehouseId.ToUpperString()), new XElement("unitId", line.UnitId.ToUpperString())));
                    }
                }
            }

            if (operations.Root.Element("commercialDocumentLine").HasElements)
            {
                if (document.DocumentType.DocumentCategory == DocumentCategory.Reservation || 
                    document.DocumentType.DocumentCategory == DocumentCategory.Service ||
                    document.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_updateReservationStock, false, operations);
                else if (document.DocumentType.DocumentCategory == DocumentCategory.Order)
                    this.ExecuteStoredProcedure(StoredProcedure.document_p_updateOrderStock, false, operations);

                this.CreateUpdateStockPackage(commXml);
            }
        }

        public XDocument CreateIncomeQuantityCorrection(Guid id, Guid version, Guid warehouseDocumentHeaderId, 
            Guid? outcomeCorrectionDocumentHeaderId, decimal quantity, decimal value, DateTime date, 
            int incomeCorrectionOridinalNumber, int? outcomeCorrectionOridinalNumber, Guid? commercialDocumentLineId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("id", id.ToUpperString()));
            xml.Root.Add(new XElement("version", version.ToUpperString()));
            xml.Root.Add(new XElement("warehouseDocumentHeaderId", warehouseDocumentHeaderId.ToUpperString()));

            if (outcomeCorrectionDocumentHeaderId != null)
                xml.Root.Add(new XElement("outcomeCorrectionDocumentHeaderId", outcomeCorrectionDocumentHeaderId.ToUpperString()));

            xml.Root.Add(new XElement("quantity", quantity.ToString(CultureInfo.InvariantCulture)));
            xml.Root.Add(new XElement("value", value.ToString(CultureInfo.InvariantCulture)));
            xml.Root.Add(new XElement("date", date.ToIsoString()));
            xml.Root.Add(new XElement("incomeCorrectionOridinalNumber", incomeCorrectionOridinalNumber.ToString(CultureInfo.InvariantCulture)));

            if (outcomeCorrectionOridinalNumber != null)
                xml.Root.Add(new XElement("outcomeCorrectionOridinalNumber", outcomeCorrectionOridinalNumber.Value.ToString(CultureInfo.InvariantCulture)));

            xml.Root.Add(new XElement("localTransactionId", SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));
            xml.Root.Add(new XElement("deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));
            xml.Root.Add(new XElement("databaseId", ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

            if (commercialDocumentLineId != null)
                xml.Root.Add(new XElement("commercialDocumentLineId", commercialDocumentLineId.ToUpperString()));

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_createIncomeQuantityCorrection, true, xml);
            return xml;
        }

        public XDocument CreateOutcomeQuantityCorrection(Guid id, Guid version, Guid warehouseDocumentHeaderId, decimal quantity, int ordinalNumber, Guid? commercialDocumentLineId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("id", id.ToUpperString()));
            xml.Root.Add(new XElement("version", version.ToUpperString()));
            xml.Root.Add(new XElement("warehouseDocumentHeaderId", warehouseDocumentHeaderId.ToUpperString()));
            xml.Root.Add(new XElement("quantity", quantity.ToString(CultureInfo.InvariantCulture)));
            xml.Root.Add(new XElement("ordinalNumber", ordinalNumber.ToString(CultureInfo.InvariantCulture)));
            xml.Root.Add(new XElement("localTransactionId", SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));
            xml.Root.Add(new XElement("deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));
            xml.Root.Add(new XElement("databaseId", ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

            if(commercialDocumentLineId != null)
                xml.Root.Add(new XElement("commercialDocumentLineId", commercialDocumentLineId.ToUpperString()));

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_createOutcomeQuantityCorrection, true, xml);
            return xml;
        }

        public XDocument LoadBusinessObjectForPrinting(string storedProcedure, string objectId)
        {
            return this.ExecuteCustomProcedure(storedProcedure, "@documentHeaderId", new Guid(objectId));
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
			if ((obj.BOType == BusinessObjectType.CommercialDocument || obj.BOType == BusinessObjectType.WarehouseDocument)
				&& (obj.Status == BusinessObjectStatus.New || obj.Status == BusinessObjectStatus.Modified || ((SimpleDocument)obj).ForceSave))
            {
				string mode = 
					obj.Status == BusinessObjectStatus.Modified 
					|| !obj.IsNew && ((Document)obj).Attributes.HasChanges
					? "update" : "insert";
                XDocument xml = XDocument.Parse(
					String.Format("<root businessObjectId=\"\" mode=\"{0}\" />", mode));
                xml.Root.Attribute("businessObjectId").Value = obj.Id.ToUpperString();
                this.ExecuteStoredProcedure(StoredProcedure.document_p_insertCommercialDocumentDictionary, false, xml
					, ConfigurationMapper.Instance.UpdateDictionaryIndexTimeout);
            }
        }

        internal void DeleteWarehouseDocumentRelations(WarehouseDocument document)
        {
            StoredProcedure sp = StoredProcedure.document_p_deleteWarehouseDocumentRelationsForOutcome;
            string packageName = null;

            if (document.WarehouseDirection == WarehouseDirection.Outcome
				|| document.WarehouseDirection == WarehouseDirection.OutcomeShift)
            {
                sp = StoredProcedure.document_p_deleteWarehouseDocumentRelationsForOutcome;
                packageName = "UnrelateWarehouseDocumentForOutcome";
            }
            else if (document.WarehouseDirection == WarehouseDirection.Income
				|| document.WarehouseDirection == WarehouseDirection.IncomeShift)
            {
                sp = StoredProcedure.document_p_deleteWarehouseDocumentRelationsForIncome;
                packageName = "UnrelateWarehouseDocumentForIncome";
            }

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                line.CommercialWarehouseRelations.RemoveAll();
                line.CommercialWarehouseValuations.RemoveAll();
                line.IncomeOutcomeRelations.RemoveAll();
            }

            if (document.AlternateVersion != null)
            {
                WarehouseDocument altDoc = (WarehouseDocument)document.AlternateVersion;

                foreach (WarehouseDocumentLine line in altDoc.Lines.Children)
                {
                    line.CommercialWarehouseRelations.RemoveAll();
                    line.CommercialWarehouseValuations.RemoveAll();
                    line.IncomeOutcomeRelations.RemoveAll();
                }
            }

            this.ExecuteStoredProcedure(sp, false, "@warehouseDocumentHeaderId", document.Id.Value);

            this.ExecuteStoredProcedure(StoredProcedure.communication_p_createUnrelateDocumentPackage, false,
                XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root id=\"{0}\" localTransactionId=\"{1}\" deferredTransactionId=\"{2}\" databaseId=\"{3}\" packageName=\"{4}\"/>",
                document.Id.ToUpperString(), SessionManager.VolatileElements.LocalTransactionId.ToUpperString(),
                SessionManager.VolatileElements.DeferredTransactionId.ToUpperString(), ConfigurationMapper.Instance.DatabaseId.ToUpperString(), packageName)));
        }

        public void CancelWarehouseDocument(Guid warehouseDocumentHeaderId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_cancelWarehouseDocument, true, "@warehouseDocumentHeaderId", warehouseDocumentHeaderId.ToUpperString());

            if (xml.Root.Element("relatedCommercialDocuments") != null && xml.Root.Element("relatedCommercialDocuments").HasElements)
                throw new ClientException(ClientExceptionId.CancelWarehouseDocumentError1, null, "docNumbers:" + this.GetDocumentNumbersFromEntries(xml.Root.Element("relatedCommercialDocuments").Elements()));
            else if (xml.Root.Element("correctiveWarehouseDocuments") != null && xml.Root.Element("correctiveWarehouseDocuments").HasElements)
                throw new ClientException(ClientExceptionId.CancelWarehouseDocumentError2, null, "docNumbers:" + this.GetDocumentNumbersFromEntries(xml.Root.Element("correctiveWarehouseDocuments").Elements()));
            else if (xml.Root.Element("relatedOutcomeWarehouseDocuments") != null && xml.Root.Element("relatedOutcomeWarehouseDocuments").HasElements)
                throw new ClientException(ClientExceptionId.CancelWarehouseDocumentError3, null, "docNumbers:" + this.GetDocumentNumbersFromEntries(xml.Root.Element("relatedOutcomeWarehouseDocuments").Elements()));
        }

        private string GetDocumentNumbersFromEntries(IEnumerable<XElement> entries)
        {
            string param = String.Empty;
            int count = entries.Count();

            for (int i = 0; i < count; i++)
            {
                param += entries.ElementAt(i).Element("fullNumber").Value;

                if (i + 1 < count)
                    param += ", ";
            }

            return param;
        }

        public XDocument UnrelateCommercialDocumentFromWarehouseDocuments(Guid commercialDocumentHeaderId)
		{
			#region Nie można odwiązać WZ dla dokumentu sprzedażowego realizującego zamnkięte zamówienie sprzedażowe
			
			CommercialDocument commercialDocument = 
				(CommercialDocument)this.LoadBusinessObject(BusinessObjectType.CommercialDocument, commercialDocumentHeaderId);
			commercialDocument.ValidateSalesOrderRealizedLines(false);
			
			#endregion

			XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_unrelateCommercialDocumentFromWarehouseDocuments, 
                true, 
                "@commercialDocumentHeaderId", commercialDocumentHeaderId,
                "@localTransactionId", SessionManager.VolatileElements.LocalTransactionId,
                "@deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId,
                "@databaseId", ConfigurationMapper.Instance.DatabaseId);

            if (!xml.Root.HasElements)
            {
				XDocument commXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root id=\"{0}\" localTransactionId=\"{1}\" deferredTransactionId=\"{2}\" databaseId=\"{3}\" packageName=\"UnrelateCommercialDocument\"/>",
                    commercialDocumentHeaderId.ToUpperString(), SessionManager.VolatileElements.LocalTransactionId.ToUpperString(),
                    SessionManager.VolatileElements.DeferredTransactionId.ToUpperString(), ConfigurationMapper.Instance.DatabaseId.ToUpperString()));
                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createUnrelateDocumentPackage, false, commXml);
				return commXml;
            }
            else
            {
                //budujemy kolekcje z nodeow. Przyklad:
                /*
                 * <root>
                 *      <bookedOutcome>
                 *          <number>...</number>
                 *          <number>...</number>
                 *          <number>...</number>
                 *      </bookedOutcome>
                 * </root>
                 */

                string docNumbers = String.Empty;

                bool first = true;

                foreach (XElement number in xml.Root.Element("bookedOutcome").Elements())
                {
                    if (!first)
                        docNumbers += ", ";

                    docNumbers += number.Value;

                    first = false;
                }

                throw new ClientException(ClientExceptionId.UnableToUnrelate, null, "docNumbers:" + docNumbers);
            }
        }

        /// <summary>
        /// Gets the deliveries for the specified items.
        /// </summary>
        /// <param name="deliveryRequests">A collection of <see cref="DeliveryRequest"/> object that contains delivery request specification.</param>
        /// <returns></returns>
        internal ICollection<DeliveryResponse> GetDeliveries(ICollection<DeliveryRequest> deliveryRequests)
        {
            XDocument xml = XDocument.Parse("<root/>");
            XDocument commXml = XDocument.Parse("<root/>");

            foreach (DeliveryRequest delivery in deliveryRequests)
            {
                xml.Root.Add(delivery.ToXElement());
                commXml.Root.Add(new XElement("entry", new XElement("itemId", delivery.ItemId.ToUpperString()), new XElement("warehouseId", delivery.WarehouseId.ToUpperString())));
            }

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getDeliveries, true, xml);

            List<DeliveryResponse> deliveryResponses = new List<DeliveryResponse>(deliveryRequests.Count);

            foreach (XElement response in xml.Root.Elements())
            {
                deliveryResponses.Add(new DeliveryResponse(response));
            }

            return deliveryResponses;
        }

        public bool IsWarehouseDocumentValuated(Guid warehouseDocumentHeaderId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_isWarehouseDocumentValuated, true, "@warehouseDocumentHeaderId", warehouseDocumentHeaderId);

            if (xml.Root.Value.ToUpperInvariant() == "TRUE")
                return true;
            else
                return false;
        }

        /// <summary>
        /// Computes document number for the specified document and series.
        /// </summary>
        /// <param name="document">The document to compute number for.</param>
        /// <param name="number">The assigned number.</param>
        /// <returns>Computed document number value.</returns>
        internal string ComputeFullDocumentNumber(SimpleDocument document, int? number)
        {
            string financialRegisterSymbol = null;

            FinancialDocument fDoc = document as FinancialDocument;
            FinancialReport fRep = document as FinancialReport;
            CommercialDocument cDoc = document as CommercialDocument;

            bool isRetailSale = false;

            if (cDoc != null && cDoc.CalculationType == CalculationType.Gross)
                isRetailSale = true;

            if (fDoc != null && fDoc.FinancialReport != null)
                financialRegisterSymbol = DictionaryMapper.Instance.GetFinancialRegister(fDoc.FinancialReport.FinancialRegisterId).Symbol;
            else if (fRep != null)
                financialRegisterSymbol = DictionaryMapper.Instance.GetFinancialRegister(fRep.FinancialRegisterId).Symbol;

            return this.ComputeFullDocumentNumber(document.Number.NumberSettingId, number, document.IssueDate, document.Symbol, financialRegisterSymbol, isRetailSale);
        }

        /// <summary>
        /// Computes document number for the specified document and series.
        /// </summary>
        /// <param name="numberSettingId">The number setting id.</param>
        /// <param name="number">Sequential number to use in this full number.</param>
        /// <param name="documentIssueDate">The document issue date.</param>
        /// <param name="documentSymbol">The document symbol.</param>
        /// <returns>Computed document number value.</returns>
        public string ComputeFullDocumentNumber(Guid numberSettingId, int? number, DateTime documentIssueDate, string documentSymbol, string financialRegisterSymbol, bool isRetailSale)
        {
            NumberSetting ns = DictionaryMapper.Instance.GetNumberSetting(numberSettingId);

            string computedPattern = this.ComputePattern(ns.NumberFormat, documentIssueDate, documentSymbol, financialRegisterSymbol, isRetailSale);
            if (number != null)
            {
                string nmb = number.ToString();

                string nmbFormat = ConfigurationMapper.Instance.GetSingleConfigurationEntry("document.sequentialNumberLong").Value.Value;
                if (nmbFormat != null)
                    nmb = String.Format(nmbFormat, number);

                computedPattern = computedPattern.Replace("[SequentialNumber]", nmb);
            }
            return computedPattern;
        }

        /// <summary>
        /// Computes series for the specified document and series.
        /// </summary>
        /// <param name="document">The document to compute series for.</param>
        /// <returns>Computed series value.</returns>
        internal string ComputeSeries(SimpleDocument document)
        {
            NumberSetting ns = DictionaryMapper.Instance.GetNumberSetting(document.Number.NumberSettingId);

            return this.ComputePattern(ns.SeriesFormat, document);
        }


        /// <summary>
        /// Computes the specified pattern with its proper values according to the document.
        /// </summary>
        /// <param name="pattern">The pattern to compute.</param>
        /// <param name="document">The document to generate number for.</param>
        /// <returns>Computed pattern.</returns>
        internal string ComputePattern(string pattern, SimpleDocument document)
        {
            if (String.IsNullOrEmpty(pattern) || document == null)
                return null;

            string financialRegisterSymbol = null;

            FinancialDocument fDoc = document as FinancialDocument;
            FinancialReport fRep = document as FinancialReport;
            CommercialDocument cDoc = document as CommercialDocument;

            bool isRetailSale = false;

            if (cDoc != null && cDoc.CalculationType == CalculationType.Gross)
                isRetailSale = true;

            if (fDoc != null && fDoc.FinancialReport != null)
                financialRegisterSymbol = DictionaryMapper.Instance.GetFinancialRegister(fDoc.FinancialReport.FinancialRegisterId).Symbol;
            else if (fRep != null)
                financialRegisterSymbol = DictionaryMapper.Instance.GetFinancialRegister(fRep.FinancialRegisterId).Symbol;

            return this.ComputePattern(pattern, document.IssueDate, document.Symbol, financialRegisterSymbol, isRetailSale);
        }

        /// <summary>
        /// Computes the specified pattern with its proper values according to the document.
        /// </summary>
        /// <param name="pattern">The pattern to compute.</param>
        /// <param name="documentIssueDate">The document issue date.</param>
        /// <param name="documentSymbol">The document symbol.</param>
        /// <returns>Computed pattern.</returns>
        public string ComputePattern(string pattern, DateTime documentIssueDate, string documentSymbol, string financialRegisterSymbol, bool isRetailSale)
        {
            if (String.IsNullOrEmpty(pattern) || String.IsNullOrEmpty(documentSymbol))
                return null;

            NameValueCollection computedComponents = new NameValueCollection(5);

            computedComponents.Add("[DocumentYear]", documentIssueDate.Year.ToString(CultureInfo.InvariantCulture));
            computedComponents.Add("[DocumentMonth]", documentIssueDate.Month.ToString(CultureInfo.InvariantCulture));
            computedComponents.Add("[DocumentDay]", documentIssueDate.Day.ToString(CultureInfo.InvariantCulture));
            computedComponents.Add("[DocumentSymbol]", documentSymbol);
            computedComponents.Add("[StrippedDocumentSymbol]", documentSymbol.Replace("-", "").Replace("+", ""));
            computedComponents.Add("[BranchSymbol]", DictionaryMapper.Instance.GetBranch(SessionManager.User.BranchId).Symbol);

            if(isRetailSale)
                computedComponents.Add("[RetailSaleMark]", "/DETAL");
            else
                computedComponents.Add("[RetailSaleMark]", "");
            
            if (!String.IsNullOrEmpty(financialRegisterSymbol))
                computedComponents.Add("[FinancialRegisterSymbol]", financialRegisterSymbol);
            else
                computedComponents.Add("[FinancialRegisterSymbol]", "??");

            string computedFormat = pattern; //initial value

            foreach (string key in computedComponents.Keys)
            {
                computedFormat = computedFormat.Replace(key, computedComponents[key]);
            }

            return computedFormat;
        }

        /// <summary>
        /// Determines whether the specified number exists in specified series.
        /// </summary>
        /// <param name="seriesValue">Computed series value.</param>
        /// <param name="number">The number to check.</param>
        /// <returns><c>true</c> if the number exists; otherwise, <c>false</c>.</returns>
        public bool IsNumberExist(string seriesValue, int number)
        {
            XDocument xml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                "<root><seriesValue>{0}</seriesValue><number>{1}</number></root>",
                seriesValue, number.ToString(CultureInfo.InvariantCulture)));

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_checkNumberExistence, true, xml);

            return Convert.ToBoolean(xml.Root.Value, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Gets the last free number for specified series.
        /// </summary>
        /// <param name="numberSettingId">The number setting id.</param>
        /// <param name="computedSeriesValue">The computed series value.</param>
        /// <returns>Number that is one greater than max number that is already in use.</returns>
        public int GetFreeNumberForSeries(Guid numberSettingId, string computedSeriesValue)
        {
            if (String.IsNullOrEmpty(computedSeriesValue))
                throw new ArgumentException("computedSeriesValue cannot be null or String.Empty", "computedSeriesValue");

            XDocument xml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                "<root><numberSettingId>{0}</numberSettingId><seriesValue>{1}</seriesValue></root>", numberSettingId.ToUpperString(),
                computedSeriesValue));

            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getLastNumberForSeries, true, xml);

            return Convert.ToInt32(xml.Root.Value, CultureInfo.InvariantCulture);
        }

        internal void ValuateCommercialDocument(CommercialDocument document)
        {
            if (document.DocumentType.DocumentCategory != DocumentCategory.Sales &&
                document.DocumentType.DocumentCategory != DocumentCategory.SalesCorrection)
                throw new InvalidOperationException("Only sales documents can be valuated");

            if (document.DocumentStatus == DocumentStatus.Committed || document.DocumentStatus == DocumentStatus.Booked)
            {
                this.ExecuteStoredProcedure(StoredProcedure.document_xp_valuateInvoice, false,
                    "@commercialDocumentHeaderId", document.Id,
                    "@localTransactionId", SessionManager.VolatileElements.LocalTransactionId,
                    "@deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId,
                    "@databaseId", ConfigurationMapper.Instance.DatabaseId);
            }
        }

        internal void ValuateIncomeWarehouseDocument(WarehouseDocument document, bool checkIfIsNeeded = false)
        {
            if (document.WarehouseDirection != WarehouseDirection.Income &&
                document.WarehouseDirection != WarehouseDirection.IncomeShift)
                throw new InvalidDataException("Only income warehouse documents can be valuated.");

            if (document.DocumentStatus == DocumentStatus.Committed || document.DocumentStatus == DocumentStatus.Booked)
            {
				bool valuate = true;
				if (checkIfIsNeeded)
				{
					XDocument checkxml = this.ExecuteStoredProcedure(StoredProcedure.document_p_checkIncomeValuation, true,
						"warehouseDocumentHeaderId", document.Id);
					valuate = checkxml.Root.Value.ToUpperInvariant() == "TRUE";
				}

				if (valuate)
				{
					XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_valuateIncome, true,
						"@warehouseDocumentHeaderId", document.Id,
						"@localTransactionId", SessionManager.VolatileElements.LocalTransactionId,
						"@deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId,
						"@databaseId", ConfigurationMapper.Instance.DatabaseId,
						"@package", true);

					if (xml.Root.HasElements)
					{
						//budujemy kolekcje z nodeow. Przyklad:
						/*
						 * <root>
						 *      <bookedOutcome>
						 *          <number>...</number>
						 *          <number>...</number>
						 *          <number>...</number>
						 *      </bookedOutcome>
						 * </root>
						 */

						string docNumbers = String.Empty;

						bool first = true;

						foreach (XElement number in xml.Root.Element("bookedOutcome").Elements())
						{
							if (!first)
								docNumbers += ", ";

							docNumbers += number.Value;

							first = false;
						}

						throw new ClientException(ClientExceptionId.BookedOutcomeError, null, "docNumbers:" + docNumbers);
					}
				}
            }
        }

        public XDocument GetCommercialDocumentLinesXml(XDocument linesId)
        {
            if (!linesId.Root.HasElements)
                return XDocument.Parse("<root><commercialDocumentLine/></root>");
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getCommercialDocumentLines, true, linesId);
            return xml;
        }

        /// <summary>
        /// Valuates the outcome warehouse document.
        /// </summary>
        /// <param name="document">The document to valuate.</param>
        internal void ValuateOutcomeWarehouseDocument(WarehouseDocument document)
        {
            if (document.WarehouseDirection != WarehouseDirection.Outcome &&
                document.WarehouseDirection != WarehouseDirection.OutcomeShift)
                throw new InvalidDataException("Only outcome warehouse documents can be valuated.");

            if (document.DocumentStatus == DocumentStatus.Committed || document.DocumentStatus == DocumentStatus.Booked)
            {
                this.ExecuteStoredProcedure(StoredProcedure.document_xp_valuateOutcome, false,
                    "@warehouseDocumentHeaderId", document.Id,
                    "@localTransactionId", SessionManager.VolatileElements.LocalTransactionId,
                    "@deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId,
                    "@databaseId", ConfigurationMapper.Instance.DatabaseId);
                XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_updateWarehouseDocumentCost, true, "@warehouseDocumentHeaderId", document.Id);

                if (xml.Root.HasElements)
                {
                    //budujemy kolekcje z nodeow. Przyklad:
                    /*
                     * <root>
                     *      <bookedOutcome>
                     *          <number>...</number>
                     *          <number>...</number>
                     *          <number>...</number>
                     *      </bookedOutcome>
                     * </root>
                     */

                    /*string docNumbers = String.Empty;

                    bool first = true;

                    foreach (XElement number in xml.Root.Element("bookedOutcome").Elements())
                    {
                        if (!first)
                            docNumbers += ", ";

                        docNumbers += number.Value;

                        first = false;
                    }*/
                    //zakomentowane bo i tak tylko wskazany dokument jest ruszany

                    throw new ClientException(ClientExceptionId.BookedOutcomeError2);
                }
            }

            if (ConfigurationMapper.Instance.BlockInvaluatedOutcomes)
            {
                bool valuated = this.IsWarehouseDocumentValuated(document.Id.Value);

                if (!valuated)
                    throw new ClientException(ClientExceptionId.InvaluatedOutcomesProhibited);
            }
        }

        internal bool HasLaterPrepayments(CommercialDocument commercialDocument)
        {
            if (commercialDocument.DocumentType.DocumentCategory == DocumentCategory.Sales)
            {
                var soRelation = commercialDocument.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault();

                if (soRelation != null)
                {
                    XDocument xml = new XDocument(new XElement("root", new XElement("salesOrderId", soRelation.RelatedDocument.Id.Value)));
                    xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getPrepaymentDocuments, true, xml);

                    var last = xml.Root.Elements().Last();

                    if (new Guid(last.Attribute("id").Value) != commercialDocument.Id.Value)
                        return true;
                }
            }

            return false;
        }

        public int GetPrepaidDocumentsNumber(Guid commercialDocumentHeaderId)
        {
            XDocument xml = new XDocument(new XElement("root", new XElement("commercialDocumentHeaderId", commercialDocumentHeaderId.ToUpperString())));
            xml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getPrepaidDocumentsNumber, true, xml);
            return Convert.ToInt32(xml.Root.Element("number").Value, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Gets an xml list of items with its parameters neccessary for adding the items to the document's line.
        /// </summary>
        /// <param name="items">Collection of items' id to get.</param>
        /// <returns>Xml containing list of quered items (raw database response).</returns>
        public XDocument GetItemsForDocument(ICollection<Guid> items)
        {
            if (items == null || items.Count == 0)
                throw new ArgumentException("items cannot be null or contains 0 elements", "items");

            XDocument xml = XDocument.Parse("<root></root>");

            foreach (Guid guid in items)
            {
                xml.Root.Add(new XElement("item", new XAttribute("id", guid.ToUpperString())));
            }

            xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsForDocument, true, xml);

            return xml;
        }

        internal void AddItemsToItemTypesCache(CommercialDocumentBase document)
        {
            List<Guid> itemsId = new List<Guid>();

            foreach (CommercialDocumentLine line in document.Lines.Children)
            {
                itemsId.Add(line.ItemId);
            }

            this.AddItemsToItemTypesCache(itemsId);
        }

        internal void AddItemsToItemTypesCache(WarehouseDocument document)
        {
            List<Guid> itemsId = new List<Guid>();

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                itemsId.Add(line.ItemId);
            }

            this.AddItemsToItemTypesCache(itemsId);
        }

        /// <summary>
        /// Gets itemTypeId for specified item collection and adds them to the item type cache.
        /// </summary>
        /// <param name="items">The collection of itemId to load and add to the cache.</param>
        public void AddItemsToItemTypesCache(ICollection<Guid> items)
        {
            XDocument xml = XDocument.Parse("<root/>");

            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            foreach (Guid item in items)
            {
                if ((cache != null && !cache.ContainsKey(item) || cache == null) &&
                    xml.Root.Elements().Where(i => i.Attribute("id").Value == item.ToUpperString()).Count() == 0)
                    xml.Root.Add(new XElement("item", new XAttribute("id", item.ToUpperString())));
            }

            if (xml.Root.HasElements)
            {
                xml = this.ExecuteStoredProcedure(StoredProcedure.item_p_getItemsTypes, true, xml);

                if (cache == null)
                {
                    cache = new Dictionary<Guid, Guid>();
                    SessionManager.VolatileElements.ItemTypesCache = cache;
                }

                foreach (XElement item in xml.Root.Elements())
                {
                    cache.Add(new Guid(item.Attribute("id").Value), new Guid(item.Attribute("itemTypeId").Value));
                }
            }
        }

        /// <summary>
        /// Creates communication xml for objects that are in the xml operations list.
        /// </summary>
        /// <param name="operations"></param>
        public override void CreateCommunicationXml(XDocument operations)
        {
            throw new NotImplementedException();
        }

		/// <summary>
		/// Validates document before commiting it using custom procedure if that procedure name is set in the documentation may introduce some changes
		/// </summary>
		/// <param name="document">Document instance to be validated</param>
		internal void ExecuteOnCommitValidationCustomProcedure(Document document)
		{
			//Procedure is called only if document.validation.onCommitCustomProcedure in configuration exists
			if (document != null && !String.IsNullOrEmpty(ConfigurationMapper.Instance.OnCommitDocumentCustomValidationProcedure))
			{
				string parameterString = String.Format(
					@"<root method=""{0}"" localTransactionId=""{4}"" deferredTransactionId=""{5}"" databaseId=""{6}"" action=""{7}""><id>{1}</id><documentTypeId>{2}</documentTypeId><symbol>{3}</symbol></root>",
					SessionManager.VolatileElements.ClientCommand ?? String.Empty, document.Id, document.DocumentTypeId, document.Symbol,
					SessionManager.VolatileElements.LocalTransactionId.ToUpperString(),
					SessionManager.VolatileElements.DeferredTransactionId.ToUpperString(),
					ConfigurationMapper.Instance.DatabaseId.ToUpperString(),
					document.AlternateVersion != null ? "update" : "insert");
				XDocument parameterXml = XDocument.Parse(parameterString);
				if (document.AlternateVersion != null)
				{
					parameterXml.Root.Add(new XElement("previousStatus", (int)((Document)document.AlternateVersion).DocumentStatus));
				}

				XElement retXml
					= this.ExecuteCustomProcedure(ConfigurationMapper.Instance.OnCommitDocumentCustomValidationProcedure, parameterXml, null);

				//If there are errors or warnings, logic to notify user
				if (retXml.Elements().Count() != 0)
				{
					IEnumerable<XElement> errors = retXml.Elements("error");
					int errorsCount = errors.Count();
					IEnumerable<XElement> warnings = retXml.Elements("warning");
					//Warnings saved in VolatileElements to be appended in return xml
					if (warnings.Count() != 0)
					{
						SessionManager.VolatileElements.Warnings.AddRange(warnings.Select(w => w.Value));
					}
					//Client exception is thrown, customMessage contains all error messages returned by custom procedure separated by coma.
					if (errorsCount != 0)
					{
						string message = null;
						if (errorsCount == 1)
						{
							message = errors.ElementAt(0).Value;
						}
						else
						{
							message = String.Join("\\n", errors.Select(s => s.Value).ToArray());
						}
						throw new ClientException(ClientExceptionId.OnDocumentCommitValidationError, null
							, "errors:" + message);
					}
				}

			}
		}

		/// <summary>
		/// Gets all lines in <see cref="CommercialDocument"/>s which realize sales order (contain attributeLineAttribute_RealizedSalesOrderLineId)
		/// </summary>
		/// <param name="salesOrderId">id of realized sales order</param>
		/// <returns>Object representing lines realizing order information</returns>
		internal SalesOrderRealizationInfo GetCommercialDocumentLinesRealizingSalesOrder(CommercialDocument salesOrder)
		{
			XDocument xmlResult = this.ExecuteStoredProcedure(StoredProcedure.document_p_getRealizedSalesOrderLines, true, "@id", salesOrder.Id);
			return new SalesOrderRealizationInfo(xmlResult.Root);
		}

		internal SalesOrderRealizationInfo GetCommercialDocumentLinesRealizingSalesOrders(List<CommercialDocument> salesOrders)
		{
			XDocument xmlResult = XDocument.Parse("<root/>");
			foreach (CommercialDocument salesOrder in salesOrders)
			{
				xmlResult.Root.Add(this.ExecuteStoredProcedure(StoredProcedure.document_p_getRealizedSalesOrderLines, true, "@id", salesOrder.Id).Root.Elements());
			}
			return new SalesOrderRealizationInfo(xmlResult.Root);
		}
        /// <summary>
        /// Gets mapping for line in warehouseDocument. Warehouse items will be changed for sales ones.
        /// </summary>
        /// <param name="document"></param>
        /// <returns></returns>
        internal XDocument GetLineMappingForWarehouseDocument(WarehouseDocument document)
        {
  
            XDocument xml = new XDocument(document.FullXml.Element("root").Element("warehouseDocument").Element("lines"));
            XDocument respXml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getLineMappingForDocument, true, xml);

            return  respXml;
        }

        internal XDocument GetLineMappingForCommercialDocument(CommercialDocument document)
        {
            XDocument xml = new XDocument(document.FullXml.Element("root").Descendants().First().Element("lines"));
            //XDocument xml = new XDocument(document.FullXml.Element("root").Element(".").Element("lines"));
            XDocument respXml = this.ExecuteStoredProcedure(StoredProcedure.document_p_getLineMappingForDocument, true, xml);

            return respXml;
        }
	}
} 
