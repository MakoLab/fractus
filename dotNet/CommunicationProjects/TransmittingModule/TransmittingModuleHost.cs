using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// <see cref="SynchronizationService"/> custom host implemented as <c>HostingService</c> module.
    /// </summary>
    public class TransmittingModuleHost : MarshalByRefObject
    {
        private ServiceHost transmittingHost;

        /// <summary>
        /// Initializes a new instance of the <see cref="TransmittingModuleHost"/> class.
        /// </summary>
        public TransmittingModuleHost()
        {
            
        }

        /// <summary>
        /// Called when <c>TransmittingModul</c> is started.
        /// </summary>
        public void OnStartModule()
        {
            this.transmittingHost = new ServiceHost(typeof(SynchronizationService));
            this.transmittingHost.Open();
            Console.WriteLine("polaczenie otwarte");
        }

        /// <summary>
        /// Called when <c>TransmittingModul</c> is stopped.
        /// </summary>
        public void OnStopModule()
        {
            Console.WriteLine("zamykam polaczenie");
            if (this.transmittingHost != null)
            {
                try 
                    { this.transmittingHost.Close(); }
                catch (CommunicationObjectFaultedException)
                    { this.transmittingHost.Abort(); }
                catch (System.TimeoutException)
                    { this.transmittingHost.Abort(); }
            }
        }

        /// <summary>
        /// Called when <c>TransmittingModul</c> is diagnosed.
        /// </summary>
        /// <param name="request">The request.</param>
        /// <returns>The response to diagnose request.</returns>
        public string OnDiagnose(string request)
        {
            Console.WriteLine("To nie dziala");
            throw new InvalidOperationException("This module does not support remote diagnose.");
        }
    }
}
