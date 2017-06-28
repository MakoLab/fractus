namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using Makolab.Fractus.Commons.DependencyInjection;
    using System.Globalization;
    using Makolab.Commons.Communication.DBLayer;

    /// <summary>
    /// Communication task that updates communication statistics by sending data to central web service.
    /// </summary>
    public class StatisticsUpdater : CommunicationTask<TransmitterManager>
    {
        public static bool facadehelper_DisableThisCodeForDebugConditionSwitch = false;      
        private IMapperFactory mapperFactory;

        private string additionalData;

        /// <summary>
        /// Initializes a new instance of the <see cref="StatisticsUpdater"/> class.
        /// </summary>
        /// <param name="manager">Transmitter module manager.</param>
        public StatisticsUpdater(TransmitterManager manager) : this(manager, IoC.Get<IMapperFactory>()) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="StatisticsUpdater"/> class.
        /// </summary>
        /// <param name="manager">Transmitter module manager.</param>
        /// <param name="mapperFactory">The mapper factory.</param>
        public StatisticsUpdater(TransmitterManager manager, IMapperFactory mapperFactory)
            : base(manager)
        {
            this.mapperFactory = mapperFactory;
        }

        /// <summary>
        /// Gets or sets the log for sender task.
        /// </summary>
        /// <value>The sender log.</value>
        public Logging.CommunicationLog SenderLogger { get; private set; }

        /// <summary>
        /// Gets or sets the log for receiver task.
        /// </summary>
        /// <value>The receiver log.</value>
        public Logging.CommunicationLog ReceiverLogger { get; private set; }

        /// <summary>
        /// Gets or sets the log for executor task.
        /// </summary>
        /// <value>The executor log.</value>
        public Logging.CommunicationLog ExecutorLogger { get; private set; }

        /// <summary>
        /// Registrers logger with StatisticsUpdater if no logger of this type is already registered
        /// and returns registered logger.
        /// </summary>
        /// <param name="logger">The logger that is registered.</param>
        /// <param name="logType">Type of the logger.</param>
        /// <returns>Registered log.</returns>
        /// <remarks>
        /// When no logger is registered it returns specified logger.
        /// When logger of the same type is already registered it returns registered logger.
        /// </remarks>
        public Logging.CommunicationLog RegisterLog(Logging.CommunicationLog logger, ServiceType logType)
        {
            lock (this)
            {
                switch (logType)
                {
                    case ServiceType.Sender:
                        if (this.SenderLogger == null) this.SenderLogger = logger;
                        return this.SenderLogger;
                    case ServiceType.Receiver:
                        if (this.ReceiverLogger == null) this.ReceiverLogger = logger;
                        return this.ReceiverLogger;
                    case ServiceType.Executor:
                        if (this.ExecutorLogger == null) this.ExecutorLogger = logger;
                        return this.ExecutorLogger;
                    case ServiceType.None:
                    default:
                        return null;
                }
            }
        }

        /// <summary>
        /// Task main method.
        /// </summary>
        /// <remarks>
        /// Run method steps:
        /// 1. Sends gathered communication statistics.
        /// ... where are 2 and 3?
        /// 4. Waits before repeating process.
        /// </remarks>
        protected override void Run()
        {
             bool facadehelper_DisableThisCodeForDebugCondition = facadehelper_DisableThisCodeForDebugConditionSwitch;
             if (!facadehelper_DisableThisCodeForDebugCondition)
             {
                 while (IsEnabled)
                 {
                     try
                     {
                         Wait();
                         lock (Makolab.Fractus.Communication.Transmitter.TransmitterSemaphore.locker)
                         {
                             CommunicationStatistics stats = GetStatistics();
                             stats.CurrentTime = DateTime.Now;
                             RoboFramework.Tools.RandomLogHelper.GetLog().Debug("StatisticsUpdater: CommunicationServiceProxy.Instance.SendData(...)");
                             CommunicationServiceProxy.Instance.SendData(SynchronizationHelper.CreateMessage(new SendDataParameters { Statistics = stats, DepartmentIdentifier = this.Manager.DatabaseId }, "SendData", CommunicationServiceProxy.ProxyFactory.Endpoint.Binding.MessageVersion));
                         }
                     }
                     catch (TimeoutException e)
                     {
                         if (this.SenderLogger != null) this.SenderLogger.Log.Error(e.ToString()); // TODO -1 change to false when we will have a general view often this happens.
                     }
                     catch (System.ServiceModel.CommunicationException e)
                     {
                         if (this.SenderLogger != null) this.SenderLogger.Log.Error(e.ToString());
                     }
                     catch (Exception e)
                     {
                         SenderLogger.Error(String.Format(CultureInfo.InvariantCulture, "Uncaught exception in StatisticsUpdater: {0}", e.ToString()));
                         //throw;
                     }
                 }
             }
        }

        /// <summary>
        /// Gets the statistics from every registered logger.
        /// </summary>
        /// <returns>Retrieved statistics.</returns>
        private CommunicationStatistics GetStatistics()
        {
            CommunicationStatistics stats = new CommunicationStatistics();

            Logging.LogMessage msg;
            if (this.ExecutorLogger != null)
            {
                msg = this.ExecutorLogger.PopLastMessage();
                if (msg != null) stats.LastExecutionMessage = new MessageData(msg.Message, msg.MessageTime);

                stats.LastExecutionTime = (DateTime?)this.ExecutorLogger.GetProperty("LastExecutionTime");
            }

            if (this.ReceiverLogger != null)
            {
                msg = this.ReceiverLogger.PopLastMessage();
                if (msg != null) stats.LastReceiveMessage = new MessageData(msg.Message, msg.MessageTime);
            }

            if (this.SenderLogger != null)
            {
                msg = this.SenderLogger.PopLastMessage();
                if (msg != null) stats.LastSendMessage = new MessageData(msg.Message, msg.MessageTime);
            }

            using (IUnitOfWork uow = Manager.CreateUnitOfWork())
            {
                uow.MapperFactory = this.mapperFactory;

                CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                stats.PackagesToExecute = repo.GetUnprocessedPackagesQuantity();
                stats.PackagesToSend = repo.GetUndeliveredPackagesQuantity();

                if (String.IsNullOrEmpty(this.Manager.TransmitterConfiguration.AdditionalDataStoreProcedure) == false)
                {
                    string newData = repo.GetAdditionalData(this.Manager.TransmitterConfiguration.AdditionalDataStoreProcedure).ToString(System.Xml.Linq.SaveOptions.DisableFormatting);
                    if (newData != this.additionalData)
                    {
                        stats.AdditionalData = repo.GetAdditionalData(this.Manager.TransmitterConfiguration.AdditionalDataStoreProcedure).ToString(System.Xml.Linq.SaveOptions.DisableFormatting);
                        this.additionalData = newData;
                    }
                }
            }

            return stats;
        }

        /// <summary>
        /// Pause the task for interval defined in configuration.
        /// </summary>
        private void Wait()
        {
            if (IsEnabled)
                Thread.Sleep(TimeSpan.FromSeconds(Manager.TransmitterConfiguration.UpdateStatisticsIntervalInSec));
        }
    }
}
