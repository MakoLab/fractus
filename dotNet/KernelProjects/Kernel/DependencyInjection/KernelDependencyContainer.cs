using System;
using Makolab.Fractus.Commons.DependencyInjection;
using Ninject.Core;
using Ninject.Core.Activation;

namespace Makolab.Fractus.Kernel.DependencyInjection
{
    /// <summary>
    /// DependencyContainer wrapper.
    /// </summary>
    public class KernelDependencyContainer : IDependencyContainer
    {
        private IKernel container;

        /// <summary>
        /// Initializes a new instance of the <see cref="KernelDependencyContainer"/> class.
        /// </summary>
        /// <param name="container">The container.</param>
        public KernelDependencyContainer(IKernel container)
        {
            this.container = container;
        }

        #region IDependencyContainer Members

        /// <summary>
        /// Retrieves an instance of the specified type from container.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <returns>An instance of the requested type.</returns>
        public T Get<T>()
        {
            T retVal = this.container.Get<T>();

            if (retVal == null)
                throw new InvalidOperationException("Dependency container returned null. Expected type: " + typeof(T).ToString());

            return retVal;
        }

        /// <summary>
        /// Retrieves an instance of the specified type from container, within an existing context.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <param name="context">The context under which to resolve the type's binding..</param>
        /// <returns>An instance of the requested type.</returns>
        public T Get<T>(object context)
        {
            return this.container.Get<T>((IContext)context);
        }

        /// <summary>
        /// Gets or sets the name of the container.
        /// </summary>
        /// <value>The name of the container.</value>
        public string Name { get; set; }

        #endregion
    }
}
