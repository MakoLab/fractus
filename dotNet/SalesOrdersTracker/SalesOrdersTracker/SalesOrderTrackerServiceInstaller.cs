using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.Linq;
using System.ServiceProcess;
using System.Configuration;


namespace SalesOrdersTrackerService
{
	[RunInstaller(true)]
	public partial class SalesOrderTrackerServiceInstaller : System.Configuration.Install.Installer
	{
		private ServiceProcessInstaller processInstaller;
		private ServiceInstaller serviceInstaller;

		public SalesOrderTrackerServiceInstaller()
		{
			InitializeComponent();
			processInstaller = new ServiceProcessInstaller();
			serviceInstaller = new ServiceInstaller();

			processInstaller.Account = ServiceAccount.LocalSystem;
			processInstaller.Username = null;
			processInstaller.Password = null;
			serviceInstaller.StartType = ServiceStartMode.Automatic;

			System.Reflection.Assembly assembly =
					System.Reflection.Assembly.GetExecutingAssembly();
			string fileName = System.IO.Path.GetFileName(assembly.Location);
			fileName += ".config";

			serviceInstaller.ServiceName = ConfigurationManager.AppSettings["serviceName"] ?? "SalesOrderTrackerService";
			serviceInstaller.DisplayName = serviceInstaller.ServiceName;
			serviceInstaller.Description = ConfigurationManager.AppSettings["serviceDescription"] ?? "SalesOrderTrackerService";

			Installers.Add(serviceInstaller);
			Installers.Add(processInstaller);
		}
	}
}
