using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using TrackerDataAccessLayer.Events;
using System.Xml.Linq;
using System.IO;

namespace OrderTrackerGUI
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                "Default", // Route name
                "{controller}/{action}/{id}", // URL with parameters
                new { controller = "Home", action = "Index", id = UrlParameter.Optional } // Parameter defaults
            );
            routes.MapRoute("List", "list", new { controller = "Home", action = "List" });
            routes.MapRoute("Order", "order", new { controller = "Home", action = "Order" });
            routes.MapRoute("Login", "login", new { controller = "Account", action = "Login" });
        }

        protected void Application_Start()
        {
            ControllerBuilder.Current.SetControllerFactory(new ManualControllerFactory());

            AreaRegistration.RegisterAllAreas();

            RegisterRoutes(RouteTable.Routes);
        }
    }
}