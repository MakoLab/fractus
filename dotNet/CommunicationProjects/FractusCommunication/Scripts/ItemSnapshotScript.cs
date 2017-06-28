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
    /// Class that executes item's relations communication package.
    /// </summary>
    public class ItemSnapshotScript : SnapshotScript
    {
        /// <summary>
        /// Item repository.
        /// </summary>
        private ItemRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemSnapshotScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ItemSnapshotScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork) 
        {
            this.repository = new ItemRepository(UnitOfWork, controller);
            this.repository.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the item root element name.
        /// </summary>
        /// <value>The item tag.</value>
        public override string MainObjectTag
        {
            get { return "item"; }
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
            xml.Root.Attribute("mode").Value = (changeset.Table(this.MainObjectTag) == null) ? "update" : changeset.Table(this.MainObjectTag).FirstRow().Xml.Attribute("action").Value;
            this.repository.IndexItem(xml);
        }

        /// <summary>
        /// Gets xml representation of item.
        /// </summary>
        /// <param name="objectId">The item id.</param>
        /// <returns>Item snapshot retrieved from database.</returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.repository.FindItemSnapshot(objectId);
            return GetSnapshotOrNull(snapshot);
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (this.repository != null) this.repository.Dispose();
        }
    }
}
