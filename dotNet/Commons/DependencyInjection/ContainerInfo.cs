
namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    /// Class that represents information required to instantiate dependency container.
    /// </summary>
    public class ContainerInfo
    {
        /// <summary>
        /// Gets or sets the name of the module class type that is instantiated.
        /// </summary>
        /// <value>The name of the type.</value>
        public string TypeName { get; set; }

        /// <summary>
        /// Gets or sets the name of the assembly.
        /// </summary>
        /// <value>The name of the assembly.</value>
        public string AssemblyName { get; set; }

        /// <summary>
        /// Gets or sets the name of the container.
        /// </summary>
        /// <value>The name of the container.</value>
        public string ContainerName { get; set; }
    }
}
