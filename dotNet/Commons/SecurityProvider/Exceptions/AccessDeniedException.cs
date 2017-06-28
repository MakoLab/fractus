using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security;

namespace Makolab.SecurityProvider.Exceptions
{
    public class AccessDeniedException : SecurityException
    {
        const string msg = "Insufficient  permissions to access required resource.";

        public AccessDeniedException() : base(msg)
        {

        }

        public AccessDeniedException(Exception innerException) : base(msg, innerException)
        {

        }


    }
}
