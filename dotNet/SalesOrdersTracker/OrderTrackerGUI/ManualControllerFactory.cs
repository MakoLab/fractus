using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OrderTrackerGUI.Controllers;
using System.Configuration;

namespace OrderTrackerGUI
{
    public class ManualControllerFactory : DefaultControllerFactory
    {
        private DatabaseRepository dbRepository;

        public ManualControllerFactory()
        {
            string connString = ConfigurationManager.ConnectionStrings["OrderTrackerDB"].ConnectionString;
            dbRepository = new DatabaseRepository(connString);
        }

        public override IController CreateController(System.Web.Routing.RequestContext requestContext, string controllerName)
        {
            return base.CreateController(requestContext, controllerName);
        }

        protected override IController GetControllerInstance(System.Web.Routing.RequestContext requestContext, Type controllerType)
        {
            Controller controller = null;
            ApplicationController appController = null;

            if (controllerType == typeof(HomeController)) appController = new HomeController(this.dbRepository);
            else if (controllerType == typeof(AccountController)) appController = new AccountController(this.dbRepository);     
            else controller = base.GetControllerInstance(requestContext, controllerType) as Controller;

            controller = appController;

            return controller; 
        }
    }
}
