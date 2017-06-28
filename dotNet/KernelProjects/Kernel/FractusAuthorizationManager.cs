using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.IdentityModel.Claims;
using Makolab.SecurityProvider;

namespace Makolab.Fractus.Kernel
{
    public class FractusAuthorizationManager : ClaimsAuthorizationManager
    {
        public override bool CheckAccess(AuthorizationContext context)
        {
            var requiredPermission = context.Resource.First().Value;

            if (context.Action.Any() && String.IsNullOrEmpty(context.Action.First().Value) == false)
            {
                requiredPermission = String.Concat(requiredPermission, ".", context.Action.First().Value);
            }

            return context.Principal.Identities[0].HasPermission(requiredPermission);
        }
    }
}
