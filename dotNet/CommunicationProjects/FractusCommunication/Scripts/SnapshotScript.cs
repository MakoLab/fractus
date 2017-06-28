namespace Makolab.Fractus.Communication.Scripts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Linq;
    using System.Data;
    using System.Data.SqlClient;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.Exceptions;
    using Makolab.Fractus.Kernel.Managers;

    /// <summary>
    /// Base class for all classes executing snapshot like communication packages.
    /// </summary>
    public abstract class SnapshotScript : ExecutingScript
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SnapshotScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        protected SnapshotScript(IUnitOfWork unitOfWork) : base(unitOfWork) { }

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public abstract string MainObjectTag { get; }

        /// <summary>
        /// Gets or sets database xml that is currently processed.
        /// </summary>
        /// <value>The currently processed database xml.</value>
        /// <remarks>The database xml is build from communication package that is currently executed.</remarks>
        protected DBXml CurrentPackage { get; set; }

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

            Guid mainObjectId = new Guid(this.CurrentPackage.Table(MainObjectTag).FirstRow().Element("id").Value);
            DBXml dbSnapshot = GetCurrentSnapshot(mainObjectId);

            try
            {
                // TODO conflict detection & resolution
                //if (dbSnapshot != null && ValidateVersion(CurrentPackage, dbSnapshot) == false)
                //{
                //    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + mainObjectId.ToString());
                //}

                DBXml changeset = GenerateChangeset(CurrentPackage, dbSnapshot);
                if (changeset != null && changeset.Tables.Count() > 0) ExecuteChangeset(changeset);
            }
            catch (SqlException e)
            {
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + mainObjectId.ToString());
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
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public abstract void ExecuteChangeset(DBXml changeset);

        /// <summary>
        /// Check whether database xml from communication has correct version.
        /// </summary>
        /// <param name="commSnapshot">The snapshot from other branch.</param>
        /// <param name="dbSnapshot">The snapshot created from database.</param>
        /// <returns><c>true</c> if database xml from communication has correct version; otherwise, <c>false</c>.</returns>
        public virtual bool ValidateVersion(DBXml commSnapshot, DBXml dbSnapshot)
        {
            return GetPreviousVersion(commSnapshot)[String.Empty].Equals(dbSnapshot.Table(MainObjectTag).FirstRow().Element("version").Value,
                                                           StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Gets the number indicating previous version of bussiness object within database xml.
        /// </summary>
        /// <param name="dbXml">The database xml.</param>
        /// <returns>Previous version of bussiness object.</returns>
        public virtual Dictionary<string, string> GetPreviousVersion(DBXml dbXml)
        {
            var result = new Dictionary<string, string>(1);
            if (dbXml.Table(MainObjectTag).FirstRow().Action == DBRowState.Delete)
            {
                var ver = dbXml.Table(MainObjectTag).FirstRow().Element("version");
                if (ver != null) result.Add(String.Empty, dbXml.Table(MainObjectTag).FirstRow().Element("version").Value);
                else return null;
            }
            else if (dbXml.PreviousVersion != null) result.Add(String.Empty, dbXml.PreviousVersion);
            else return null;
            return result;
        }

        /// <summary>
        /// Removes the previous version number from database xml.
        /// </summary>
        /// <param name="dbXml">The db XML.</param>
        /// <returns>Specified database xml without previous version number.</returns>
        public virtual DBXml RemovePreviousVersion(DBXml dbXml)
        {
            dbXml.RemovePreviousVersion();
            return dbXml;
        }

        public virtual void SetPreviousVersion(DBXml dbXml, Dictionary<string, string> previousVersions)
        {
            // TODO zamienic na jakis inny wyjatek
            if (previousVersions.ContainsKey(String.Empty) == false) throw new Exception("Previous version is not present in collection uder null key");
            if (dbXml.Table(MainObjectTag).FirstRow().Element("version") == null) dbXml.Table(MainObjectTag).FirstRow().AddElement("version", previousVersions[String.Empty]);
        }

        /// <summary>
        /// Generates the changeset - diff beetween two snapshots.
        /// </summary>
        /// <param name="commSnapshot">The snapshot from other branch.</param>
        /// <param name="dbSnapshot">The snapshot created from database.</param>
        /// <returns>Generated xml changeset.</returns>
        public virtual DBXml GenerateChangeset(DBXml commSnapshot, DBXml dbSnapshot)
        {
            DBXml result = new DBXml(commSnapshot);
            Dictionary<string, string> previousVersion = GetPreviousVersion(result);
            RemovePreviousVersion(result);

            IEnumerable<DBRow> resultEntries = result.Tables.SelectMany(table => table.Rows);

            if (dbSnapshot == null)
            {
                var eTables = new List<DBTable>();
                foreach (var table in result.Tables) if (table.HasRows == false) eTables.Add(table);
                foreach (var table in eTables) table.Remove();

                return MarkAsInserted(resultEntries).First().Table.Document;
            }

            IEnumerable<DBRow> dbEntries = dbSnapshot.Tables.SelectMany(table => table.Rows).Where(row => row.HasAction == false);

            List<DBRow> unmodifiedEntries = new List<DBRow>();

            foreach (DBRow entry in resultEntries)
            {
                DBRow match = dbSnapshot.FindRow(entry);

                if (match != null)
                {
                    //entry.Action != DBRowState.Delete - niestety musialem dolozyc ten warunek gdyz ciezko jest dogadac sie z chlopakami 
                    // by entry przy delete tez zawieraly wersje
                    if (entry.Action != DBRowState.Delete && entry.IsTheSameAs(match))
                    {
                        if (entry.Action == null) unmodifiedEntries.Add(entry);
                        else if (entry.Action == DBRowState.Insert) entry.SetAction(DBRowState.Update);
                    }
                    else if (entry.Action == null)
                    {
                        entry.Element("version").Name = "_version";
                        entry.SetAction(DBRowState.Update);
                    }

                    match.Remove();
                }
                else if (entry.Action == null) entry.SetAction(DBRowState.Insert);
            }

            if (previousVersion != null) // && result.Table(MainObjectTag).FirstRow().Element("version") == null
            {
                SetPreviousVersion(result, previousVersion);
                //result.Table(MainObjectTag).FirstRow().AddElement("version", previousVersion);
            }

            // remove unmodified entries from result
            unmodifiedEntries.ForEach(entry => entry.Remove());

            foreach (DBRow entry in dbEntries) entry.SetAction(DBRowState.Delete);

            result.AddTable(from table in dbSnapshot.Tables where table.HasRows select table);

            var emptyTables = new List<DBTable>();
            foreach (var table in result.Tables) if (table.HasRows == false) emptyTables.Add(table);
            foreach (var table in emptyTables) table.Remove();
            
            return result;
        }

        /// <summary>
        /// Marks entries/rows (parts of data) collection as new data.
        /// </summary>
        /// <param name="entries">The entries.</param>
        /// <returns>Collection of entries marked as inserted by setting action attribiute.</returns>
        public IEnumerable<DBRow> MarkAsInserted(IEnumerable<DBRow> entries)
        {
            // FIX dodany warunek if (entry.Action == null) ze wzgledu na xmle kasujace nieistniejace dane
            // (a brak aktualnych danych wykrywny jest jako insert), trzeba odnalezc przyczyne czemu tych danych nie ma
            // wykryte na kasacji powiazan commercialWarehouseValuation
            foreach (DBRow entry in entries) if (entry.Action == null) entry.SetAction(DBRowState.Insert);
            return entries;
        }

        /// <summary>
        /// Gets xml representation of bussiness object with related objects.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns><see cref="DBXml"/> from database with specified id.</returns>
        public abstract DBXml GetCurrentSnapshot(Guid objectId);

        /// <summary>
        /// Gets the object snapshot or null when snapshot is empty.
        /// </summary>
        /// <param name="snapshot">The snapshot.</param>
        /// <returns>Snapshot if snapshot is not empty; otherwise, <c>null</c></returns>
        protected DBXml GetSnapshotOrNull(DBXml snapshot)
        {
            if (snapshot == null) return null;

            if (snapshot != null && snapshot.Tables.Any(table => table.HasRows) == false) return null;
            else return snapshot;          
        }
    }
}
