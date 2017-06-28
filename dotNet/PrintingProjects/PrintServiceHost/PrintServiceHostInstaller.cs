using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;
using System.ServiceProcess;
using System.Configuration;
using System.Configuration.Install;
using System.Diagnostics;
using System.Xml;

namespace Makolab.Fractus.Printing
{
    /// <summary>
    /// Provices data to install HostingService windows service in opperating system.
    /// </summary>
    [RunInstaller(true)]
    public class PrintServiceHostInstaller : Installer
    {
        private ServiceProcessInstaller processInstaller;
        private ServiceInstaller serviceInstaller;

        /// <summary>
        /// Initializes a new instance of the <see cref="HostingServiceInstaller"/> class.
        /// </summary>
        public PrintServiceHostInstaller()
        {
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

            string serviceName = null;
            string serviceDescription = null;
            List<string> serviceDependencies = new List<string>();

            EventLog eventLog = new EventLog();
            eventLog.Source = "ServIns";
            try
            {
                XmlTextReader reader = new XmlTextReader(fileName);
                reader.WhitespaceHandling = WhitespaceHandling.None;
                XmlDocument doc = new XmlDocument();
                doc.Load(reader);
                XmlNode serviceNode = doc.DocumentElement.SelectSingleNode("printService");
                serviceName = serviceNode.Attributes.GetNamedItem("Name").Value;
                serviceDescription = serviceNode.Attributes.GetNamedItem("Description").Value;

                XmlNodeList dependencies = doc.DocumentElement.SelectNodes("externalDependencies/dependency");
                if (dependencies != null && dependencies.Count > 0)
                    foreach (XmlNode dep in dependencies)
                    {
                        serviceDependencies.Add(dep.InnerText);
                    }
            }
            catch (Exception ex)
            {
                eventLog.WriteEntry(ex.ToString());
            }

            serviceInstaller.ServiceName = serviceName;
            serviceInstaller.DisplayName = serviceName;
            serviceInstaller.Description = serviceDescription;
            serviceInstaller.ServicesDependedOn = serviceDependencies.ToArray();

            Installers.Add(serviceInstaller);
            Installers.Add(processInstaller);
        }

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true to release both managed and unmanaged resources; false to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
        }
    }
}
