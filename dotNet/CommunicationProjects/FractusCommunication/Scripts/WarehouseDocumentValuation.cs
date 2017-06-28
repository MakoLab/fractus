using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process the WarehouseDocumentValuation communication package.
    /// </summary>
    public class WarehouseDocumentValuation : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        //1 - everything (valuations) at once, 0 - single valuation per transaction.
        private int executionMode;

        /// <summary>
        /// Gets or sets a value indicating whether this branch is headquarter.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this branch is headquarter; otherwise, <c>false</c>.
        /// </value>
        protected bool IsHeadquarter { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="WarehouseDocumentValuation"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        /// <param name="isHeadquarter">if set to <c>true</c> currnet branch is headquarter, hope I don't have to explain what it means when it's set to false.</param>
        public WarehouseDocumentValuation(IUnitOfWork unitOfWork, ExecutionController controller, bool isHeadquarter)
            : base(unitOfWork)
	    {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.ExecutionController = controller;
            this.IsHeadquarter = isHeadquarter;
	    }

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "warehouseDocumentValuation"; }
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
            return ExecutePackage(communicationPackage, 1);
        }

        /// <summary>
        /// Process communication package persisting it's data to database.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <param name="executionMode">The execution mode. 1 - everything at once, 0 - single valuation per transaction.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public bool ExecutePackage(ICommunicationPackage communicationPackage, int executionMode)
        {
            this.executionMode = executionMode;

            SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
            SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

            
            this.CurrentPackage = new DBXml(XDocument.Parse(communicationPackage.XmlData.Content));

            if (this.IsHeadquarter == true)
            {

                List<Guid> valuationsId = new List<Guid>();

                foreach (DBRow row in this.CurrentPackage.Table(this.MainObjectTag).Rows)
                {
                    Guid valuationId = new Guid(row.Element("id").Value);
                    valuationsId.Add(valuationId);
                }

                DBXml dbSnapshot = GetCurrentSnapshot(valuationsId);
                bool hasSavepoint = false;
                try
                {
                    // TODO conflict detection & resolution
                    //// Conflict detection
                    //if (dbSnapshot != null && ValidateVersion(CurrentPackage, dbSnapshot) == false)
                    //{
                    //    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + mainObjectId.ToString());
                    //}

                    PackageExecutionHelper.RemoveDeletedRows(this.CurrentPackage, dbSnapshot, this.MainObjectTag, this.Log);

                    if (this.CurrentPackage.Table(this.MainObjectTag).HasRows == false) return true;
                    //else do the rest

                    DBXml changeset = GenerateChangeset(CurrentPackage, dbSnapshot);

                    this.repository.CreateSavepoint("warehouseValuationSP");
                    hasSavepoint = true;
                    ExecuteChangeset(changeset);

                    //check whether headquarter is a target branch - we have a document so it's not a big deal, and if so valuate incom shift
                    var distributedLines = this.CurrentPackage.Table(this.MainObjectTag).Rows
                                                .Where(
                                                    row => row.Element("isDistributed") != null
                                                        && row.Element("isDistributed").Value.Equals("True", StringComparison.OrdinalIgnoreCase)
                                                        && row.Element("warehouseDocumentHeaderId") != null
                                                        && row.Action != DBRowState.Delete)
                                                .GroupBy(row => row.Element("warehouseDocumentHeaderId").Value);

                    if (distributedLines.Count() > 0) this.ExecutionController.ExecuteCommand(() => ValuateIncomeFromOutcome(distributedLines));


                }
                catch (ClientException e)
                {
                    string s = "";
                    foreach (var parameter in e.Parameters)
                    {
                        s += ";" + parameter;
                    }
                    this.Log.Info(s);
                    throw;
                }
                catch (SqlException e)
                {
                    if (e.Number == 547)
                    {
                        if (hasSavepoint) this.repository.RollbackToSavepoint("warehouseValuationSP");
                        this.Log.Info(String.Format("Paczka wyceny {0} pominieta - brak wycenianego dokumentu: {1}", communicationPackage.OrderNumber, e.ToString()));
                        return true;
                    }
                    if (e.Number == 50012) // Conflict detection
                    {
                        throw new ConflictException("Conflict detected while changing " + this.MainObjectTag);
                    }
                    else
                    {
                        this.Log.Error("SnapshotScript:ExecutePackage " + e.ToString());
                        return false;
                    }
                }
                if (this.CurrentPackage.Xml.Root.Attribute("skipPackage") == null) this.CurrentPackage.Xml.Root.Add(new XAttribute("skipPackage", true));
                communicationPackage.XmlData.Content = this.CurrentPackage.Xml.ToString(SaveOptions.DisableFormatting);
                return true;
            }
            else if (this.CurrentPackage.Table(this.MainObjectTag).Rows.Any(row => row.Element("isDistributed") != null
                                                                                && row.Element("isDistributed").Value.Equals("True", StringComparison.OrdinalIgnoreCase)))
            {
                // if the branch is not headquarther we consider it as target branch for shift document and try to valuate income shift
                this.ExecutionController.ExecuteCommand(() => ValuateIncomeFromOutcome());
                return true;
            }
            else
            {
                //its not a shift valuation, 
                // just other warehouse document valuation returned from HQ probably cause of some accounting operations
                List<Guid> valuationsId = new List<Guid>();

                foreach (DBRow row in this.CurrentPackage.Table(this.MainObjectTag).Rows)
                {
                    Guid valuationId = new Guid(row.Element("id").Value);
                    valuationsId.Add(valuationId);
                }

                DBXml dbSnapshot = GetCurrentSnapshot(valuationsId);
                bool hasSavepoint = false;
                try
                {
                    // TODO conflict detection & resolution
                    //// Conflict detection
                    //if (dbSnapshot != null && ValidateVersion(CurrentPackage, dbSnapshot) == false)
                    //{
                    //    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + mainObjectId.ToString());
                    //}

                    PackageExecutionHelper.RemoveDeletedRows(this.CurrentPackage, dbSnapshot, this.MainObjectTag, this.Log);

                    if (this.CurrentPackage.Table(this.MainObjectTag).HasRows == false) return true;
                    //else do the rest

                    DBXml changeset = GenerateChangeset(CurrentPackage, dbSnapshot);

                    this.repository.CreateSavepoint("warehouseValuationSP");
                    hasSavepoint = true;
                    ExecuteChangeset(changeset);
                }
                catch (ClientException e)
                {
                    string s = "";
                    foreach (var parameter in e.Parameters)
                    {
                        s += ";" + parameter;
                    }
                    this.Log.Info(s);
                    throw;
                }
                catch (SqlException e)
                {
                    if (e.Number == 547)
                    {
                        if (hasSavepoint) this.repository.RollbackToSavepoint("warehouseValuationSP");
                        this.Log.Info(String.Format("Paczka wyceny {0} pominieta - brak wycenianego dokumentu: {1}", communicationPackage.OrderNumber, e.ToString()));
                        return true;
                    }
                    if (e.Number == 50012) // Conflict detection
                    {
                        throw new ConflictException("Conflict detected while changing " + this.MainObjectTag);
                    }
                    else
                    {
                        this.Log.Error("SnapshotScript:ExecutePackage " + e.ToString());
                        return false;
                    }
                }
                if (this.CurrentPackage.Xml.Root.Attribute("skipPackage") == null) this.CurrentPackage.Xml.Root.Add(new XAttribute("skipPackage", true));
                communicationPackage.XmlData.Content = this.CurrentPackage.Xml.ToString(SaveOptions.DisableFormatting);
                return true;
            }
        }

        private void ValuateIncomeFromOutcome(IEnumerable<IGrouping<string, DBRow>> shiftLines)
        {
            XDocument valuationTemplate = XDocument.Parse("<root><warehouseDocumentValuation /></root>");
            using (var whDocCoord = new DocumentCoordinator(false, false))
            {
                foreach (var warehouseDocGroup in shiftLines)
                {
                    WarehouseDocument shift = null;
                    try
                    {
                        shift = (WarehouseDocument)whDocCoord.LoadBusinessObject(Makolab.Fractus.Kernel.Enums.BusinessObjectType.WarehouseDocument,
                                                                                                    new Guid(warehouseDocGroup.Key));
                    }
                    catch (ClientException) { }

                    //there is a valuated document in database so we can forward valuation - no document = skip income valuation for this doc
                    if (shift != null)
                    {
						DocumentAttrValue oppositeWarehouseIdAttr = shift.Attributes.Children.Where(attr => attr.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId).SingleOrDefault();
						string oppositeWarehouseId = oppositeWarehouseIdAttr != null ? oppositeWarehouseIdAttr.Value.Value : null;
                        if (oppositeWarehouseId != null)
                        {
                            Warehouse oppositeWarehouse = DictionaryMapper.Instance.GetWarehouse(new Guid(oppositeWarehouseId));
                            Warehouse warehouse = DictionaryMapper.Instance.GetWarehouse(shift.WarehouseId);

                            //skip local shift document valuations
                            if (warehouse.BranchId == oppositeWarehouse.BranchId) continue;

                            // skip valuation in headquarter if not a target branch
                            if (this.IsHeadquarter == true && DictionaryMapper.Instance.GetBranch(oppositeWarehouse.BranchId).DatabaseId != Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.DatabaseId) continue;

                            foreach (var valuation in warehouseDocGroup)
                            {
                                var whDocLine = shift.Lines.Children.Where(line => line.Id.ToString()
                                                                                    .Equals(valuation.Element("outcomeWarehouseDocumentLineId").Value, StringComparison.OrdinalIgnoreCase))
                                                                    .SingleOrDefault();
                                valuation.Xml.Add(new XAttribute("outcomeShiftOrdinalNumber", whDocLine.OrdinalNumber));
                            }

                            var valuationPkg = new XDocument(valuationTemplate);
                            valuationPkg.Root.Element("warehouseDocumentValuation").Add(new XAttribute("outcomeShiftId", shift.Id));
                            valuationPkg.Root.Element("warehouseDocumentValuation").Add(warehouseDocGroup);

                            try
                            {
                                whDocCoord.ValuateIncomeShiftDocument(valuationPkg.Root);
                            }
                            catch (ClientException e)
                            {
                                if (e.Id != Makolab.Fractus.Kernel.Enums.ClientExceptionId.ObjectNotFound) throw;
                            }
                        }
                    }
                }
            }            
        }

        private void ValuateIncomeFromOutcome()
        {

            using (Kernel.Coordinators.DocumentCoordinator coordinator = new Makolab.Fractus.Kernel.Coordinators.DocumentCoordinator(false, false))
            {
                try
                {
                    coordinator.ValuateIncomeShiftDocument(this.CurrentPackage.Xml.Root);
                }
                catch (ClientException e)
                {
                    if (e.Id != Makolab.Fractus.Kernel.Enums.ClientExceptionId.ObjectNotFound) throw;
                }
            }
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            if (this.executionMode == 1) repository.ExecuteOperations(changeset);
            else 
            {
                DBXml xml = new DBXml();
                DBTable tab = xml.AddTable(this.MainObjectTag);
                foreach (var valuation in changeset.Table(this.MainObjectTag).Rows)
                {
                    Guid? savepointName = null;
                    var row = tab.AddRow(valuation);
                    try
                    {
                        savepointName = Guid.NewGuid();
                        this.repository.CreateSavepoint(savepointName.ToString());
                        repository.ExecuteOperations(xml);
                    }
                    catch (SqlException)
                    {
                        if (savepointName.HasValue) this.repository.RollbackToSavepoint(savepointName.ToString());
                    }
                    row.Remove();
                } 
            }
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
            DBXml snapshot = this.repository.FindIncomeOutcomeRelation(new List<Guid> { objectId });
            return GetSnapshotOrNull(snapshot);
        }

        /// <summary>
        /// Gets the current snapshot.
        /// </summary>
        /// <param name="valuationId">The list of valuation ids.</param>
        /// <returns></returns>
        public DBXml GetCurrentSnapshot(List<Guid> valuationId)
        {
            DBXml snapshot = this.repository.FindWarehouseDocumentValuations(valuationId);
            return GetSnapshotOrNull(snapshot);
        }

        /// <summary>
        /// Gets the number indicating previous version of contractor relations within database xml.
        /// </summary>
        /// <param name="dbXml">The database xml.</param>
        /// <returns>Previous version of contractor relations.</returns>
        public override Dictionary<string, string> GetPreviousVersion(DBXml dbXml)
        {
            return PackageExecutionHelper.GetPreviousVersion(dbXml, this.MainObjectTag);
        }

        /// <summary>
        /// Removes the previous version number from database xml.
        /// </summary>
        /// <param name="dbXml">The db XML.</param>
        /// <returns>
        /// Specified database xml without previous version number.
        /// </returns>
        public override DBXml RemovePreviousVersion(DBXml dbXml)
        {
            return PackageExecutionHelper.RemovePreviousVersion(dbXml);
        }

        /// <summary>
        /// Sets the previous version.
        /// </summary>
        /// <param name="dbXml">The db XML.</param>
        /// <param name="previousVersions">The previous versions.</param>
        public override void SetPreviousVersion(DBXml dbXml, Dictionary<string, string> previousVersions)
        {
            PackageExecutionHelper.SetPreviousVersion(dbXml, previousVersions, this.MainObjectTag);
        }
    }
}
