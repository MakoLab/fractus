using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Xml;
using System.Globalization;

namespace Makolab.Fractus.Communication.ServiceMonitor
{
    /// <summary>
    /// Handles the access to monitor configuration section.
    /// </summary>
    public class MonitorSectionHandler : IConfigurationSectionHandler
    {
        internal static double? interval;

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
            if (section.Attributes["interval"] != null) MonitorSectionHandler.interval = Double.Parse(section.Attributes["interval"].Value, CultureInfo.InvariantCulture);

            List<WindowsService> monitoredServices = new List<WindowsService>();

            foreach (XmlNode serviceNode in section.SelectNodes("service"))
            {
                if (serviceNode.Attributes["name"] == null) throw new ConfigurationErrorsException("name argument must be set.");
                if (serviceNode.Attributes["interval"] == null) throw new ConfigurationErrorsException("interval argument must be set.");
                WindowsService service = new WindowsService(serviceNode.Attributes["name"].Value, Double.Parse(serviceNode.Attributes["interval"].Value, CultureInfo.InvariantCulture));
                monitoredServices.Add(service);
            }

            return monitoredServices;
        }

        #endregion
    }
}
