using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading;
using SalesOrderTracker;
using System.Configuration;

	public partial class SalesOrderTrackerWindowsService : ServiceBase
	{
		private Thread messageLogicThread;

		public SalesOrderTrackerWindowsService()
		{
			InitializeService();
		}

		protected override void OnStart(string[] args)
		{
			MessagingLogic logic = new MessagingLogic();
			messageLogicThread = new Thread(logic.ProcessSalesOrderEvents);
			messageLogicThread.Start();
		}

		protected override void OnStop()
		{
			messageLogicThread.Abort();
		}

		private void InitializeService()
        {
            this.ServiceName = ConfigurationManager.AppSettings["serviceName"] ?? "SalesOrderTrackerService";
            this.CanStop = true;
            this.CanPauseAndContinue = false;
            this.AutoLog = true;
            this.CanShutdown = true;
        }
}
