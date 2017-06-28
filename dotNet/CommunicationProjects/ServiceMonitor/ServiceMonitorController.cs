using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Threading;
using System.ServiceProcess;
using Makolab.Fractus.Commons;
using System.Globalization;

namespace Makolab.Fractus.Communication.ServiceMonitor
{
    /// <summary>
    /// Manages the lifetime of service monitor by starting and stopping module.
    /// </summary>
    public class ServiceMonitorController : MarshalByRefObject
    {
        private TimeSpan checkInterval;
        private Thread monitoringThread;
        private IEnumerable<WindowsService> monitoredServices;
        private Queue<string> exceptions;

        private const int DEFAULT_CHECK_INTERVAL_IN_MINUTES = 2;

        /// <summary>
        /// Initializes a new instance of the <see cref="ServiceMonitorController"/> class.
        /// </summary>
        public ServiceMonitorController()
        {
            this.monitoredServices = (IEnumerable<WindowsService>)ConfigurationManager.GetSection("monitor");

            double interval = DEFAULT_CHECK_INTERVAL_IN_MINUTES;
            if (MonitorSectionHandler.interval != null)
            {
                interval = MonitorSectionHandler.interval.Value;
            }
            this.checkInterval = TimeSpan.FromMinutes(interval);

            this.monitoringThread = new Thread(MonitorServices);
            this.exceptions = new Queue<string>();
        }

        /// <summary>
        /// Called when service monitor is started.
        /// </summary>
        public void OnStartModule()
        {
            if (this.monitoringThread != null) this.monitoringThread.Start();
        }

        /// <summary>
        /// Called when service monitor is stopped.
        /// </summary>
        public void OnStopModule()
        {
            if (this.monitoringThread != null && this.monitoringThread.ThreadState == ThreadState.Running) this.monitoringThread.Abort();
        }

        /// <summary>
        /// Called when service monitor is diagnosed.
        /// </summary>
        /// <param name="request">The request.</param>
        /// <returns>The response to diagnose request.</returns>
        public string OnDiagnose(string request)
        {
            return DiagnosticHelper.Diagnose(request, this);
        }

        /// <summary>
        /// Gets the specified service.
        /// </summary>
        /// <param name="serviceName">Name of the service.</param>
        /// <returns>Specified service.</returns>
        public WindowsService GetService(string serviceName)
        {
            return this.monitoredServices.SingleOrDefault(s => s.Name == serviceName);
        }

        /// <summary>
        /// Monitors the services state and starts them when stopped.
        /// </summary>
        public void MonitorServices()
        {
            while (true)
            {
                Thread.Sleep(this.checkInterval);

                DateTime now = DateTime.Now;
                foreach (var service in this.monitoredServices.Where(s => s.NextCheckTime < now))
                {
                    try
                    {
                        service.Controller.Refresh();
                        if (service.Controller.Status == ServiceControllerStatus.Stopped) service.Controller.Start();
                        service.SetCheckTime();
                    }
                    catch (Exception e)
                    {
                        if (exceptions.Count > 20) exceptions.Dequeue();
                        exceptions.Enqueue(e.ToString());
                    }
                }
            }
        }
    }
}
