using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Fractus.Printing
{
    public class UnhandableException : Exception
    {
        public UnhandableException(string msg) : base(msg)
        {

        }
    }
}
