
namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    /// Creates context to use with dependency container.
    /// </summary>
    public interface IContextProvider
    {
        /// <summary>
        /// Creates the context.
        /// </summary>
        /// <param name="container">The container.</param>
        /// <param name="key">The key.</param>
        /// <param name="value">The value.</param>
        /// <returns>New context instance.</returns>
        object CreateContext(IDependencyContainer container, string key, object value);

        /// <summary>
        /// Adds specified value to context.
        /// </summary>
        /// <param name="context">The context.</param>
        /// <param name="key">The key of the value :D.</param>
        /// <param name="value">The value of the key :D.</param>
        /// <returns>Specified context with new value.</returns>
        object AddToContext(object context, string key, object value);
    }
}
