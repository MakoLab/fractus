using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Globalization;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Handles the access to service configuration section.
    /// </summary>
    public class ServiceSectionHandler : IConfigurationSectionHandler
    {
        /// <summary>
        /// Gets or sets the name of the HostingService service.
        /// </summary>
        /// <value>The name of the service.</value>
        public string ServiceName { get; set; }

        /// <summary>
        /// Gets or sets the module unload timeout.
        /// </summary>
        /// <value>The module unload timeout.</value>
        public int ModuleUnloadTimeout { get; set; }

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
            ServiceName = section.Attributes["Name"].Value;
            ModuleUnloadTimeout = Convert.ToInt32(section.Attributes["ModuleUnloadTimeout"].Value, CultureInfo.InvariantCulture);
            return this;
        }

        #endregion
    }
}
