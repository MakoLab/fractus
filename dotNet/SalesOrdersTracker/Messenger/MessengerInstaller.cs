using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.Linq;
using System.ServiceProcess;
using System.Diagnostics;
using System.Xml;


namespace Makolab.Fractus.Messenger
{
    [RunInstaller(true)]
    public partial class MessengerInstaller : Installer
    {
        private ServiceProcessInstaller processInstaller;
        private ServiceInstaller serviceInstaller;

        public MessengerInstaller()
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
                XmlNode serviceNode = doc.DocumentElement.SelectSingleNode("messenger");
                serviceName = serviceNode.Attributes.GetNamedItem("name").Value;
                serviceDescription = serviceNode.Attributes.GetNamedItem("description").Value;

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
