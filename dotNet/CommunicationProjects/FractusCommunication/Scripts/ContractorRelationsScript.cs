namespace Makolab.Fractus.Communication.Scripts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
using System.Xml.Linq;

    /// <summary>
    /// Class that executes contractor relations communication package.
    /// </summary>
    public class ContractorRelationsScript : SnapshotScript
    {
        /// <summary>
        /// Contractor repository
        /// </summary>
        private ContractorRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorRelationsScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ContractorRelationsScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork) 
        {
            this.repository = new ContractorRepository(UnitOfWork, controller);
            this.repository.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the contractor's relations root element name.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "contractorRelation"; }
        }

        /// <summary>
        /// Gets xml representation of contractor relations.
        /// </summary>
        /// <param name="objectId">The contractor relations id.</param>
        /// <returns>Contractor relations snapshot retrieved from database.</returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.repository.FindContractorRelationsSnapshot(objectId);
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

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            this.repository.ExecuteOperations(changeset);

            List<string> indexedContractors = new List<string>();
            XDocument xml = XDocument.Parse("<root businessObjectId=\"\" mode=\"\" />");
            var mainItem = this.CurrentPackage.Xml.Root.Descendants("contractorId").FirstOrDefault();
            if (mainItem != null)
            {
                xml.Root.Attribute("businessObjectId").Value = mainItem.Value;
                xml.Root.Attribute("mode").Value = DBRowState.Update.ToStateName();
                this.repository.IndexContractor(xml);
                indexedContractors.Add(xml.Root.Attribute("businessObjectId").Value);
            }

            foreach (DBRow row in changeset.Table(MainObjectTag).Rows)
            {
                if (row.Action == DBRowState.Delete) continue;

                string id = row.Element("relatedContractorId").Value;
                if (indexedContractors.Contains(id) == true) continue;

                xml.Root.Attribute("businessObjectId").Value = id;
                xml.Root.Attribute("mode").Value = DBRowState.Update.ToStateName();
                indexedContractors.Add(xml.Root.Attribute("businessObjectId").Value);
                this.repository.IndexContractor(xml);
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
