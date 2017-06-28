using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;

namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    /// Creates dependency container.
    /// </summary>
    public static class DependencyContainerFactory
    {
        /// <summary>
        /// Creates the dependency containers specified in configuration file.
        /// </summary>
        /// <returns>A collection of dependency injection containers.</returns>
        public static IDictionary<string, IDependencyContainer> CreateContainers()
        {
            IEnumerable<ContainerInfo> info = ((DependencyContainersConfiguration)ConfigurationManager.GetSection("dependencyContainers")).Containers;
            Dictionary<string, IDependencyContainer> containers = new Dictionary<string, IDependencyContainer>(StringComparer.InvariantCulture);
            foreach (var cInfo in info)
            {
                IDependencyContainerProvider provider = (IDependencyContainerProvider)Activator.CreateInstance(cInfo.AssemblyName, cInfo.TypeName).Unwrap();
                IDependencyContainer container = provider.GetContainer();
                container.Name = cInfo.ContainerName;
                containers.Add(cInfo.ContainerName, container);
            }

            return containers;
        }

        /// <summary>
        /// Creates the dependency container specified in configuration.
        /// </summary>
        /// <param name="containerName">Name of the container that is created.</param>
        /// <returns>An instance of dependency injection container.</returns>
        public static IDependencyContainer CreateContainer(string containerName)
        {
            IEnumerable<ContainerInfo> info = ((DependencyContainersConfiguration)ConfigurationManager.GetSection("dependencyContainers")).Containers;
            ContainerInfo selContInfo = (from contInf in info where contInf.ContainerName == containerName select contInf).SingleOrDefault();
            IDependencyContainerProvider provider = (IDependencyContainerProvider)Activator.CreateInstance(selContInfo.AssemblyName, selContInfo.TypeName).Unwrap();
            IDependencyContainer container = provider.GetContainer();
            container.Name = containerName;
            return container;
        }
    }
}
