namespace Makolab.Fractus.Printing
{
    using System;
    using System.Collections.Generic;
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
            #region Testcode
            //            string doc = @"<document type='bill' id='3F9B5D38-6DE8-4BF1-BF5A-04560B023254' xmlns:fn='http://www.w3.org/2005/02/xpath-functions'>
            //<configuration mode='offline' printerModel='PosnetThermal5V' portName='COM1' wsdl='http://192.168.1.50/Printing/?wsdl' />
            //<number>202/O1/2009</number><cashier>11</cashier><grossValue>12.20</grossValue><lines><line position='1'><name>pomidory</name>
            //<quantity>1.000000</quantity><vatRateType>A</vatRateType><grossPrice>12.20</grossPrice><grossValue>12.20</grossValue><unit>kg</unit></line></lines></document>";
            //            PrintingService ps = new PrintingService();
            //            ps.FiscalPrint(doc); 
            #endregion

            AppDomain.CurrentDomain.UnhandledException +=
                 new UnhandledExceptionEventHandler(HostingServiceLogger.DomainUnhandledExceptionHandler);

            // service
            if (args.Length == 0)
            {
                ServiceBase[] hostingService = new ServiceBase[] { new PrintServiceHost() };
                ServiceBase.Run(hostingService);
            }
            else
            {
                ManualResetEvent stopper = new ManualResetEvent(false);
                PrintServiceHost srv = new PrintServiceHost();
                srv.Start();
                stopper.WaitOne();
            }
        }
    }
}
