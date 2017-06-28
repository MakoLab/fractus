namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.DBLayer;

    /// <summary>
    /// Class that retrieves and saves CommunicationPackages.
    /// </summary>
    public class CommunicationPackageRepository : Repository<ICommunicationPackage>, ICommunicationPackageRepository
    {
        /// <summary>
        /// CommunicationPackage mapper
        /// </summary>
        private ICommunicationPackageMapper mapper;
        private ICommunicationStatisticsMapper statisticsMapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageRepository"/> class.
        /// </summary>
        /// <param name="context">The UnitOfWork.</param>
        public CommunicationPackageRepository(IUnitOfWork context) : base(context)
        {
            this.mapper = context.MapperFactory.CreateMapper<ICommunicationPackageMapper>(context.ConnectionManager);
            this.statisticsMapper = context.MapperFactory.CreateMapper<ICommunicationStatisticsMapper>(context.ConnectionManager);

            this.mapper.Transaction = context.Transaction;
            this.statisticsMapper.Transaction = context.Transaction;
        }

        /// <summary>
        /// Finds the undelivered packages.
        /// </summary>
        /// <param name="maxTransactions">The max transactions quantity.</param>
        /// <param name="databaseId">The database identifier.</param>
        /// <returns>List of undelivered packages</returns>
        public List<ICommunicationPackage> FindUndeliveredPackages(int maxTransactions, Guid databaseId)
        {
            return this.mapper.GetOutgoingPackagesQueue(maxTransactions, null, databaseId);
        }

        /// <summary>
        /// Finds the undelivered packages.
        /// </summary>
        /// <param name="maxTransactions">The max transactions quantity.</param>
        /// <param name="lastDeliveredPackageId">The id of package that was recently delivered or retrieved.</param>
        /// <param name="databaseId">The database identifier.</param>
        /// <returns>List of undelivered packages</returns>
        public List<ICommunicationPackage> FindUndeliveredPackages(int maxTransactions, Guid? lastDeliveredPackageId, Guid databaseId)
        {
            return this.mapper.GetOutgoingPackagesQueue(maxTransactions, lastDeliveredPackageId, databaseId);
        }

        /// <summary>
        /// Finds the unprocessed packages.
        /// </summary>
        /// <param name="maxTransactions">The max transactions quantity.</param>
        /// <returns>List of unprocessed communication packages.</returns>
        public List<ICommunicationPackage> FindUnprocessedPackages(int maxTransactions)
        {
            return this.mapper.GetIncomingPackagesQueue(maxTransactions);
        }

        /// <summary>
        /// Gets the undelivered packages quantity.
        /// </summary>
        /// <returns>
        /// List of undelivered communication packages.
        /// </returns>
        public int GetUndeliveredPackagesQuantity()
        {
            return GetUndeliveredPackagesQuantity(null);
        }

        /// <summary>
        /// Gets the undelivered packages quantity.
        /// </summary>
        /// <param name="branchId">The id of the branch...</param>
        /// <returns>
        /// Amount of undelivered communication packages for specified branch.
        /// </returns>
        public int GetUndeliveredPackagesQuantity(Guid? branchId)
        {
            return this.mapper.GetUndeliveredPackagesQuantity(branchId);
        }

        /// <summary>
        /// Gets the unprocessed packages quantity.
        /// </summary>
        /// <returns>
        /// Amount of unprocessed communication packages.
        /// </returns>
        public int GetUnprocessedPackagesQuantity()
        {
            return this.mapper.GetUnprocessedPackagesQuantity();
        }

        /// <summary>
        /// Sets package as send.
        /// </summary>
        /// <param name="packageId">The package id.</param>
        public void MarkAsSend(Guid packageId)
        {
            this.mapper.MarkAsSend(packageId);
        }

        /// <summary>
        /// Sets package as executed.
        /// </summary>
        /// <param name="packageId">The package id.</param>
        /// <param name="executionTime">The package execution time.</param>
        public void MarkAsExecuted(Guid packageId, double executionTime)
        {
            this.mapper.MarkAsExecuted(packageId, executionTime);
        }

        /// <summary>
        /// Sets the package's group/transaction as completed.
        /// </summary>
        /// <param name="localTransactionId">The local transaction id.</param>
        public void MarkTransactionAsCompleted(Guid localTransactionId)
        {
            this.mapper.MarkTransactionAsCompleted(localTransactionId);
        }

        /// <summary>
        /// Adds the specified communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        public void Add(ICommunicationPackage communicationPackage)
        {
            this.mapper.SavePackage(communicationPackage);
        }

        /// <summary>
        /// Adds the specified communication package to outgoing queue.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        public void PutToOutgoingQueue(ICommunicationPackage communicationPackage)
        {
            this.mapper.SaveOutgoingPackage(communicationPackage);
        }

        /// <summary>
        /// Adds the specified communication package to outgoing queue.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <param name="targetBranches">The target branches.</param>
        public void PutToOutgoingQueue(ICommunicationPackage communicationPackage, IEnumerable<Guid> targetBranches)
        {
            this.mapper.SaveOutgoingPackage(communicationPackage, targetBranches);
        }

        /// <summary>
        /// Gets the database identifier.
        /// </summary>
        /// <returns>Database id.</returns>
        public Guid GetDatabaseId()
        {
            return this.mapper.GetDatabaseId();
        }

        /// <summary>
        /// Determines whether this branch is headquarter.
        /// </summary>
        /// <returns>
        /// 	<c>true</c> if this branch is headquarter; otherwise, <c>false</c>.
        /// </returns>
        public bool IsHeadquarter()
        {
            return this.mapper.IsHeadquarter();
        }

        /// <summary>
        /// Gets the last received transacion id.
        /// </summary>
        /// <param name="databaseId">The database id.</param>
        /// <returns></returns>
        public Guid? GetLastReceivedTransacionId(Guid databaseId)
        {
            return this.mapper.GetLastReceivedTransactionId(databaseId);
        }

        /// <summary>
        /// Updates the communication statistics.
        /// </summary>
        /// <param name="statistics">The updated statistics.</param>
        /// <param name="departmentId">The source department id.</param>
        public void UpdateStatistics(CommunicationStatistics statistics, Guid departmentId)
        {
            this.statisticsMapper.UpdateStatistics(statistics, departmentId);
        }

        public System.Xml.Linq.XDocument GetAdditionalData(string procedureName)
        {
            try
            {
                return this.statisticsMapper.GetAdditionalData(procedureName);
            }
            catch (System.Data.SqlClient.SqlException)
            {
                throw new ArgumentException("Store procedure " + procedureName + " could not be found in communication schema." , "procedureName");
            }
        }

    }
}
