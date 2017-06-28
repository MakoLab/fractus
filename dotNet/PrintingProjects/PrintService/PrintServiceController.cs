using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.Configuration;
using log4net;

namespace Makolab.Fractus.Printing
{
    public class PrintServiceController : MarshalByRefObject
    {
        private ServiceHost printingHost;
        private CrossDomainWebServer crossDomainWS;
        private ILog log = log4net.LogManager.GetLogger(typeof(PrintServiceController));

        public void OnStartModule()
        {
            this.printingHost = new ServiceHost(typeof(PrintingService));
            this.printingHost.Open();
            Console.WriteLine("otwarto polaczenie");
            object port = ConfigurationManager.GetSection("crossDomainXmlProvider");
            this.crossDomainWS = new CrossDomainWebServer((Int32)port);
            this.crossDomainWS.Log = this.log;
            this.crossDomainWS.Start();
        }

        public void OnStopModule()
        {
            this.crossDomainWS.Close();

            Console.WriteLine("zamykanie polaczenia");
            if (this.printingHost != null)
            {
                try
                    { this.printingHost.Close(); }
                catch (CommunicationObjectFaultedException)
                    { this.printingHost.Abort(); }
                catch (System.TimeoutException)
                    { this.printingHost.Abort(); }
            }
        }

        public string OnDiagnose(string request)
        {
            return null;
        }
    }
}
