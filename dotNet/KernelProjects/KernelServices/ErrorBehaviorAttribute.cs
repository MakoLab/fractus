using System;
using System.Collections.ObjectModel;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;

namespace Makolab.Fractus.Kernel.Services
{
    [AttributeUsage(AttributeTargets.Class)]
    public sealed class ErrorBehaviorAttribute : Attribute, IServiceBehavior
    {
        private Type errorHandlerType;

        public Type ErrorHandlerType
        { get {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("ErrorBehaviorAttribute:getter");
            return this.errorHandlerType; } }

        public ErrorBehaviorAttribute(Type errorHandlerType)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("ErrorBehaviorAttribute:ErrorBehaviorAttribute(Type errorHandlerType)");
            this.errorHandlerType = errorHandlerType;
        }

        public void Validate(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)
        { }

        public void AddBindingParameters(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase, Collection<ServiceEndpoint> endpoints, BindingParameterCollection bindingParameters)
        { }

        public void ApplyDispatchBehavior(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase) 
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("ErrorBehaviorAttribute:ApplyDispatchBehavior(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)");
            IErrorHandler errorHandler;
            errorHandler = (IErrorHandler)Activator.CreateInstance(errorHandlerType); 
            
            foreach (ChannelDispatcherBase channelDispatcherBase in serviceHostBase.ChannelDispatchers) 
            { 
                ChannelDispatcher channelDispatcher = channelDispatcherBase as ChannelDispatcher; 
                channelDispatcher.ErrorHandlers.Add(errorHandler); 
            } 
        }
    }
}
