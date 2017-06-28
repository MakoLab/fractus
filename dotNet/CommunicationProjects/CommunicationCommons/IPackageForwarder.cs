using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Provides a mechanism to send the communication package to other departments.
    /// </summary>
    public interface IPackageForwarder
    {
        /// <summary>
        /// Gets or sets the message log.
        /// </summary>
        /// <value>The log.</value>
        ICommunicationLog Log { get; set; }

        /// <summary>
        /// Forwards the specified package to other departments.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <param name="repository">The communication package repository.</param>
        void ForwardPackage(ICommunicationPackage communicationPackage, ICommunicationPackageRepository repository);
    }
}
