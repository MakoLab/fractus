using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using System.Xml.Linq;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using System.IO;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process the WarehouseDocumentSnapshot communication package with shift document.
    /// </summary>
    public class ShiftDocumentSnapshot : WarehouseDocumentSnapshot
    {
        private DBXml previousDocument;

        /// <summary>
        /// Initializes a new instance of the <see cref="ShiftDocumentSnapshot"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        /// <param name="isHeadquarter">if set to <c>true</c> currnet branch is headquarter.</param>
        public ShiftDocumentSnapshot(IUnitOfWork unitOfWork, ExecutionController controller, bool isHeadquarter)
            : base(unitOfWork, controller, isHeadquarter)
        {

        }

        /// <summary>
        /// Process communication package persisting it's data to database.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            try
            {
                SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
                SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

                bool result = base.ExecutePackage(communicationPackage);
                if (result == false) return false;

                //skip local shift documents
                if (IsLocal(this.CurrentPackage) == true) return true;

                using (var wrapper = this.UnitOfWork.ConnectionManager.SynchronizeConnection())
                {
                    SqlConnectionManager.Instance.SetConnection(wrapper.Connection, this.UnitOfWork.Transaction as SqlTransaction);
                }

                bool isOutcomeshift = IsOutcomeshift(this.CurrentPackage);
                bool isIncomeShift = IsIncomeshift(this.CurrentPackage);
                bool isTargetBranch = IsTargetBranch(this.CurrentPackage);
                bool isSourceBranch = IsSourceBranch(this.CurrentPackage);

                if (isOutcomeshift == true)
                {
                    if (isTargetBranch == true)
                    {
                        if (this.IsHeadquarter == false)
                        {
                            DBXml series = new DBXml();
                            series.AddTable(this.CurrentPackage.Table("series"));

                            SeriesScript seriesProcessor = new SeriesScript(this.UnitOfWork, this.ExecutionController);
                            seriesProcessor.Log = this.Log;
                            seriesProcessor.LocalTransactionId = this.LocalTransactionId;
                            CommunicationPackage seriesPackage = new CommunicationPackage(new XmlTransferObject() { Content = series.Xml.ToString(SaveOptions.DisableFormatting) });
                            seriesPackage.DatabaseId = communicationPackage.DatabaseId;
                            seriesPackage.XmlData.LocalTransactionId = communicationPackage.XmlData.LocalTransactionId;
                            seriesPackage.XmlData.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
                            seriesProcessor.ExecutePackage(seriesPackage);
                        }

                        this.ExecutionController.ExecuteCommand(() => ExecuteOutcomeShift());
                        if (this.CurrentPackage.Xml.Root.Attribute("skipPackage") == null)  this.CurrentPackage.Xml.Root.Add(new XAttribute("skipPackage", true));
                    }

                    if (this.IsHeadquarter && isTargetBranch == false)
                    {
                        DBXml series = this.Repository.FindSeries(new Guid(this.CurrentPackage.Table("warehouseDocumentHeader").FirstRow().Element("seriesId").Value));
                        this.CurrentPackage.AddTable(series.Table("series"));
                    }
                    if (this.IsHeadquarter == false && isTargetBranch == false && isSourceBranch == false) throw new InvalidOperationException("ShiftDocumentSnapshot is in invalid branch.");
                }
                else if (isIncomeShift == true && this.IsHeadquarter == true && (isTargetBranch || IsNewOrChanged(this.CurrentPackage, this.previousDocument)))
                {
                    this.ExecutionController.ExecuteCommand(() => ExecuteIncomeShift());
                }
                communicationPackage.XmlData.Content = this.CurrentPackage.Xml.ToString(SaveOptions.DisableFormatting);
                return result;

            }
            catch (SqlException e)
            {
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag);
                }
                else
                {
                    this.Log.Error("ShiftDocumentSnapshot:ExecutePackage " + e.ToString());
                    return false;
                }
            }
        }

        /// <summary>
        /// Generates the changeset - diff beetween two snapshots.
        /// </summary>
        /// <param name="commSnapshot">The snapshot from other branch.</param>
        /// <param name="dbSnapshot">The snapshot created from database.</param>
        /// <returns>Generated xml changeset.</returns>
        public override DBXml GenerateChangeset(DBXml commSnapshot, DBXml dbSnapshot)
        {
            this.previousDocument = (dbSnapshot == null) ? null : new DBXml(dbSnapshot);
            return base.GenerateChangeset(commSnapshot, dbSnapshot);
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            if (this.IsHeadquarter == true && IsLocal(this.CurrentPackage) == false) base.ExecuteChangeset(changeset);
        }

        /// <summary>
        /// Gets xml representation of bussiness object with related objects.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns>
        /// 	<see cref="DBXml"/> from database with specified id.
        /// </returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            if (this.IsHeadquarter == true) return base.GetCurrentSnapshot(objectId);
            else return null;
        }

        /// <summary>
        /// Generates the shift document status package.
        /// </summary>
        /// <returns>Generated ShiftDocumentStatus package.</returns>
        private CommunicationPackage GenerateShiftDocumentStatusPackage()
        {
            string oppositeShiftDocFieldId = DictionaryMapper.Instance.GetDocumentField(Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId).Id.Value.ToString().ToUpperInvariant();
            string oppositeShiftDocId = this.CurrentPackage.Table("documentAttrValue").Rows
                                        .Where(row => row.Element("documentFieldId").Value.Equals(oppositeShiftDocFieldId))
                                        .Select(row => row.Element("textValue").Value)
                                        .SingleOrDefault();
            if (oppositeShiftDocId == null) throw new InvalidDataException("Missing opposite document id in attribute.");

            XDocument statusXml = XDocument.Parse("<root><shiftDocumentStatus/></root>");
            statusXml.Root.Element("shiftDocumentStatus").Add(new XAttribute("incomeShiftId", 
                                                                             this.CurrentPackage.Table("warehouseDocumentHeader").FirstRow().Element("id").Value),
                                                              new XAttribute("outcomeShiftId", oppositeShiftDocId),
                                                              new XAttribute("status", 
                                                                this.CurrentPackage.Table("warehouseDocumentHeader").FirstRow().Element("status").Value));
            
            XmlTransferObject statusPkgData = new XmlTransferObject
            {
                DeferredTransactionId = Guid.NewGuid(),
                Id = Guid.NewGuid(),
                LocalTransactionId = this.LocalTransactionId,
                XmlType = "ShiftDocumentStatus",
                Content = statusXml.ToString(SaveOptions.DisableFormatting)
            };
            return new CommunicationPackage(statusPkgData);
        }

        private static bool IsOutcomeshift(DBXml shiftDocument)
        {
            DocumentType docType = DictionaryMapper.Instance.GetDocumentType(new Guid(
                            shiftDocument.Table("warehouseDocumentHeader")
                            .FirstRow().Element("documentTypeId").Value));

            return (docType.WarehouseDocumentOptions.WarehouseDirection == Makolab.Fractus.Kernel.Enums.WarehouseDirection.OutcomeShift);
        }

        private static bool IsIncomeshift(DBXml shiftDocument)
        {
            DocumentType docType = DictionaryMapper.Instance.GetDocumentType(new Guid(
                            shiftDocument.Table("warehouseDocumentHeader")
                            .FirstRow().Element("documentTypeId").Value));

            return (docType.WarehouseDocumentOptions.WarehouseDirection == Makolab.Fractus.Kernel.Enums.WarehouseDirection.IncomeShift);
        }

        private static bool IsTargetBranch(DBXml shiftDocument)
        {
            Guid branchId = Guid.Empty;
            if (IsOutcomeshift(shiftDocument) == true)
            {
                string targetWarehouseId = null;
                string oppositeWarehouseFieldId = DictionaryMapper.Instance.GetDocumentField(Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId).Id.Value.ToString().ToUpperInvariant();
                targetWarehouseId = shiftDocument.Xml.Root.Element("documentAttrValue").Elements()
                                            .Where(row => row.Element("documentFieldId").Value.Equals(oppositeWarehouseFieldId))
                                            .Select(row => row.Element("textValue").Value)
                                            .SingleOrDefault();
                if (targetWarehouseId == null) throw new InvalidDataException("Missing target warehouse id.");
                Warehouse targetWarehouse = DictionaryMapper.Instance.GetWarehouse(new Guid(targetWarehouseId));
                branchId = targetWarehouse.BranchId;
            }
            else branchId = new Guid(shiftDocument.Table("warehouseDocumentHeader").FirstRow().Element("branchId").Value);

            return (Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.DatabaseId == DictionaryMapper.Instance.GetBranch(branchId).DatabaseId);
        }

        private static bool IsSourceBranch(DBXml shiftDocument)
        {
            Guid branchId = Guid.Empty;
            if (IsOutcomeshift(shiftDocument) == true) branchId = new Guid(shiftDocument.Table("warehouseDocumentHeader").FirstRow().Element("branchId").Value);
            else
            {
                string targetWarehouseId = null;
                string oppositeWarehouseFieldId = DictionaryMapper.Instance.GetDocumentField(Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId).Id.Value.ToString().ToUpperInvariant();
                targetWarehouseId = shiftDocument.Xml.Root.Element("documentAttrValue").Elements()
                                            .Where(row => row.Element("documentFieldId").Value.Equals(oppositeWarehouseFieldId))
                                            .Select(row => row.Element("textValue").Value)
                                            .SingleOrDefault();
                if (targetWarehouseId == null) throw new InvalidDataException("Missing target warehouse id.");
                Warehouse targetWarehouse = DictionaryMapper.Instance.GetWarehouse(new Guid(targetWarehouseId));
                branchId = targetWarehouse.BranchId;
            }

            return (Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.DatabaseId == DictionaryMapper.Instance.GetBranch(branchId).DatabaseId);
        }

        private static bool IsLocal(DBXml communicationPackage)
        {
            return (IsTargetBranch(communicationPackage) && IsSourceBranch(communicationPackage));     
        }

        private static bool IsNewOrChanged(DBXml currentDocument, DBXml previousDocument)
        {
            return (previousDocument == null ||
                    currentDocument.Table("warehouseDocumentHeader").FirstRow().Element("status").Value.Equals(
                    previousDocument.Table("warehouseDocumentHeader").FirstRow().Element("status").Value) == false);
        }

        private void ExecuteOutcomeShift()
        {
            var valuationsData = this.CurrentPackage.Table("warehouseDocumentValuation");
            if (valuationsData != null && valuationsData.HasRows == true)
            {
                valuationsData.Xml.Add(new XAttribute("outcomeShiftId", this.CurrentPackage.Table("warehouseDocumentHeader").FirstRow().Element("id").Value));
                foreach (DBRow valuationRow in valuationsData.Rows)
                {
                    var docLine = this.CurrentPackage.Table("warehouseDocumentLine").Rows.Where(row => row.Element("id").Value.Equals(valuationRow.Element("outcomeWarehouseDocumentLineId").Value)).SingleOrDefault();
                    valuationRow.Xml.Add(new XAttribute("outcomeShiftOrdinalNumber", docLine.Element("ordinalNumber").Value));
                }
            }

            using (Kernel.Coordinators.DocumentCoordinator coordinator = new Makolab.Fractus.Kernel.Coordinators.DocumentCoordinator(false, false))
            {
                coordinator.CreateOrUpdateIncomeShiftDocumentFromOutcomeShift(this.CurrentPackage.Xml.Root);
                if (valuationsData != null && valuationsData.HasRows == true) coordinator.ValuateIncomeShiftDocument(this.CurrentPackage.Xml.Root);
            }
        }

        private void ExecuteIncomeShift()
        {
            CommunicationPackage statusPkg = GenerateShiftDocumentStatusPackage();

            string oppositeWarehouseFieldId = DictionaryMapper.Instance.GetDocumentField(Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId).Id.Value.ToString().ToUpperInvariant();
            string oppositeWarehouseId = this.CurrentPackage.Xml.Root.Element("documentAttrValue").Elements()
                                        .Where(row => row.Element("documentFieldId").Value.Equals(oppositeWarehouseFieldId))
                                        .Select(row => row.Element("textValue").Value)
                                        .SingleOrDefault();
            if (oppositeWarehouseId == null) throw new InvalidDataException("Missing opposite warehouse id in document attributes");

            Warehouse w = DictionaryMapper.Instance.GetWarehouse(new Guid(oppositeWarehouseId));
            statusPkg.DatabaseId = DictionaryMapper.Instance.GetBranch(w.BranchId).DatabaseId;
            CommunicationPackageRepository pkgRepo = new CommunicationPackageRepository(this.UnitOfWork);
            pkgRepo.PutToOutgoingQueue(statusPkg);
        }
    }
}
