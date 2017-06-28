using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;

namespace Makolab.Fractus.Communication.Scripts
{
    public class ComplaintDocumentSnapshot : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        protected DocumentRepository repository;


        /// <summary>
        /// Initializes a new instance of the <see cref="CommercialDocumentScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ComplaintDocumentSnapshot(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.ExecutionController = controller;
        }

        public override string MainObjectTag
        {
            get { return "complaintDocumentHeader"; }
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
        /// Gets xml representation of bussiness object with related objects.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns>
        /// 	<see cref="DBXml"/> from database with specified id.
        /// </returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.repository.FindComplaintDocumentSnapshot(objectId);
            return GetSnapshotOrNull(snapshot);
        }
    }
}
