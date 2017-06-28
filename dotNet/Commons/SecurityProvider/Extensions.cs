using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.IdentityModel.Claims;
using Thinktecture.IdentityModel.Extensions;

namespace Makolab.SecurityProvider
{
    public static class Extensions
    {
        public static bool HasPermission(this IClaimsIdentity identity, string permission)
        {
            return identity.ClaimExists(FractusClaimTypes.Permission, permission);
        }
    }
}
