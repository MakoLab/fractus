using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Mvc;
using System.Net;
using OrderTrackerGUI.Controllers;
using System.Web.Routing;

namespace OrderTrackerGUI
{
    public class LoginRequiredAttribute : FilterAttribute, IAuthorizationFilter
    {
        #region IAuthorizationFilter Members

        public void OnAuthorization(AuthorizationContext filterContext)
        {
            var session = filterContext.HttpContext.Session[SessionKeys.CurrentUser];
            var cookie = filterContext.HttpContext.Request.Cookies[SessionKeys.SessionId];
            
            if (session != null && cookie != null) return;

            if (cookie == null)
            {
                filterContext.Controller.TempData["Message"] = "Ta funkcjonalność dostępna jest po zalogowaniu.";
            }
            else if (session == null)
            {
                filterContext.Controller.TempData["Message"] = "Sesja wygasła, zaloguj się ponownie."; 
            }
            filterContext.Result = new RedirectToRouteResult(new RouteValueDictionary(new { controller = "Account", action = "Login" })); //new RedirectResult("http://localhost:56500/Account/Login"); 
        }

        #endregion
    }
}
