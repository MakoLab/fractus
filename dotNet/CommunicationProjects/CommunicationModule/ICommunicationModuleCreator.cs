namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Defines interface for creating communication modules.
    /// </summary>
    public interface ICommunicationModuleCreator
    {
        /// <summary>
        /// Creates the communication module.
        /// </summary>
        /// <returns>Created communication module.</returns>
        ICommunicationModule CreateModule();
    }
}
