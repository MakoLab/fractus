using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Fractus.Kernel.Managers;
using System.Xml.Linq;
using System.Data.SqlClient;
using System.IO;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process UnrelateWarehouseDocumentForIncome communication package.
    /// </summary>
    public class UnrelateWarehouseDocumentForIncomeScript : ExecutingScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="UnrelateWarehouseDocumentForIncomeScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public UnrelateWarehouseDocumentForIncomeScript(IUnitOfWork unitOfWork, ExecutionController controller)
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
                var warehouseDocumentIdElement = commPkg.Root.Element("id");
                if (warehouseDocumentIdElement == null || warehouseDocumentIdElement.Value.Length == 0)
                {
                    throw new InvalidDataException("Invalid xml data.");
                }
                Guid warehouseDocumentId = new Guid(warehouseDocumentIdElement.Value);
                this.repository.UnrelateWarehouseDocumentForIncome(warehouseDocumentId);
                return true;
            }
            catch (SqlException e)
            {
                this.Log.Error("UnrelateWarehouseDocumentForOutcome:ExecutePackage " + e.ToString());
                return false;
            }
        }
    }
}
