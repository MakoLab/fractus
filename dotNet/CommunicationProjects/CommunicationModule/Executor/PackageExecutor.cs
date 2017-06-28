namespace Makolab.Fractus.Communication.Executor
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading;
    using System.Data.SqlClient;
    using Makolab.Fractus.Communication.DatabaseConnector;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.Exceptions;
    using Makolab.Fractus.Commons.DependencyInjection;
    using System.Xml.Linq;
    using System.Diagnostics;

    /// <summary>
    /// Communication task that manages processing of communication packages.
    /// </summary>
    public class PackageExecutor : CommunicationTask<ExecutorManager>
    {
        /// <summary>
        /// Factory that creates object responsible for processing package of specified type.
        /// </summary>
        private IExecutingScriptsFactory scriptFactory;

        private IPackageForwarder packageForwarder;

        private IMapperFactory mapperFactory;

        private IExecutionManager executionManager;

        /// <summary>
        /// Initializes a new instance of the <see cref="PackageExecutor"/> class.
        /// </summary>
        /// <param name="manager">Executor module manager.</param>
        public PackageExecutor(ExecutorManager manager)
            : this(manager, IoC.Get<IExecutingScriptsFactory>(), IoC.Get<IPackageForwarder>(), IoC.Get<IMapperFactory>(), IoC.Get<IExecutionManager>())
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="PackageExecutor"/> class.
        /// </summary>
        /// <param name="manager">Executor module manager.</param>
        /// <param name="scriptFactory">The communication scripts factory.</param>
        /// <param name="packageForwarder">The communication package forwarder.</param>
        /// <param name="mapperFactory">The mapper factory.</param>
        /// <param name="executionManager">The execution manager.</param>
        public PackageExecutor(ExecutorManager manager, IExecutingScriptsFactory scriptFactory, IPackageForwarder packageForwarder, IMapperFactory mapperFactory, IExecutionManager executionManager)
            : base(manager)
        {
            this.XmlList = new List<ICommunicationPackage>();
            this.scriptFactory = scriptFactory;
            this.packageForwarder = packageForwarder;
            this.mapperFactory = mapperFactory;
            this.executionManager = executionManager;
        }

        /// <summary>
        /// Gets or sets the list of communication packages that are queued for processing.
        /// </summary>
        /// <value>The communication packages list.</value>
        public List<ICommunicationPackage> XmlList { get; set; }

        /// <summary>
        /// Gets or sets total amount of unprocessed communication packages.
        /// </summary>
        /// <value>The total amount of unprocessed communication packages.</value>
        public int WaitingPackages { get; set; }

        /// <summary>
        /// Task main method.
        /// </summary>
        /// <remarks>
        /// Run method steps:
        /// 1. Retrives unprocessed packages.
        /// 2. Creates objects that process packages.
        /// 3. Sets execution flag for processed packages.
        /// 4. Pauses before repeating process.
        /// </remarks>
        protected override void Run()
        {
            this.executionManager.Initialize(Manager.Database);
            this.scriptFactory.IsHeadquarter = this.Manager.IsHeadquarter;
            this.packageForwarder.Log = this.Manager.Log;
            this.executionManager.Log = this.Manager.Log;

            while (this.IsEnabled)
            {
                Wait();
                try
                {
                    this.XmlList.Clear();
                    GetNewXmlPackages();

                    if (this.XmlList.Count > 0)
                    {
                        lock (Makolab.Fractus.Communication.Transmitter.TransmitterSemaphore.locker)
                        {
                            ICommunicationPackage communicationPackage = this.XmlList.Single(pkg => pkg.OrderNumber == this.XmlList.Min(cpkg => cpkg.OrderNumber));

                            if (ExecuteLocalTransaction(communicationPackage.XmlData.LocalTransactionId))
                            {
                                this.XmlList.RemoveAll(p => p.XmlData.LocalTransactionId == communicationPackage.XmlData.LocalTransactionId);
                            }
                            else
                            {
                                throw new InvalidOperationException("this.XmlList.RemoveAll(p => p.XmlData.LocalTransactionId == communicationPackage.XmlData.LocalTransactionId);");
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    this.Manager.Log.Error(String.Format(System.Globalization.CultureInfo.InvariantCulture,
                                                    "Uncaught exception in PackageExecutor: {0}",
                                                    e.ToString()));
                }
            }
            this.executionManager.Clean(Manager.Database);
        }

        /// <summary>
        /// Retrives new portion of unprocessed packages.
        /// </summary>
        private void GetNewXmlPackages()
        {
            if (this.XmlList.Count == 0)
            {
                using (IUnitOfWork uow = Manager.CreateUnitOfWork())
                {
                    uow.MapperFactory = this.mapperFactory;

                    CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                    this.XmlList = repo.FindUnprocessedPackages(Manager.ExecutorConfiguration.MaxTransactionCount);

                    if (this.XmlList.Count > 0) this.WaitingPackages = repo.GetUnprocessedPackagesQuantity();
                    else this.WaitingPackages = 0;
                }
            }
        }

        private bool ExecuteLocalTransaction(IEnumerable<ICommunicationPackage> packageList, IUnitOfWork unitOfWork)
        {
            bool result = true;
            Guid localTransactionId = Guid.NewGuid();
            Guid currentPackageId = Guid.Empty;

            this.scriptFactory.UnitOfWork = unitOfWork;
            this.scriptFactory.LocalTransactionId = localTransactionId;
            CommunicationPackageRepository repo = new CommunicationPackageRepository(unitOfWork);
            Stopwatch timer = new Stopwatch();
            foreach (ICommunicationPackage communicationPackage in packageList)
            {
                var currentPackage = communicationPackage;//.Clone() as ICommunicationPackage;
                currentPackageId = communicationPackage.XmlData.Id;
                Manager.Log.Info("Wykonywanie paczki: " + communicationPackage.OrderNumber + "=" + currentPackageId);
                if (this.executionManager.IsExecutionRequired(communicationPackage))
                {
                    XDocument commXml = XDocument.Parse(communicationPackage.XmlData.Content);
                    IExecutingScript script = this.scriptFactory.CreateScript(communicationPackage.XmlData.XmlType, commXml);
                    script.UnitOfWork = unitOfWork;
                    script.Log = this.Manager.Log;

                    try
                    {
                        executionManager.BeforePackageExecution(unitOfWork);
                        timer.Reset();
                        timer.Start();
                        result = script.ExecutePackage(currentPackage);
                        timer.Stop();
                        communicationPackage.ExecutionTime = timer.Elapsed.TotalSeconds;
                    }
                    catch (ConflictException)
                    {
                        Manager.Log.Error("Conflict was detected while executing package, id=" + currentPackageId);
                        result = false;
                    }
                }
                else Manager.Log.Info("Pomijanie paczki: " + currentPackage.OrderNumber + "=" + currentPackageId);

                if (result == false) return false;
            }

            return result;
        }

        /// <summary>
        /// Executes group of packages that belongs to specified local transaction.
        /// </summary>
        /// <param name="transactionId">The local transaction id.</param>
        /// <returns><c>true</c> if execution is successful; otherwise, <c>false</c>.</returns>
        private bool ExecuteLocalTransaction(Guid transactionId)
        {
            bool result = true;
            Guid localTransactionId = Guid.NewGuid();
            IEnumerable<ICommunicationPackage> packages = from communicationPackage in this.XmlList
                                                          where communicationPackage.XmlData.LocalTransactionId == transactionId
                                                          orderby communicationPackage.OrderNumber ascending
                                                          select communicationPackage;

            using (IUnitOfWork uow = Manager.CreateUnitOfWork())
            {
                this.executionManager.BeforeTransactionExecution(uow);
                uow.MapperFactory = this.mapperFactory;
                uow.StartTransaction();

                result = (this.Manager.ExecutorConfiguration.UseCustomPackageExecutor == true) ? this.executionManager.ExecuteLocalTransaction(packages, uow) : this.ExecuteLocalTransaction(packages, uow);
                if (result == true)
                {
                    CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                    foreach (var package in packages)
                    {
                        //Console.WriteLine("id=" + package.XmlData.Id);
                        repo.MarkAsExecuted(package.XmlData.Id, package.ExecutionTime);
                        Manager.Log.SetProperty("LastExecutionTime", DateTime.Now);
                        var forwardedPackage = package.Clone() as ICommunicationPackage;
                        forwardedPackage.XmlData.Id = Guid.NewGuid();
                        forwardedPackage.XmlData.LocalTransactionId = localTransactionId;
                        this.packageForwarder.ForwardPackage(forwardedPackage, repo);
                    }
                    uow.SubmitChanges();
                }
                else uow.CancelChanges();
            }


            return result;
        }

        /// <summary>
        /// Pause the task for interval defined in configuration.
        /// </summary>
        private void Wait()
        {
            if (IsEnabled)
            {
                Thread.Sleep(CommunicationIntervalRules.GetExecutionInterval(this.WaitingPackages, Manager.ExecutorConfiguration.ExecutionInterval));
            }
        }
    }
}
