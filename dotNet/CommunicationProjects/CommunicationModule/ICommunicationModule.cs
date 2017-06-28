namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Fractus.Commons;
    using Makolab.Fractus.Commons.DependencyInjection;

    /// <summary>
    /// Defines interface for communication module.
    /// </summary>
    public interface ICommunicationModule : IDisposable
    {
        /// <summary>
        /// Gets or sets the communication module configuration.
        /// </summary>
        /// <value>The configuration.</value>
        ICommunicationModuleConfiguration Configuration { get; set; }

        /// <summary>
        /// Gets or sets the communication module state.
        /// </summary>
        /// <value>The state.</value>
        CommunicationModuleState State { get; set; }

        ///// <summary>
        ///// Gets or sets the objects dependency injection container.
        ///// </summary>
        ///// <value>The objects dependency injection container.</value>
        //IDependencyContainer Container { get; set; }

        /// <summary>
        /// Starts the communication module.
        /// </summary>
        void StartModule();

        /// <summary>
        /// Stops the communication module.
        /// </summary>
        void StopModule();

        /// <summary>
        /// Restarts the communication module.
        /// </summary>
        void RestartModule();

        /// <summary>
        /// Refreshes the communication module configuration.
        /// </summary>
        void RefreshConfiguration();

        /// <summary>
        /// Binds the communication module dependencies.
        /// </summary>
        /// <param name="dependencies">The dependencies to bind.</param>
        /// <remarks>Dependencies are references to other communication modules.</remarks>
        void BindInternalDependencies(IDictionary<string, ICommunicationModule> dependencies);
    }
}
