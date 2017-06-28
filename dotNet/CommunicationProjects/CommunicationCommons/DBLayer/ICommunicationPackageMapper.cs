namespace Makolab.Commons.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data;
    using Makolab.Commons.Communication;

    /// <summary>
    /// Mapps <see cref="ICommunicationPackage"/> objects to and from database.
    /// </summary>
    public interface ICommunicationPackageMapper : IMapper
    {
        /// <summary>
        /// Gets the database connection manager.
        /// </summary>
        /// <value>The database connection manager.</value>
        IDatabaseConnectionManager Database { get; }

        /// <summary>
        /// Returns the outgoing/undelivered packages queue.
        /// </summary>
        /// <param name="maxTransactionsCount">The max transactions quantity.</param>
        /// <param name="lastPackageId">The id of package that was recently delivered or retrieved.</param>
        /// <param name="databaseId">The database identifier.</param>
        /// <returns>
        /// List of undelivered <see cref="CommunicationPackage"/>s
        /// </returns>
        List<ICommunicationPackage> GetOutgoingPackagesQueue(int maxTransactionsCount, Guid? lastPackageId, Guid databaseId);

        /// <summary>
        /// Returns the incoming/unprocessed packages queue.
        /// </summary>
        /// <param name="maxTransactionsCount">The max transactions quantity.</param>
        /// <returns>List of unprocessed <see cref="CommunicationPackage"/>s</returns>
        List<ICommunicationPackage> GetIncomingPackagesQueue(int maxTransactionsCount);

        /// <summary>
        /// Sets package as send.
        /// </summary>
        /// <param name="id">The package id.</param>
        void MarkAsSend(Guid id);

        /// <summary>
        /// Sets package as executed.
        /// </summary>
        /// <param name="id">The package id.</param>
        /// <param name="executionTime">The package execution time.</param>
        void MarkAsExecuted(Guid id, double executionTime);

        /// <summary>
        /// Saves the package.
        /// </summary>
        /// <param name="xml">The XML package to save.</param>
        void SavePackage(ICommunicationPackage xml);

        /// <summary>
        /// Puts the communication package in outgoing queue.
        /// </summary>
        /// <param name="xml">The XML package to save.</param>
        void SaveOutgoingPackage(ICommunicationPackage xml);

        /// <summary>
        /// Puts the communication package in outgoing queue.
        /// </summary>
        /// <param name="xml">The XML package to save.</param>
        /// <param name="targetBranches">The target branches of communication package.</param>
        void SaveOutgoingPackage(ICommunicationPackage xml, IEnumerable<Guid> targetBranches);

        /// <summary>
        /// Sets the package's group/transaction as completed.
        /// </summary>
        /// <param name="localTransactionId">The local transaction id.</param>
        void MarkTransactionAsCompleted(Guid localTransactionId);

        /// <summary>
        /// Gets the unprocessed packages quantity.
        /// </summary>
        /// <returns>Quantity of unprocessed packages.</returns>
        int GetUnprocessedPackagesQuantity();

        /// <summary>
        /// Gets the undelivered packages quantity.
        /// </summary>
        /// <param name="branchId">The id of the branch...</param>
        /// <returns>Quantity of undelivered packages.</returns>
        int GetUndeliveredPackagesQuantity(Guid? branchId);

        /// <summary>
        /// Gets the database identifier.
        /// </summary>
        /// <returns>Database identifier</returns>
        Guid GetDatabaseId();

        /// <summary>
        /// Determines whether communication is running in headquarter branch or not.
        /// </summary>
        /// <returns>
        /// 	<c>true</c> if this branch is headquarter; otherwise, <c>false</c>.
        /// </returns>
        bool IsHeadquarter();

        /// <summary>
        /// Gets the last received transaction id.
        /// </summary>
        /// <param name="databaseId">The database id.</param>
        /// <returns></returns>
        Guid? GetLastReceivedTransactionId(Guid databaseId);
    }
}
