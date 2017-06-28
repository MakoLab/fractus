namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Configuration;
    using System.Xml;
    using System.Collections;

    /// <summary>
    /// Main configuration of the communication module.
    /// </summary>
    [Serializable]
    public class ControllerSectionHandler : GenericSectionHandler<ControllerConfiguration>
    {
        /// <summary>
        /// Name of Controller configuration root element from configuration xml.
        /// </summary>
        private const string CONFIG_TAG_NAME = "controller";

        /// <summary>
        /// Initializes a new instance of the <see cref="ControllerSectionHandler"/> class.
        /// </summary>
        public ControllerSectionHandler() : base(CONFIG_TAG_NAME) { }

        /// <summary>
        /// Validates the Controller configuration.
        /// </summary>
        /// <param name="configuration">The Controller configuration that is validated.</param>
        protected override void ValidateConfiguration(ControllerConfiguration configuration)
        {
            base.ValidateConfiguration(configuration);

            if (configuration.ModuleType != CommunicationModuleType.Other) throw new ConfigurationErrorsException("Invalid configuration type.");
            if (String.IsNullOrEmpty(configuration.ProgramSpecificAssembly)) throw new ConfigurationErrorsException("ProgramSpecificAssembly not specified.");
        }
    }
}
