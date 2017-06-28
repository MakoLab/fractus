using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OrderTrackerGUI.Models;
using TrackerDataAccessLayer;
using System.Data.Entity;
using System.Web.Caching;

namespace OrderTrackerGUI.Controllers
{
    [HandleError]
    public class HomeController : ApplicationController
    {
        public HomeController(DatabaseRepository repositories)
            : base(repositories)
        {
        }

		[LoginRequired]
		public ActionResult Index()
        {
			if (this.CurrentUser != null)
			{
				OrderList list = (OrderList)HttpContext.Cache[CurrentUser.Id + SessionKeys.List];
				if (list == null)
				{
					list = new OrderList()
					{
						Orders = TrackerEntitiesManager.Instance.GetSalesOrdersList(this.CurrentUser.Id),
						Contractor = TrackerEntitiesManager.Instance.GetContractor(this.CurrentUser.Id)
					};
					//HttpContext.Cache.Add(CurrentUser.Id + SessionKeys.List, list, null
					//    , Cache.NoAbsoluteExpiration, TimeSpan.FromSeconds(30), CacheItemPriority.Default, null);
				}
				return View("List", list);
			}
			else
			{
				TempData["Message"] = null;
				return RedirectToAction("Login", "Account");
			}
        }

        public ActionResult List(OrderList model)
        {
            return View(model);
        }

        [LoginRequired]
        public ActionResult Order(Guid id)
        {
			var order = TrackerEntitiesManager.Instance.CreateNewSalesOrderSnapshot(id);
			TrackerEntitiesManager.Instance.CreateEventsList(order);//Aby ustawiły się opisy
			order.Items = TrackerEntitiesManager.Instance.GetSalesOrderItems(id);
			return View(order);
        }
    }
}
