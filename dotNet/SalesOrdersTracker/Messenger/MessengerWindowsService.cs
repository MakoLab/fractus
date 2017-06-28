using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.ServiceProcess;
using System.Security.Permissions;
using System.Configuration;
using Ninject;
using CommonServiceLocator.NinjectAdapter;
using Microsoft.Practices.ServiceLocation;
using Ninject.Modules;


namespace Makolab.Fractus.Messenger
{
    public partial class MessengerWindowsService : ServiceBase
    {
        private MessageService messenger;

        [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
        public MessengerWindowsService()
        {
            InitializeService();
        }

        /// <summary>
        /// Executes when the system is shutting down. Specifies what should occur immediately prior to the system shutting down.
        /// </summary>
        protected override void OnShutdown()
        {
            this.OnStop();
        }

        protected override void OnStart(string[] args)
        {
            var locator = new NinjectServiceLocator(MessengerWindowsService.GetBindingsConfiguration());
            ServiceLocator.SetLocatorProvider(() => locator);

            this.messenger = new MessageService();
            this.messenger.Start();
        }

        protected override void OnStop()
        {
            this.messenger.Stop();
        }

        public void Start()
        {
            this.OnStart(null);
        }

        /// <summary>
        /// Disposes of the resources (other than memory) used by the <see cref="T:System.ServiceProcess.ServiceBase"/>.
        /// </summary>
        /// <param name="disposing">true to release both managed and unmanaged resources; false to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
        }

        /// <summary>
        /// Initializes the hosting service instance.
        /// </summary>
        private void InitializeService()
        {
            this.ServiceName = (ConfigurationManager.GetSection("messenger") as MessengerConfiguration).ServiceName;
            this.CanStop = true;
            this.CanPauseAndContinue = false;
            this.AutoLog = true;
            this.CanShutdown = true;
        }

        public static IKernel GetBindingsConfiguration()
        {
            var bindings = new StandardKernel();
            bindings.Bind<IHttpWebRequestWrapper>().To<HttpWebRequestWrapper>();
            bindings.Bind<IHttpWebResponseWrapper>().To<HttpWebResponseWrapper>();

            return bindings;
        }
    }
}
