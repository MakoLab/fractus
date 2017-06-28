
namespace Makolab.Fractus.Commons.DependencyInjection
{
    /// <summary>
    ///  Defines interface for classes that provides access to depencency injection container.
    /// </summary>
    public interface IDependencyContainerProvider
    {
        /// <summary>
        /// Retrieves an instance of depencency injection container.
        /// </summary>
        /// <returns>An instance of depencency injection container</returns>
        IDependencyContainer GetContainer();
    }
}
