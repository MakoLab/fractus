using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Reflection;

namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    /// Provides access to Dependency Injection container defined in configuration. 
    /// </summary>
    public static class IoC
    {
        private static IDictionary<string, IDependencyContainer> containers;
        private static IDictionary<string, IDependencyContainer> bindings;
        private static char[] separator = { ',' };
        private static bool isInitialized;

        /// <summary>
        /// Initializes the dependency container.
        /// </summary>
        public static void Initialize()
        {
            lock (typeof(IoC))
            {
                if (IoC.isInitialized == true) return;

                containers = DependencyContainerFactory.CreateContainers();
                bindings = new Dictionary<string, IDependencyContainer>(StringComparer.InvariantCultureIgnoreCase);
                IDictionary<string, string> bindingsInfo = ((DependencyContainersConfiguration)ConfigurationManager.GetSection("dependencyContainers")).Bindings;
                foreach (var binding in bindingsInfo)
                {
                    bindings.Add(binding.Key, containers[binding.Value]);
                }

                IoC.isInitialized = true;
            }
        }

        public static void Clear()
        {
            lock (typeof(IoC))
            {
                if (IoC.isInitialized == false) return;

                containers.Clear();
                containers = null;
                bindings.Clear();
                bindings = null;

                IoC.isInitialized = false;
            }
        }

        /// <summary>
        /// Adds the dependency container.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="container">The container.</param>
        public static void AddContainer(string containerName, IDependencyContainer container)
        {
            lock (typeof(IoC))
            {
                if (IoC.containers == null) IoC.containers = new Dictionary<string, IDependencyContainer>(StringComparer.InvariantCulture);

                IoC.containers.Add(containerName, container);
            }
        }

        /// <summary>
        /// Removes the dependency container.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        public static void RemoveContainer(string containerName)
        {
            lock (typeof(IoC))
            {
                if (IoC.containers == null) return;

                IDependencyContainer container = IoC.containers[containerName];
                IoC.containers.Remove(containerName);

                if (IoC.bindings.Values.Contains(container))
                {
                    var assembly = (from d in bindings where d.Value == container select d.Key).Single();
                    bindings.Remove(assembly);
                }
            }
        }

        /// <summary>
        /// Adds the binding between container and assembly.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="assemblyName">Name of the assembly.</param>
        public static void AddBinding(string containerName, string assemblyName)
        {
            lock (typeof(IoC))
            {
                if (containers.ContainsKey(containerName) == false) throw new KeyNotFoundException("Container named " + containerName + " not found");

                bindings.Add(assemblyName, containers[containerName]);
            }
        }

        /// <summary>
        /// Removes the binding between container and assembly.
        /// </summary>
        /// <param name="assemblyName">Name of the assembly.</param>
        public static void RemoveBinding(string assemblyName)
        {
            lock (typeof(IoC))
            {
                if (bindings.ContainsKey(assemblyName)) bindings.Remove(assemblyName);
            }
        }

        /// <summary>
        /// Gets the specified container.
        /// </summary>
        /// <param name="name">The name of the container that is returned.</param>
        /// <returns>Specified container.</returns>
        public static IDependencyContainer Container(string name)
        {
            return IoC.containers[name];
        }

        /// <summary>
        /// Gets the container that is bound to the calling assembly.
        /// </summary>
        /// <returns>Container bound to calling assembly.</returns>
        public static IDependencyContainer Container()
        {
            return bindings[Assembly.GetCallingAssembly().FullName.Split(separator, 2)[0]];
        }

        /// <summary>
        /// Retrieves an instance of the specified type from container defined in configuration.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <returns>An instance of the requested type.</returns>
        public static T Get<T>()
        {
            return bindings[Assembly.GetCallingAssembly().FullName.Split(separator, 2)[0]].Get<T>();
        }

        /// <summary>
        /// Retrieves an instance of the specified type from container defined in configuration, within an existing context.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <param name="context">The context under which to resolve the type's binding..</param>
        /// <returns>An instance of the requested type.</returns>
        public static T Get<T>(object context)
        {
            return bindings[Assembly.GetCallingAssembly().FullName.Split(separator, 2)[0]].Get<T>(context);
        }

        /// <summary>
        /// Retrieves an instance of the specified type from container defined in configuration.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <param name="container">The container name.</param>
        /// <returns>An instance of the requested type.</returns>
        public static T Get<T>(string container)
        {
            return containers[container].Get<T>();
        }

        /// <summary>
        /// Retrieves an instance of the specified type from container defined in configuration, within an existing context.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <param name="container">The container name.</param>
        /// <param name="context">The context under which to resolve the type's binding..</param>
        /// <returns>An instance of the requested type.</returns>
        public static T Get<T>(string container, object context)
        {
            return containers[container].Get<T>(context);
        }
    }
}
