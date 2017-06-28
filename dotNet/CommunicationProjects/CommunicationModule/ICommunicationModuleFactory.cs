namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Defines interface for communication module factory.
    /// </summary>
    public interface ICommunicationModuleFactory
    {
        /// <summary>
        /// Creates the communication module.
        /// </summary>
        /// <param name="creator">The communication module creator.</param>
        /// <returns>Created communication module.</returns>
        ICommunicationModule CreateModule(ICommunicationModuleCreator creator);
    }
}
