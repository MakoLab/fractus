using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using System.Globalization;
using System.Xml.Linq;
using System.IO;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Provides a mechanism to send the communication package to other departments.
    /// </summary>
    public class FractusPackageForwarder : IPackageForwarder
    {

        private Dictionary<CommunicationPackageType, List<Branch>> destinations;
        private bool? isHQ;
        private Guid? currentDatabaseId;

        #region IPackageForwarder Members

        /// <summary>
        /// Gets or sets the message log.
        /// </summary>
        /// <value>The log.</value>
        public ICommunicationLog Log { get; set; }

        /// <summary>
        /// Forwards the specified package to other departments.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <param name="repository">The communication package repository.</param>
        public void ForwardPackage(ICommunicationPackage communicationPackage, ICommunicationPackageRepository repository)
        {
            //TODO
            //mechanism that deley insertion of forwarded packages if executing in deffered mode
            //not a major problem because everything is in the same transaction, but constansts rollback will mess with order column
            if (this.isHQ == null) SetHeadquater(repository.Context);

            if (this.currentDatabaseId == null) SetDatabaseId(repository.Context);

            if (this.isHQ == true) ForwardInHeadquarter(communicationPackage, repository);
            //else ForwardInBranch
        }

        #endregion

        /// <summary>
        /// Forwards the communication package in headquarter branch.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <param name="repository">The communication package repository.</param>
        private void ForwardInHeadquarter(ICommunicationPackage communicationPackage, ICommunicationPackageRepository repository)
        {
            XDocument commPkg = XDocument.Parse(communicationPackage.XmlData.Content);
            var skipPackage = XDocument.Parse(communicationPackage.XmlData.Content).Root.Attribute("skipPackage");
            if (skipPackage != null && skipPackage.Value.Equals("true", StringComparison.OrdinalIgnoreCase)) return;

            CommunicationPackageType pkgType = GetPackageType(communicationPackage);

            if (pkgType == CommunicationPackageType.Configuration ||
                pkgType == CommunicationPackageType.ContractorSnapshot ||
                pkgType == CommunicationPackageType.ContractorRelations ||
                pkgType == CommunicationPackageType.ContractorGroupMembership ||
                pkgType == CommunicationPackageType.ItemSnapshot ||
                pkgType == CommunicationPackageType.ItemRelation ||
                pkgType == CommunicationPackageType.ItemGroupMembership ||
                pkgType == CommunicationPackageType.ItemUnitRelation ||
                pkgType == CommunicationPackageType.WarehouseStock || 
                pkgType == CommunicationPackageType.Payment || 
                //pkgType == CommunicationPackageType.PaymentSettlementSnapshot ||
                pkgType == CommunicationPackageType.FileDescriptor ||
                pkgType == CommunicationPackageType.DictionaryPackage || 
                pkgType == CommunicationPackageType.PriceRule || 
                pkgType == CommunicationPackageType.PriceRuleList||
                pkgType == CommunicationPackageType.Custom)
            {
                IEnumerable<Guid> destinationDatabases = GetDestinations(communicationPackage, repository.Context.ConnectionManager);
                if (destinationDatabases != null) repository.PutToOutgoingQueue(communicationPackage, destinationDatabases);
            }
            else if (pkgType == CommunicationPackageType.WarehouseDocumentSnapshot)
            {
                if (commPkg.Root.Element("warehouseDocumentLine").Elements("entry").All(row => row.Element("isDistributed").Value.Equals("1")))
                {
                    ForwardShiftDocument(communicationPackage, repository, commPkg);
                }
            }
            else if (pkgType == CommunicationPackageType.WarehouseDocumentValuation)
            {
                // zapobiega zapetleniu paczek
                if (communicationPackage.DatabaseId != this.currentDatabaseId)  ForwardValuations(communicationPackage, commPkg, repository);
            }
        }

        private static void ForwardShiftDocument(ICommunicationPackage communicationPackage, ICommunicationPackageRepository repository, XDocument commPkg)
        {
            using (var wrapper = repository.Context.ConnectionManager.SynchronizeConnection())
            {
                SqlConnectionManager.Instance.SetConnection(wrapper.Connection, (SqlTransaction)repository.Context.Transaction);
            }
            DocumentType docType = DictionaryMapper.Instance.GetDocumentType(new Guid(
                                        commPkg.Root.Element("warehouseDocumentHeader")
                                        .Element("entry").Element("documentTypeId").Value));
            if (docType.WarehouseDocumentOptions.WarehouseDirection != Makolab.Fractus.Kernel.Enums.WarehouseDirection.OutcomeShift || docType.DocumentCategory == DocumentCategory.IncomeWarehouseCorrection || docType.DocumentCategory == DocumentCategory.OutcomeWarehouseCorrection) return;

            string oppositeWarehouseFieldId = DictionaryMapper.Instance.GetDocumentField(Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId).Id.Value.ToString().ToUpperInvariant();
            string oppositeWarehouseId = commPkg.Root.Element("documentAttrValue").Elements()
                                        .Where(row => row.Element("documentFieldId").Value.Equals(oppositeWarehouseFieldId))
                                        .Select(row => row.Element("textValue").Value)
                                        .SingleOrDefault();
            if (oppositeWarehouseId == null) throw new InvalidDataException("Missing opposite warehouse id in document attributes");

            Warehouse oppositeWarehouse = DictionaryMapper.Instance.GetWarehouse(new Guid(oppositeWarehouseId));
            Warehouse warehouse = DictionaryMapper.Instance.GetWarehouse(new Guid(commPkg.Root.Element("warehouseDocumentHeader").Element("entry").Element("warehouseId").Value));
            //skip local shift documents
            if (warehouse.BranchId != oppositeWarehouse.BranchId)
            {
                communicationPackage.DatabaseId = DictionaryMapper.Instance.GetBranch(oppositeWarehouse.BranchId).DatabaseId;
                repository.PutToOutgoingQueue(communicationPackage);
            }
        }

        private static void ForwardValuations(ICommunicationPackage communicationPackage, XDocument commPkg, ICommunicationPackageRepository repository)
        {
            var distributedLines = commPkg.Root.Element("warehouseDocumentValuation").Elements("entry")
                                        .Where(
                                            row => row.Element("isDistributed") != null
                                                && row.Element("isDistributed").Value.Equals("True", StringComparison.OrdinalIgnoreCase)
                                                && row.Element("warehouseDocumentHeaderId") != null
                                                && (row.Attribute("action") == null || row.Attribute("action").Value.Equals("delete", StringComparison.OrdinalIgnoreCase) == false))
                                        .GroupBy(row => row.Element("warehouseDocumentHeaderId").Value);
            
            //this valuation is not for shift document, so we don't forward it
            if (distributedLines.Count() == 0) return;

            XDocument valuationTemplate = XDocument.Parse("<root><warehouseDocumentValuation /></root>");
            Guid localTransactionId = Guid.NewGuid();
            using (var wrapper = repository.Context.ConnectionManager.SynchronizeConnection())
            {
                SqlConnectionManager.Instance.SetConnection(wrapper.Connection, (SqlTransaction)repository.Context.Transaction);
            }
            using (var whDocCoord = new DocumentCoordinator(false, false))
            {
                foreach (var warehouseDocGroup in distributedLines)
                {
                    WarehouseDocument shift = null;
                    try
                    {
                        shift = (WarehouseDocument)whDocCoord.LoadBusinessObject(Makolab.Fractus.Kernel.Enums.BusinessObjectType.WarehouseDocument,
                                                                                                    new Guid(warehouseDocGroup.Key));
                    }
                    catch (ClientException) { }

                    //there is a valuated document in database so we can forward valuation - no document = skip valuations for this doc
                    if (shift != null)
                    {
                        string oppositeWarehouseId = (shift.Attributes.Count() > 0 && shift.Attributes.Children.Any(attr => attr.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId)) 
                                                    ? shift.Attributes[DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId].Value.Value 
                                                    : null;
                        if (oppositeWarehouseId != null)
                        {
                            Warehouse oppositeWarehouse = DictionaryMapper.Instance.GetWarehouse(new Guid(oppositeWarehouseId));
                            Warehouse warehouse = DictionaryMapper.Instance.GetWarehouse(shift.WarehouseId);
                            
                            //skip local shift document valuations
                            if (warehouse.BranchId == oppositeWarehouse.BranchId) continue;

                            foreach (var valuation in warehouseDocGroup)
                            {
                                var whDocLine = shift.Lines.Children.Where(line => line.Id.ToString()
                                                                                    .Equals(valuation.Element("outcomeWarehouseDocumentLineId").Value, StringComparison.OrdinalIgnoreCase))
                                                                    .SingleOrDefault();
                                valuation.Add(new XAttribute("outcomeShiftOrdinalNumber", whDocLine.OrdinalNumber));
                            }

                            var valuationPkg = new XDocument(valuationTemplate);
                            valuationPkg.Root.Element("warehouseDocumentValuation").Add(new XAttribute("outcomeShiftId", shift.Id));
                            valuationPkg.Root.Element("warehouseDocumentValuation").Add(warehouseDocGroup);

                            XmlTransferObject valuationData = new XmlTransferObject
                            {
                                DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId,
                                Id = Guid.NewGuid(),
                                LocalTransactionId = localTransactionId,
                                XmlType = "WarehouseDocumentValuation",
                                Content = valuationPkg.ToString(SaveOptions.DisableFormatting)
                            };
                            ICommunicationPackage pkg = new CommunicationPackage(valuationData);
                            pkg.DatabaseId = DictionaryMapper.Instance.GetBranch(oppositeWarehouse.BranchId).DatabaseId;
                            repository.PutToOutgoingQueue(pkg);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Sets the isHeadquater marker.
        /// </summary>
        /// <param name="unitOfWork">The active unit of work.</param>
        private void SetHeadquater(IUnitOfWork unitOfWork)
        {
            using (var wrapper = unitOfWork.ConnectionManager.SynchronizeConnection())
            {
                SqlConnectionManager.Instance.SetConnection(wrapper.Connection, (SqlTransaction)unitOfWork.Transaction);
            }
            var hqCfg = Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.GetSingleConfigurationEntry("system.isHeadquarter");
            if (hqCfg == null) throw new System.Configuration.ConfigurationErrorsException("system.isHeadquarter no defined in configuration");
            this.isHQ = Boolean.Parse(hqCfg.Value.Value);
        }

        /// <summary>
        /// Sets the database id.
        /// </summary>
        /// <param name="unitOfWork">The active unit of work.</param>
        private void SetDatabaseId(IUnitOfWork unitOfWork)
        {
            using (var wrapper = unitOfWork.ConnectionManager.SynchronizeConnection())
            {
                SqlConnectionManager.Instance.SetConnection(wrapper.Connection, (SqlTransaction)unitOfWork.Transaction);
            }
            this.currentDatabaseId = Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.DatabaseId;
        }

        /// <summary>
        /// Gets the type of the specified communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <returns>Communication package type</returns>
        private CommunicationPackageType GetPackageType(ICommunicationPackage communicationPackage)
        {
            CommunicationPackageType pkgType;
            try
            {
                pkgType = (CommunicationPackageType)Enum.Parse(typeof(CommunicationPackageType), communicationPackage.XmlData.XmlType);
            }
            catch (ArgumentException)
            {
                this.Log.Info(String.Format("Unknown package type - {0} in package {1}", 
                                            communicationPackage.XmlData.XmlType, 
                                            communicationPackage.XmlData.Id));
                pkgType = CommunicationPackageType.Unknown;
            }
            return pkgType;
        }

        /// <summary>
        /// Gets the destinations departments for specified communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <param name="dbMan">The database connection manager.</param>
        /// <returns>Collection of destination department ids.</returns>
        internal IEnumerable<Guid> GetDestinations(ICommunicationPackage communicationPackage, IDatabaseConnectionManager dbMan)
        {
            if (this.destinations == null)
            {
                Makolab.Fractus.Communication.DBLayer.CommunicationPackageMapper mapper =
                        new Makolab.Fractus.Communication.DBLayer.CommunicationPackageMapper(dbMan);

                destinations = mapper.GetDestinations();
            }
            CommunicationPackageType type = GetPackageType(communicationPackage);

            if (this.destinations.ContainsKey(type) == false) return null;

            return (from branch in this.destinations[type]
                    where branch.DatabaseId != communicationPackage.DatabaseId.Value &&
                          branch.DatabaseId != currentDatabaseId.Value
                    select branch.DatabaseId).Distinct();
        }
    }
}
