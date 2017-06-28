namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using Makolab.Fractus.Commons.DependencyInjection;

    /// <summary>
    /// Manager for Transmitter module that coordinates transmission of communication packages.
    /// </summary>
    public class TransmitterManager : CommunicationModule
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="TransmitterManager"/> class.
        /// </summary>
        public TransmitterManager()
        {
            this.Updater = new StatisticsUpdater(this);
            this.Sender = new PackageSender(this);
            this.Receiver = new PackageReceiver(this);
        }

        /// <summary>
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager Database { get; private set; }

        /// <summary>
        /// Gets or sets the sender task that sends communication packages.
        /// </summary>
        /// <value>The sender.</value>
        public PackageSender Sender { get; private set; }

        /// <summary>
        /// Gets or sets the receiver task that receives communication packages.
        /// </summary>
        /// <value>The receicer.</value>
        public PackageReceiver Receiver { get; private set; }

        /// <summary>
        /// Gets or sets the statistics updater task that transmitts communication statistics.
        /// </summary>
        /// <value>The statistics updater.</value>
        public StatisticsUpdater Updater { get; private set; }

        /// <summary>
        /// Gets or sets the Transmitter module configuration.
        /// </summary>
        /// <value>The Transmitter configuration.</value>
        public TransmitterConfiguration TransmitterConfiguration { get; private set; }

        #region ICommunicationModule Members

        /// <summary>
        /// Gets or sets the Transmitter module configuration.
        /// </summary>
        /// <value>The Transmitter configuration.</value>
        public override ICommunicationModuleConfiguration Configuration
        {
            get { return TransmitterConfiguration; }
            set
            {
                TransmitterConfiguration cfg = value as TransmitterConfiguration;
                if (cfg == null)
                    throw new ArgumentException("Invalid type. Must assign TransmitterConfiguration object to Configuration property.", "value");
                TransmitterConfiguration = cfg;
            }
        }

        /// <summary>
        /// Starts Transmitter module.
        /// </summary>
        public override void StartModule()
        {
            if (State != CommunicationModuleState.Stopped)
                return;

            State = CommunicationModuleState.Starting;

            if (TransmitterConfiguration.EnableStatistics == true)
                this.Updater.Start();
            if (TransmitterConfiguration.EnableReceiver == true)
                this.Receiver.Start();
            if (TransmitterConfiguration.EnableSender == true)
                this.Sender.Start();
            State = CommunicationModuleState.Started;
        }

        /// <summary>
        /// Stops Transmitter module.
        /// </summary>
        public override void StopModule()
        {
            if (State != CommunicationModuleState.Started)
                return;

            State = CommunicationModuleState.Stopping;
            this.Sender.Stop();
            this.Receiver.Stop();
            this.Updater.Stop();
            this.databaseId = null;
            State = CommunicationModuleState.Stopped;
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
        /// Gets the database identifier.
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
    }
}
