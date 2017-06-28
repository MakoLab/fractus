namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Runtime.Serialization;
    using System.Security.Permissions;

    /// <summary>
    /// The exception that is thrown when an attempt to find specified module fails.
    /// </summary>
    [Serializable]
    public class ModuleNotFoundException : Exception
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="ModuleNotFoundException"/> class.
        /// </summary>
        public ModuleNotFoundException() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="ModuleNotFoundException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        public ModuleNotFoundException(string message) : base(message) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="ModuleNotFoundException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        /// <param name="moduleName">Name of the module that was not found.</param>
        public ModuleNotFoundException(string message, string moduleName)
            : base(message)
        {
            this.ModuleName = moduleName;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ModuleNotFoundException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        /// <param name="innerException">The inner exception.</param>
        public ModuleNotFoundException(string message, Exception innerException) : base(message, innerException) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="ModuleNotFoundException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        /// <param name="moduleName">Name of the module that was not found.</param>
        /// <param name="innerException">The inner exception.</param>
        public ModuleNotFoundException(string message, string moduleName, Exception innerException)
            : base(message, innerException)
        {
            this.ModuleName = moduleName;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ModuleNotFoundException"/> class.
        /// </summary>
        /// <param name="info">The <see cref="T:System.Runtime.Serialization.SerializationInfo"/> that holds the serialized object data about the exception being thrown.</param>
        /// <param name="context">The <see cref="T:System.Runtime.Serialization.StreamingContext"/> that contains contextual information about the source or destination.</param>
        /// <exception cref="T:System.ArgumentNullException">The <paramref name="info"/> parameter is null. </exception>
        /// <exception cref="T:System.Runtime.Serialization.SerializationException">The class name is null or <see cref="P:System.Exception.HResult"/> is zero (0). </exception>
        protected ModuleNotFoundException(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
            if (info != null) this.ModuleName = info.GetString("ModuleName");
        } 
        #endregion

        /// <summary>
        /// Gets or sets the name of the module.
        /// </summary>
        /// <value>The name of the module.</value>
        public string ModuleName { get; private set; }

        /// <summary>
        /// Sets the <see cref="T:System.Runtime.Serialization.SerializationInfo"/> with information about the exception.
        /// </summary>
        /// <param name="info">The <see cref="T:System.Runtime.Serialization.SerializationInfo"/> that holds the serialized object data about the exception being thrown.</param>
        /// <param name="context">The <see cref="T:System.Runtime.Serialization.StreamingContext"/> that contains contextual information about the source or destination.</param>
        /// <exception cref="T:System.ArgumentNullException">The <paramref name="info"/> parameter is a null reference (Nothing in Visual Basic). </exception>
        /// <PermissionSet>
        /// 	<IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Read="*AllFiles*" PathDiscovery="*AllFiles*"/>
        /// 	<IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="SerializationFormatter"/>
        /// </PermissionSet>
        [SecurityPermission(SecurityAction.LinkDemand, Flags = SecurityPermissionFlag.SerializationFormatter)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            base.GetObjectData(info, context);
            if (info != null) info.AddValue("ModuleName", this.ModuleName);
        }
    }
}
