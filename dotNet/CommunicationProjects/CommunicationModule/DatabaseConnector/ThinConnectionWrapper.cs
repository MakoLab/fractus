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
    ///  Wrappers around database connection object that allows access to connection without synchronization.
    /// </summary>
    public sealed class ThinConnectionWrapper : IConnectionWrapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ThinConnectionWrapper"/> class.
        /// </summary>
        /// <param name="manager">The manager responsible for database connection.</param>
        /// <param name="connection">The database connection.</param>
        public ThinConnectionWrapper(DatabaseConnectorManager manager, SqlConnection connection)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("ThinConnectionWrapper:ThinConnectionWrapper(DatabaseConnectorManager manager, SqlConnection connection) - MethodEntered from thread " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
            if (manager.State != CommunicationModuleState.Started) return;
            
            manager.OpenConnection();
            this.Connection = connection;
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("ThinConnectionWrapper:ThinConnectionWrapper(DatabaseConnectorManager manager, SqlConnection connection) - MethodExited from thread " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
        }

        #region IConnectionWrapper Members

        /// <summary>
        /// Gets the database connection.
        /// </summary>
        /// <value>The database connection.</value>
        public System.Data.SqlClient.SqlConnection Connection { get; private set; }

        #endregion

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            GC.SuppressFinalize(this);
        }

        #endregion
    }
}
