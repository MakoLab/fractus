using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Fractus.Commons.DependencyInjection;
using Makolab.Fractus.Kernel.Managers;
using System.Data.SqlClient;
using System.Xml.Linq;
using Makolab.Commons.Communication.Exceptions;
using System.Diagnostics;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Runs the custom logic in specific moments of package execution.
    /// </summary>
    public class FractusExecutionManager : IExecutionManager
    {
        private Guid currentDatabaseId;
        private bool isHeadquarter;
        private List<string> exceptionalPackages;
        private ExecutingScriptsFactory scriptFactory;

        /// <summary>
        /// Initializes a new instance of the <see cref="FractusExecutionManager"/> class.
        /// </summary>
        public FractusExecutionManager()
        {
            this.exceptionalPackages = new List<string>();
            this.exceptionalPackages.Add(CommunicationPackageType.WarehouseDocumentSnapshot.ToString());
            this.exceptionalPackages.Add(CommunicationPackageType.ShiftDocumentStatus.ToString());

            this.scriptFactory = new ExecutingScriptsFactory();


            //this.exceptionalPackages.Add(CommunicationPackageType.WarehouseDocumentValuation.ToString());
        }

        #region IExecutionManager Members

        /// <summary>
        /// Gets or sets the log object.
        /// </summary>
        /// <value>The log.</value>
        /// <remarks>
        /// Log object allows logging of different message types to configured sink.
        /// </remarks>
        public ICommunicationLog Log { get; set; }

        /// <summary>
        /// Initializes the execution engine. Runs before any package is executed.
        /// </summary>
        /// <param name="connectionManager">The database connection manager.</param>
        public void Initialize(IDatabaseConnectionManager connectionManager)
        {
            using (IConnectionWrapper wrapper = connectionManager.SynchronizeConnection())
            {
                Makolab.Fractus.Kernel.Managers.SqlConnectionManager.Instance.SetConnection(wrapper.Connection, null);
                Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
                KernelSessionManager.IsLogged = true;
                Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.LocalTransactionId = Guid.NewGuid();
                Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.DeferredTransactionId = Guid.NewGuid();
                SetDatabaseId();
                SetHeadquarterStatus(connectionManager);
            }
        }

        /// <summary>
        /// Cleans the execution engine. Runs when execution engine is stopping.
        /// </summary>
        /// <param name="connectionManager">The database connection manager.</param>
        public void Clean(IDatabaseConnectionManager connectionManager)
        {
            using (IConnectionWrapper wrapper = connectionManager.SynchronizeConnection())
            {
                Makolab.Fractus.Kernel.Managers.SqlConnectionManager.Instance.SetConnection(wrapper.Connection, null);
                Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOff();
                KernelSessionManager.IsLogged = false;
            }
        }

        /// <summary>
        /// Determines whether the execution of specified communication package is required or package must be skipped.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <returns>
        /// 	<c>true</c> if execution is required; otherwise, <c>false</c>.
        /// </returns>
        public bool IsExecutionRequired(ICommunicationPackage communicationPackage)
        {
            if (this.exceptionalPackages.Contains(communicationPackage.XmlData.XmlType))
            {
                var skipPackage = XDocument.Parse(communicationPackage.XmlData.Content).Root.Attribute("skipPackage");
                if (skipPackage != null && skipPackage.Value.Equals("true", StringComparison.OrdinalIgnoreCase)) return false;
                else return true;
            }
            else if (this.isHeadquarter == false || (this.isHeadquarter && communicationPackage.DatabaseId.Value != this.currentDatabaseId))
            {
                return true;
            }
            else return false;
        }


        /// <summary>
        /// Allow to run custom logic before execution of local transaction.
        /// </summary>
        /// <param name="unitOfWork">The active unit of work.</param>
        public void BeforeTransactionExecution(IUnitOfWork unitOfWork)
        {
            using (var wrapper = unitOfWork.ConnectionManager.SynchronizeConnection())
            {
                SqlConnectionManager.Instance.SetConnection(wrapper.Connection, null);
            }
            //FIX: poprawka bledu zawieszania na WaitOne w CheckForChanges() 
            //     przez dodanie nadmiarowych linijek z EnterReadLock i ExitReadLock
            Makolab.Fractus.Kernel.Managers.SessionManager.ResetVolatileContainer();
            Makolab.Fractus.Kernel.Mappers.DictionaryMapper.Instance.DictionaryLock.EnterReadLock();
            try
            {
                Makolab.Fractus.Kernel.Mappers.DictionaryMapper.Instance.CheckForChanges();
            }
            finally
            {
                Makolab.Fractus.Kernel.Mappers.DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
            }
            
        }


        /// <summary>
        /// Allow to run custom logic after  execution of local transaction.
        /// </summary>
        /// <param name="unitOfWork">The active unit of work.</param>
        public void AfterTransactionExecution(IUnitOfWork unitOfWork)
        { 
        
        }

        public void BeforePackageExecution(IUnitOfWork unitOfWork)
        {
            using (var wrapper = unitOfWork.ConnectionManager.SynchronizeConnection())
            {
                SqlConnectionManager.Instance.SetConnection(wrapper.Connection, unitOfWork.Transaction as SqlTransaction);
            }
        }

        #endregion

        /// <summary>
        /// Sets the database id.
        /// </summary>
        private void SetDatabaseId()
        {
            this.currentDatabaseId = Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.DatabaseId;
        }

        /// <summary>
        /// Sets whether current branch is headquarter.
        /// </summary>
        /// <param name="connectionManager">The database connection manager.</param>
        private void SetHeadquarterStatus(IDatabaseConnectionManager connectionManager)
        {
            using (IUnitOfWork uow = new UnitOfWork(connectionManager))
            {
                uow.MapperFactory = IoC.Get<IMapperFactory>();
                CommunicationPackageRepository repo = new CommunicationPackageRepository(uow);
                this.isHeadquarter = repo.IsHeadquarter();
            }        
        }

        #region IExecutionManager Members


        /// <summary>
        /// Executes the local transaction.
        /// </summary>
        /// <param name="packageList">The list of packages belonging to one local transaction.</param>
        /// <param name="unitOfWork"></param>
        /// <returns>
        /// 	<c>true</c> if succeeded; otherwise, <c>false</c>.
        /// </returns>
        public bool ExecuteLocalTransaction(IEnumerable<ICommunicationPackage> packageList, IUnitOfWork unitOfWork)
        {
            bool result = true;
            Guid localTransactionId = Guid.NewGuid();
            Guid currentPackageId = Guid.Empty;
            

            this.scriptFactory.UnitOfWork = unitOfWork;
            this.scriptFactory.LocalTransactionId = localTransactionId;
            this.scriptFactory.IsHeadquarter = this.isHeadquarter;
            this.scriptFactory.ExecutionController.IsDeffered = true;
            this.scriptFactory.ExecutionController.UnitOfWork = unitOfWork;
            

            CommunicationPackageRepository repo = new CommunicationPackageRepository(unitOfWork);
            Stopwatch timer = new Stopwatch();
            timer.Start();
            foreach (ICommunicationPackage communicationPackage in packageList)
            {
                var currentPackage = communicationPackage;//.Clone() as ICommunicationPackage;
                currentPackageId = communicationPackage.XmlData.Id;
                this.Log.Info("Wykonywanie paczki: " + communicationPackage.OrderNumber + "=" + currentPackageId);
                if (this.IsExecutionRequired(communicationPackage))
                {
                    XDocument commXml = XDocument.Parse(communicationPackage.XmlData.Content);
                    IExecutingScript script = this.scriptFactory.CreateScript(communicationPackage.XmlData.XmlType, commXml);
                    script.UnitOfWork = unitOfWork;
                    script.Log = this.Log;

                    try
                    {
                        this.BeforePackageExecution(unitOfWork);
                        result = script.ExecutePackage(currentPackage);
                    }
                    catch (ConflictException)
                    {
                        this.Log.Error("Conflict was detected while executing package, id=" + currentPackageId);
                        result = false;
                    }
                }
                else this.Log.Info("Pomijanie paczki: " + currentPackage.OrderNumber + "=" + currentPackageId);

                if (result == false) return false;
            }

            this.scriptFactory.ExecutionController.RunDefferedActions();
            timer.Stop();
            packageList.ToList().ForEach(p => p.ExecutionTime = timer.Elapsed.TotalSeconds);
            return result;      
        }

        #endregion
    }
}
