using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Commons;
using Ninject.Core;
using Makolab.Commons.Communication;
using Makolab.Fractus.Commons.DependencyInjection;
using Ninject.Core.Behavior;
using Makolab.Fractus.Communication.Scripts;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Class that provides access to depencency injection container.
    /// </summary>
    public class FractusContainerProvider : IDependencyContainerProvider
    {
        /// <summary>
        /// Retrieves an instance of depencency injection container.
        /// </summary>
        /// <returns>
        /// An instance of depencency injection container.
        /// </returns>
        public IDependencyContainer GetContainer()
        {
            InlineModule iMod = new InlineModule(mod => mod.Bind<IExecutingScriptsFactory>().To<ExecutingScriptsFactory>().Using<SingletonBehavior>(),
                                                 mod => mod.Bind<ICommunicationPackageFactory>().To<FractusPackageFactory>().Using<SingletonBehavior>(),
                                                 mod => mod.Bind<IMapperFactory>().To<Fractus.Communication.DBLayer.FractusMapperFactory>().Using<SingletonBehavior>(),
                                                 mod => mod.Bind<IPackageForwarder>().To<FractusPackageForwarder>().Using<SingletonBehavior>(),
                                                 mod => mod.Bind<IContextProvider>().To<FractusContextProvider>().Using<SingletonBehavior>(),
                                                 mod => mod.Bind<IExecutionManager>().To<FractusExecutionManager>().Using<SingletonBehavior>(),
                                                 mod => mod.Bind<IPackageValidator>().ToProvider<FractusPackageValidatorProvider>().Using<SingletonBehavior>()
                                                );

            IKernel container = new StandardKernel(iMod);
            return new FractusDependencyContainer() { Container = container };
        }
    }
}
