using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    /// <summary>
    /// Plugin for <see cref="ConfigurationCoordinator"/> that executes additional logic for saving <see cref="Configuration"/> business objects that contains contractors group definition.
    /// </summary>
    internal class ContractorsGroupDefinitionPlugin : Plugin
    {
        /// <summary>
        /// <see cref="Configuration"/> business object that contains contractors group definition.
        /// </summary>
        private Configuration businessObject;

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorsGroupDefinitionPlugin"/> class.
        /// </summary>
        /// <param name="businessObject">Configuration object containing contractors group definition.</param>
        protected ContractorsGroupDefinitionPlugin(Configuration businessObject)
        {
            this.businessObject = businessObject;
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>ExecuteLogic</c> phase.
        /// </summary>
        /// <param name="businessObject">Main business object currently processed.</param>
        public override void OnExecuteLogic(IBusinessObject businessObject)
        {
            //generate id's for new groups
            var groupsWithoutId = from node in this.businessObject.Value.Descendants()
                                  where node.Name.LocalName == "group" && (node.Attribute("id") == null || node.Attribute("id").Value.Length == 0)
                                  select node;

            foreach (XElement group in groupsWithoutId)
            {
                if (group.Attribute("id") == null)
                    group.Add(new XAttribute("id", Guid.NewGuid().ToUpperString()));
                else
                    group.Attribute("id").Value = Guid.NewGuid().ToUpperString();
            }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>ValidateTransaction</c> phase.
        /// </summary>
        /// <param name="businessObject">Optional parameter.</param>
        public override void OnValidateTransaction(IBusinessObject businessObject)
        {
            var presentGroupsId = from node in ((Configuration)this.businessObject.AlternateVersion).Value.Descendants()
                                  where node.Name.LocalName == "group" && node.Attribute("id") != null && node.Attribute("id").Value.Length != 0
                                  select node.Attribute("id").Value;

            var modifiedGroupsId = from node in this.businessObject.Value.Descendants()
                                   where node.Name.LocalName == "group" && node.Attribute("id") != null && node.Attribute("id").Value.Length != 0
                                   select node.Attribute("id").Value;

            var deletedGroupsId = from grpId in presentGroupsId
                                  where modifiedGroupsId.Contains(grpId) == false
                                  select grpId;

            Configuration conf = (Configuration)businessObject;

            if (conf.Key == "contractors.group")
            {
                ContractorMapper mapper = DependencyContainerManager.Container.Get<ContractorMapper>();

                //check if any group that contains attached contractors has been deleted
                foreach (string group in deletedGroupsId)
                {
                    int count = mapper.GetContractorGroupMembershipsCount(new Guid(group));

                    if (count > 0)
                        throw new ClientException(ClientExceptionId.ContractorsGroupDeleteException, null, "count:" + count.ToString(CultureInfo.InvariantCulture));
                }
            }
            else if (conf.Key == "items.group")
            {
                ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();

                //check if any group that contains attached contractors has been deleted
                foreach (string group in deletedGroupsId)
                {
                    int count = mapper.GetItemGroupMembershipsCount(new Guid(group));

                    if (count > 0)
                        throw new ClientException(ClientExceptionId.ItemsGroupDeleteException, null, "count:" + count.ToString(CultureInfo.InvariantCulture));
                }
            }
        }

        /// <summary>
        /// Initializes plugin.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="coordinator">ConfigurationCoordinator to attach the plugin.</param>
        /// <param name="businessObject">Configuration business object.</param>
        public static void Initialize(CoordinatorPluginPhase pluginPhase, ConfigurationCoordinator coordinator, Configuration businessObject)
        {
            if (pluginPhase != CoordinatorPluginPhase.SaveObject)
                return;

            if (businessObject.Key == "contractors.group" || businessObject.Key == "items.group")
            {
                coordinator.Plugins.Add(new ContractorsGroupDefinitionPlugin(businessObject));
            }   
        }
    }
}
