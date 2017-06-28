using System.Collections.Generic;

namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    /// Class that represents configuration of dependency containers retrieved from file.
    /// </summary>
    public class DependencyContainersConfiguration
    {
        /// <summary>
        /// Gets or sets the containers.
        /// </summary>
        /// <value>The containers.</value>
        public IEnumerable<ContainerInfo> Containers { get; set; }

        /// <summary>
        /// Gets or sets the bindings.
        /// </summary>
        /// <value>The bindings.</value>
        public IDictionary<string, string> Bindings { get; set; }
    }
}
