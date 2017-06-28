namespace Makolab.Fractus.Communication.Scripts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using System.Xml.Linq;
    using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
    using Makolab.Fractus.Kernel.Mappers;

    /// <summary>
    /// Class that executes item's relations communication package.
    /// </summary>
    public class ItemRelationScript : SnapshotScript
    {
        /// <summary>
        /// Item repository.
        /// </summary>
        private ItemRepository repository;
        private ContractorRepository contractorRepository;

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemRelationScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ItemRelationScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new ItemRepository(unitOfWork, controller);
            this.contractorRepository = new ContractorRepository(unitOfWork, controller);
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the item's relations root element name.
        /// </summary>
        /// <value>The item's relations tag.</value>
        public override string MainObjectTag
        {
            get { return "itemRelation"; }
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            repository.ExecuteOperations(changeset);

            List<string> indexedItems = new List<string>();
            XDocument xml = XDocument.Parse("<root businessObjectId=\"\" mode=\"\" />");
            var mainItem = this.CurrentPackage.Xml.Root.Descendants("itemId").FirstOrDefault();
            if (mainItem != null)
            {
                xml.Root.Attribute("businessObjectId").Value = mainItem.Value;
                xml.Root.Attribute("mode").Value = DBRowState.Update.ToStateName();
                this.repository.IndexItem(xml);
                indexedItems.Add(xml.Root.Attribute("businessObjectId").Value);
            }

            foreach (DBRow row in changeset.Table(MainObjectTag).Rows)
            {
                if (row.Action == DBRowState.Delete) continue;

                string id = row.Element("relatedObjectId").Value;
                if (indexedItems.Contains(id) == true) continue;
                
                xml.Root.Attribute("businessObjectId").Value = id;
                xml.Root.Attribute("mode").Value = DBRowState.Update.ToStateName();
                ItemRelationType relationType = DictionaryMapper.Instance.GetItemRelationType(new Guid(row.Element("itemRelationTypeId").Value));
                string relatedObjectType = relationType.Metadata.Element("relatedObjectType").Value;
                switch (relatedObjectType)
                {
                    case "Item":
                        this.repository.IndexItem(xml);
                        break;
                    case "Contractor":
                        this.contractorRepository.IndexContractor(xml);
                        break;
                }
                indexedItems.Add(xml.Root.Attribute("businessObjectId").Value);
            }
        }

        /// <summary>
        /// Gets xml representation of item's relations.
        /// </summary>
        /// <param name="objectId">The item's relations id.</param>
        /// <returns>Item's relations snapshot retrieved from database.</returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            return GetSnapshotOrNull(repository.FindItemRelationsSnapshot(objectId));
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (this.repository != null) this.repository.Dispose();
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
