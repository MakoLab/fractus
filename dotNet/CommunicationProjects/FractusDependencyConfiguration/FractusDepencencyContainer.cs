using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Commons;
using Ninject.Core;
using Makolab.Fractus.Commons.DependencyInjection;

namespace Makolab.Fractus.Communication
{

    /// <summary>
    /// Inversion of control container.
    /// </summary>
    public class FractusDependencyContainer : IDependencyContainer
    {
        internal IKernel Container { get; set; }

        #region IDependencyContainer Members

        /// <summary>
        /// Retrieves an instance of the specified type from container.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <returns>An instance of the requested type.</returns>
        public T Get<T>()
        {
            return this.Container.Get<T>();
        }

        /// <summary>
        /// Retrieves an instance of the specified type from container, within an existing context.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <param name="context">The context under which to resolve the type's binding..</param>
        /// <returns>An instance of the requested type.</returns>
        public T Get<T>(object context)
        {
            return this.Container.Get<T>((Ninject.Core.Activation.IContext)context);
        }

        /// <summary>
        /// Gets or sets the name of the container.
        /// </summary>
        /// <value>The name of the container.</value>
        public string Name { get; set; }

        #endregion
    }
}
