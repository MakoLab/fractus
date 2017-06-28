namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using Common.Patterns.Singleton;
    using Makolab.Fractus.Communication;

//-----------------------------------------------------

    /// <summary>
    /// Class that creates <see cref="CommunicationServiceProxy"/> instance.
    /// </summary>
    /// <typeparam name="T">Type of communication service</typeparam>
    internal class CommunicationProxyAllocator<T> : ProxyAllocator<T>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationProxyAllocator&lt;T&gt;"/> class.
        /// </summary>
        private CommunicationProxyAllocator() { }

        /// <summary>
        /// Gets the name of the endpoint configuration.
        /// </summary>
        /// <value>The name of the endpoint configuration.</value>
        protected override string EndpointConfigurationName
        {
            get { return "communicationService"; }
        }
    }

    /// <summary>
    /// Communication web service proxy.
    /// </summary>
    /// <remarks>Is able to send and receive communication packages.</remarks>
    internal sealed class CommunicationServiceProxy : Singleton<ISynchronizationService, CommunicationProxyAllocator<ISynchronizationService>>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationServiceProxy"/> class.
        /// </summary>
        private CommunicationServiceProxy() { }

        ////unused
        ////public static void DisposeInstance()
        ////{
        ////    try
        ////    {
        ////        allocator.Dispose();
        ////    }
        ////    catch { }
        ////}

        /// <summary>
        /// Gets the proxy factory.
        /// </summary>
        /// <value>The proxy factory.</value>
        internal static System.ServiceModel.ChannelFactory<ISynchronizationService> ProxyFactory
        {
            get { return (Allocator as ProxyAllocator<ISynchronizationService>).Factory; }
        }
    }
}
