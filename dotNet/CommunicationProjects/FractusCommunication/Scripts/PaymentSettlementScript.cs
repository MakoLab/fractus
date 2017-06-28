using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process PaymentSettlementSnapshot communication package.
    /// </summary>
    public class PaymentSettlementSnapshot : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="PaymentSettlementSnapshot"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        /// <param name="controller">The controller.</param>
        public PaymentSettlementSnapshot(IUnitOfWork unitOfWork, ExecutionController controller) : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "paymentSettlement"; }
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
            DBXml snapshot = this.repository.FindPaymentSettlementSnapshot(objectId);
            return GetSnapshotOrNull(snapshot);
        }
    }
}
