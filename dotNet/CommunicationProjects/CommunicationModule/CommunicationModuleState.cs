namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Describes the current state of the communication module. 
    /// </summary>
    public enum CommunicationModuleState
    {
        /// <summary>
        /// Communication module is stopped.
        /// </summary>
        Stopped, 

        /// <summary>
        /// Communication module is stopping.
        /// </summary>
        Stopping,

        /// <summary>
        /// Communication module is starting.
        /// </summary>
        Started, 

        /// <summary>
        /// Communication module is started.
        /// </summary>
        Starting
    }
}
