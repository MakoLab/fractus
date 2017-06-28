namespace Makolab.Commons.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Text;

    /// <summary>
    /// The type of communication module.
    /// </summary>
    public enum ServiceType
    {
        /// <summary>
        /// Module has different or unknown type.
        /// </summary>
        None,
        /// <summary>
        /// Module is sending communication packages.
        /// </summary>
        Sender,
        /// <summary>
        /// Module is reveiving communication pakages.
        /// </summary>
        Receiver,
        /// <summary>
        /// Module executes communication packages.
        /// </summary>
        Executor
    }
}
