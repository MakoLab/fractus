using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Commons.Communication.Exceptions
{
    /// <summary>
    /// The exception that is thrown when communication package is dublicated or already exists in storage.
    /// </summary>
    [Serializable]
    public class CommunicationPackageExistsException : ArgumentException
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageExistsException"/> class.
        /// </summary>
        public CommunicationPackageExistsException() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageExistsException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        public CommunicationPackageExistsException(string message) : base(message) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageExistsException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        /// <param name="innerException">The inner exception.</param>
        public CommunicationPackageExistsException(string message, Exception innerException) : base(message, innerException) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageExistsException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        /// <param name="communicationPackageId">The communication package id.</param>
        public CommunicationPackageExistsException(string message, string communicationPackageId) : base(message, communicationPackageId) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackageExistsException"/> class.
        /// </summary>
        /// <param name="message">The exception message.</param>
        /// <param name="communicationPackageId">The communication package id.</param>
        /// <param name="innerException">The inner exception.</param>
        public CommunicationPackageExistsException(string message, string communicationPackageId, Exception innerException) : base(message, communicationPackageId, innerException) { }
    }
}
