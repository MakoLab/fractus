using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process Series communication package.
    /// </summary>
    public class SeriesScript : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "series"; }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="SeriesScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public SeriesScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.ExecutionController = controller;
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
            DBXml seriesXml = this.repository.FindSeries(objectId);
            return GetSnapshotOrNull(seriesXml);
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            if (changeset != null) repository.ExecuteOperations(changeset);
        }

        /// <summary>
        /// Generates the changeset - diff beetween two snapshots.
        /// </summary>
        /// <param name="commSnapshot">The snapshot from other branch.</param>
        /// <param name="dbSnapshot">The snapshot created from database.</param>
        /// <returns>Generated xml changeset.</returns>
        public override DBXml GenerateChangeset(DBXml commSnapshot, DBXml dbSnapshot)
        {
            if (dbSnapshot == null) return base.GenerateChangeset(commSnapshot, null);
            else return null;
        }

        /// <summary>
        /// Check whether database xml from communication has correct version.
        /// </summary>
        /// <param name="commSnapshot">The snapshot from other branch.</param>
        /// <param name="dbSnapshot">The snapshot created from database.</param>
        /// <returns>
        /// 	<c>true</c> if database xml from communication has correct version; otherwise, <c>false</c>.
        /// </returns>
        public override bool ValidateVersion(DBXml commSnapshot, DBXml dbSnapshot)
        {
            return true;
        }
    }
}
