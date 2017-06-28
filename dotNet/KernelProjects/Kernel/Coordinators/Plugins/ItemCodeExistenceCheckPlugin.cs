using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    internal class ItemCodeExistenceCheckPlugin : Plugin
    {
        public override void OnValidateTransaction(IBusinessObject businessObject)
        {
            ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();
            bool b = mapper.CheckItemCodeExistence(businessObject.FullXml);

            if (b)
                throw new ClientException(ClientExceptionId.ItemCodeAlreadyExists);
        }

        public static void Initialize(CoordinatorPluginPhase pluginPhase, ItemCoordinator coordinator)
        {
            if (pluginPhase != CoordinatorPluginPhase.SaveObject)
                return;

            coordinator.Plugins.Add(new ItemCodeExistenceCheckPlugin());
        }
    }
}
