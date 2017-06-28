namespace Makolab.Fractus.Communication.Executor
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using Makolab.Fractus.Commons.DependencyInjection;

    /// <summary>
    /// Manager for Executor module that coordinates processing of communication packages.
    /// </summary>
    public class ExecutorManager : CommunicationModule
    {
        /// <summary>
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager Database { get; private set; }

        /// <summary>
        /// Gets or sets the executor task that runs the processing scripts.
        /// </summary>
        /// <value>The executor.</value>
        public PackageExecutor Executor { get; private set; }

        /// <summary>
        /// Gets or sets the log object.
        /// </summary>
        /// <value>The log.</value>
        /// <remarks>
        /// Log object allows logging of different message types to configured sink.
        /// </remarks>
        public ICommunicationLog Log { get; private set; }

        /// <summary>
        /// Gets or sets the Executor module configuration.
        /// </summary>
        /// <value>The Executor configuration.</value>
        public ExecutorConfiguration ExecutorConfiguration { get; private set; }

        #region ICommunicationModule Members

        /// <summary>
        /// Gets or sets the Executor module configuration.
        /// </summary>
        /// <value>The Executor configuration.</value>
        public override ICommunicationModuleConfiguration Configuration
        {
            get
            {
                return ExecutorConfiguration;
            }

            set
            {
                ExecutorConfiguration cfg = value as ExecutorConfiguration;
                if (cfg == null) throw new ArgumentException("Invalid type. Must assign ExecutorConfiguration object to Configuration property.", "value");

                ExecutorConfiguration = cfg;
            }
        }

        /// <summary>
        /// Starts Executor module.
        /// </summary>
        public override void StartModule()
        {
            if (State != CommunicationModuleState.Stopped) return;

            State = CommunicationModuleState.Starting;

            var x = this.DatabaseId;
            this.Executor = new PackageExecutor(this);
            this.Executor.Start();

            State = CommunicationModuleState.Started;
        }

        /// <summary>
        /// Stops Executor module.
        /// </summary>
        public override void StopModule()
        {
            if (State != CommunicationModuleState.Started) return;

            State = CommunicationModuleState.Stopping;
            this.Executor.Stop();
            this.databaseId = null;
            State = CommunicationModuleState.Stopped;
        }

        /// <summary>
        /// Initialize Executor module dependencies.
        /// </summary>
        /// <param name="dependencies">Dependencies collection.</param>
        public override void BindInternalDependencies(IDictionary<string, ICommunicationModule> dependencies)
        {
            base.BindInternalDependencies(dependencies);
            Logging.CommunicationLog log = Logging.CommunicationModuleLogger.CreateLog();

            if (dependencies.ContainsKey("Transmitter") == false) this.Log = log;
            else
            {
                this.Log = (dependencies["Transmitter"] as Transmitter.TransmitterManager)
                      .Updater.RegisterLog(log, ServiceType.Executor);
            }
        }

        #endregion

        /// <summary>
        /// Creates the unit of work.
        /// </summary>
        /// <returns>Created Unit of Work object.</returns>
        public virtual IUnitOfWork CreateUnitOfWork()
        {
            return new UnitOfWork(this.Database);
        }

        private Guid? databaseId;
        /// <summary>
        /// Gets the database id.
        /// </summary>
        /// <value>The database id.</value>
        public Guid DatabaseId
        {
            get
            {
                if (this.databaseId == null)
                {
                    using (IUnitOfWork uow = this.CreateUnitOfWork())
                    {
                        uow.MapperFactory = IoC.Get<IMapperFactory>();
                        CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                        this.databaseId = repo.GetDatabaseId();
                    }
                }
                return this.databaseId.Value;
            }
        }

        private bool? isHeadquarter;
        /// <summary>
        /// Gets the database id.
        /// </summary>
        /// <value>The database id.</value>
        public bool IsHeadquarter
        {
            get
            {
                if (this.isHeadquarter == null)
                {
                    using (IUnitOfWork uow = this.CreateUnitOfWork())
                    {
                        uow.MapperFactory = IoC.Get<IMapperFactory>();
                        CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                        this.isHeadquarter = repo.IsHeadquarter();
                    }
                }
                return this.isHeadquarter.Value;
            }
        }
    }
}
