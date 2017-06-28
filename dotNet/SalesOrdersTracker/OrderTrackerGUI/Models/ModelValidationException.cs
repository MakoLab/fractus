using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net;
using System.Security.Permissions;
using System.Runtime.Serialization;

namespace OrderTrackerGUI.Models
{
    [Serializable]
    public class ModelValidationException : Exception
    {
        public HttpStatusCode ResponseStatus { get; private set; }

        public string ParameterName { get; private set; }


            #region Constructors
            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            public ModelValidationException() 
            {
                this.ResponseStatus = HttpStatusCode.BadRequest;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            public ModelValidationException(string message) : this(message, HttpStatusCode.BadRequest) { }

            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            /// <param name="parameterName">Name of the parameter.</param>
            public ModelValidationException(string message, string parameterName) : this(message, HttpStatusCode.BadRequest)
            {
                this.ParameterName = parameterName;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            /// <param name="responseStatus">The response status.</param>
            public ModelValidationException(string message, HttpStatusCode responseStatus) : base(message)
            {
                this.ResponseStatus = responseStatus;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="LoginExistsException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            /// <param name="innerException">The inner exception.</param>
            public ModelValidationException(string message, Exception innerException) : base(message, innerException) 
            {
                this.ResponseStatus = HttpStatusCode.BadRequest;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            /// <param name="parameterName">Name of the parameter.</param>
            /// <param name="innerException">The inner exception.</param>
            public ModelValidationException(string message, string parameterName, Exception innerException) : this(message, innerException)
            {
                this.ParameterName = parameterName;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            /// <param name="responseStatus">The response status.</param>
            /// <param name="innerException">The inner exception.</param>
            public ModelValidationException(string message, HttpStatusCode responseStatus, Exception innerException) : this(message, innerException)
            {
                this.ResponseStatus = responseStatus;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            /// <param name="parameterName">Name of the parameter.</param>
            /// <param name="responseStatus">The response status.</param>
            /// <param name="innerException">The inner exception.</param>
            public ModelValidationException(string message, string parameterName, HttpStatusCode responseStatus, Exception innerException)
                : base(message, innerException)
            {
                this.ResponseStatus = responseStatus;
                this.ParameterName = parameterName;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="ModelValidationException"/> class.
            /// </summary>
            /// <param name="message">The exception message.</param>
            /// <param name="parameterName">Name of the parameter.</param>
            /// <param name="responseStatus">The response status.</param>
            /// <param name="innerException">The inner exception.</param>
            public ModelValidationException(string message, string parameterName, HttpStatusCode responseStatus) : base(message)
            {
                this.ResponseStatus = responseStatus;
                this.ParameterName = parameterName;
            }

            /// <summary>
            /// Initializes a new instance of the <see cref="LoginExistsException"/> class.
            /// </summary>
            /// <param name="info">The <see cref="T:System.Runtime.Serialization.SerializationInfo"/> that holds the serialized object data about the exception being thrown.</param>
            /// <param name="context">The <see cref="T:System.Runtime.Serialization.StreamingContext"/> that contains contextual information about the source or destination.</param>
            /// <exception cref="T:System.ArgumentNullException">The <paramref name="info"/> parameter is null. </exception>
            /// <exception cref="T:System.Runtime.Serialization.SerializationException">The class name is null or <see cref="P:System.Exception.HResult"/> is zero (0). </exception>
            protected ModelValidationException(SerializationInfo info, StreamingContext context) : base(info, context)
            {
                if (info != null)
                {
                    this.ParameterName = info.GetString("ParameterName");
                    this.ResponseStatus = (HttpStatusCode)info.GetValue("ResponseStatus", typeof(HttpStatusCode));
                }
            }
            #endregion

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
                if (info != null) info.AddValue("ParameterName", this.ParameterName);
                if (info != null) info.AddValue("ResponseStatus", this.ResponseStatus);
            }
    }
}