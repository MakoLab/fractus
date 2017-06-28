namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using System.Threading;
    using System.Globalization;
    using System.ServiceModel;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using System.ServiceModel.Channels;
    using Makolab.Fractus.Commons.DependencyInjection;
    using System.ServiceModel.Security;
    using Makolab.Commons.Communication.Exceptions;

    /// <summary>
    /// Communication task that retrives communication packages.
    /// </summary>
    public class PackageReceiver : CommunicationTask<TransmitterManager>
    {
        public static bool facadehelper_DisableThisCodeForDebugConditionSwitch = false;

        private ICommunicationPackageFactory packageFactory;
        private IMapperFactory mapperFactory;

        /// <summary>
        /// Initializes a new instance of the <see cref="PackageReceiver"/> class.
        /// </summary>
        /// <param name="manager">Transmitter module manager.</param>
        public PackageReceiver(TransmitterManager manager)
            : this(manager, IoC.Get<ICommunicationPackageFactory>(), IoC.Get<IMapperFactory>())
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="PackageReceiver"/> class.
        /// </summary>
        /// <param name="manager">Transmitter module manager.</param>
        /// <param name="packageFactory">The communication package factory.</param>
        /// <param name="mapperFactory">The mappers factory.</param>
        public PackageReceiver(TransmitterManager manager, ICommunicationPackageFactory packageFactory, IMapperFactory mapperFactory)
            : base(manager)
        {
            this.Log = Manager.Updater.RegisterLog(Logging.CommunicationModuleLogger.CreateLog(), ServiceType.Receiver);
            this.packageFactory = packageFactory;
            this.mapperFactory = mapperFactory;
        }

        /// <summary>
        /// Gets or sets the log.
        /// </summary>
        /// <value>The log.</value>
        public ICommunicationLog Log { get; private set; }

        /// <summary>
        /// Gets or sets total amount of communication packages to receive.
        /// </summary>
        /// <value>The total amount of communication packages to receive.</value>
        public int WaitingPackages { get; set; }

        /// <summary>
        /// Starts the task in seprete thread.
        /// </summary>
        public override void Start()
        {
            base.Start();
        }

        /// <summary>
        /// Saves the specified xml to storage.
        /// </summary>
        /// <param name="xmlData">The xml to save.</param>
        /// <param name="databaseId">The database id.</param>
        /// <returns>
        /// 	<c>true</c> if  is saving successful; otherwise, <c>false</c>.
        /// </returns>
        public bool ProcessXml(XmlTransferObject xmlData, Guid? databaseId)
        {
            bool isSaved = false;
            ICommunicationPackage xml = this.packageFactory.CreatePackage(xmlData);
            xml.DatabaseId = databaseId;
            xml.Decompress();
            if (xml.CheckSyntax())
            {
                int retryCount = 0;
                using (IUnitOfWork uow = Manager.CreateUnitOfWork())
                {
                    uow.MapperFactory = this.mapperFactory;

                    CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                    while (isSaved == false && retryCount < 10)
                    {
                        try
                        {
                            repo.Add(xml);
                            isSaved = true;
                        }
                        catch (SqlException)
                        {
                            ++retryCount;
                            Wait();
                        }
                        catch (CommunicationPackageExistsException e) // Xml with the same id exists in db
                        {
                            this.Log.Info(e.ToString(), false);
                            isSaved = true;
                        }
                    }

                    if (!isSaved)
                    {
                        Log.Error("EXCEPTION: CRITICAL ERROR ALERT! What to do with unset (Saves the specified xml to storage) ProcessXml(XmlTransferObject xmlData,Guid? databaseId) PackageReceiver.cs");
                    }
                }
            }
            else
            {
                Log.Error("Invalid xml received, syntax error. Xml id=" + xmlData.Id + " content=" + xmlData.Content);
                ////it shouldnt be received in the first place = validation on the WebService site

                return false;
            }

            return isSaved;
        }

        /// <summary>
        /// Task main method.
        /// </summary>
        /// <remarks>
        /// Run method steps:
        /// 1. Retrives next package.
        /// 2. Presists package.
        /// 3. Waits before repeating process.
        /// </remarks>
        protected override void Run()
        {
            Guid? lastReceivedXmlId = null;
            Guid? lastReceivedTransactionId = null;
            Guid databaseId = this.Manager.DatabaseId;
            lastReceivedTransactionId = GetLastTransactionId();

            while (IsEnabled)
            {
                lock (Makolab.Fractus.Communication.Transmitter.TransmitterSemaphore.locker)
                {
                    try
                    {
                        GetDataResponse response = GetNextXmlPackage(lastReceivedXmlId, databaseId);
                        if (lastReceivedTransactionId != null && response != GetDataResponse.ExceptionResponse && (response.XmlData == null || response.XmlData.LocalTransactionId != lastReceivedTransactionId.Value))
                        {
                            using (IUnitOfWork uow = Manager.CreateUnitOfWork())
                            {
                                uow.MapperFactory = this.mapperFactory;
                                CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                                repo.MarkTransactionAsCompleted(lastReceivedTransactionId.Value);
                                lastReceivedTransactionId = null;
                            }
                        }

                        if (response.XmlData != null && ProcessXml(response.XmlData, response.DatabaseId) == true)
                        {
                            lastReceivedXmlId = response.XmlData.Id;
                            lastReceivedTransactionId = response.XmlData.LocalTransactionId;
                        }
                        else
                        {
                            lastReceivedXmlId = null;
                        }

                        if (response.AdditionalData != null && response.AdditionalData.UndeliveredPackagesQuantity != null)
                        {
                            this.WaitingPackages = response.AdditionalData.UndeliveredPackagesQuantity.Value;
                        }

                        
                    }
                    catch (Exception e)
                    {
                        Log.Error(String.Format(CultureInfo.InvariantCulture, "Uncaught exception in PackageReceiver: {0}", e.ToString()));
                    }
                }

                Wait();
            }
        }

        private Guid? GetLastTransactionId()
        {
            using (IUnitOfWork uow = Manager.CreateUnitOfWork())
            {
                uow.MapperFactory = this.mapperFactory;

                CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                return repo.GetLastReceivedTransacionId(repo.GetDatabaseId());
            }
        }

        /// <summary>
        /// Asks web service for next communication package.
        /// </summary>
        /// <param name="lastReceivedXmlId">The last received communication package id.</param>
        /// <param name="databaseId">The database id.</param>
        private GetDataResponse GetNextXmlPackage(Guid? lastReceivedXmlId, Guid databaseId)
        {
            bool facadehelper_DisableThisCodeForDebugCondition = facadehelper_DisableThisCodeForDebugConditionSwitch;

            if (!facadehelper_DisableThisCodeForDebugCondition)
            {
                try
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("PackageReceiver.cs - CommunicationServiceProxy.Instance.GetData(data)");
                    using (Message data = SynchronizationHelper.CreateMessage(new GetDataParameters { LastReceivedXmlId = lastReceivedXmlId, DatabaseId = databaseId }, "GetData", CommunicationServiceProxy.ProxyFactory.Endpoint.Binding.MessageVersion))
                    {
                        GetDataResponse response = SynchronizationHelper.GetData<GetDataResponse>(CommunicationServiceProxy.Instance.GetData(data));
                        if (response == null) return GetDataResponse.EmptyResponse;
                        else return response;
                    }
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
                    Log.Error(e.ToString(), true); // TODO -1 change to false when we will have a general view how often this happens.
                    return GetDataResponse.ExceptionResponse;
                }
                catch (CommunicationException e)
                {
                    Log.Error(e.ToString());
                    return GetDataResponse.ExceptionResponse;
                }
            }
            else
            {
                return GetDataResponse.EmptyResponse;
            }
        }

        /// <summary>
        /// Pause the task for interval defined in configuration.
        /// </summary>
        private void Wait()
        {
            if (IsEnabled)
            {
                Thread.Sleep(
                    CommunicationIntervalRules.GetReceiveInterval(
                        this.WaitingPackages, Manager.TransmitterConfiguration.ReceiveInterval));
            }
        }
    }
}
