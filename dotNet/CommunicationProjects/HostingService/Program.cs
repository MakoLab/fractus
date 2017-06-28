namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.ServiceProcess;
    using System.Threading;

    /// <summary>
    /// Entry point class.
    /// </summary>
    public sealed class Program
    {
        private Program()
        {
        }

        /// <summary>
        /// The main entry point.
        /// </summary>
        /// <param name="args">The args.</param>
        public static void Main(string[] args)
        {
            AppDomain.CurrentDomain.UnhandledException +=
                 new UnhandledExceptionEventHandler(HostingServiceLogger.DomainUnhandledExceptionHandler);

            // service
            if (args.Length == 0)
            {
                ServiceBase[] hostingService = new ServiceBase[] { new HostingService() };
                ServiceBase.Run(hostingService);
            }
            else
            {
                ManualResetEvent stopper = new ManualResetEvent(false);
                //HostingServiceController controller = new HostingServiceController(10000);
                //controller.Start();
                HostingService srv = new HostingService();
                srv.Start();
                stopper.WaitOne();
            }
        }
    }
}
