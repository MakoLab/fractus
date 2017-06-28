using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Globalization;

namespace Makolab.Fractus.Printing
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
            return this;
        }

        #endregion
    }
}
