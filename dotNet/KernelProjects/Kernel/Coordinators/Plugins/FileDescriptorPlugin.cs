using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Repository;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    /// <summary>
    /// Class that gets modificationDate from saved <see cref="FileDescriptor"/> and adds it to the return Xml.
    /// </summary>
    internal class FileDescriptorPlugin : Plugin
    {
        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>AfterSave</c> phase.
        /// </summary>
        /// <param name="operationsList">The operations list.</param>
        /// <param name="returnXml">Xml that will be returned to the client.</param>
        public override void OnAfterSave(XDocument operationsList, XDocument returnXml)
        {
            if(operationsList.Root.Element("fileDescriptor") != null)
            {
                var entries = from node in operationsList.Root.Element("fileDescriptor").Elements()
                              where node.Attribute("action").Value == "insert" || node.Attribute("action").Value == "update"
                              select node;

                if(entries.Count() > 0)
                    returnXml.Root.Add(new XElement("modificationDate", entries.ElementAt(0).Element("modificationDate").Value));
            }
        }

        /// <summary>
        /// Initializes plugin.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="coordinator">Coordinator to attach the plugin.</param>
        public static void Initialize(CoordinatorPluginPhase pluginPhase, RepositoryCoordinator coordinator)
        {
            if (pluginPhase != CoordinatorPluginPhase.SaveObject)
                return;

            coordinator.Plugins.Add(new FileDescriptorPlugin());
        }
    }
}
