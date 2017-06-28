using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Class that represents information required to instantiate module.
    /// </summary>
    public class HandlerInfo
    {
        /// <summary>
        /// Gets or sets the name of the handler class type that is instantiated.
        /// </summary>
        /// <value>The name of the type.</value>
        public string TypeName { get; set; }

        /// <summary>
        /// Gets or sets the name of the assembly containing handler class.
        /// </summary>
        /// <value>The name of the assembly.</value>
        public string AssemblyName { get; set; }
    }
}
