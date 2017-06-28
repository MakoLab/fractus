using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ninject.Core.Activation;
using Ninject.Core;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Fractus custom context container.
    /// </summary>
    public class FractusContainerContext : StandardContext
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="FractusContainerContext"/> class.
        /// </summary>
        /// <param name="kernel">The kernel.</param>
        /// <param name="service">The service.</param>
        public FractusContainerContext(IKernel kernel, Type service) : base(kernel, service)
        {
            this.Parameters = new Dictionary<string, object>();
        }

        /// <summary>
        /// Gets or sets the transient parameters for the context, if any are defined.
        /// </summary>
        /// <value></value>
        public new IDictionary<string, object> Parameters { get; private set; } 
    }
}
