using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Fractus.Printing
{
    public class NotInheritedException : Exception
    {
        private const string EXCEPTION_TEMPLATE = "Makolab.Fractus.Commons.Samples.Exceptions.xml";
        private string id;
        public string Id
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

        public string MessageTemplateName
        {
            get { return EXCEPTION_TEMPLATE; }
        }

        /// <summary>
        /// Exception's parameters.
        /// </summary>
        private List<string> parameters;

        /// <summary>
        /// Gets the collection of exception's parameters.
        /// </summary>
        public ICollection<string> Parameters
        { 
            get { return this.parameters; } 
        }

        public NotInheritedException(string id)
        {
            this.id = id;
        }

        public NotInheritedException(string id, params string[] list)
        {
            this.id = id;
            this.AddParams(list);
        }

        protected void AddParams(params string[] list)
        {
            if (list != null)
            {
                this.parameters = new List<string>(list.Length);

                foreach (string param in list)
                    this.parameters.Add(param);
            }
        }
    }
}
