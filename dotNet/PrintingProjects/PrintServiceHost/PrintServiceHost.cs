using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceProcess;
using System.Configuration;
using System.Security.Permissions;
using System.IO;
using System.Reflection;
using Makolab.Fractus.Printing;

namespace Makolab.Fractus.Printing
{
    /// <summary>
    /// Class that describes HostingService behavior. 
    /// Derives from <see cref="ServiceBase"/>.
    /// </summary>
    public class PrintServiceHost : ServiceBase
    {
        private FileSystemWatcher watcher;
        private DateTime lastWatcherEventTime = DateTime.Now;
        private WatcherChangeTypes lastWatcherEventType = WatcherChangeTypes.All;
        private PrintServiceController printService;

        /// <summary>
        /// Initializes a new instance of the <see cref="HostingService"/> class.
        /// </summary>
        [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
        public PrintServiceHost()
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

        #region Unused
        ///// <summary>
        ///// Starts the diagnostic web service.
        ///// </summary>
        //private void StartDiagnosticService()
        //{
        //    this.diagnosticHost = new ServiceHost(new DiagnosticService(this.controller.Modules, this.controller), new Uri[0]);
        //    this.diagnosticHost.Open();
        //}

        ///// <summary>
        ///// Stops the diagnostic web service.
        ///// </summary>
        //private void StopDiagnosticService()
        //{
        //    if (this.diagnosticHost != null)
        //    {
        //        try
        //        {
        //            this.diagnosticHost.Close();
        //        }
        //        catch (CommunicationObjectFaultedException)
        //        {
        //            this.diagnosticHost.Abort();
        //        }
        //        catch (System.TimeoutException)
        //        {
        //            this.diagnosticHost.Abort();
        //        }
        //        finally
        //        {
        //            this.diagnosticHost = null;
        //        }
        //    }
        //} 
        #endregion

        /// <summary>
        /// Executes when a Start command is sent to the service by the Service Control Manager (SCM) or when the operating system starts (for a service that starts automatically). Specifies actions to take when the service starts.
        /// </summary>
        /// <param name="args">Data passed by the start command.</param>
        protected override void OnStart(string[] args)
        {
            //controller = new HostingServiceController((ServiceSectionHandler)ConfigurationManager.GetSection("service"));
            //controller.Start();
            //this.StartDiagnosticService();
            this.printService.OnStartModule();
            this.watcher.EnableRaisingEvents = true;
        }

        /// <summary>
        /// Executes when a Stop command is sent to the service by the Service Control Manager (SCM). Specifies actions to take when a service stops running.
        /// </summary>
        protected override void OnStop()
        {
            this.watcher.EnableRaisingEvents = false;
            this.printService.OnStopModule();
            //if (controller != null) controller.Stop();
            //this.StopDiagnosticService();
        }

        /// <summary>
        /// Disposes of the resources (other than memory) used by the <see cref="T:System.ServiceProcess.ServiceBase"/>.
        /// </summary>
        /// <param name="disposing">true to release both managed and unmanaged resources; false to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                //if (controller != null) controller.Dispose();

                if (this.watcher != null) this.watcher.Dispose();

                //if (this.diagnosticHost != null) this.diagnosticHost.Close();
            }

            base.Dispose(disposing);
        }

        /// <summary>
        /// Starts this instance.
        /// </summary>
        public void Start()
        {
            this.OnStart(null);
        }

        /// <summary>
        /// Initializes the hosting service instance.
        /// </summary>
        private void InitializeService()
        {
            this.ServiceName = (ConfigurationManager.GetSection("printService") as ServiceSectionHandler).ServiceName;
            this.CanStop = true;
            this.CanPauseAndContinue = false;
            this.AutoLog = true;
            this.CanShutdown = true;

            string fullPath = Assembly.GetEntryAssembly().Location;
            string filename = fullPath.Substring(fullPath.LastIndexOf('\\') + 1);
            string directory = fullPath.Substring(0, fullPath.LastIndexOf('\\') + 1);

            this.printService = new PrintServiceController();

            this.watcher = new FileSystemWatcher(directory, filename + ".config") { NotifyFilter = NotifyFilters.LastWrite };
            this.watcher.Changed += new FileSystemEventHandler(OnAppConfigChanged);
            this.watcher.Created += new FileSystemEventHandler(OnAppConfigChanged);
            this.watcher.Deleted += new FileSystemEventHandler(OnAppConfigChanged);
        }

        /// <summary>
        /// Called when hosting service configuration changes.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="System.IO.FileSystemEventArgs"/> instance containing the event data.</param>
        private void OnAppConfigChanged(object sender, FileSystemEventArgs e)
        {
            double dt = (DateTime.Now - this.lastWatcherEventTime).TotalSeconds;

            if (this.lastWatcherEventType != e.ChangeType || dt > 1)
            {
                this.lastWatcherEventTime = DateTime.Now;
                this.lastWatcherEventType = e.ChangeType;
                this.OnStop();
                this.OnStart(null);
            }
        }
    }
}
