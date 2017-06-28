using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.IdentityModel.Claims;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.SecurityProvider;

namespace Makolab.Fractus.Kernel
{
    public class FractusClaimsTransformer : ClaimsAuthenticationManager
    {
        public override IClaimsPrincipal Authenticate(string resourceName, IClaimsPrincipal incomingPrincipal)
        {
            if (!incomingPrincipal.Identity.IsAuthenticated)
            {
                return base.Authenticate(resourceName, incomingPrincipal);
            }

            
            //Add permission claimes to identity
            
            if (SessionManager.User != null)
            {
                using (ConfigurationCoordinator coordinator = new ConfigurationCoordinator(false, false))
                {
                    //SessionManager.VolatileElements.ClientCommand = "GetConfiguration";
                    var profile = coordinator.GetConfiguration("permissions.profiles." + SessionManager.User.PermissionProfile);

                    foreach (var permission in profile.Root.Element("configValue").Element("profile").Element("permissions").Elements("permission"))
                    {
                        var claim = new Claim(FractusClaimTypes.Permission, permission.Attribute("key").Value);
                        incomingPrincipal.Identities[0].Claims.Add(claim);
                    }
                }
            }

            return incomingPrincipal;
        }
    }
}
