using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Factory that is responsible for creating communication packages from specified data.
    /// </summary>
    public interface ICommunicationPackageFactory
    {
        /// <summary>
        /// Creates the communication package..
        /// </summary>
        /// <param name="data">The object with communication package data.</param>
        /// <returns>Created communication package.</returns>
        ICommunicationPackage CreatePackage(object data);

        /// <summary>
        /// Creates the communication package from <see cref="XmlTransferObject"/> object.
        /// </summary>
        /// <param name="data">The <see cref="XmlTransferObject"/> with communication package data.</param>
        /// <returns>Communication package created from <see cref="XmlTransferObject"/> object.</returns>
        ICommunicationPackage CreatePackage(XmlTransferObject data);
    }
}
