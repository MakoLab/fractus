using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    internal class ContractorCodeExistenceCheckPlugin : Plugin
    {
        public override void OnValidateTransaction(IBusinessObject businessObject)
        {
            ContractorMapper mapper = DependencyContainerManager.Container.Get<ContractorMapper>();
            bool b = mapper.CheckContractorCodeExistence(businessObject.FullXml);

            if (b)
                throw new ClientException(ClientExceptionId.ContractorCodeAlreadyExists);
        }

        public static void Initialize(CoordinatorPluginPhase pluginPhase, ContractorCoordinator coordinator)
        {
            if (pluginPhase != CoordinatorPluginPhase.SaveObject)
                return;

            coordinator.Plugins.Add(new ContractorCodeExistenceCheckPlugin());
        }
    }
}
