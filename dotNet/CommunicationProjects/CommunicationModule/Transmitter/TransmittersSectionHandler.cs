namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Configuration;
    using System.Xml;
    using System.Collections;

    /// <summary>
    /// Configuration section handler for Transmitters module.
    /// </summary>
    [Serializable]
    public class TransmittersSectionHandler : GenericSectionHandler<TransmitterConfiguration>
    {
        /// <summary>
        /// Name of Transmitters configuration root element from configuration xml.
        /// </summary>
        private const string CONFIG_TAG_NAME = "transmitter";

        /// <summary>
        /// Initializes a new instance of the <see cref="TransmittersSectionHandler"/> class.
        /// </summary>
        public TransmittersSectionHandler() : base(CONFIG_TAG_NAME) { }

        /// <summary>
        /// Validates the Transmitters configuration.
        /// </summary>
        /// <param name="configuration">The Transmitters configuration that is validated.</param>
        protected override void ValidateConfiguration(TransmitterConfiguration configuration)
        {
            if (configuration.ModuleType != CommunicationModuleType.Transmitter)
                throw new ConfigurationErrorsException("Invalid configuration type.");
            if (configuration.InternalDependencies.ContainsKey("Database") == false)
                throw new ConfigurationErrorsException("DatabaseConnector not specified.");
        }
    }
}
