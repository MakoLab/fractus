using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Messenger
{
    public class MailServerConfiguration
    {
    
        public int Port
        { get; set; }

        public string SMTP
        { get; set; }

        public string Password
        { get; set; }

        public string Account
        { get; set; }

        public bool UseSSL
        { get; set; }
    }
}
