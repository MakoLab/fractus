namespace Makolab.Fractus.Kernel.Managers
{
    using System;
    using System.Data;
    using System.Data.SqlClient;
    using System.Threading;
    using Makolab.Fractus.Kernel.Enums;
    using Makolab.Fractus.Kernel.Exceptions;
    using System.Configuration;
    using System.Diagnostics;
    using System.Globalization;
    
    /// <summary>
    /// Class that manages every connection to database.
    /// </summary>
    public class SqlConnectionManager : IDisposable
    {
        [ThreadStatic]
        private static volatile bool connectionAlreadyInitialized;

        [ThreadStatic]
        private static volatile object objectSynchronizator;

        [ThreadStatic]
        private static Stopwatch stopwatch;

        [ThreadStatic]
        private static long numberOfUsesOfConnection;

        /// <summary>
        /// Gets the instance of <see cref="SqlConnectionManager"/>.
        /// </summary>
        public static SqlConnectionManager Instance
        {
            get
            {
                if (SqlConnectionManager.instance == null)
                {
                    SqlConnectionManager.instance = new SqlConnectionManager();
                }

                return SqlConnectionManager.instance;
            }
        }

        /// <summary>
        /// Initializes an opened <see cref="SqlConnection"/> and creates a new command for it.
        /// </summary>
        /// <exception cref="TimeoutException">Timeout occured.</exception>
        public void InitializeConnection()
        {
            bool alreadyDecrementedCounter_numberOfUsesOfConnection = false;
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:InitializeConnection() - MethodEntered from thread " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
            lock (objectSynchronizator)
            {
                //try
                //{
                    Interlocked.Increment(ref numberOfUsesOfConnection);
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:InitializeConnection() - ConnectionUses = " + numberOfUsesOfConnection.ToString());
                    if (connectionAlreadyInitialized == true)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:InitializeConnection() - MethodExit");
                        return;
                    }

                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:InitializeConnection() - Start");
                    this.connection = new SqlConnection(this.connectionString);
                    //try
                    //{
                      


                            int noTries = 0;
                            while (this.connection.State != ConnectionState.Open && (noTries++ < 500))
                            {
                                try
                                {
                                    this.connection.Open();
                                }
                                catch (SqlException e)
                                {
                                    //if (e.Number == 4060 || e.Number == -2 || e.Number == 233 || e.Number == 10054 || e.Number == 64 || e.Number == 10053 || e.Number == 10061 || e.Number == -1)
                                    //{
                                        /*
                                         *  Handled exception list:
                                         *  4060 - Cannot open database
                                         *  -2 - Timeout
                                         *  233 - No process is on the other end of the pipe
                                         *  10054 - An existing connection was forcibly closed by the remote host | Connection refused
                                         *  10053 - An  established connection was aborted by software in your host machin
                                         *  64 - The specified network name is no longer available.
                                         *  10061 - No connection could be made because the target machine actively refused it
                                         *  -1 - Error Locating Server/Instance Specified
                                         */

                                        try
                                        {
                                            this.connection.Dispose();
                                        }
                                        catch (Exception) { }
                                        Thread.Sleep(2000);
                                        this.connection = new SqlConnection(this.connectionString);
                                    //}
                                    //else
                                    //{
                                        ////tymczasowo by wychwycic numery wszyskich bledow ktore moga wystapic po restarcie/uruchomieniu kompa
                                        //using (var file = new System.IO.FileStream(logFile, System.IO.FileMode.OpenOrCreate))
                                        //using (var writer = new System.IO.StreamWriter(file))
                                        //{
                                        //    file.SetLength(0);
                                        //    writer.WriteLine(DateTime.Now.ToString() + " -  Nieprzewidziany wyjatek o nr: " + e.Number + " - " + e.ToString());
                                        //    writer.Flush();
                                        //}

                                    //    if (this.connection != null)
                                    //        this.connection.Dispose();
                                    //    //throw new ClientException(ClientExceptionId.SqlConnectionError);
                                    //    throw new InvalidOperationException("EXCEPTION: throwed by this.connection.Open(); " + e.Number + " - " + e.Message + e.StackTrace);
                                    //}
                                }
                            }


                        stopwatch.Start();
                    //}
                    //catch (Exception ex)
                    //{
                    //    Interlocked.Decrement(ref numberOfUsesOfConnection);
                    //    alreadyDecrementedCounter_numberOfUsesOfConnection = true;
                    //    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: SqlConnectionManager:InitializeConnection() " + ex.Message + ex.StackTrace);
                    //    throw new InvalidOperationException("EXCEPTION: throwed by this.connection.Open(); " + ex.Message + ex.StackTrace);
                    //}

                    this.command = new SqlCommand();
                    this.command.Connection = this.connection;
                    this.command.CommandType = CommandType.StoredProcedure;
                    this.transaction = null;
                    connectionAlreadyInitialized = true;
                    //RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:InitializeConnection() - End");
                //}
                //catch (Exception ex)
                //{
                //    if (!alreadyDecrementedCounter_numberOfUsesOfConnection)
                //    {
                //        Interlocked.Decrement(ref numberOfUsesOfConnection);
                //    }

                //    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: SqlConnectionManager:InitializeConnection() " + ex.Message + ex.StackTrace);
                //    throw new InvalidOperationException("EXCEPTION: throwed by InitializeConnection(); " + ex.Message + ex.StackTrace);
                //}
            }
        }

        /// <summary>
        /// Sets the database connection to the current thread.
        /// </summary>
        /// <param name="connection">The connection.</param>
        /// <param name="transaction">The transaction.</param>
        public void SetConnection(SqlConnection connection, SqlTransaction transaction)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:SetConnection - MethodEntered from thread " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));

            lock (objectSynchronizator)
            {
                try
                {
                    if (this.connection != null)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:SetConnection - set connection on connection != null " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
                        //return;
                        //throw new InvalidOperationException("SqlConnectionManager:SetConnection - set connection on connection != null ");
                    }

                    Interlocked.Increment(ref numberOfUsesOfConnection);
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:InitializeConnection() - ConnectionUses = " + numberOfUsesOfConnection.ToString());
                    this.connection = connection;
                    if (this.command != null)
                    {
                        this.command.Dispose();
                    }

                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = connection;
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Transaction = transaction;
                    this.command = cmd;
                    this.transaction = transaction;
                }
                catch (Exception ex)
                {
                    KernelHelpers.FastTest.Fail("SqlConnectionManager:SetConnection " + ex.Message + ex.StackTrace);
                    throw new InvalidOperationException("SqlConnectionManager:SetConnection " + ex.Message + ex.StackTrace);
                }
            }
        }

        /// <summary>
        /// Gets the connection string to the database.
        /// </summary>
        //public string ConnectionString
        //{ get { return this.connectionString; } }

        /// <summary>
        /// Get the transaction assigned to the current thread.
        /// </summary>
        public SqlTransaction Transaction { get { return this.transaction; } }

        /// <summary>
        /// Begins the database transaction.
        /// </summary>
        public void BeginTransaction()
        {
            try
            {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:BeginTransaction() - Start");
            if (this.transaction == null)
            {
                this.transaction = this.connection.BeginTransaction(IsolationLevel.Serializable);
                this.command.Transaction = this.transaction;
                SessionManager.VolatileElements.LocalTransactionId = Guid.NewGuid();
                SessionManager.VolatileElements.DeferredTransactionId = Guid.NewGuid();
            }
            else
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:BeginTransaction() - Warning! Transaction is not null on BeginTransaction!");
            }
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:BeginTransaction() - End");
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: RETHROWING SqlConnectionManager:BeginTransaction() " + ex.Message + ex.StackTrace);
                throw new InvalidOperationException("EXCEPTION: RETHROWING throwed by BeginTransaction(); " + ex.Message + ex.StackTrace);
            }
        }

        public void CommitTransaction()
        {
            try{
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:CommitTransaction() - Start");
            if (this.transaction != null)
            {
                this.transaction.Commit();
                this.ResetTransaction();
            }
            else
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:CommitTransaction() - Warning! Commit on null object!");
            }
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:CommitTransaction() - End");
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: RETHROWING SqlConnectionManager:CommitTransaction() " + ex.Message + ex.StackTrace);
                throw new InvalidOperationException("EXCEPTION: RETHROWING throwed by CommitTransaction(); " + ex.Message + ex.StackTrace);
            }
        }

        public void RollbackTransaction()
        {
            try{
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:RollbackTransaction() - Start");
            if (this.transaction != null)
            {
                this.transaction.Rollback();
                this.ResetTransaction();
            }
            else
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:RollbackTransaction() - Warning! Rollback on null object!");
            }
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:RollbackTransaction() - End");
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: RETHROWING SqlConnectionManager:RollbackTransaction() " + ex.Message + ex.StackTrace);
                throw new InvalidOperationException("EXCEPTION: RETHROWING throwed by RollbackTransaction(); " + ex.Message + ex.StackTrace);
            }
        }

        /// <summary>
        /// Gets the command assigned to the current thread.
        /// </summary>
        /// TODO: Protect bad usage of Command getter
        public SqlCommand Command { get { return this.command; } }

        /// <summary>
        /// Closes and releases previously initialized privileged connection.
        /// </summary>
        public void ReleaseConnection()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:ReleaseConnection() method entered from thread" + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture));
            lock (objectSynchronizator)
            {
                try
                {
                    if (numberOfUsesOfConnection == 0)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: CATCH SqlConnectionManager:ReleasePrivilegedConnection() numberOfUsesOfConnection == 0");
                        throw new InvalidOperationException("EXCEPTION: CATCH SqlConnectionManager:ReleasePrivilegedConnection() numberOfUsesOfConnection == 0");
                    }
                    else if (numberOfUsesOfConnection > 1)
                    {
                        Interlocked.Decrement(ref numberOfUsesOfConnection);
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:ReleasePrivilegedConnection() Decrementing numberOfUsesOfConnection =" + numberOfUsesOfConnection.ToString());
                        return;
                    }

                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:ReleasePrivilegedConnection() - Start");
                    if (this.command != null)
                    {
                        this.command.Dispose();
                    }

                    this.command = null;
                    this.ResetTransaction();

                    try
                    {
                        this.connection.Close();
                        stopwatch.Stop();
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("(Sql connection) Time used (rounded): " + stopwatch.ElapsedMilliseconds + "ms");
                    }
                    catch (Exception)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: CATCH SqlConnectionManager:ReleasePrivilegedConnection()");
                        try
                        {
                            this.connection.Dispose();
                        }
                        catch (Exception)
                        {
                            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: CATCH2 SqlConnectionManager:ReleasePrivilegedConnection()");
                        }
                    }

                    if (this.connection.State == ConnectionState.Broken)
                    {
                        try
                        {
                            this.connection.Dispose();
                        }
                        catch (Exception)
                        {
                            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: CATCH3 SqlConnectionManager:ReleasePrivilegedConnection()");
                        }
                    }

                    this.connection = null;
                    connectionAlreadyInitialized = false;
                    Interlocked.Decrement(ref numberOfUsesOfConnection);
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SqlConnectionManager:ReleasePrivilegedConnection() - End");
                }
                catch (Exception ex)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: RETHROWING SqlConnectionManager:ReleasePrivilegedConnection() " + ex.Message + ex.StackTrace);
                    throw new InvalidOperationException("EXCEPTION: RETHROWING throwed by ReleasePrivilegedConnection() " + ex.Message + ex.StackTrace);
                }
            }
        }

        /// <summary>
        /// Gets the value that indicates whether <see cref="Dispose(bool)"/> has been called.
        /// </summary>
        protected bool IsDisposed { get; set; }

        #region Private part

        /// <summary>
        /// Gets the connection assigned to the current thread.
        /// </summary>
        //private SqlConnection Connection { get { return this.connection; } }

        //private static SqlConnection GetInitializedConnection(string connString, int? maxNoTries = null)
        //{
        //    SqlConnection conn = new SqlConnection(connString);

        //    //string logFile = System.IO.Path.Combine(GetLogFolder(), "error.log");
        //    int noTries = 0;
        //    while (conn.State != ConnectionState.Open && (maxNoTries == null || noTries++ < maxNoTries))
        //    {
        //        try
        //        {
        //            conn.Open();
        //        }
        //        catch (SqlException e)
        //        {
        //            if (e.Number == 4060 || e.Number == -2 || e.Number == 233 || e.Number == 10054 || e.Number == 64 || e.Number == 10053 || e.Number == 10061 || e.Number == -1)
        //            {
        //                /*
        //                 *  Handled exception list:
        //                 *  4060 - Cannot open database
        //                 *  -2 - Timeout
        //                 *  233 - No process is on the other end of the pipe
        //                 *  10054 - An existing connection was forcibly closed by the remote host | Connection refused
        //                 *  10053 - An  established connection was aborted by software in your host machin
        //                 *  64 - The specified network name is no longer available.
        //                 *  10061 - No connection could be made because the target machine actively refused it
        //                 *  -1 - Error Locating Server/Instance Specified
        //                 */

        //                //trzeba zalgowac wystapienie tej sytuacji bo innaczej nie bedzie wiadomo czemu siedzimy w petli nieskonczonej
        //                //bo pomylka w nazwie bazy tez bedzie tu wisiec
        //                using (var file = new System.IO.FileStream(logFile, System.IO.FileMode.OpenOrCreate))
        //                using (var writer = new System.IO.StreamWriter(file))
        //                {
        //                    file.SetLength(0);
        //                    writer.WriteLine(String.Format("{0} - {1}, SqlConnectionManager.InitializePrivilegedConnection exception: {2}", DateTime.Now.ToString(), connString, e.ToString()));
        //                    writer.Flush();
        //                }
        //                try
        //                {
        //                    conn.Dispose();
        //                }
        //                catch (Exception) { }
        //                Thread.Sleep(2000);
        //                conn = new SqlConnection(connString);
        //            }
        //            else
        //            {
        //                //tymczasowo by wychwycic numery wszyskich bledow ktore moga wystapic po restarcie/uruchomieniu kompa
        //                using (var file = new System.IO.FileStream(logFile, System.IO.FileMode.OpenOrCreate))
        //                using (var writer = new System.IO.StreamWriter(file))
        //                {
        //                    file.SetLength(0);
        //                    writer.WriteLine(DateTime.Now.ToString() + " -  Nieprzewidziany wyjatek o nr: " + e.Number + " - " + e.ToString());
        //                    writer.Flush();
        //                }

        //                if (conn != null)
        //                    conn.Dispose();
        //                throw new ClientException(ClientExceptionId.SqlConnectionError);
        //            }
        //        }
        //    }

        //    return conn;
        //}

        /// <summary>
        /// Instance of <see cref="SqlConnectionManager"/>.
        /// </summary>
        [ThreadStatic]
        private static SqlConnectionManager instance; 

        //[ThreadStatic]
        //private static SqlConnectionManager testDbInstance;

        //public static SqlConnectionManager TestDbInstance
        //{
        //    get
        //    {
        //        if (SqlConnectionManager.testDbInstance == null)
        //        {
        //            SqlConnectionManager.testDbInstance = new SqlConnectionManager("Tests");
        //            TestRecorderExceptionLogger.Instance.Log(new Exception("testDbInstance new"));
        //        }

        //        return SqlConnectionManager.testDbInstance;
        //    }
        //}

        //[ThreadStatic]
        //private static Dictionary<Guid, SqlConnectionManager> branchesConnectionManagers;

        /// <summary>
        /// Array of connection managers for all branches in company
        /// </summary>
        // REFACTORINDICATOR
        //public static Dictionary<Guid, SqlConnectionManager> BranchesConnectionManagers
        //{
        //    get
        //    {
        //        if (SqlConnectionManager.branchesConnectionManagers == null)
        //        {
        //            var branchesIds = DictionaryMapper.Instance.GetBranchesIds();
        //            Dictionary<Guid, SqlConnectionManager> tmpManagers = new Dictionary<Guid, SqlConnectionManager>(branchesIds.Count);

        //            foreach (Guid branchId in branchesIds)
        //            {
        //                if (System.Configuration.ConfigurationManager.ConnectionStrings[branchId.ToUpperString()] != null)
        //                {
        //                    tmpManagers.Add(branchId, new SqlConnectionManager(branchId.ToUpperString()));
        //                }
        //            }
        //            SqlConnectionManager.branchesConnectionManagers = tmpManagers;
        //        }
        //        return SqlConnectionManager.branchesConnectionManagers;
        //    }
        //}

        /// <summary>
        /// Connection that is assigned to every request.
        /// </summary>
        private SqlConnection connection;

        /// <summary>
        /// Command that is assigned to every request.
        /// </summary>
        private SqlCommand command;

        /// <summary>
        /// Transaction that is assigned to every request.
        /// </summary>
        private SqlTransaction transaction;

        /// <summary>
        /// Specifies how long a thread will be waiting for the database connection.
        /// </summary>
        private int millisecondsTimeout = (int)TimeSpan.FromSeconds(30).TotalMilliseconds;

        /// <summary>
        /// Connection string to the database.
        /// </summary>
        private string connectionString;

        /// <summary>
        /// Initializes a new instance of the <see cref="SqlConnectionManager"/> class.
        /// </summary>
        private SqlConnectionManager()
        {
            this.connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["Main"].ConnectionString;
            objectSynchronizator = new object();
            connectionAlreadyInitialized = false;
            numberOfUsesOfConnection = 0;
            stopwatch = new Stopwatch();
        }

        //private SqlConnectionManager(string connStringName) : this()
        //{
        //    ConnectionStringSettings connStringSettings = System.Configuration.ConfigurationManager.ConnectionStrings[connStringName];
        //    if (connStringSettings != null)
        //    {
        //        this.connectionString = connStringSettings.ConnectionString;
        //    }
        //    else
        //    {
        //        throw new ArgumentException(String.Format("Misisng connection string {0}", connStringName));
        //    }
        //}

        /// <summary>
        /// Resets the transaction.
        /// </summary>
        private void ResetTransaction()
        {
            if (this.transaction != null)
            {
                this.transaction.Dispose();
                this.transaction = null;
            }
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="SqlConnectionManager"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (!this.IsDisposed)
            {
                if (disposing)
                {

                }
            }
            // Code to dispose the unmanaged resources 
            // held by the class
            this.IsDisposed = true;
        }

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        // TODO: review this
        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        #endregion
    }
}
