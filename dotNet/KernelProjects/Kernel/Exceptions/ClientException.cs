using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Exceptions
{
    /// <summary>
    /// Exception that can be thrown to client.
    /// </summary>
    [Serializable]
    public class ClientException : Exception
    {
        /// <summary>
        /// Exception's parameters.
        /// </summary>
        private List<string> parameters;

        /// <summary>
        /// Gets the collection of exception's parameters.
        /// </summary>
        public ICollection<string> Parameters
        { get { return this.parameters; } }

        /// <summary>
        /// Exception's message Id.
        /// </summary>
        private ClientExceptionId id;

        /// <summary>
        /// Gets the exception's message Id.
        /// </summary>
        public ClientExceptionId Id
        { get { return this.id; } }

        public XElement XmlData { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ClientException"/> class.
        /// </summary>
        public ClientException()
        { }

        public ClientException(ClientExceptionId id)
            : this(id, null, null)
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="ClientException"/> class with a specified id and optional parameters.
        /// </summary>
        /// <param name="id">Exception id.</param>
        /// <param name="list">Optional parameters for the error message.</param>
        public ClientException(ClientExceptionId id, Exception innerException, params string[] list)
            : base(null, innerException)
        {
            this.id = id;

            if (list != null)
            {
                this.parameters = new List<string>(list.Length);

                foreach (string param in list)
                    this.parameters.Add(param);
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ClientException"/> class.
        /// </summary>
        /// <param name="info">The <see cref="T:System.Runtime.Serialization.SerializationInfo"/> that holds the serialized object data about the exception being thrown.</param>
        /// <param name="context">The <see cref="T:System.Runtime.Serialization.StreamingContext"/> that contains contextual information about the source or destination.</param>
        /// <exception cref="T:System.ArgumentNullException">
        /// The <paramref name="info"/> parameter is null.
        /// </exception>
        /// <exception cref="T:System.Runtime.Serialization.SerializationException">
        /// The class name is null or <see cref="P:System.Exception.HResult"/> is zero (0).
        /// </exception>
        protected ClientException(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
            if (info != null)
            {
                this.id = (ClientExceptionId)info.GetValue("id", typeof(ClientExceptionId));
            }
        }

        /// <summary>
        /// Creates and returns a string representation of the current exception.
        /// </summary>
        /// <returns>
        /// A string representation of the current exception.
        /// </returns>
        /// <PermissionSet>
        /// 	<IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" PathDiscovery="*AllFiles*"/>
        /// </PermissionSet>
        public override string ToString()
        {
            string label = "ClientException: " + this.Id.ToString();

            if (!String.IsNullOrEmpty(this.StackTrace))
                label += "\nStackTrace :" + this.StackTrace;

            return label;
        }

        /// <summary>
        /// When overridden in a derived class, sets the <see cref="T:System.Runtime.Serialization.SerializationInfo"/> with information about the exception.
        /// </summary>
        /// <param name="info">The <see cref="T:System.Runtime.Serialization.SerializationInfo"/> that holds the serialized object data about the exception being thrown.</param>
        /// <param name="context">The <see cref="T:System.Runtime.Serialization.StreamingContext"/> that contains contextual information about the source or destination.</param>
        /// <exception cref="T:System.ArgumentNullException">
        /// The <paramref name="info"/> parameter is a null reference (Nothing in Visual Basic).
        /// </exception>
        /// <PermissionSet>
        /// 	<IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Read="*AllFiles*" PathDiscovery="*AllFiles*"/>
        /// 	<IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="SerializationFormatter"/>
        /// </PermissionSet>
        [SecurityPermission(SecurityAction.LinkDemand, Flags = SecurityPermissionFlag.SerializationFormatter)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            base.GetObjectData(info, context);
            if (info != null) info.AddValue("id", this.id);
        }
    }
}
