using Makolab.Fractus.Commons.DependencyInjection;

namespace Makolab.Fractus.Kernel.Managers
{
    /// <summary>
    /// Manager that exposes DependencyContainer.
    /// </summary>
    public static class DependencyContainerManager
    {
        /// <summary>
        /// DependencyContainer that creates objects in Fractus Kernel.
        /// </summary>
        private static IDependencyContainer container = DependencyContainerFactory.CreateContainer("KernelContainer");

        /// <summary>
        /// Gets a DependencyContainer that creates objects in Fractus Kernel.
        /// </summary>
        public static IDependencyContainer Container { get { return DependencyContainerManager.container; } }
    }
}
