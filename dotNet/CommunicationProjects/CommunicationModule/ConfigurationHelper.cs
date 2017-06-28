namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using System.Xml.Serialization;
    using System.IO;
    using System.Globalization;

    /// <summary>
    /// Utility class that manages communication modules configuration.
    /// </summary>
    public static class ConfigurationHelper
    {
        /// <summary>
        /// Namespace used in configuration serialization.
        /// </summary>
        internal static XmlSerializerNamespaces ConfigurationNamespaces = CreateEmptyNamespace();

        /// <summary>
        /// Setting for <see cref="XmlWriter"/> that omits xml declaration on serialization.
        /// </summary>
        private static XmlWriterSettings omitXmlDeclarationSettings = new XmlWriterSettings { OmitXmlDeclaration = true };

        /// <summary>
        /// Creates xml namespace with no name - empty.
        /// </summary>
        /// <returns>Empty namespace.</returns>
        private static XmlSerializerNamespaces CreateEmptyNamespace()
        {
                XmlSerializerNamespaces namespaces = new XmlSerializerNamespaces();
                namespaces.Add("", "");
                return namespaces;
        } 

        /// <summary>
        /// Creates communication module configuration object from xml.
        /// </summary>
        /// <typeparam name="T">Type of created configuration.</typeparam>
        /// <param name="configurationNode">Xml node with configuration.</param>
        /// <returns>Created configuration.</returns>
        public static T CreateConfigurationFromXml<T>(XmlNode configurationNode) where T : class
        {
            XmlSerializer serializer = new XmlSerializer(typeof(T));
            using (StringReader reader = new StringReader(configurationNode.OuterXml))
            {
                return serializer.Deserialize(reader) as T;                
            }
        }

        /// <summary>
        /// Creates xml from communication module configuration.
        /// </summary>
        /// <param name="configuration">Communication module configuration.</param>
        /// <returns>Xml with module configuration.</returns>
        public static string CreateXmlFromConfiguration(ICommunicationModuleConfiguration configuration)
        {
            // TODO -1 remove nodes (mostly attributes) that have default value
            XmlSerializer serializer = new XmlSerializer(configuration.GetType());
            StringWriter swr = null;
            XmlWriter xwr = null;
            try
            {
                swr = new StringWriter(CultureInfo.InvariantCulture);
                xwr = XmlWriter.Create(swr, omitXmlDeclarationSettings);
                serializer.Serialize(xwr, configuration, ConfigurationNamespaces);
                return swr.ToString();
            }
            finally
            {
                if (xwr != null) xwr.Close();
                if (swr != null) swr.Dispose();
            }          
        }
    }
}
