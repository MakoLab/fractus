using System;
using System.Collections.Generic;
using System.Configuration;
using System.Xml;

namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    /// Configuration section handler for dependency injection container.
    /// </summary>
    public class ContainerSectionHandler : IConfigurationSectionHandler
    {
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
            DependencyContainersConfiguration config = new DependencyContainersConfiguration();
            List<ContainerInfo> containersInfo = new List<ContainerInfo>();
            foreach (XmlNode ci in section.SelectNodes("container"))
            {
                containersInfo.Add(new ContainerInfo()
                {
                    AssemblyName = ci.Attributes["type"].Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[1],
                    ContainerName = ci.Attributes["name"].Value,
                    TypeName = ci.Attributes["type"].Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[0]
                });
            }
            config.Containers = containersInfo;

            config.Bindings = new Dictionary<string, string>();
            foreach (XmlNode binding in section.SelectNodes("binding"))
            {
                config.Bindings.Add(binding.Attributes["assembly"].Value, binding.Attributes["container"].Value);
            }
            return config;
        }

        #endregion
    }
}
