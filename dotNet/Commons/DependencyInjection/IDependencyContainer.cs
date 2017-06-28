
namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    /// Inversion of control container interface.
    /// </summary>
    public interface IDependencyContainer
    {
        /// <summary>
        /// Retrieves an instance of the specified type from container.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <returns>An instance of the requested type.</returns>
        T Get<T>();

        /// <summary>
        /// Retrieves an instance of the specified type from container, within an existing context.
        /// </summary>
        /// <typeparam name="T">The type to retrieve.</typeparam>
        /// <param name="context">The context under which to resolve the type's binding..</param>
        /// <returns>An instance of the requested type.</returns>
        T Get<T>(object context);

        /// <summary>
        /// Gets or sets the name of the container.
        /// </summary>
        /// <value>The name of the container.</value>
        string Name { get; set; }
    }
}
