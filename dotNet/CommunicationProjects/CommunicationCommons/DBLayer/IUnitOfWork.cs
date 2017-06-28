namespace Makolab.Commons.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data;

    /// <summary>
    /// Interface for UnitOfWork.
    /// </summary>
    public interface IUnitOfWork : IDisposable
    {
        /// <summary>
        /// Gets or sets the database transaction.
        /// </summary>
        /// <value>The database transaction.</value>
        IDbTransaction Transaction { get; set; }

        /// <summary>
        /// Gets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        IDatabaseConnectionManager ConnectionManager { get; }

        /// <summary>
        /// Gets or sets the mapper factory.
        /// </summary>
        /// <value>The mapper factory.</value>
        IMapperFactory MapperFactory { get; set; }

        /// <summary>
        /// Submits the changes.
        /// </summary>
        void SubmitChanges();

        /// <summary>
        /// Cancels the changes.
        /// </summary>
        void CancelChanges();

        /// <summary>
        /// Starts the transaction.
        /// </summary>
        void StartTransaction();

        /// <summary>
        /// Starts the transaction.
        /// </summary>
        /// <param name="transactionLevel">The transaction isolation level.</param>
        void StartTransaction(IsolationLevel transactionLevel);
    }
}
