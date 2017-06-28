using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.Xml.Linq;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process Configuration communication package.
    /// </summary>
    public class ConfigurationScript : ExecutingScript
    {

        private ConfigurationMapper mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ConfigurationScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public ConfigurationScript(IUnitOfWork unitOfWork, ExecutionController controller) : base(unitOfWork)
        {
            this.mapper = new ConfigurationMapper(unitOfWork.ConnectionManager);
            this.mapper.Transaction = unitOfWork.Transaction;
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
            try
            {
                SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
                SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

                XDocument commXml = XDocument.Parse(communicationPackage.XmlData.Content);

                foreach (var row in commXml.Root.Element("configuration").Elements("entry"))
                {
                    var action = row.Attribute("action");
                    if (action != null && action.Value == DBRowState.Delete.ToStateName()) 
                    {
                        this.mapper.DeleteConfiguration(new Guid(row.Element("id").Value));
                    }

                }

                var updated = XDocument.Parse("<root><configuration/></root>");
                var inserted = XDocument.Parse("<root><configuration/></root>");

                updated.Root.Element("configuration").Add(from row in commXml.Root.Element("configuration").Elements("entry")
                                 where row.Element("version") != null && row.Element("_version") != null
                                 select row);

                inserted.Root.Element("configuration").Add(from row in commXml.Root.Element("configuration").Elements("entry")
                                 where row.Element("version") == null && row.Element("_version") != null
                                 select row);

                if (updated.Root.Element("configuration").Elements("entry").Count() > 0) this.mapper.UpdateConfiguration(updated);
                if (inserted.Root.Element("configuration").Elements("entry").Count() > 0) this.mapper.InsertConfiguration(inserted);

                return true;
            }
            catch (SqlException e)
            {
                this.Log.Error("ConfigurationMapper:ExecutePackage " + e.ToString());
                return false;
            }
        }
    }
}
