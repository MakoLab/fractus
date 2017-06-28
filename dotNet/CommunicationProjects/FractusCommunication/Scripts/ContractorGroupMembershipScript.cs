using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;
using System.Xml.Linq;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Class that executes contractor's group membership communication package.
    /// </summary>
    public class ContractorGroupMembershipScript : SnapshotScript
    {
        /// <summary>
        /// Contractor repository
        /// </summary>
        private ContractorRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorGroupMembershipScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ContractorGroupMembershipScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork) 
        {
            this.repository = new ContractorRepository(UnitOfWork, controller);
            this.repository.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the contractor's group membership root element name.
        /// </summary>
        /// <value>The contractor's group membership tag.</value>
        public override string MainObjectTag
        {
            get { return "contractorGroupMembership"; }
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
            SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
            SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

            this.CurrentPackage = new DBXml(XDocument.Parse(communicationPackage.XmlData.Content));

            //Guid mainObjectId = new Guid(this.CurrentPackage.Table(MainObjectTag).Row().Element("id").Value);
            //DBXml dbSnapshot = GetCurrentSnapshot(mainObjectId);

            DBXml dbSnapshot = new DBXml();
            Guid currentConGrMemId = Guid.Empty;
            var dbTables = new List<DBTable>();
            try
            {
                var groupsAlreadyRemoved = new List<DBRow>();
                foreach (var conGrMem in this.CurrentPackage.Table(MainObjectTag).Rows)
                {
                    currentConGrMemId = new Guid(conGrMem.Element("id").Value);
                    DBXml currentDBSnapshot = GetCurrentSnapshot(currentConGrMemId);

                    if (conGrMem.Action == DBRowState.Delete && currentDBSnapshot == null) groupsAlreadyRemoved.Add(conGrMem);

                    // TODO conflict detection & resolution
                    //if (ValidateVersion(conGrMem, currentDBSnapshot) == false)
                    //{
                    //    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + currentConGrMemId);
                    //}

                    if (conGrMem.Element("_object1from") != null)
                    {
                        DBXml contractor = repository.FindContractorSnapshot(new Guid(conGrMem.Element("contractorId").Value));
                        if (contractor != null && contractor.Table("contractor").FirstRow().Element("version").Value.Equals(conGrMem.Element("_object1from").Value) == false)
                        {
                            this.Log.Error("ItemGroupMembershipScript: Wystapil konflikt wersji towaru " + conGrMem.Element("contractorId").Value + " oczekiwano " +
                                                conGrMem.Element("_object1from").Value +
                                                " otrzymano " + contractor.Table("contractor").FirstRow().Element("version").Value);

                            conGrMem.Element("_object1from").Value = contractor.Table("contractor").FirstRow().Element("version").Value;
                        }
                    }

                    if (currentDBSnapshot != null) dbTables.Add(currentDBSnapshot.Table(this.MainObjectTag));
                }
                dbSnapshot.AddTable(dbTables);

                DBXml changeset = GenerateChangeset(CurrentPackage, dbSnapshot);
                ExecuteChangeset(changeset);
            }
            catch (SqlException e)
            {
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + currentConGrMemId.ToString());
                }
                else
                {
                    this.Log.Error("SnapshotScript:ExecutePackage " + e.ToString());
                    return false;
                }
            }

            return true;
        }


        /// <summary>
        /// Check whether database xml from communication has correct version.
        /// </summary>
        /// <param name="commSnapshot">The snapshot from other branch.</param>
        /// <param name="dbSnapshot">The snapshot created from database.</param>
        /// <returns><c>true</c> if database xml from communication has correct version; otherwise, <c>false</c>.</returns>
        public bool ValidateVersion(DBRow commSnapshot, DBXml dbSnapshot)
        {
            if (dbSnapshot != null &&
                commSnapshot.HasAction == false && //only delete action is valid
                commSnapshot.PreviousVersion.Equals(dbSnapshot.Table(MainObjectTag).FirstRow().Element("version").Value,
                                                          StringComparison.OrdinalIgnoreCase) == false)
            {
                return false;
            }
            else if (dbSnapshot != null &&
                     commSnapshot.HasAction == true && //only delete action is valid
                     commSnapshot.Element("version").Value.Equals(dbSnapshot.Table(MainObjectTag).FirstRow().Element("version").Value,
                                                                        StringComparison.OrdinalIgnoreCase) == false)
            {
                return false;
            }

            else return true;
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            this.repository.ExecuteOperations(changeset);
        }

        /// <summary>
        /// Gets xml representation of contractor's group membership.
        /// </summary>
        /// <param name="objectId">The contractor's group membership id.</param>
        /// <returns>Contractor's group membership snapshot retrieved from database.</returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.repository.FindContractorGroupMembershipSnapshot(objectId);
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

        public override void SetPreviousVersion(DBXml dbXml, Dictionary<string, string> previousVersions)
        {
            PackageExecutionHelper.SetPreviousVersion(dbXml, previousVersions, this.MainObjectTag);
        }
    }
}
