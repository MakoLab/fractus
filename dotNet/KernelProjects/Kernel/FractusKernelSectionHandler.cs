using System;
using System.Configuration;
using System.Globalization;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel
{
    /// <summary>
    /// Kernel configuration section handler in app.config.
    /// </summary>
    public class FractusKernelSectionHandler : IConfigurationSectionHandler
    {
        /// <summary>
        /// Gets or sets the configuration xml.
        /// </summary>
        /// <value>Configuration xml.</value>
        private XElement xml { get; set; }

        /// <summary>
        /// Gets the session timeout.
        /// </summary>
        public int SessionTimeout
        {
            get
            {
                if (xml.Element("session") != null && xml.Element("session").Attribute("timeout") != null)
                    return Convert.ToInt32(xml.Element("session").Attribute("timeout").Value, CultureInfo.InvariantCulture);
                else
                    return 30;
            }
        }

        /// <summary>
        /// Gets a flag indicating whether every transaction should be rollbacked.
        /// </summary>
        public bool ForceRollbackTransaction
        {
            get
            {
                if (xml.Element("transaction") != null && xml.Element("transaction").Attribute("forceRollback") != null)
                    return Convert.ToBoolean(xml.Element("transaction").Attribute("forceRollback").Value, CultureInfo.InvariantCulture);
                else
                    return false;
            }
        }

        /// <summary>
        /// Gets a flag indicating whether every communication to the database should be logged to file.
        /// </summary>
        public bool LogDatabaseCommunication
        {
            get
            {
                if (xml.Element("database") != null && xml.Element("database").Attribute("logCommunication") != null)
                    return Convert.ToBoolean(xml.Element("database").Attribute("logCommunication").Value, CultureInfo.InvariantCulture);
                else
                    return false;
            }
        }

        public bool LogHandledExceptions
        {
            get
            {
                if (xml.Element("kernel") != null && xml.Element("kernel").Attribute("logHandledExceptions") != null)
                    return Convert.ToBoolean(xml.Element("kernel").Attribute("logHandledExceptions").Value, CultureInfo.InvariantCulture);
                else
                    return false;
            }
        }

        public int ConnectionLimit
        {
            get
            {
                if (xml.Element("database") != null && xml.Element("database").Attribute("connectionLimit") != null)
                    return Convert.ToInt32(xml.Element("database").Attribute("connectionLimit").Value, CultureInfo.InvariantCulture);
                else
                    return 10;
            }
        }

        /// <summary>
        /// Gets path to a file where communication to the database should be logged.
        /// </summary>
        public string DatabaseCommunicationLogPath
        {
            get
            {
                if (xml.Element("database") != null && xml.Element("database").Attribute("logPath") != null)
                    return xml.Element("database").Attribute("logPath").Value;
                else
                    return null;
            }
        }

        public string PrintServiceAddress
        {
            get
            {
                if (xml.Element("kernel") != null && xml.Element("kernel").Attribute("printServiceAddress") != null)
                    return xml.Element("kernel").Attribute("printServiceAddress").Value;
                else
                    return null;
            }
        }

        public int CatalogueLimit
        {
            get
            {
                if (xml.Element("kernel") != null && xml.Element("kernel").Attribute("catalogueLimit") != null)
                    return Convert.ToInt32(xml.Element("kernel").Attribute("catalogueLimit").Value, CultureInfo.InvariantCulture);
                else
                    return 0;
            }
        }

        /// <summary>
        /// Gets a flag indicating whether kernel should work in desktop mode.
        /// </summary>
        public bool DesktopMode
        {
            get
            {
                if (xml.Element("kernel") != null && xml.Element("kernel").Attribute("mode") != null &&
                    xml.Element("kernel").Attribute("mode").Value.ToUpperInvariant() == "DESKTOP")
                    return true;
                else
                    return false;
            }
        }

        public bool ExtendedJournal
        {
            get
            {
                if (xml.Element("kernel") != null && xml.Element("kernel").Attribute("journal") != null &&
                    xml.Element("kernel").Attribute("journal").Value.ToUpperInvariant() == "EXTENDED")
                    return true;
                else
                    return false;
            }
        }

        public string SessionType
        {
            get
            {
                if (xml.Element("session") != null && xml.Element("session").Attribute("type") != null)
                    return xml.Element("session").Attribute("type").Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[0];
                else
                    return null;              
            }
        }

        public string SessionAssembly
        {
            get
            {
                if (xml.Element("session") != null && xml.Element("session").Attribute("type") != null)
                    return xml.Element("session").Attribute("type").Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[1];
                else
                    return null;
            }
        }

        public string SessionIdProviderType
        {
            get
            {
                if (xml.Element("session") != null && xml.Element("session").Attribute("providerType") != null)
                    return xml.Element("session").Attribute("providerType").Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[0];
                else
                    return null;
            }
        }

        public string SessionIdProviderAssembly
        {
            get
            {
                if (xml.Element("session") != null && xml.Element("session").Attribute("providerType") != null)
                    return xml.Element("session").Attribute("providerType").Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[1];
                else
                    return null;
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="FractusKernelSectionHandler"/> class.
        /// </summary>
        public FractusKernelSectionHandler()
        {
        }

        #region IConfigurationSectionHandler Members

        /// <summary>
        /// Creates a configuration section handler.
        /// </summary>
        /// <param name="parent">Parent object.</param>
        /// <param name="configContext">Configuration context object.</param>
        /// <param name="section">Section XML node.</param>
        /// <returns>The created section handler object.</returns>
        public object Create(object parent, object configContext, System.Xml.XmlNode section)
        {
            this.xml = XElement.Parse(section.OuterXml);
            return this;
        }

        #endregion
    }
}
