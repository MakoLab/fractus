using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Repository that encapsulates operations on communication packages (like save and load).
    /// </summary>
    public interface ICommunicationPackageRepository : IRepository<ICommunicationPackage>
    {
        /// <summary>
        /// Finds the undelivered packages.
        /// </summary>
        /// <param name="maxTransactions">The max transactions quantity.</param>
        /// <param name="databaseId">The database identifier.</param>
        /// <returns>List of undelivered packages</returns>
        List<ICommunicationPackage> FindUndeliveredPackages(int maxTransactions, Guid databaseId);

        /// <summary>
        /// Finds the undelivered packages.
        /// </summary>
        /// <param name="maxTransactions">The max transactions quantity.</param>
        /// <param name="lastDeliveredPackageId">The id of package that was recently delivered or retrieved.</param>
        /// <param name="databaseId">The database identifier.</param>
        /// <returns>List of undelivered packages</returns>
        List<ICommunicationPackage> FindUndeliveredPackages(int maxTransactions, Guid? lastDeliveredPackageId, Guid databaseId);

        /// <summary>
        /// Finds the unprocessed packages.
        /// </summary>
        /// <param name="maxTransactions">The max transactions quantity.</param>
        /// <returns>List of unprocessed communication packages.</returns>
        List<ICommunicationPackage> FindUnprocessedPackages(int maxTransactions);

        /// <summary>
        /// Gets the undelivered packages quantity.
        /// </summary>
        /// <returns>List of undelivered communication packages.</returns>
        int GetUndeliveredPackagesQuantity();

        /// <summary>
        /// Gets the undelivered packages quantity.
        /// </summary>
        /// <param name="branchId">The id of the target/source branch</param>
        /// <returns>Amount of undelivered communication packages for specified branch.</returns>
        int GetUndeliveredPackagesQuantity(Guid? branchId);

        /// <summary>
        /// Gets the unprocessed packages quantity.
        /// </summary>
        /// <returns>Amount of unprocessed communication packages.</returns>
        int GetUnprocessedPackagesQuantity();

        /// <summary>
        /// Sets package as send.
        /// </summary>
        /// <param name="packageId">The package id.</param>
        void MarkAsSend(Guid packageId);

        /// <summary>
        /// Sets package as executed.
        /// </summary>
        /// <param name="packageId">The package id.</param>
        /// <param name="executionTime">The package execution time.</param>
        void MarkAsExecuted(Guid packageId, double executionTime);

        /// <summary>
        /// Sets the package's group/transaction as completed.
        /// </summary>
        /// <param name="localTransactionId">The local transaction id.</param>
        void MarkTransactionAsCompleted(Guid localTransactionId);

        /// <summary>
        /// Adds the specified communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        void Add(ICommunicationPackage communicationPackage);

        /// <summary>
        /// Adds the specified communication package to outgoing queue.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        void PutToOutgoingQueue(ICommunicationPackage communicationPackage);

        /// <summary>
        /// Adds the specified communication package to outgoing queue.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <param name="targetBranches">The target branches of communication package.</param>
        void PutToOutgoingQueue(ICommunicationPackage communicationPackage, IEnumerable<Guid> targetBranches);
    }
}
