using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using SalesOrderTracker;

namespace SalesOrdersTracker
{
	static class Program
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		static void Main(string[] args)
		{
			if (args.Length > 0)
			{
				MessagingLogic logic = new MessagingLogic();
				logic.ProcessSalesOrderEvents();
			}
			else
			{
				ServiceBase[] ServicesToRun;
				ServicesToRun = new ServiceBase[] 
			{ 
				new SalesOrderTrackerWindowsService() 
			};
				ServiceBase.Run(ServicesToRun);
			}
		}
	}
}
