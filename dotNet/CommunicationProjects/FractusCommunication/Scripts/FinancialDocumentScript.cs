using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication.Scripts
{
    public class FinancialDocumentScript : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="FinancialDocumentScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public FinancialDocumentScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.repository.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "financialDocumentHeader"; }
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
        /// Gets xml representation of bussiness object with related objects.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns>
        /// 	<see cref="DBXml"/> from database with specified id.
        /// </returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            return this.repository.FindFinancialDocumentSnapshot(objectId);
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
            if (base.ExecutePackage(communicationPackage) == false) return false;

            CommunicationPackage payment = PackageExecutionHelper.ExtractPaymentPackage(this.CurrentPackage, communicationPackage);
            if (payment != null)
            {
                payment.XmlData.LocalTransactionId = this.LocalTransactionId;
                var pkgRepo = new CommunicationPackageRepository(this.UnitOfWork);
                var forwarder = Makolab.Fractus.Commons.DependencyInjection.IoC.Get<IPackageForwarder>();
                forwarder.Log = this.Log;
                forwarder.ForwardPackage(payment, pkgRepo);
            }

            return true;
        }
    }
}
