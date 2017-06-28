using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceProcess;

namespace Makolab.Fractus.Communication.ServiceMonitor
{
    /// <summary>
    /// Encapsulates the monitored windows service data.
    /// </summary>
    public class WindowsService
    {
        /// <summary>
        /// Gets or sets the service name.
        /// </summary>
        /// <value>The name.</value>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the service validation interval.
        /// </summary>
        /// <value>The check interval.</value>
        public double CheckInterval { get; set; }

        /// <summary>
        /// Gets or sets the service monitor controller.
        /// </summary>
        /// <value>The controller.</value>
        public ServiceController Controller { get; private set; }

        /// <summary>
        /// Gets or sets the next service validation time.
        /// </summary>
        /// <value>The next check time.</value>
        public DateTime NextCheckTime { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="WindowsService"/> class.
        /// </summary>
        /// <param name="serviceName">Name of the service.</param>
        /// <param name="checkInterval">The validation interval.</param>
        public WindowsService(string serviceName, double checkInterval)
        {
            if (String.IsNullOrEmpty(serviceName)) throw new ArgumentException("", "serviceName");
            if (checkInterval > 1) throw new ArgumentException("checkInterval must by grater then 0", "checkInterval");
            this.Name = serviceName;
            this.CheckInterval = checkInterval;
            this.Controller = new ServiceController(Name);
            SetCheckTime();

            if (this.Controller == null) throw new ServiceNotFoundException("", serviceName);
        }

        /// <summary>
        /// Sets the next validation time.
        /// </summary>
        public void SetCheckTime()
        {
            this.NextCheckTime = DateTime.Now.Add(TimeSpan.FromMinutes(this.CheckInterval));
        }
    }
}
