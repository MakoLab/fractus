using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.IdentityModel.Claims;
using Thinktecture.IdentityModel.Claims;
using Microsoft.IdentityModel.Web;

namespace Makolab.SecurityProvider
{
    public class AuthenticationHelper
    {
        public IClaimsPrincipal CreatePrincipal(string userId, string username, string authenticationMethod)
        {
            var claims = new List<Claim>
                    {
                        new Claim(ClaimTypes.Name, username),
                        new Claim(ClaimTypes.NameIdentifier, userId),
                        new Claim(ClaimTypes.AuthenticationMethod, authenticationMethod),
                        AuthenticationInstantClaim.Now
                    };

            var principal = ClaimsPrincipal.CreateFromIdentity(new ClaimsIdentity(claims));
            return FederatedAuthentication.ServiceConfiguration.ClaimsAuthenticationManager.Authenticate(string.Empty, principal);
        }
    }
}
