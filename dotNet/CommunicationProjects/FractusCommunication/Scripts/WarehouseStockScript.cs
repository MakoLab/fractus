using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.IO;
using System.Xml.Linq;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process WarehouseStock communication package.
    /// </summary>
    public class WarehouseStockScript : ExecutingScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="WarehouseStockScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public WarehouseStockScript(IUnitOfWork unitOfWork, ExecutionController controller)
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
                // paczka nie dojdzie do oddzialu z ktorego przyszla wiec nie ma potrzeby sprawdzania 
                // czy przenoszony stan nalezy do magazynu lokalnego
                //XDocument warehoues = XDocument.Parse("<root/>");
                //warehoues.Root.Add(from entry in commPkg.Root.Element("warehouseStock").Elements("entry")
                //                    select entry.Element("warehouseId"));

                //var localWarehouses = this.repository.FindLocalWarehouses(warehoues).Root.Elements("warehouse")
                //                                     .Where(wh => wh.Element("isLocal").Value.Equals("true", StringComparison.OrdinalIgnoreCase))
                //                                     .Select(wh => new Guid(wh.Element("warehouseId").Value));
                //foreach (XElement entry in commPkg.Root.Element("warehouseStock").Elements("entry"))
                //{
                //    if (localWarehouses.Contains(new Guid(entry.Element("warehouseId").Value)) == true) entry.Remove();
                //}
                //if (commPkg.Root.Element("warehouseStock").Elements("entry").Count() > 0) 
                this.repository.UpdateStock(commPkg);
                return true;
            }
            catch (SqlException e)
            {
                this.Log.Error("WarehouseStockScript:ExecutePackage " + e.ToString());
                return false;
            }
        }
    }
}
