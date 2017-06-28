namespace Makolab.Fractus.Communication.Executor
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Configuration;
    using System.Xml;
    using System.Collections;

    /// <summary>
    /// Configuration section handler for Executor module.
    /// </summary>
    [Serializable]
    public class ExecutorsSectionHandler : GenericSectionHandler<ExecutorConfiguration>
    {
        /// <summary>
        /// Name of Executor configuration root element from configuration xml.
        /// </summary>
        private const string CONFIG_TAG_NAME = "executor";

        /// <summary>
        /// Initializes a new instance of the <see cref="ExecutorsSectionHandler"/> class.
        /// </summary>
        public ExecutorsSectionHandler() : base(CONFIG_TAG_NAME) { }

        /// <summary>
        /// Validates the Executor configuration.
        /// </summary>
        /// <param name="configuration">The Executor configuration that is validated.</param>
        protected override void ValidateConfiguration(ExecutorConfiguration configuration)
        {
            base.ValidateConfiguration(configuration);

            if (configuration.ModuleType != CommunicationModuleType.Executor) throw new ConfigurationErrorsException("Invalid configuration type.");
        }
    }
}
