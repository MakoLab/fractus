using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using System.Security.Cryptography;
using System.Text;

namespace OrderTrackerGUI.Models
{
    public class User
    {
        [Required(ErrorMessage="Login jest wymagany")]
        [DisplayName("Login")]
        public string Login { get; set; }

		[Required(ErrorMessage = "Hasło jest wymagane")]
        [DataType(DataType.Password)]
        [DisplayName("Hasło")]
        public string Password { get; set; }

        public Guid Id { get; set; }
    }
}
