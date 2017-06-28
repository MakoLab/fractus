namespace Makolab.Fractus.Communication.DatabaseConnector
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Serialization;

    /// <summary>
    /// Configuration of DatabaseConnector module.
    /// </summary>
    [XmlRoot(ElementName = "databaseConnector")]
    public sealed class DatabaseConnectorConfiguration : CommunicationModuleConfiguration, ICommunicationModuleCreator
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="DatabaseConnectorConfiguration"/> class.
        /// </summary>
        public DatabaseConnectorConfiguration()
        {
            SetDefaultValues();
        } 
        #endregion

        #region Configuration Properties
        /// <summary>
        /// Gets or sets the connection string.
        /// </summary>
        /// <value>The connection string.</value>
        [XmlAttribute]
        public string ConnectionString { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether connection is keep opened all the time.
        /// </summary>
        /// <value><c>true</c> if connection is never closed; otherwise, <c>false</c>.</value>
        [XmlAttribute]
        public bool KeepOpened { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether access to database connection object should be synchronized.
        /// </summary>
        /// <value><c>true</c> if database connection object should be synchronized; otherwise, <c>false</c>.</value>
        [XmlAttribute]
        public bool BlockConnection { get; set; }
        #endregion

        #region CommunicationModuleConfiguration Members
        /// <summary>
        /// Sets DatabaseConnector configuration default values.
        /// </summary>
        public override void SetDefaultValues()
        {
            this.KeepOpened = true;
            ModuleType = CommunicationModuleType.DatabaseConnector;
            this.BlockConnection = true;
        } 
        #endregion

        #region ICommunicationModuleCreator Members

        /// <summary>
        /// Creates new DatabaseConnector module.
        /// </summary>
        /// <returns>Created DatabaseConnector module.</returns>
        public ICommunicationModule CreateModule()
        {
            return new DatabaseConnectorManager();
        }

        #endregion
    }
}
