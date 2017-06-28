namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Configuration;
    using System.Collections;
    using System.Globalization;
    using Makolab.Commons.Communication;
    using Makolab.Fractus.Commons;
    using Makolab.Fractus.Commons.DependencyInjection;

    /// <summary>
    /// Creates and manages <see cref="CommunicationModule"/>s.
    /// </summary>
    ///<remarks>Creates modules defined in configuration file and manages modules lifecycle.</remarks>
    public class CommunicationController : MarshalByRefObject
    {
        /// <summary>
        /// Collection of known modules configuration tags.
        /// </summary>
        private static string[] knownModulesConfigurationName = {"executors", "databaseConnectors", "transmitters"};

        static CommunicationController()
        {
            IoC.Initialize();
        }

        /// <summary>
        /// Used to force static constructor to run.
        /// </summary>
        public static void Initialize() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationController"/> with <see cref="CommunicationModuleFactory"/>.
        /// </summary>
        public CommunicationController()
        {
            this.CommunicationModules = new List<ICommunicationModule>();
            this.ModuleFactory = new CommunicationModuleFactory();
        }

        /// <summary>
        /// Gets the collection of communication modules.
        /// </summary>
        public ICollection<ICommunicationModule> CommunicationModules { get; private set; }

        /// <summary>
        /// Gets or sets communication module factory used to create modules from configuration.
        /// </summary>
        public ICommunicationModuleFactory ModuleFactory { get; set; }

        /// <summary>
        /// Creates and starts communication modules.
        /// </summary>
        public void OnStartModule()
        {
            Logging.CommunicationModuleLogger.Strategy = Logging.LoggingStrategy.BuildFromConfigurationFile;
            Logging.CommunicationModuleLogger.LogMessage("Starting CommunicationModule.");

            ArrayList configs = CreateConfigurations();
            CreateCommunicationModules(configs);
            BindInternalDependencies();
            StartCommunicationModules();
        }

        /// <summary>
        /// Stop all created communication modules.
        /// </summary>
        public void OnStopModule()
        {
            Logging.CommunicationModuleLogger.LogMessage("Stopping CommunicationModule.");
            StopCommunicationModules();
            
            RunOnEachModule(mod => mod.Dispose());
        }

        /// <summary>
        /// Diagnose the state of communication module.
        /// </summary>
        /// <param name="request">The diagnostic request.</param>
        /// <returns>Response to diagnose request.</returns>
        public string OnDiagnose(string request)
        {
            return DiagnosticHelper.Diagnose(request, this);
        }

        /// <summary>
        /// Creates list communication modules configuration objects from configuration file.
        /// </summary>
        /// <returns>Collection of communication modules configurations.</returns>
        public ArrayList CreateConfigurations()
        {
            ArrayList configs = new ArrayList();
            foreach (string configurationName in knownModulesConfigurationName)
            {
                ArrayList cfgs = ConfigurationManager.GetSection(configurationName) as ArrayList;
                if (cfgs != null) configs.AddRange(cfgs);
            }

            return configs;
        }

        /// <summary>
        /// Creates communication modules from configuration.
        /// </summary>
        /// <param name="configs">Collection of communication modules configuration.</param>
        /// <exception cref="ConfigurationErrorsException">Module with same name is already defined.</exception>
        public void CreateCommunicationModules(ArrayList configs)
        {
            foreach (object config in configs)
            {
                ICommunicationModule module = this.ModuleFactory.CreateModule(config as ICommunicationModuleCreator);
                module.Configuration = config as ICommunicationModuleConfiguration;

                if (GetModule(module.Configuration.Name) != null)
                {
                    throw new ConfigurationErrorsException(String.Format(CultureInfo.InvariantCulture,
                                                    "Module with name '{0}' is already defined. Module name must be unique.", 
                                                    module.Configuration.Name));
                }

                this.CommunicationModules.Add(module);
            }
        }

        /// <summary>
        /// Initialize dependencies of all created modules.
        /// </summary>
        /// <remarks>
        /// Dependency is a reference to another module.
        /// </remarks>
        public void BindInternalDependencies()
        {
            foreach (ICommunicationModule module in this.CommunicationModules)
            {
                if (module.Configuration.InternalDependencies != null && module.Configuration.InternalDependencies.Count > 0)
                {
                    module.BindInternalDependencies(GenerateInternalDependencies(module.Configuration.InternalDependencies));
                }
            }
        }

        /// <summary>
        /// Creates collection of module dependancies from configuration.
        /// </summary>
        /// <param name="configDependencies">Configuration of module dependancies.</param>
        /// <returns>Collection of module dependencies as <see cref="Dictionary&lt;TKey, TValue&gt;"/> where depenandcy name is key and dependant module is value.</returns>
        /// <remarks>
        /// Returns a collection of modules that other module is dependent on from dependent module configuration.
        /// </remarks>
        /// <exception cref="ArgumentNullException"><i>configDependencies</i> is null reference.</exception>
        public Dictionary<string, ICommunicationModule> GenerateInternalDependencies(SerializableStringDictionary configDependencies)
        {
            if (configDependencies == null) throw new ArgumentNullException("configDependencies");

            Dictionary<string, ICommunicationModule> dependencies = new Dictionary<string, ICommunicationModule>();
            foreach (KeyValuePair<string, string> depInfo in configDependencies)
            {
                ICommunicationModule depModule = GetModule(depInfo.Value);
                if (depModule == null)
                {
                    throw new ConfigurationErrorsException(String.Format(CultureInfo.InvariantCulture,
                                                                         "Dependant module '{0}' not found.", 
                                                                         depInfo.Value));
                }

                dependencies.Add(depInfo.Key, depModule);
            }

            return dependencies;
        }

        /// <summary>
        /// Starts all communication modules with <see cref="ICommunicationModuleConfiguration.Autostart"/> set to <c>true</c>.
        /// </summary>
        public void StartCommunicationModules()
        {
            // first start database modules
            RunOnSelectedModules(mod => mod.Configuration.Autostart == true
                                    && mod.Configuration.ModuleType == CommunicationModuleType.DatabaseConnector, 
                                 mod => mod.StartModule());

            RunOnSelectedModules(mod => mod.Configuration.Autostart == true &&
                                 mod.Configuration.ModuleType != CommunicationModuleType.DatabaseConnector,
                                 mod => mod.StartModule());
        }

        /// <summary>
        /// Stops all communication modules.
        /// </summary>
        public void StopCommunicationModules()
        {
            RunOnSelectedModules(mod => mod.Configuration.ModuleType != CommunicationModuleType.DatabaseConnector, 
                                 mod => mod.StopModule());

            RunOnSelectedModules(mod => mod.Configuration.ModuleType == CommunicationModuleType.DatabaseConnector,
                                 mod => mod.StopModule());
        }

        /// <summary>
        /// Starts selected communication module.
        /// </summary>
        /// <param name="name">Communication module name.</param>
        /// <exception cref="ArgumentNullException"><i>name</i> is null reference.</exception>
        public void StartCommunicationModule(string name)
        {
            FindModule(name).StartModule();
        }


        /// <summary>
        /// Stops selected communication module.
        /// </summary>
        /// <param name="name">Communication module name.</param>
        /// <exception cref="ArgumentNullException"><i>name</i> is null reference.</exception>
        public void StopCommunicationModule(string name)
        {
            FindModule(name).StopModule();
        }

        /// <summary>
        /// Runs specified action on all modules.
        /// </summary>
        /// <param name="action">Action that can operate on ICommunicationModule.</param>
        /// <exception cref="ArgumentNullException"><i>action</i> is a null reference.</exception>
        public void RunOnEachModule(Action<ICommunicationModule> action)
        {
            this.CommunicationModules.ToList().ForEach(action);
        }

        /// <summary>
        /// Runs specified action on selected modules.
        /// </summary>
        /// <param name="predicate">Condition that selects communication modules.</param>
        /// <param name="action">Action that can operate on ICommunicationModule.</param>
        /// <exception cref="ArgumentNullException"><i>predicate</i> or <i>action</i> is a null reference.</exception>
        public void RunOnSelectedModules(Func<ICommunicationModule, bool> predicate, Action<ICommunicationModule> action)
        {
            if (predicate == null) throw new ArgumentNullException("predicate");

            if (action == null) throw new ArgumentNullException("action");

            var l = this.CommunicationModules.Where(predicate).ToList();
            l.ForEach(action);
        }

        /// <summary>
        /// Returns module with specified name 
        /// or throw <see cref="Exceptions.ModuleNotFoundException"/> exception when module is not found.
        /// </summary>
        /// <param name="name">Communication module name.</param>
        /// <returns>Communication module.</returns>
        /// <exception cref="Exceptions.ModuleNotFoundException">Module with specified name does not exist.</exception>
        /// <exception cref="ArgumentNullException"><i>name</i> is null reference.</exception>
        public ICommunicationModule FindModule(string name)
        {
            ICommunicationModule mod = GetModule(name);
            if (mod == null) throw new Exceptions.ModuleNotFoundException("Module not found.", name);

            return mod;
        }

        /// <summary>
        /// Returns module with specified name or null when module is not found.
        /// </summary>
        /// <param name="name">Communication module name.</param>
        /// <returns>Communication module.</returns>
        /// <exception cref="ArgumentNullException"><i>name</i> is null reference.</exception>
        public ICommunicationModule GetModule(string name)
        {
            if (name == null) throw new ArgumentNullException("name");

            return (from module in CommunicationModules where module.Configuration.Name == name select module)
                        .SingleOrDefault<ICommunicationModule>();
        }
    }
}
