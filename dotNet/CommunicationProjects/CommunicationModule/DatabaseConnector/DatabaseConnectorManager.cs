namespace Makolab.Fractus.Communication.DatabaseConnector
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using System.Data;
    using Makolab.Commons.Communication;
    using System.Threading;
    using System.Globalization;

    /// <summary>
    /// Manager for DatabaseConnector module that manages database connection object.
    /// </summary>
    /// <remarks>It's main purpose is database connection object synchronization.</remarks>
    public class DatabaseConnectorManager : CommunicationModule, IDatabaseConnectionManager
    {
        /// <summary>
        /// Object used in database connection object synchronization.
        /// </summary>
        internal object ConnectionSyncRoot;

        /// <summary>
        /// Database connection.
        /// </summary>
        private SqlConnection connection;


        /// <summary>
        /// Collection of SQL commands associated with <see cref="connection"/>.
        /// </summary>
        private List<SqlCommand> associatedCommands;

        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="DatabaseConnectorManager"/> class.
        /// </summary>
        public DatabaseConnectorManager()
        {
            this.ConnectionSyncRoot = new object();
            this.associatedCommands = new List<SqlCommand>();
        }
        #endregion

        /// <summary>
        /// Gets or sets the DatabaseConnector configuration.
        /// </summary>
        /// <value>The DatabaseConnector configuration.</value>
        public DatabaseConnectorConfiguration DatabaseConnectorConfiguration { get; private set; }

        #region ICommunicationModule Members

        /// <summary>
        /// Gets or sets DatabaseConnector configuration.
        /// </summary>
        /// <value>The DatabaseConnector configuration.</value>
        public override ICommunicationModuleConfiguration Configuration
        {
            get 
            { 
                return DatabaseConnectorConfiguration; 
            }

            set
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("DatabaseConnectorManager:ICommunicationModuleConfiguration Configuration " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
                DatabaseConnectorConfiguration cfg = value as DatabaseConnectorConfiguration;
                if (cfg == null) throw new ArgumentException("Invalid type. Must assign DatabaseConnectorConfiguration to Configuration.", "value");

                DatabaseConnectorConfiguration = cfg;
            }
        }

        /// <summary>
        /// Starts DatabaseConnector module.
        /// </summary>
        public override void StartModule()
        {
            if (State != CommunicationModuleState.Stopped) return;

            State = CommunicationModuleState.Starting;
            base.StartModule();
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("DatabaseConnectorManager:StartModule() - Set conn " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
            this.connection = new SqlConnection(DatabaseConnectorConfiguration.ConnectionString);
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("DatabaseConnectorManager:StartModule() - Set conn finished" + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));

            foreach (SqlCommand cmd in this.associatedCommands) cmd.Connection = this.connection;

            State = CommunicationModuleState.Started;
        }

        /// <summary>
        /// Stops DatabaseConnector module.
        /// </summary>
        public override void StopModule()
        {
            if (State != CommunicationModuleState.Started) return;

            State = CommunicationModuleState.Stopping;
            DisposeConnection();

            foreach (SqlCommand cmd in this.associatedCommands) cmd.Connection = null;

            State = CommunicationModuleState.Stopped;
        }

        #endregion

        /// <summary>
        /// Returns wrapper around database connection object.
        /// </summary>
        /// <returns>Wrapper that allows access database connection object in sychronized or unsynchronized way.</returns>
        public IConnectionWrapper SynchronizeConnection() 
        {
            if (this.DatabaseConnectorConfiguration.BlockConnection == true) return new ConnectionSynchronizer(this, this.connection);
            else return new ThinConnectionWrapper(this, this.connection);
        }

        /// <summary>
        /// Creates the SQL command that has object lifetime.
        /// </summary>
        /// <returns>Created SQL command.</returns>
        public SqlCommand CreateObjectScopedSqlCommand()
        {
            if (State != CommunicationModuleState.Started) throw new InvalidOperationException("DatabaseConnectorManager is not started");

            SqlCommand cmd = CreateMethodScopedSqlCommand();
            cmd.Disposed += new EventHandler(OnSqlCommandDispose);
            this.associatedCommands.Add(cmd);
            return cmd;
        }

        /// <summary>
        /// Creates the SQL command that has method lifetime.
        /// </summary>
        /// <returns>Created SQL command.</returns>
        public SqlCommand CreateMethodScopedSqlCommand()
        {
            if (State != CommunicationModuleState.Started) throw new InvalidOperationException("DatabaseConnectorManager is not started");
            else return this.connection.CreateCommand();
        }

        /// <summary>
        /// Starts the transaction on database connection object.
        /// </summary>
        /// <param name="transactionLevel">The transaction isolation level.</param>
        /// <returns>Created transaction object.</returns>
        public SqlTransaction StartTransaction(IsolationLevel transactionLevel)
        {
            OpenConnection();
            return this.connection.BeginTransaction(transactionLevel);
        }

        /// <summary>
        /// Starts the transaction on database connection object.
        /// </summary>
        /// <param name="transactionLevel">The transaction isolation level.</param>
        /// <param name="transactionName">Name of the transaction.</param>
        /// <returns>Created transaction object.</returns>
        public SqlTransaction StartTransaction(IsolationLevel transactionLevel, string transactionName)
        {
            OpenConnection();
            return this.connection.BeginTransaction(transactionLevel, transactionName);            
        }

        /// <summary>
        /// Opens database connection.
        /// </summary>
        /// <remarks>If the attempt to open the connection fails it clears connection pool, crates new connection, and tries to open it.</remarks>
        public virtual void OpenConnection()
        {
            if (State != CommunicationModuleState.Started) throw new InvalidOperationException("DatabaseConnectorManager is not started");

            if (this.connection.State == ConnectionState.Broken) RestartModule();

            if (this.connection.State == ConnectionState.Closed)
            {
                try
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("DatabaseConnectorManager:OpenConnection() - Open Connection " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
                    this.connection.Open();
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("DatabaseConnectorManager:OpenConnection() - Open Connection success" + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
                }

                // sometimes IndexOutOfRangeException
                // at System.Data.ProviderBase.DbConnectionPool.GetConnection(DbConnection owningObject) is thrown
                // and it is not possible to open the connection
                catch (IndexOutOfRangeException)
                {
                    SqlConnection.ClearPool(this.connection);
                    RestartModule();
                    this.connection.Open();
                }
            }
        }

        /// <summary>
        /// Called when database connection object is disposed to dispose associated SQL commands.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="System.EventArgs"/> instance containing the event data.</param>
        internal void OnSqlCommandDispose(object sender, EventArgs e)
        {
            SqlCommand cmd = sender as SqlCommand;
            if (cmd != null) this.associatedCommands.Remove(cmd);
        }

        /// <summary>
        /// Disposes the database connection object.
        /// </summary>
        private void DisposeConnection()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("DatabaseConnectorManager:DisposeConnection()" + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
            if (this.connection != null) this.connection.Dispose();

            this.connection = null;
        }
    }
}
