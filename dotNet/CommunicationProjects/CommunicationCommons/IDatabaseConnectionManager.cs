namespace Makolab.Commons.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using System.Data;

    /// <summary>
    /// Manages database connection. Creates transactions, associated <see cref="SqlCommand"/>s and synchronize access.
    /// </summary>
    public interface IDatabaseConnectionManager
    {
        /// <summary>
        /// Returns wrapper around database connection object.
        /// </summary>
        /// <returns>Wrapper that allows access database connection object in sychronized or unsynchronized way.</returns>
        IConnectionWrapper SynchronizeConnection();

        /// <summary>
        /// Creates the SQL command that has object lifetime.
        /// </summary>
        /// <returns>Created SQL command.</returns>
        SqlCommand CreateObjectScopedSqlCommand();

        /// <summary>
        /// Creates the SQL command that has method lifetime.
        /// </summary>
        /// <returns>Created SQL command.</returns>
        SqlCommand CreateMethodScopedSqlCommand();

        /// <summary>
        /// Starts the transaction on database connection object.
        /// </summary>
        /// <param name="transactionLevel">The transaction isolation level.</param>
        /// <returns>Created transaction object.</returns>
        SqlTransaction StartTransaction(IsolationLevel transactionLevel);

        /// <summary>
        /// Starts the transaction on database connection object.
        /// </summary>
        /// <param name="transactionLevel">The transaction isolation level.</param>
        /// <param name="transactionName">Name of the transaction.</param>
        /// <returns>Created transaction object.</returns>
        SqlTransaction StartTransaction(IsolationLevel transactionLevel, string transactionName);
    }
}
