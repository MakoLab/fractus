namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Specifies the type of communication module.
    /// </summary>
    public enum CommunicationModuleType
    {
        /// <summary>
        /// Module is a DatabaseConnector
        /// </summary>
        DatabaseConnector,

        /// <summary>
        /// Module is an Executor
        /// </summary>
        Executor,

        /// <summary>
        /// Module is a Transmitter
        /// </summary>
        Transmitter,

        /// <summary>
        /// Module is something else.
        /// </summary>
        Other
    }
}
