
namespace Makolab.Fractus.Communication.Scripts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;

    /// <summary>
    /// Class that executes item's unit relation communication package.
    /// </summary>
    public class ItemUnitRelationScript : SnapshotScript
    {
        /// <summary>
        /// Item repository.
        /// </summary>
        private ItemRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemUnitRelationScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ItemUnitRelationScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork) 
        {
            this.repository = new ItemRepository(unitOfWork, controller);
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the item's unit relation root element name.
        /// </summary>
        /// <value>The item's unit relation tag.</value>
        public override string MainObjectTag
        {
            get { throw new NotImplementedException(); }
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            repository.ExecuteOperations(changeset);
        }

        /// <summary>
        /// Gets xml representation of item's unit relation.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns>Item's unit relation snapshot retrieved from database.</returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            return GetSnapshotOrNull(repository.FindItemUnitRelationsSnapshot(objectId));
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
