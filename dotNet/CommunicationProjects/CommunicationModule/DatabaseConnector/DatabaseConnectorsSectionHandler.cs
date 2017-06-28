namespace Makolab.Fractus.Communication.DatabaseConnector
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Configuration;
    using System.Xml;
    using System.Collections;

    /// <summary>
    /// Configuration section handler for DatabaseConnector module.
    /// </summary>
    [Serializable]
    public class DatabaseConnectorsSectionHandler : GenericSectionHandler<DatabaseConnectorConfiguration>
    {
        /// <summary>
        /// Name of DatabaseConnector configuration root element from configuration xml.
        /// </summary>
        private const string CONFIG_TAG_NAME = "databaseConnector";

        /// <summary>
        /// Initializes a new instance of the <see cref="DatabaseConnectorsSectionHandler"/> class.
        /// </summary>
        public DatabaseConnectorsSectionHandler() : base(CONFIG_TAG_NAME) { }

        /// <summary>
        /// Validates the DatabaseConnector configuration.
        /// </summary>
        /// <param name="configuration">The DatabaseConnector configuration that is validated.</param>
        protected override void ValidateConfiguration(DatabaseConnectorConfiguration configuration)
        {
            base.ValidateConfiguration(configuration);

            if (configuration.ModuleType != CommunicationModuleType.DatabaseConnector) throw new ConfigurationErrorsException("Invalid configuration type.");

            if (String.IsNullOrEmpty(configuration.ConnectionString)) throw new ConfigurationErrorsException("ConnectionString not specified.");
        }
    }
}
