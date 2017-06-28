using System;
using System.Reflection;
using System.ServiceModel;

namespace Common.Patterns.Singleton
{
    /// <summary>
    /// Alocates service proxy object of specified type.
    /// </summary>
    /// <typeparam name="T">Type of proxy</typeparam>
    public abstract class ProxyAllocator<T> : Common.Patterns.Singleton.Allocator<T>
    {
        /// <summary>
        /// Proxy factory.
        /// </summary>
        protected static ChannelFactory<T> StaticFactory;

        /// <summary>
        /// Instance of proxy.
        /// </summary>
        protected T ProxyInstance;

        /// <summary>
        /// Initializes the <see cref="ProxyAllocator&lt;T&gt;"/> class.
        /// </summary>
        static ProxyAllocator()
        {
            foreach (ConstructorInfo c in typeof(T).GetConstructors())
                if (c.IsPublic)
                    throw new InvalidOperationException(typeof(T).Name + " cannot have a public constructor");
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ProxyAllocator&lt;T&gt;"/> class.
        /// </summary>
        protected ProxyAllocator() 
        {
            StaticFactory = CreateFactory();
        }

        /// <summary>
        /// Gets the proxy factory.
        /// </summary>
        /// <value>The proxy factory.</value>
        public ChannelFactory<T> Factory
        {
            get { return StaticFactory; }
        }

        /// <summary>
        /// The property returns the only instance of the Singleton Object in question.
        /// </summary>
        /// <value></value>
        /// <remarks>This property implementation must enforce the Single Object property of Singletons throwing an exception.</remarks>
        public override T Instance
        {
            get
            {
                if (ProxyInstance == null)
                {
                    lock (this)
                    {
                        if (ProxyInstance == null) ProxyInstance = CreateInstance();
                    }
                }

                IClientChannel proxyChannel = ProxyInstance as IClientChannel;
                ////Console.WriteLine(proxyChannel.State);

                if (proxyChannel.State == CommunicationState.Faulted || proxyChannel.State == CommunicationState.Closed || proxyChannel.State == CommunicationState.Closing)
                {
                    lock (this)
                    {
                        if (proxyChannel.State == CommunicationState.Faulted || proxyChannel.State == CommunicationState.Closed || proxyChannel.State == CommunicationState.Closing)
                        {
                            try
                            {
                                proxyChannel.Abort();
                            }
                            catch { }
                            ProxyInstance = CreateInstance();
                            proxyChannel = ProxyInstance as IClientChannel;
                        }
                    }
                }

                if (proxyChannel.State == CommunicationState.Created)
                {
                    lock (this)
                    {
                        if (proxyChannel.State == CommunicationState.Created)
                        {
                            //Console.WriteLine("Otwieranie kanalu: " + proxyChannel.State + " " + DateTime.Now.ToString());
                            try
                            {
                                if (Timeout == TimeSpan.Zero)
                                    proxyChannel.Open();
                                else
                                    proxyChannel.Open(Timeout);
                            }
                            catch (Exception)
                            {
                                try
                                {
                                    proxyChannel.Abort();
                                }
                                catch { }
                                finally
                                {
                                    ProxyInstance = default(T);
                                }
                                throw;
                            }
                        }
                    }
                }

                return ProxyInstance;
            }
        }

        /// <summary>
        /// Gets the proxy timeout.
        /// </summary>
        /// <value>The proxy timeout.</value>
        protected virtual TimeSpan Timeout
        {
            get { return TimeSpan.Zero; }
        }

        /// <summary>
        /// Gets the name of the endpoint configuration.
        /// </summary>
        /// <value>The name of the endpoint configuration.</value>
        protected abstract string EndpointConfigurationName { get; }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing == true)
            {
                IClientChannel proxyChannel = ProxyInstance as IClientChannel;
                try
                {
                    if (proxyChannel != null)
                    {
                        if (proxyChannel.State != CommunicationState.Faulted) proxyChannel.Close();
                        else proxyChannel.Abort();
                    }
                }
                catch (CommunicationException)
                {
                    if (proxyChannel != null) proxyChannel.Abort();
                }
                catch (TimeoutException)
                {
                    if (proxyChannel != null) proxyChannel.Abort();
                }
                catch (Exception)
                {
                    if (proxyChannel != null) proxyChannel.Abort();
                    throw;
                }
                finally
                {
                    ProxyInstance = default(T);
                }
            }
        }

        /// <summary>
        /// Creates the proxy factory.
        /// </summary>
        /// <returns>Created proxy factory.</returns>
        protected virtual ChannelFactory<T> CreateFactory()
        {
            return new ChannelFactory<T>(EndpointConfigurationName);
        }

        /// <summary>
        /// Creates the instance of proxy.
        /// </summary>
        /// <returns>Created proxy instance.</returns>
        protected virtual T CreateInstance()
        {
            if (StaticFactory.State != CommunicationState.Opened)
            {
                lock (this)
                {
                    if (StaticFactory.State != CommunicationState.Opened)
                    {
                        try
                        {
                            StaticFactory.Close();
                        }
                        catch
                        {
                            try
                            {
                                StaticFactory.Abort();
                            }
                            catch { }
                        }
                        StaticFactory = CreateFactory();
                    }
                }
            }
            return StaticFactory.CreateChannel();
        }
    }
}
