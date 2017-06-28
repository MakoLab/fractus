namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using System.Xml;
    using System.Xml.Linq;
    using System.Data.SqlTypes;
    using System.IO;
    using System.Data;
    using Makolab.Fractus.Commons;
    using System.Globalization;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.DBLayer;
    using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
    using Makolab.Fractus.Kernel.Mappers;
    using Makolab.Commons.Communication.Exceptions;

    /// <summary>
    /// Class that handles CommunicationPackage object persistance.
    /// </summary>
    public class CommunicationPackageMapper : IMapper, ICommunicationPackageMapper
    {
        public static bool facadehelper_DisableThisCodeForDebugConditionSwitch = false;

        /// <summary>
        /// Helper object.
        /// </summary>
        private MapperHelper helper;

        private FractusPackageFactory packageFactory;

        #region Contructors
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageMapper"/> class.
        /// </summary>
        public CommunicationPackageMapper() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageMapper"/> class.
        /// </summary>
        /// <param name="databaseConnectorManager">The database connector manager.</param>
        public CommunicationPackageMapper(IDatabaseConnectionManager databaseConnectorManager)
        {
            if (databaseConnectorManager == null) throw new ArgumentNullException("databaseConnectorManager");

            this.Database = databaseConnectorManager;

            this.helper = new MapperHelper(this.Database, this);
            this.packageFactory = new FractusPackageFactory();
        }
        #endregion

        /// <summary>
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager Database { get; private set; }

        /// <summary>
        /// Gets or sets the database transaction.
        /// </summary>
        /// <value>The database transaction.</value>
        public IDbTransaction Transaction { get; set; }

        /// <summary>
        /// Returns the outgoing/undilivered packages queue.
        /// </summary>
        /// <param name="maxTransactionsCount">The max transactions quantity.</param>
        /// <param name="lastPackageId">The id of package that was recently delivered or retrieved.</param>
        /// <param name="databaseId">The database identifier.</param>
        /// <returns>
        /// List of undelivered <see cref="CommunicationPackage"/>s
        /// </returns>
        public virtual List<ICommunicationPackage> GetOutgoingPackagesQueue(int maxTransactionsCount, Guid? lastPackageId, Guid databaseId)
        {
            return this.GetPackagesQueue(StoredProcedure.communication_p_getOutgoingQueue.ToProcedureName(), maxTransactionsCount, lastPackageId, databaseId);
        }

        /// <summary>
        /// Returns the incoming/unprocessed packages queue.
        /// </summary>
        /// <param name="maxTransactionsCount">The max transactions quantity.</param>
        /// <returns>List of unprocessed <see cref="CommunicationPackage"/>s</returns>
        public virtual List<ICommunicationPackage> GetIncomingPackagesQueue(int maxTransactionsCount)
        {
            return this.GetPackagesQueue(StoredProcedure.communication_p_getIncomingQueue.ToProcedureName(), maxTransactionsCount, null, null);
        }

        /// <summary>
        /// Sets package as send.
        /// </summary>
        /// <param name="id">The package id.</param>
        public virtual void MarkAsSend(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_setPackageSent.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier), 
                                                       id);

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Sets package as executed.
        /// </summary>
        /// <param name="id">The package id.</param>
        /// <param name="executionTime">The package execution time.</param>
        public virtual void MarkAsExecuted(Guid id, double executionTime)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_setPackageExecuted.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier), 
                                                       id);
            cmd.Parameters.Add("@executionTime", SqlDbType.Float).Value = executionTime;

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Saves the package.
        /// </summary>
        /// <param name="xml">The XML package to save.</param>
        public virtual void SavePackage(ICommunicationPackage xml)
        {
            if (xml == null) throw new ArgumentNullException("xml");

            DBRow row = new DBXml().AddTable("incomingXmlQueue").AddRow();
            row.AddElement("id", xml.XmlData.Id.ToUpperString());
            row.AddElement("localTransactionId", xml.XmlData.LocalTransactionId.ToUpperString());
            row.AddElement("deferredTransactionId", xml.XmlData.DeferredTransactionId.ToUpperString());
            row.AddElement("databaseId", xml.DatabaseId);
            row.AddElement("type", xml.XmlData.XmlType);
            row.AddElement("xml", XElement.Parse(xml.XmlData.Content));

            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_insertIncomingPackage.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml), 
                                                       this.helper.CreateSqlXml(row.Table.Document.Xml));

            using (this.Database.SynchronizeConnection())
            {
                try
                {
                    cmd.ExecuteNonQuery();
                }
                catch (SqlException e)
                {
                    if (e.Number == 2627)
                    {
                        //xml with the same id is already in database so we assume that it's the same and skip this one usually
                        //but its other method decision
                        throw new CommunicationPackageExistsException("Communication package with the same id already exists in the database.",
                                                    xml.XmlData.Id.ToString(),
                                                    e);
                    }
                    else throw;
                }
            }
        }

        /// <summary>
        /// Puts the communication package in outgoing queue.
        /// </summary>
        /// <param name="xml">The XML package to save.</param>
        public void SaveOutgoingPackage(ICommunicationPackage xml)
        {
            if (xml == null) throw new ArgumentNullException("xml");

            DBRow row = new DBXml().AddTable("outgoingXmlQueue").AddRow();
            row.AddElement("id", xml.XmlData.Id.ToUpperString());
            row.AddElement("localTransactionId", xml.XmlData.LocalTransactionId.ToUpperString());
            row.AddElement("deferredTransactionId", xml.XmlData.DeferredTransactionId.ToUpperString());
            row.AddElement("databaseId", xml.DatabaseId.Value.ToUpperString());
            row.AddElement("type", xml.XmlData.XmlType);
            row.AddElement("xml", XElement.Parse(xml.XmlData.Content));

            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_insertOutgoingPackage.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                       this.helper.CreateSqlXml(row.Table.Document.Xml));

            using (this.Database.SynchronizeConnection())
            {
                try
                {
                    cmd.ExecuteNonQuery();
                }
                catch (SqlException e)
                {
                    if (e.Number == 2627)
                    {
                        throw new CommunicationPackageExistsException("Communication package with the same id already exists in the database.",
                                                    xml.XmlData.Id.ToString(),
                                                    e);
                    }
                    else throw;
                }
            }             
        }

        /// <summary>
        /// Puts the communication package in outgoing queue.
        /// </summary>
        /// <param name="xml">The XML package to save.</param>
        /// <param name="targetBranches">The target branches.</param>
        public void SaveOutgoingPackage(ICommunicationPackage xml, IEnumerable<Guid> targetBranches)
        {
            if (xml == null) throw new ArgumentNullException("xml");
            if (targetBranches == null || targetBranches.Count() == 0) return;

            DBTable outgoingXmlQueue = new DBXml().AddTable("outgoingXmlQueue");
            foreach (var branchId in targetBranches)
            {
                DBRow row = outgoingXmlQueue.AddRow();
                row.AddElement("id", Guid.NewGuid().ToUpperString());
                row.AddElement("localTransactionId", xml.XmlData.LocalTransactionId.ToUpperString());
                row.AddElement("deferredTransactionId", xml.XmlData.DeferredTransactionId.ToUpperString());
                row.AddElement("databaseId", branchId.ToUpperString());
                row.AddElement("type", xml.XmlData.XmlType);
                row.AddElement("xml", XElement.Parse(xml.XmlData.Content));
            }

            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_insertOutgoingPackage.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                       this.helper.CreateSqlXml(outgoingXmlQueue.Document.Xml));

            using (this.Database.SynchronizeConnection())
            {
                try
                {
                    cmd.ExecuteNonQuery();
                }
                catch (SqlException e)
                {
                    if (e.Number == 2627)
                    {
                        throw new CommunicationPackageExistsException("Communication package with the same id already exists in the database.",
                                                    xml.XmlData.Id.ToString(),
                                                    e);
                    }
                    else throw;
                }
            }
        }

        /// <summary>
        /// Sets the package's group/transaction as completed.
        /// </summary>
        /// <param name="localTransactionId">The local transaction id.</param>
        public virtual void MarkTransactionAsCompleted(Guid localTransactionId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_setIncomingTransactionCompleted.ToProcedureName(),
                                                       new SqlParameter("@localTransactionId", SqlDbType.UniqueIdentifier), 
                                                       localTransactionId);

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }            
        }

        /// <summary>
        /// Gets the unprocessed packages quantity.
        /// </summary>
        /// <returns>Quantity of unprocessed packages.</returns>
        public virtual int GetUnprocessedPackagesQuantity()
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getUnprocessedPackagesQuantity.ToProcedureName());
            using (this.Database.SynchronizeConnection())
            {
                return Convert.ToInt32(cmd.ExecuteScalar(), CultureInfo.InvariantCulture);
            }
        }

        /// <summary>
        /// Gets the undelivered packages quantity.
        /// </summary>
        /// <param name="branchId">The id of the branch...</param>
        /// <returns>Quantity of undelivered packages.</returns>
        public virtual int GetUndeliveredPackagesQuantity(Guid? branchId)
        {
            object paramValue;
            if (branchId == null) paramValue = DBNull.Value;
            else paramValue = branchId.Value;

            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getUndeliveredPackagesQuantity.ToProcedureName(),
                                                       new SqlParameter("@databaseId", SqlDbType.UniqueIdentifier), 
                                                       paramValue);

            using (this.Database.SynchronizeConnection())
            {
                return Convert.ToInt32(cmd.ExecuteScalar(), CultureInfo.InvariantCulture);
            }
        }


        /// <summary>
        /// Gets the last received transaction id.
        /// </summary>
        /// <param name="databaseId">The database id.</param>
        /// <returns></returns>
        public Guid? GetLastReceivedTransactionId(Guid databaseId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getLastIncompleteTransactionByDatabase.ToProcedureName(),
                new SqlParameter("@databaseId", SqlDbType.UniqueIdentifier), databaseId);
            using (this.Database.SynchronizeConnection())
            using (var reader = cmd.ExecuteReader())
            {
                if (reader.Read()) return reader.GetGuid(0);
                else return null;
            }
        }

        /// <summary>
        /// Gets the database identifier.
        /// </summary>
        /// <returns>Database identifier</returns>
        public Guid GetDatabaseId()
        {
            using (IConnectionWrapper wrapper = this.Database.SynchronizeConnection())
            {
                Makolab.Fractus.Kernel.Managers.SqlConnectionManager.Instance.SetConnection(wrapper.Connection, this.Transaction as SqlTransaction);
                bool logOut = false;
                if (KernelSessionManager.IsLogged == false)
                {
                    Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
                    KernelSessionManager.IsLogged = true;
                    logOut = true;
                    Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.LocalTransactionId = Guid.NewGuid();
                    Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.DeferredTransactionId = Guid.NewGuid(); 
                }

                var databaseId = Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.GetSingleConfigurationEntry("communication.databaseId");

                if (logOut)
                {
                    Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOff();
                    KernelSessionManager.IsLogged = false;
                }
                return new Guid(databaseId.Value.Value);
            }
        }

        /// <summary>
        /// Determines whether communication is running in headquarter branch or not.
        /// </summary>
        /// <returns>
        /// 	<c>true</c> if this branch is headquarter; otherwise, <c>false</c>.
        /// </returns>
        public bool IsHeadquarter()
        {
            using (IConnectionWrapper wrapper = this.Database.SynchronizeConnection())
            {
                Makolab.Fractus.Kernel.Managers.SqlConnectionManager.Instance.SetConnection(wrapper.Connection, this.Transaction as SqlTransaction);
                bool logOut = false;
                if (KernelSessionManager.IsLogged == false)
                {
                    Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
                    KernelSessionManager.IsLogged = true;
                    logOut = true;
                    Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.LocalTransactionId = Guid.NewGuid();
                    Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.DeferredTransactionId = Guid.NewGuid(); 
                }

                var isHeadquarter = Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.GetSingleConfigurationEntry("system.isHeadquarter");

                if (logOut)
                {
                    Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOff();
                    KernelSessionManager.IsLogged = false;
                }
                return Boolean.Parse(isHeadquarter.Value.Value);
            }
        }

        internal virtual Dictionary<CommunicationPackageType, List<Branch>> GetDestinations()
        {
            using (var wrapper = this.Database.SynchronizeConnection())
            {
                Makolab.Fractus.Kernel.Managers.SqlConnectionManager.Instance.SetConnection(wrapper.Connection, this.Transaction as SqlTransaction);
            }

            bool logOut = false;
            if (KernelSessionManager.IsLogged == false)
            {
                Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
                KernelSessionManager.IsLogged = true;
                logOut = true;
                Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.LocalTransactionId = Guid.NewGuid();
                Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.DeferredTransactionId = Guid.NewGuid(); 
            }
            var result = new Dictionary<CommunicationPackageType, List<Branch>>();
            List<Branch> allBranches = new List<Branch>();
            var branches = Makolab.Fractus.Kernel.Mappers.DictionaryMapper.Instance.GetBranches().Root.Element("branch").Elements("branch");
            if (logOut)
            {
                Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOff();
                KernelSessionManager.IsLogged = false;
            }
            foreach (var branch in branches)
            {
                branch.Attributes("type").Remove();
                Branch b = new Branch();
                b.Deserialize(branch);
                allBranches.Add(b);
            }

            result.Add(CommunicationPackageType.Configuration, allBranches);
            result.Add(CommunicationPackageType.ContractorGroupMembership, allBranches);
            result.Add(CommunicationPackageType.ContractorRelations, allBranches);
            result.Add(CommunicationPackageType.ContractorSnapshot, allBranches);
            result.Add(CommunicationPackageType.ItemGroupMembership, allBranches);
            result.Add(CommunicationPackageType.ItemRelation, allBranches);
            result.Add(CommunicationPackageType.ItemSnapshot, allBranches);
            result.Add(CommunicationPackageType.ItemUnitRelation, allBranches);
            result.Add(CommunicationPackageType.WarehouseStock, allBranches);
            result.Add(CommunicationPackageType.Payment, allBranches);
            result.Add(CommunicationPackageType.DictionaryPackage, allBranches);
            //result.Add(CommunicationPackageType.PaymentSettlementSnapshot, allBranches);
            result.Add(CommunicationPackageType.FileDescriptor, allBranches);
            result.Add(CommunicationPackageType.PriceRule, allBranches);
            result.Add(CommunicationPackageType.PriceRuleList, allBranches);

            return result;
        }

        /// <summary>
        /// Gets the packages queue.
        /// </summary>
        /// <param name="procedure">The stored procedure used to retrieve collection.</param>
        /// <param name="maxTransactionsCount">The max transactions quantity.</param>
        /// <param name="lastPackageId">The id of package that was recently retrieved.</param>
        /// <param name="databaseId">The database id.</param>
        /// <returns>
        /// Collection of <see cref="CommunicationPackage"/>s
        /// </returns>
        internal virtual List<ICommunicationPackage> GetPackagesQueue(string procedure, int maxTransactionsCount, Guid? lastPackageId, Guid? databaseId)
        {
            bool facadehelper_DisableThisCodeForDebugCondition = facadehelper_DisableThisCodeForDebugConditionSwitch;
            if (!facadehelper_DisableThisCodeForDebugCondition)
            {
                SqlCommand cmd = this.helper.CreateCommand(procedure, new SqlParameter("@maxTransactionCount", System.Data.SqlDbType.Int), maxTransactionsCount);
                if (lastPackageId != null) cmd.Parameters.Add("@id", System.Data.SqlDbType.UniqueIdentifier).Value = lastPackageId.Value;
                if (databaseId != null) cmd.Parameters.Add("@databaseId", System.Data.SqlDbType.UniqueIdentifier).Value = databaseId.Value;

                XDocument xdoc = null;
                using (this.Database.SynchronizeConnection())
                {
                    xdoc = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                }

                return new List<ICommunicationPackage>(from entry in xdoc.Root.Elements("entry") select this.packageFactory.CreatePackage(entry));
            }
            else
            {
                return new List<ICommunicationPackage>();
            }
        }
    }
}
