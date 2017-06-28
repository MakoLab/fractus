using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;

namespace Makolab.Fractus.Messenger
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main(params string[] args)
        {
            if (args.Length == 0)
            {
                ServiceBase[] ServicesToRun;
                ServicesToRun = new ServiceBase[] 
			    { 
				    new MessengerWindowsService() 
			    };
                ServiceBase.Run(ServicesToRun);
            }
            else
            {
                var s = new MessengerWindowsService();
                s.Start();
                System.Threading.ManualResetEvent e = new System.Threading.ManualResetEvent(false);
                e.WaitOne();
                Console.ReadKey();
            }
        }
    }
}
