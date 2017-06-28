namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Creates communication modules.
    /// </summary>
    public class CommunicationModuleFactory : ICommunicationModuleFactory
    {
        /// <summary>
        /// Creates communication module from module creator.
        /// </summary>
        /// <param name="creator">The communication module creator.</param>
        /// <returns>Communication module instance.</returns>
        public ICommunicationModule CreateModule(ICommunicationModuleCreator creator)
        {
            return creator.CreateModule();
        }
    }
}
