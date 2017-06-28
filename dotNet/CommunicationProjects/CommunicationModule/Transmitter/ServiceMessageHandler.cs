namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Commons.Communication;
    using Makolab.Fractus.Communication.DBLayer;
    using System.Data;
    using System.Xml.Schema;
    using Makolab.Fractus.Commons.DependencyInjection;
    using Makolab.Commons.Communication.Exceptions;

    /// <summary>
    /// Handles synchronization web service requests
    /// </summary>
    public class ServiceMessageHandler : IMessageHandler
    {
        internal bool isValidationEnabled;
        internal IPackageValidator validator;


        static ServiceMessageHandler()
        {
            CommunicationController.Initialize(); // to inintialize IoC class
        }

        /// <summary>
        /// Messages log.
        /// </summary>
        public static readonly Logging.CommunicationLog Log = CreateLog();

        /// <summary>
        /// Creates the log.
        /// </summary>
        /// <returns>Created log.</returns>
        public static Logging.CommunicationLog CreateLog()
        {
            Logging.CommunicationModuleLogger.Strategy = Logging.LoggingStrategy.BuildFromConfigurationFile;
            var log = Logging.CommunicationModuleLogger.CreateLog();
            return log;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ServiceMessageHandler"/> class.
        /// </summary>
        public ServiceMessageHandler()
        {
            isValidationEnabled = Boolean.Parse(System.Configuration.ConfigurationManager.AppSettings["EnablePackageValidation"]);
        }

        #region IMessageHandler Members

        /// <summary>
        /// Process data that was received by web service method.
        /// </summary>
        /// <param name="data">The data received via web service method call.</param>
        /// <returns>Response to web service client.</returns>
        public object DataReceived(object data)
        {
            SendDataParameters methodParams = (SendDataParameters)data;

            if (methodParams == null) return null;

            SendDataResponse response = new SendDataResponse();

            ICommunicationPackage communicationPackage = (methodParams.Xml == null) ? null : CreateCommunicationPackage(methodParams);

            DatabaseConnector.DatabaseConnectorManager dbm = GetDatabaseConnector();
            dbm.StartModule();
            try
            {
                using (IUnitOfWork uow = new UnitOfWork(dbm))
                {
                    uow.MapperFactory = IoC.Get<IMapperFactory>();
                    uow.StartTransaction(IsolationLevel.Serializable);

                    CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                    if (communicationPackage != null) repo.Add(communicationPackage);
                    if (methodParams.IsLastInTransaction) repo.MarkTransactionAsCompleted(communicationPackage.XmlData.LocalTransactionId);
                    if (methodParams.Statistics != null) repo.UpdateStatistics(methodParams.Statistics, methodParams.DepartmentIdentifier);

                    uow.SubmitChanges();
                }
            }
            catch (System.Data.SqlClient.SqlException e)
            {
                response.Result = false;
                Log.Error(e.ToString(), false);
                return response;
            }
            catch (CommunicationPackageExistsException e) //Xml already in database. 
            {
                Log.Info(e.ToString(), false);
            }
            finally
            {
                dbm.StopModule();
            }

            response.Result = true;
            return response;
        }

        /// <summary>
        /// Respond to request for data received by web service method call.
        /// (TODO wtf translate the above comment to english please :) )
        /// </summary>
        /// <param name="data">The data received via web service method call.</param>
        /// <returns>Response to web service client.</returns>
        public object DataRequested(object data)
        {
            GetDataParameters methodParams = (GetDataParameters)data;
            if (methodParams == null) return null;

            DatabaseConnector.DatabaseConnectorManager dbm = GetDatabaseConnector();
            dbm.StartModule();

            //ICommunicationPackageMapper mapper = NullMapperFactory.Instance.CreateMapper<ICommunicationPackageMapper>(dbm);
            List<ICommunicationPackage> packagesQueue = null;
            try
            {
                using (IUnitOfWork uow = new UnitOfWork(dbm))
                {
                    uow.MapperFactory = IoC.Get<IMapperFactory>();
                    CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                    if (methodParams.LastReceivedXmlId != null) repo.MarkAsSend(methodParams.LastReceivedXmlId.Value);

                    packagesQueue = repo.FindUndeliveredPackages(1, methodParams.LastReceivedXmlId, methodParams.DatabaseId);
                    if (packagesQueue.Count == 0) return null;

                    ICommunicationPackage pkg = packagesQueue.Single(cPkg => cPkg.OrderNumber == packagesQueue.Min(communicationPackage => communicationPackage.OrderNumber));

                    //IEnumerable<ICommunicationPackage> tmp = packagesQueue.Where(cPkg => cPkg.BranchId == methodParams.DatabaseId);
                    //ICommunicationPackage pkg = tmp.Single(cPkg => cPkg.OrderNumber == tmp.Min(communicationPackage => communicationPackage.OrderNumber));
                        //from pkg2 in packagesQueue where pkg2.OrderNumber == packagesQueue.Min(communicationPackage => communicationPackage.OrderNumber) select pkg2;
                        //packagesQueue[packagesQueue.Min(communicationPackage => communicationPackage.OrderNumber) - 1];
                    if (pkg.CheckSyntax() == false)
                    {
                        Log.Error("Invalid xml in outgoing queue.- syntax error. Xml Id=" + pkg.XmlData.Id);
                        return null;
                    }

                    if (isValidationEnabled)
                    {
                        if (validator == null)
                        {
                            object context = IoC.Get<IContextProvider>().CreateContext(IoC.Container(), "IDatabaseConnectionManager", uow.ConnectionManager);
                            //throws XmlSchemaValidationException
                            this.validator = IoC.Get<IPackageValidator>(context);
                        }
                        this.validator.ConnectionManager = uow.ConnectionManager;
                        this.validator.Validate(pkg);
                    }

                    pkg.Compress();
                    GetDataResponse response = new GetDataResponse();
                    response.XmlData = pkg.XmlData;
                    response.DatabaseId = pkg.DatabaseId;
                    response.AdditionalData = GetUndeliveredPackagesQuantity(response.AdditionalData, repo, methodParams);
                    return response;
                }
            }
            finally
            {
                dbm.StopModule();
            }
        }

        /// <summary>
        /// Gets the DataReceived method parameter type.
        /// </summary>
        /// <returns>DataReceived method parameter type</returns>
        public Type GetDataReceivedParameterType()
        {
            return typeof(SendDataParameters);
        }

        /// <summary>
        /// Gets the DataRequested method parameter type.
        /// </summary>
        /// <returns>DataRequested method parameter type.</returns>
        public Type GetDataRequestedParameterType()
        {
            return typeof(GetDataParameters);
        }

        #endregion

        /// <summary>
        /// Creates new instance of <see cref="DatabaseConnector.DatabaseConnectorManager"/>.
        /// New instance is created at every call becouse of concurent access to database.
        /// </summary>
        /// <returns>Created instance of <see cref="DatabaseConnector.DatabaseConnectorManager"/>.</returns>
        private static DatabaseConnector.DatabaseConnectorManager GetDatabaseConnector()
        {
            CommunicationController controller = new CommunicationController();
            controller.CreateCommunicationModules(controller.CreateConfigurations()); 
            DatabaseConnector.DatabaseConnectorManager dbm = controller.GetModule("fraktusek2") as DatabaseConnector.DatabaseConnectorManager;
            return dbm;
        }

        private AdditionalInfo GetUndeliveredPackagesQuantity(AdditionalInfo additionalData, CommunicationPackageRepository repository, GetDataParameters source)
        {
            int packagesLeft = repository.GetUndeliveredPackagesQuantity(source.DatabaseId);
            if (packagesLeft > 0)
            {
                if (additionalData == null) additionalData = new AdditionalInfo();
                additionalData.UndeliveredPackagesQuantity = packagesLeft;
            }

            return additionalData;
        }


        private ICommunicationPackage CreateCommunicationPackage(SendDataParameters methodParams)
        {
            ICommunicationPackage communicationPackage = IoC.Get<ICommunicationPackageFactory>().CreatePackage(methodParams.Xml);
            communicationPackage.DatabaseId = methodParams.DepartmentIdentifier;
            communicationPackage.Decompress();

            //log when package is invalid but save it anyway
            if (communicationPackage.CheckSyntax() == false)
            {
                Log.Error("Invalid xml received - syntax error. Xml Id=" + communicationPackage.XmlData.Id);
            }
            return communicationPackage;
        }
    }
}
