using System;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    internal class ApplicationUserPlugin : Plugin
    {
        public override void OnExecuteLogic(IBusinessObject businessObject)
        {
            if (businessObject.AlternateVersion != null)
            {
                ApplicationUser updatedUser = (ApplicationUser)businessObject;
                ApplicationUser alternateUser = (ApplicationUser)businessObject.AlternateVersion;

                if (updatedUser.Password == null)
                    updatedUser.Password = alternateUser.Password;
                else if (updatedUser.Password == String.Empty)
                    updatedUser.Password = null;

                updatedUser.UpdateStatus(true);
            }
        }

        public static void Initialize(CoordinatorPluginPhase pluginPhase, ContractorCoordinator coordinator, Contractor businessObject)
        {
            if (pluginPhase == CoordinatorPluginPhase.SaveObject && coordinator != null && businessObject.BOType == BusinessObjectType.ApplicationUser)
                coordinator.Plugins.Add(new ApplicationUserPlugin());
        }
    }
}
