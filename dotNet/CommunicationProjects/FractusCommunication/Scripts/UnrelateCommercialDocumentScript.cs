using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.Xml.Linq;
using System.Data.SqlClient;
using System.IO;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process UnrelateCommercialDocument communication package.
    /// </summary>
    public class UnrelateCommercialDocumentScript : ExecutingScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="UnrelateCommercialDocumentScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public UnrelateCommercialDocumentScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Executes the communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
            SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

            try
            {
                XDocument commPkg = XDocument.Parse(communicationPackage.XmlData.Content);
                var commercialDocumentIdElement = commPkg.Root.Element("id");
                if (commercialDocumentIdElement == null || commercialDocumentIdElement.Value.Length == 0)
                {
                    throw new InvalidDataException("Invalid xml data.");
                }
                Guid commercialDocumentId = new Guid(commercialDocumentIdElement.Value);
                var pkgRepo = new CommunicationPackageRepository(this.UnitOfWork);
                this.repository.UnrelateCommercialDocument(commercialDocumentId, this.LocalTransactionId, communicationPackage.XmlData.DeferredTransactionId, pkgRepo.GetDatabaseId());
                return true;
            }
            catch (SqlException e)
            {
                this.Log.Error("UnrelateCommercialDocument:ExecutePackage " + e.ToString());
                return false;
            }
        }
    }
}
