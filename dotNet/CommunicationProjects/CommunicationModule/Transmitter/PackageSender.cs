namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading;
    using System.Data.SqlClient;
    using System.Globalization;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using System.ServiceModel.Channels;
    using Makolab.Fractus.Commons.DependencyInjection;
    using System.ServiceModel.Security;

    /// <summary>
    /// Communication task that sends communication packages.
    /// </summary>
    public class PackageSender : CommunicationTask<TransmitterManager>
    {
        private IMapperFactory mapperFactory;

        /// <summary>
        /// Initializes a new instance of the <see cref="PackageSender"/> class.
        /// </summary>
        /// <param name="manager">Transmitter module manager.</param>
        public PackageSender(TransmitterManager manager)
            : this(manager, IoC.Get<IMapperFactory>())
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="PackageSender"/> class.
        /// </summary>
        /// <param name="manager">Transmitter module manager.</param>
        /// <param name="mapperFactory">The mapper factory.</param>
        public PackageSender(TransmitterManager manager, IMapperFactory mapperFactory)
            : base(manager)
        {
            this.XmlList = new List<ICommunicationPackage>();
            this.mapperFactory = mapperFactory;
            this.Log = Manager.Updater.RegisterLog(Logging.CommunicationModuleLogger.CreateLog(), ServiceType.Sender);
        }

        /// <summary>
        /// Gets or sets the list of communication packages that are queued for delivery.
        /// </summary>
        /// <value>The communication packages list.</value>
        public List<ICommunicationPackage> XmlList { get; set; }

        /// <summary>
        /// Gets or sets the log.
        /// </summary>
        /// <value>The log.</value>
        public Logging.CommunicationLog Log { get; private set; }

        /// <summary>
        /// Gets or sets total amount of undelivered communication packages.
        /// </summary>
        /// <value>The total amount of undelivered communication packages.</value>
        public int WaitingPackages { get; set; }

        /// <summary>
        /// Task main method.
        /// </summary>
        /// <remarks>
        /// Run method steps:
        /// 1. Retrives undelivered packages.
        /// 2. Sends packages.
        /// 3. Sets send flag for delivered packages.
        /// 4. Waits before repeating process.
        /// </remarks>
        protected override void Run()
        {
            Guid databaseId = this.Manager.DatabaseId;

            while (IsEnabled)
            {
                try
                {
                    lock (Makolab.Fractus.Communication.Transmitter.TransmitterSemaphore.locker)
                    {
                        GetNewXmlPackages(databaseId);
                        SendXmlPackages();
                    }
                    Wait();
                }
                catch (Exception e)
                {
                    Log.Error(String.Format(CultureInfo.InvariantCulture, "Uncaught exception in PackageSender: {0}", e.ToString()));
                }
            }
        }

        /// <summary>
        /// Retrives new portion of undelivered packages.
        /// </summary>
        private void GetNewXmlPackages(Guid databaseId)
        {
            if (this.XmlList.Count == 0)
            {
                using (IUnitOfWork uow = Manager.CreateUnitOfWork())
                {
                    uow.MapperFactory = this.mapperFactory;

                    CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                    this.XmlList = repo.FindUndeliveredPackages(Manager.TransmitterConfiguration.MaxTransactionCount, databaseId);
                    if (this.XmlList.Count > 0) this.WaitingPackages = repo.GetUndeliveredPackagesQuantity();
                    else this.WaitingPackages = 0;
                }
            }
        }

        /// <summary>
        /// Sends the communication packages.
        /// </summary>
        private void SendXmlPackages()
        {
            if (this.XmlList.Count > 0)
            {
                ICommunicationPackage communicationPackage = this.XmlList[0];
                SendLocalTransaction(communicationPackage.XmlData.LocalTransactionId);
                this.XmlList.RemoveAll(p => p.XmlData.LocalTransactionId == communicationPackage.XmlData.LocalTransactionId);
            }
        }

        /// <summary>
        /// Sends group of packages that belongs to specified local transaction.
        /// </summary>
        /// <param name="transactionId">The local transaction id.</param>
        /// <returns><c>true</c> if send is successful; otherwise, <c>false</c>.</returns>
        private void SendLocalTransaction(Guid transactionId)
        {
            IEnumerable<ICommunicationPackage> packages = from communicationPackage in this.XmlList
                                                          where communicationPackage.XmlData.LocalTransactionId == transactionId
                                                          orderby communicationPackage.OrderNumber ascending
                                                          select communicationPackage;

            bool isLast = false;
            ICommunicationPackage lastPackage = packages.Last();
            foreach (ICommunicationPackage communicationPackage in packages)
            {
                if (communicationPackage == lastPackage) isLast = true;
                else isLast = false;

                while (SendPackage(communicationPackage.Clone() as ICommunicationPackage, isLast) == false) Wait();

                SetXmlSentWithRetry(communicationPackage.XmlData.Id);

                if (isLast == false) Wait();
            }
        }

        /// <summary>
        /// Sends specified communication package.
        /// </summary>
        /// <param name="xml">The comunication package.</param>
        /// <param name="isLastPackage">if set to <c>true</c> it's last package in transaction.</param>
        /// <returns><c>true</c> if send is successful; otherwise, <c>false</c>.</returns>
        private bool SendPackage(ICommunicationPackage xml, bool isLastPackage)
        {
            xml.Compress();
            try
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("PackageSender.cs - SendPackage(ICommunicationPackage xml, bool isLastPackage)");
                Message result = CommunicationServiceProxy.Instance.SendData(
                                                                            SynchronizationHelper.CreateMessage(
                                                                            new SendDataParameters
                                                                            {
                                                                                Xml = xml.XmlData,
                                                                                IsLastInTransaction = isLastPackage,
                                                                                DepartmentIdentifier = xml.DatabaseId.Value
                                                                            },
                                                                            "SendData",
                                                                            CommunicationServiceProxy.ProxyFactory.Endpoint.Binding.MessageVersion));

                SendDataResponse response = SynchronizationHelper.GetData<SendDataResponse>(result);

                if (response == null) return false;

                if (response.AdditionalData != null && response.AdditionalData.UndeliveredPackagesQuantity != null)
                {
                    Manager.Receiver.WaitingPackages = response.AdditionalData.UndeliveredPackagesQuantity.Value;
                }
                return response.Result;
            }
            catch (MessageSecurityException mse)
            {
                Log.Info("WCF MessageSecurityException");
                Log.Info(mse.ToString());
                Log.Info("=================================================================");
                try
                {
                    CommunicationServiceProxy.ProxyFactory.Close();
                }
                catch
                {
                    try
                    {
                        CommunicationServiceProxy.ProxyFactory.Abort();
                    }
                    catch { }
                }
                throw;
            }
            catch (TimeoutException e)
            {
                Log.Error(e.ToString(), true); // TODO -1 change to false when we will have a general view often this happens.
                return false;
            }
            catch (System.ServiceModel.CommunicationException e)
            {
                Log.Error(e.ToString());
                return false;
            }
        }

        /// <summary>
        /// Pause the task for interval defined in configuration.
        /// </summary>
        private void Wait()
        {
            if (IsEnabled == true)
            {
                Thread.Sleep(CommunicationIntervalRules.GetSendInterval(this.WaitingPackages, Manager.TransmitterConfiguration.SendInterval));
            }
        }

        /// <summary>
        /// Sets the communication package send flag to true.
        /// </summary>
        /// <param name="id">The communication package id.</param>
        private void SetXmlSentWithRetry(Guid id)
        {
            bool isSet = false;
            int retryCount = 0;
            using (IUnitOfWork uow = Manager.CreateUnitOfWork())
            {
                uow.MapperFactory = this.mapperFactory;

                CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                while (isSet == false && retryCount < 10)
                {
                    try
                    {
                        repo.MarkAsSend(id);
                        isSet = true;
                    }
                    catch (SqlException)
                    {
                        ++retryCount;
                        Wait();
                    }
                }

                if (!isSet)
                {
                    Log.Error("EXCEPTION: CRITICAL ERROR ALERT! What to do with unset (Sets the communication package send flag to true) SetXmlSentWithRetry(Guid id) PackageSender.cs");
                }
            }
        }
    }
}
