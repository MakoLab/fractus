namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Collections;

    /// <summary>
    /// Defines interface for communication module configuration object. 
    /// </summary>
    public interface ICommunicationModuleConfiguration
    {
        /// <summary>
        /// Gets or sets the communication module name.
        /// </summary>
        /// <value>The communication module name.</value>
        string Name { get; set; }

        /// <summary>
        /// Gets or sets the type of the module.
        /// </summary>
        /// <value>The type of the module.</value>
        CommunicationModuleType ModuleType { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether to start communication module automatically
        /// </summary>
        /// <value><c>true</c> if autostart; otherwise, <c>false</c>.</value>
        bool Autostart { get; set; }

        /// <summary>
        /// Gets the communication module dependencies.
        /// </summary>
        /// <value>The communication module dependencies.</value>
        SerializableStringDictionary InternalDependencies { get; }

        /// <summary>
        /// Sets the default configuration values.
        /// </summary>
        void SetDefaultValues();
    }
}
