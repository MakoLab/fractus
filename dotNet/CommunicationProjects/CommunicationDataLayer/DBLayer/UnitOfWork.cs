namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data;
    using Makolab.Commons.Communication;

    /// <summary>
    /// Class that manages database transaction scope and DatabaseConnectorManager sharing.
    /// </summary>
    /// <remarks>
    /// It almost implements unit of work pattern ;)
    /// but still it makes unit tests without touching database little easier or even possible.
    /// </remarks>
    public class UnitOfWork : IUnitOfWork
    {
        /// <summary>
        /// Indicates whether database transaction has been started.
        /// </summary>
        private bool isTransactionCommited;

        /// <summary>
        /// Initializes a new instance of the <see cref="UnitOfWork"/> class.
        /// </summary>
        /// <param name="connectionManager">The connection manager.</param>
        public UnitOfWork(IDatabaseConnectionManager connectionManager)
        {
            this.Transaction = NullTransaction.Instance;
            this.ConnectionManager = connectionManager;
            this.MapperFactory = NullMapperFactory.Instance;
        }

        #region IUnitOfWork Members

        /// <summary>
        /// Gets or sets the database transaction.
        /// </summary>
        /// <value>The database transaction.</value>
        public IDbTransaction Transaction { get; set; }

        /// <summary>
        /// Gets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager ConnectionManager { get; private set; }

        /// <summary>
        /// Gets or sets the mapper factory.
        /// </summary>
        /// <value>The mapper factory.</value>
        public IMapperFactory MapperFactory { get; set; }

        /// <summary>
        /// Submits the changes to database.
        /// </summary>
        public void SubmitChanges()
        {
            this.Transaction.Commit();
            this.isTransactionCommited = true;
        }

        /// <summary>
        /// Cancels the changes by rollbacking transaction.
        /// </summary>
        public void CancelChanges()
        {
            this.Transaction.Rollback();
            this.isTransactionCommited = true;
        }

        /// <summary>
        /// Starts the new database transaction.
        /// </summary>
        public void StartTransaction()
        {
            StartTransaction(IsolationLevel.Serializable);
        }

        /// <summary>
        /// Starts the new database transaction.
        /// </summary>
        /// <param name="transactionLevel">The transaction isolation level.</param>
        public void StartTransaction(IsolationLevel transactionLevel)
        {
            this.isTransactionCommited = false;
            this.Transaction = ConnectionManager.StartTransaction(transactionLevel);
        }

        #endregion

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (this.isTransactionCommited == false) this.CancelChanges();

            this.Transaction.Dispose(); 
        }

        #endregion
    }
}
