using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net;
using System.Text;
using OrderTrackerGUI;
using OrderTrackerGUI.Models;

namespace OrderTrackerGUI.Controllers
{
    public abstract class ApplicationController : Controller
    {
        internal DatabaseRepository data;

        public ApplicationController(DatabaseRepository repositories)
        {
            this.data = repositories;
        }

        /// <summary>
        /// Gets or sets the current user using Session.
        /// </summary>
        /// <value>The current user.</value>
        public User CurrentUser
        {
            get
            {
                return Session[SessionKeys.CurrentUser] as User;
            }
            set
            {
                Session.Add(SessionKeys.CurrentUser, value);
            }
        }
   
    }
}
