using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using System.Globalization;
using TrackerDataAccessLayer;

namespace OrderTrackerGUI.Models
{
    public class OrderList
    {
		[DisplayName("Zamówienia")]
		public List<SalesOrderSnapshot> Orders { get; set; }
		[DisplayName("Dane Klienta")]
		public Contractor Contractor { get; set; }
    }
}