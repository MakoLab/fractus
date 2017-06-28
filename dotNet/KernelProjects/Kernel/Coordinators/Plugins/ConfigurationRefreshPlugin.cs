using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    /// <summary>
    /// Plugin for <see cref="ConfigurationCoordinator"/> that watches whether the coordinator is saving templates and
    /// if it detects such a change it fires procedure that updates templates' version.
    /// </summary>
    internal class ConfigurationRefreshPlugin : Plugin
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ConfigurationRefreshPlugin"/> class.
        /// </summary>
        protected ConfigurationRefreshPlugin()
        {
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>AfterSave</c> phase.
        /// </summary>
        /// <param name="operationsList">The operations list.</param>
        /// <param name="returnXml">Xml that will be returned to the client.</param>
        public override void OnAfterSave(XDocument operationsList, XDocument returnXml)
        {
            if (operationsList.Root.HasElements)
                ConfigurationMapper.Instance.UpdateConfigurationVersion();
        }

        /// <summary>
        /// Initializes plugin.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="coordinator">ConfigurationCoordinator to attach the plugin.</param>
        /// <param name="businessObject">Configuration business object.</param>
        public static void Initialize(CoordinatorPluginPhase pluginPhase, ConfigurationCoordinator coordinator, Configuration businessObject)
        {
            if (pluginPhase == CoordinatorPluginPhase.SaveObject)
            {
                if (businessObject.Key.StartsWith("templates.", StringComparison.Ordinal))
                    coordinator.Plugins.Add(new ConfigurationRefreshPlugin());
            }
        }
    }
}
