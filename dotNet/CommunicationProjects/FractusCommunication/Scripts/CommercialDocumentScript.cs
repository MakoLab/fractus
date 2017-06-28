using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process CommercialDocumentSnapshot communication package.
    /// </summary>
    public class CommercialDocumentScript : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        protected DocumentRepository repository;


        /// <summary>
        /// Initializes a new instance of the <see cref="CommercialDocumentScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public CommercialDocumentScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
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
            get { return "commercialDocumentHeader"; }
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
            DBXml snapshot = this.repository.FindCommercialDocumentSnapshot(objectId);
            return GetSnapshotOrNull(snapshot);  
        }


        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            repository.ExecuteOperations(changeset);
            //because 
            if (changeset.Table(this.MainObjectTag) != null)
            {
                bool isNew = (changeset.Table(this.MainObjectTag).FirstRow().Action.Value == DBRowState.Insert) ? true : false;
                XDocument xml = XDocument.Parse("<root businessObjectId=\"\" mode=\"\" />");
                xml.Root.Attribute("businessObjectId").Value = this.CurrentPackage.Table(this.MainObjectTag).FirstRow().Element("id").Value;
                xml.Root.Attribute("mode").Value = changeset.Table(this.MainObjectTag).FirstRow().Xml.Attribute("action").Value;
                this.repository.IndexDocument(xml, isNew);
            }
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
