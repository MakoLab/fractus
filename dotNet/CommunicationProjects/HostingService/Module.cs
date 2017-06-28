using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Encapsulates <see cref="IModule"/> object and its environment.
    /// </summary>
    public class ExternalModule
    {
        /// <summary>
        /// Gets or sets the module info.
        /// </summary>
        /// <value>The info.</value>
        public ModuleInfo Info { get; set; }

        /// <summary>
        /// Gets or sets the module instance.
        /// </summary>
        /// <value>The instance.</value>
        public IModule Instance { get; set; }

        /// <summary>
        /// Gets or sets the domain.
        /// </summary>
        /// <value>The module application domain.</value>
        public AppDomain Domain { get; set; }
    }
}
