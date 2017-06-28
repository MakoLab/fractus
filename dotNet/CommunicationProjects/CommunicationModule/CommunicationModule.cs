namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Reflection;
    using Makolab.Fractus.Commons;
    using Makolab.Fractus.Commons.DependencyInjection;

    /// <summary>
    /// Communication module base class.
    /// </summary>
    public abstract class CommunicationModule : ICommunicationModule
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationModule"/> class.
        /// </summary>
        protected CommunicationModule()
        {
            this.State = CommunicationModuleState.Stopped;
        } 
        #endregion

        #region ICommunicationModule Members

        /// <summary>
        /// Gets or sets module configuration.
        /// </summary>
        public abstract ICommunicationModuleConfiguration Configuration { get; set; }

        /// <summary>
        /// Gets or sets module state.
        /// </summary>
        public CommunicationModuleState State { get; set; }

        ///// <summary>
        ///// Gets or sets the objects dependency injection container.
        ///// </summary>
        ///// <value>The objects dependency injection container.</value>
        //public IDependencyContainer Container { get; set; }
        
        /// <summary>
        /// Stops communication module.
        /// </summary>
        public abstract void StopModule();


        /// <summary>
        /// Starts communication module.
        /// </summary>
        public virtual void StartModule()
        {
            if (this.Configuration == null) throw new InvalidOperationException("Unable to start communication module without defined configuration.");
        }

        /// <summary>
        /// Restarts communication module.
        /// </summary>
        public virtual void RestartModule()
        {
            StopModule();
            StartModule();
        }

        /// <summary>
        /// Reloads communication module configuration.
        /// </summary>
        public virtual void RefreshConfiguration()
        {
            StopModule();
            StartModule();
        }

        /// <summary>
        /// Initialize communication module dependencies.
        /// </summary>
        /// <param name="dependencies">Dependencies collection.</param>
        public virtual void BindInternalDependencies(IDictionary<string, ICommunicationModule> dependencies) 
        {
            Type moduleType = this.GetType();
            foreach (KeyValuePair<string, ICommunicationModule> depencency in dependencies)
            {
                PropertyInfo depProp = moduleType.GetProperty(depencency.Key);
                if(depProp != null) depProp.SetValue(this, depencency.Value, null);
            }
        }

        /// <summary>
        /// Releases all resources used by the <see cref="CommunicationModule"/>.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="CommunicationModule"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        { 
        }

        #endregion
    }
}
