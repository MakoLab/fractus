namespace Makolab.Fractus.Communication.DatabaseConnector
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using Makolab.Commons.Communication;
    using System.Threading;
    using System.Globalization;

    /// <summary>
    ///  Wrappers around database connection object that allows access to connection with synchronization.
    /// </summary>
    public sealed class ConnectionSynchronizer : IConnectionWrapper
    {
        /// <summary>
        /// DatabaseConnector manager that contains database connection object. 
        /// </summary>
        private DatabaseConnectorManager manager;

        /// <summary>
        /// Initializes a new instance of the <see cref="ConnectionSynchronizer"/> class.
        /// </summary>
        /// <param name="manager">The DatabaseConnector manager.</param>
        /// <param name="connection">The database connection.</param>
        public ConnectionSynchronizer(DatabaseConnectorManager manager, SqlConnection connection)
        {
            if (manager.State != CommunicationModuleState.Started) return;
            
            this.manager = manager;
            System.Threading.Monitor.Enter(manager.ConnectionSyncRoot);
            manager.OpenConnection();
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("ConnectionSynchronizer:ConnectionSynchronizer(DatabaseConnectorManager manager, SqlConnection connection) - Set conn " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
            this.Connection = connection;
        }

        #region IConnectionWrapper Members

        /// <summary>
        /// Gets the database connection.
        /// </summary>
        /// <value>The database connection.</value>
        public SqlConnection Connection { get; private set; }

        #endregion

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            if (this.manager != null) System.Threading.Monitor.Exit(this.manager.ConnectionSyncRoot);
            
            GC.SuppressFinalize(this);
        }

        #endregion        
    }
}
