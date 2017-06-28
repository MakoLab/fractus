using Makolab.Fractus.Commons.DependencyInjection;
using Makolab.Fractus.Kernel.Mappers;
using Ninject.Core;
using Ninject.Core.Behavior;

namespace Makolab.Fractus.Kernel.DependencyInjection
{
    /// <summary>
    /// DependencyContainer provider that returns Ninject dependency container.
    /// </summary>
    public class KernelContainerProvider : IDependencyContainerProvider
    {
        #region IDependencyContainerProvider Members

        /// <summary>
        /// Retrieves an instance of depencency injection container.
        /// </summary>
        /// <returns>
        /// An instance of depencency injection container
        /// </returns>
        public IDependencyContainer GetContainer()
        {
            //this line is required to force faster SecurityManager instantiation
            int notUsed = Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.GetHashCode();

            InlineModule iMod = new InlineModule(mod => mod.Bind<ContractorMapper>().To<ContractorMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<DocumentMapper>().To<DocumentMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<ItemMapper>().To<ItemMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<JournalMapper>().To<JournalMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<ListMapper>().To<ListMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<RepositoryMapper>().To<RepositoryMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<SecurityMapper>().To<SecurityMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<WarehouseMapper>().To<WarehouseMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<ServiceMapper>().To<ServiceMapper>().Using<SingletonBehavior>(),
                                                mod => mod.Bind<ConfigurationMapper>().ToConstant<ConfigurationMapper>(ConfigurationMapper.Instance).Using<SingletonBehavior>(),
                                                mod => mod.Bind<DictionaryMapper>().ToConstant<DictionaryMapper>(DictionaryMapper.Instance).Using<SingletonBehavior>());

            IKernel container = new StandardKernel(iMod);
            return new KernelDependencyContainer(container);
        }

        #endregion
    }
}
