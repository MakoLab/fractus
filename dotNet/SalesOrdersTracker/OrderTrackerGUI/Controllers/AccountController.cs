using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;
using OrderTrackerGUI.Models;

namespace OrderTrackerGUI.Controllers
{

    [HandleError]
    public class AccountController : ApplicationController
    {
        public AccountController(DatabaseRepository repositories)
            : base(repositories)
        {
        }

        [HttpGet]
        public ActionResult Login()
        {
            if (TempData["Message"] != null) ModelState.AddModelError("", TempData["Message"].ToString());
            return View();
        }

        [HttpPost]
        public ActionResult Login(User model)
        {
            try
            {
                if (ModelState.IsValid)
                {
					User loggedUser = this.data.Login(model);

                    if (loggedUser == null)
                    {
                        throw new ModelValidationException("Niepoprawny login lub hasło albo brak obsługi coockies w przeglądarce.");
                    }
                    else
                    {
                        this.CurrentUser = loggedUser;
                        return RedirectToAction("Index","Home");
                    }
                }
                else
                {
                    return View(model);
                }
            }
            catch(FormatException e)
            {
                ModelState.AddModelError("", e.Message);
                return View(model);            
            }
            catch (ModelValidationException e)
            {
                ModelState.AddModelError("", e.Message);
                return View(model);
            }
        }

        public ActionResult LogOut()
        {
            Session.Clear();
            Session.Abandon();

            Response.Cookies.Add(new HttpCookie(SessionKeys.SessionId) { Expires = DateTime.Now.AddDays(-1) });

            return RedirectToAction("Login");
        }
    }
}
