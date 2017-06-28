using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;
using System.Xml.Linq;
using Makolab.Commons.Communication.Exceptions;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process ItemGroupMembership communication package.
    /// </summary>
    public class ItemGroupMembershipScript : SnapshotScript
    {
        /// <summary>
        /// Item repository
        /// </summary>
        private ItemRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorGroupMembershipScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ItemGroupMembershipScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork) 
        {
            this.repository = new ItemRepository(unitOfWork, controller);
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "itemGroupMembership"; }
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
            Guid currentItemGrMemId = Guid.Empty;
            var dbTables = new List<DBTable>();
            try
            {
                var groupsAlreadyRemoved = new List<DBRow>();
                foreach (var itemGrMem in this.CurrentPackage.Table(MainObjectTag).Rows)
                {
                    currentItemGrMemId = new Guid(itemGrMem.Element("id").Value);
                    DBXml currentDBSnapshot = GetCurrentSnapshot(currentItemGrMemId);

                    if (itemGrMem.Action == DBRowState.Delete && currentDBSnapshot == null) groupsAlreadyRemoved.Add(itemGrMem);

                    // TODO conflict detection & resolution
                    //if (ValidateVersion(itemGrMem, currentDBSnapshot) == false)
                    //{
                    //    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + currentItemGrMemId);
                    //}

                    if (itemGrMem.Element("_object1from") != null)
                    {
                        DBXml item = repository.FindItemSnapshot(new Guid(itemGrMem.Element("itemId").Value));
                        if (item != null && item.Table("item").FirstRow().Element("version").Value.Equals(itemGrMem.Element("_object1from").Value) == false)
                        {
                            this.Log.Error("ItemGroupMembershipScript: Wystapil konflikt wersji towaru " + itemGrMem.Element("itemId").Value + " oczekiwano " + 
                                                itemGrMem.Element("_object1from").Value + 
                                                " otrzymano " + item.Table("item").FirstRow().Element("version").Value);

                            itemGrMem.Element("_object1from").Value = item.Table("item").FirstRow().Element("version").Value;
                        }
                    }

                    if (currentDBSnapshot != null) dbTables.Add(currentDBSnapshot.Table(this.MainObjectTag));
                }
                groupsAlreadyRemoved.ForEach(row => row.Remove());
                dbSnapshot.AddTable(dbTables);

                DBXml changeset = GenerateChangeset(CurrentPackage, dbSnapshot);
                ExecuteChangeset(changeset);
            }
            catch (SqlException e)
            {
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + currentItemGrMemId.ToString());
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
        /// Validates the version.
        /// </summary>
        /// <param name="commSnapshot">The comm snapshot.</param>
        /// <param name="dbSnapshot">The db snapshot.</param>
        /// <returns><c>true</c> if xml from communication has correct version; otherwise, <c>false</c>.</returns>
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
        /// <returns>Item's group membership snapshot retrieved from database.</returns>
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
