using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Fractus.Printing
{
    public class InheritedException : Makolab.Fractus.Commons.ClientException
    {
        private const string EXCEPTION_TEMPLATE = "Makolab.Fractus.Commons.Samples.Exceptions.xml";
        private string id;
        public override string Id
        {
            get
            {
                return this.id;
            }
            protected set
            {
                this.id = value;
            }
        }

        public InheritedException(string id) : base(EXCEPTION_TEMPLATE)
        {
            this.id = id;
        }

        public InheritedException(string id, params string[] list) : base(EXCEPTION_TEMPLATE, list)
        {
            this.id = id;
        }
    }
}
