using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Security.Permissions;
using LinFu.Reflection;
using System.Threading;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Controls the process of hosting and managing of modules.
    /// </summary>
    public class HostingServiceController : IDisposable
    {
        private ManualResetEvent unloaderEvent;
        private Thread unloaderThread;

        /// <summary>
        /// Gets or sets the name of the service.
        /// </summary>
        /// <value>The name of the service.</value>
        public string ServiceName { get; set; }

        /// <summary>
        /// Gets the get collection of hosting modules defined in configuration.
        /// </summary>
        /// <value>The get modules.</value>
        public static ICollection<ModuleInfo> GetModules
        {
            get { return (ConfigurationManager.GetSection("modules") as ModulesSectionHandler).Modules; }
        }

        /// <summary>
        /// Gets or sets the module unload timeout.
        /// </summary>
        /// <value>The module unload timeout.</value>
        public int ModuleUnloadTimeout { get; set; }

        /// <summary>
        /// Gets or sets the collection of loaded modules.
        /// </summary>
        /// <value>The modules.</value>
        public ICollection<ExternalModule> Modules { get; private set; }

        /// <summary>
        /// Creates the application domain for module.
        /// </summary>
        /// <param name="moduleInfo">The module info.</param>
        /// <returns>Created application domain.</returns>
        public static AppDomain CreateAppDomain(ModuleInfo moduleInfo)
        {
            AppDomain domain = CreateModuleSpecificDomain(moduleInfo);

            if (domain == null) domain = CreateGenericDomain(moduleInfo);
            if (domain == null) throw new AppDomainCreateException("AppDomain not created.");

            return domain;
        }

        /// <summary>
        /// Creates the module from specified data in specified <see cref="AppDomain"/>.
        /// </summary>
        /// <param name="moduleInfo">The module info.</param>
        /// <param name="domain">The module domain.</param>
        /// <returns>Created module.</returns>
        public static IModule CreateModule(ModuleInfo moduleInfo, AppDomain domain)
        {
            object moduleInstance = domain.CreateInstanceAndUnwrap(moduleInfo.AssemblyName, moduleInfo.TypeName);
            DynamicObject dynModule = new DynamicObject(moduleInstance);
            if (dynModule.LooksLike<IModule>() == false)
                throw new MissingMethodException("Required methods not found.");
            IModule moduleDuck = dynModule.CreateDuck<IModule>();
            return moduleDuck;
        }

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        /// <summary>
        /// Initializes a new instance of the <see cref="HostingServiceController"/> class.
        /// </summary>
        /// <param name="serviceCfg">The service configuration handler.</param>
        public HostingServiceController(ServiceSectionHandler serviceCfg)
        {
            this.ModuleUnloadTimeout = serviceCfg.ModuleUnloadTimeout;
            this.ServiceName = serviceCfg.ServiceName;
        }

        /// <summary>
        /// Starts HostingService.
        /// </summary>
        [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
        public void Start() 
        {
            ICollection<ModuleInfo> definedModules = GetModules;
            Modules = new List<ExternalModule>();
            
            // start modules in app domain
            foreach (ModuleInfo moduleInfo in definedModules)
            {
                AppDomain domain = CreateAppDomain(moduleInfo);

                // TODO -1 create dynamic object that inherits from MarshalByRefObject or have [Serializable] attribute if
                // module.TypeName doesn't do that - perhaps in version 10.0 ;-) , low priority 
                IModule moduleDuck = CreateModule(moduleInfo, domain);

                Modules.Add(new ExternalModule { Instance = moduleDuck, Info = moduleInfo, Domain = domain });

                AttachUnhandledExceptionsHandler(domain);
            }

            StartExternalModules();
        }

        /// <summary>
        /// Starts the created modules.
        /// </summary>
        public void StartExternalModules()
        {
            foreach (ExternalModule module in Modules) module.Instance.OnStartModule();
        }

        /// <summary>
        /// Stops the created modules.
        /// </summary>
        public void StopExternalModules()
        {
            foreach (ExternalModule module in Modules) module.Instance.OnStopModule();
        }

        /// <summary>
        /// Stops HostingService.
        /// </summary>
        public void Stop() 
        {
            foreach (ExternalModule module in Modules)
            {
                this.unloaderEvent = new ManualResetEvent(false);
                this.unloaderThread = new Thread(new ParameterizedThreadStart(UnloaderFunc));
                this.unloaderThread.Start(module);

                this.unloaderEvent.WaitOne(this.ModuleUnloadTimeout, false);

                try
                {
                    AppDomain.Unload(module.Domain);
                }
                catch (AppDomainUnloadedException)
                {

                }

                if (this.unloaderThread != null)
                    this.unloaderThread.Abort();

                if (this.unloaderEvent != null)
                    this.unloaderEvent.Close();
            }        
        }

        /// <summary>
        /// Unloads module.
        /// </summary>
        /// <param name="param">The param.</param>
        private void UnloaderFunc(object param)
        {
            try
            {
                ((ExternalModule)param).Instance.OnStopModule();

                if (this.unloaderEvent != null)
                    this.unloaderEvent.Set();
            }
            catch (Exception e)
            {
                HostingServiceLogger.LogMessage(e.ToString());
            }
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (this.unloaderEvent != null) this.unloaderEvent.Close();
            }
        }

        /// <summary>
        /// Creates the module specific domain.
        /// </summary>
        /// <param name="module">The module.</param>
        /// <returns>Created application domain.</returns>
        private static AppDomain CreateModuleSpecificDomain(ModuleInfo module)
        {
            object moduleInstance = Activator.CreateInstance(module.AssemblyName, module.TypeName).Unwrap();
            DynamicObject dynModule = new DynamicObject(moduleInstance);
            if (dynModule.LooksLike<IDomainCreator>())
                return dynModule.CreateDuck<IDomainCreator>().CreateDomain();
            else
                return null;
        }

        ////[SecurityPermission(SecurityAction.LinkDemand, Unrestricted = true)]
        /// <summary>
        /// Creates the generic domain.
        /// </summary>
        /// <param name="module">The module.</param>
        /// <returns>Created application domain.</returns>
        private static AppDomain CreateGenericDomain(ModuleInfo module)
        {
            AppDomainSetup ads = new AppDomainSetup();
            ads.ApplicationName = module.Name;
            AppDomain aspd = AppDomain.CreateDomain(module.Name + "Domain", null, ads);
            return aspd;
        }

        /// <summary>
        /// Attaches the unhandled exceptions handler.
        /// </summary>
        /// <param name="domain">The domain.</param>
        [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
        private static void AttachUnhandledExceptionsHandler(AppDomain domain)
        {
            domain.UnhandledException +=
                 new UnhandledExceptionEventHandler(HostingServiceLogger.DomainUnhandledExceptionHandler);
        }

        /// <summary>
        /// Called when diagnose request is recived.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <returns>Diagnostic query response.</returns>
        public string OnDiagnose(string query)
        {
            return Makolab.Fractus.Commons.DiagnosticHelper.Diagnose(query, this);
        }

        /// <summary>
        /// Gets the name of the modules.
        /// </summary>
        /// <returns>Array of modules name.</returns>
        public string[] GetModulesName()
        {
            return (from module in this.Modules select module.Info.Name).ToArray();
        }
    }
}
