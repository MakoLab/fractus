using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;

namespace Makolab.Fractus.Commons
{
    public abstract class ClientException : Exception
    {
        public abstract string Id
        {
            get;
            protected set;
        }

        protected string msgTemplateName;

        public string MessageTemplateName
        {
            get { return this.msgTemplateName; }
            protected set { this.msgTemplateName = value; }
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

        public ClientException(string messageTemplateName)
        {
            this.msgTemplateName = messageTemplateName;
        }

        public ClientException(string messageTemplateName, params string[] list) : this(messageTemplateName)
        {
            this.AddParams(list);
        }

        /// <summary>
        /// Returns a <see cref="System.String"/> that represents this instance.
        /// </summary>
        /// <returns>
        /// A <see cref="System.String"/> that represents this instance.
        /// </returns>
        /// <PermissionSet>
        /// 	<IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" PathDiscovery="*AllFiles*"/>
        /// </PermissionSet>
        public override string ToString()
        {
            string label = this.GetType().Name + ": " + this.Id;

            if (String.IsNullOrEmpty(this.StackTrace) == false) label += "\nStackTrace :" + this.StackTrace;
            return label;
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
