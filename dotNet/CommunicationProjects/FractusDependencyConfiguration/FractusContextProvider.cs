using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Commons.DependencyInjection;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Creates context to use with dependency container.
    /// </summary>
    public class FractusContextProvider : IContextProvider
    {

        #region IContextProvider Members

        /// <summary>
        /// Creates the context.
        /// </summary>
        /// <param name="container">The container.</param>
        /// <param name="key">The key.</param>
        /// <param name="value">The value.</param>
        /// <returns>New context instance.</returns>
        public object CreateContext(IDependencyContainer container, string key, object value)
        {
            FractusDependencyContainer fractusContainer = (FractusDependencyContainer)container;

            FractusContainerContext context = new FractusContainerContext(fractusContainer.Container, typeof(object));
            context.Parameters.Add(key, value);
            return context;
        }

        /// <summary>
        /// Adds specified value to context.
        /// </summary>
        /// <param name="context">The context.</param>
        /// <param name="key">The key of the value :D.</param>
        /// <param name="value">The value of the key :D.</param>
        /// <returns>Specified context with new value.</returns>
        public object AddToContext(object context, string key, object value)
        {
            FractusContainerContext fractusContext = (FractusContainerContext)context;
            fractusContext.Parameters.Add(key, value);
            return fractusContext;
        }

        #endregion
    }
}
