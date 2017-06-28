namespace Makolab.Fractus.Communication.Scripts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Linq;
    using System.Data.SqlClient;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;

    /// <summary>
    /// Class that executes contractor communication package.
    /// </summary>
    public class ContractorScript : SnapshotScript
    {
        /// <summary>
        /// Contractor repository
        /// </summary>
        private ContractorRepository repository;
        private string[] extensionTables = { "employee", "bank", "applicationUser" };
        private DBXml currentContractor;

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ContractorScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork) 
        {
            this.repository = new ContractorRepository(UnitOfWork, controller);
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the contractor's root element name.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "contractor"; }
        }

        /// <summary>
        /// Gets xml representation of contractor with related objects.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns>Contractor snapshot retrieved from database.</returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.repository.FindContractorSnapshot(objectId);
            return GetSnapshotOrNull(snapshot);              
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            this.repository.ExecuteOperations(changeset);

            XDocument xml = XDocument.Parse("<root businessObjectId=\"\" mode=\"\" />");
            xml.Root.Attribute("businessObjectId").Value = this.CurrentPackage.Table(this.MainObjectTag).FirstRow().Element("id").Value;
            xml.Root.Attribute("mode").Value = changeset.Table(this.MainObjectTag).FirstRow().Xml.Attribute("action").Value;
            this.repository.IndexContractor(xml);
        }

        /// <summary>
        /// Generates the changeset - diff beetween two snapshots.
        /// </summary>
        /// <param name="commSnapshot">The snapshot from other branch.</param>
        /// <param name="dbSnapshot">The snapshot created from database.</param>
        /// <returns>Generated xml changeset.</returns>
        public override DBXml GenerateChangeset(DBXml commSnapshot, DBXml dbSnapshot)
        {
            var entries = commSnapshot.Tables.SelectMany(tab => tab.Rows);
            foreach (var entry in entries) if (entry.Element("id") == null) entry.AddElement("id", entry.Element("contractorId").Value);

            if (dbSnapshot != null)
            {
                entries = dbSnapshot.Tables.SelectMany(tab => tab.Rows);
                foreach (var entry in entries) if (entry.Element("id") == null) entry.AddElement("id", entry.Element("contractorId").Value);
            }
            this.currentContractor = dbSnapshot;
            return base.GenerateChangeset(commSnapshot, dbSnapshot);
        }

        public override Dictionary<string, string> GetPreviousVersion(DBXml dbXml)
        {
            var prevVers = base.GetPreviousVersion(dbXml);
            if (this.currentContractor == null) return prevVers;

            foreach (var table in this.extensionTables)
            {
                var commTab = dbXml.Table(table);
                var dbTab = this.currentContractor.Table(table);
                if (commTab != null && commTab.HasRows && dbTab != null && dbTab.HasRows)
                {
                    string rand = Guid.NewGuid().ToString();
                    commTab.FirstRow().AddElement("_commReq", rand);
                    prevVers.Add(rand, dbTab.FirstRow().Element("version").Value);
                }
            }

            return prevVers;
        }

        public override void SetPreviousVersion(DBXml dbXml, Dictionary<string, string> previousVersions)
        {
            base.SetPreviousVersion(dbXml, previousVersions);
            foreach (var objectVersion in previousVersions)
            {
                if (objectVersion.Key.Length > 0)
                {
                    var row = dbXml.FindRow(r => r.Element("_commReq") != null && r.Element("_commReq").Value == objectVersion.Key);
                    if (row != null) row.AddElement("version", objectVersion.Value);
                }
            }

        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            //if (this.repository != null) this.repository.Dispose();
        }
    }
}
