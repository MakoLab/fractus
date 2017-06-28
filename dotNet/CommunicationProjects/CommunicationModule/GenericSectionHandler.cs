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
    /// Base class of configuration section handlers.
    /// </summary>
    /// <typeparam name="T">Type of communication module configuration that is processed by handler.</typeparam>
    [Serializable]
    public abstract class GenericSectionHandler<T> : IConfigurationSectionHandler where T : class, ICommunicationModuleConfiguration
    {
        /// <summary>
        /// Name of module's configuration section root element.
        /// </summary>
        protected readonly string ConfigTagName;

        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="GenericSectionHandler&lt;T&gt;"/> class.
        /// </summary>
        /// <param name="configurationTagName">Name of module's configuration section root element.</param>
        protected GenericSectionHandler(string configurationTagName)
        {
            this.ConfigTagName = configurationTagName;
        } 
        #endregion

        #region IConfigurationSectionHandler Members

        /// <summary>
        /// Creates a configuration object.
        /// </summary>
        /// <param name="parent">Parent object.</param>
        /// <param name="configContext">Context object.</param>
        /// <param name="section">XML node with configuration section.</param>
        /// <returns>The created configuration object.</returns>
        public virtual object Create(object parent, object configContext, System.Xml.XmlNode section)
        {
            XmlNodeList configNodes = section.SelectNodes(this.ConfigTagName);
            ArrayList moduleConfigurations = new ArrayList(configNodes.Count);
            foreach (XmlNode configNode in configNodes)
            {
                T config = ConfigurationHelper.CreateConfigurationFromXml<T>(configNode);
                if (config == null) throw new ConfigurationErrorsException("Unable to create configuration.", configNode);

                ValidateConfiguration(config);

                moduleConfigurations.Add(config);
            }

            return moduleConfigurations;
        }
        #endregion


        /// <summary>
        /// Validates the configuration.
        /// </summary>
        /// <param name="configuration">The configuration that is validated.</param>
        protected virtual void ValidateConfiguration(T configuration)
        {
            if (String.IsNullOrEmpty(configuration.Name)) throw new ConfigurationErrorsException("Name not specified.");          
        }
    }
}
