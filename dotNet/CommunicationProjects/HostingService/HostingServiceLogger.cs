using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Manages message logging for hosting service.
    /// </summary>
    public class HostingServiceLogger
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="HostingServiceLogger"/> class.
        /// </summary>
        private HostingServiceLogger() { }

        /// <summary>
        /// Writes the specified message to sink.
        /// </summary>
        /// <param name="msg">The message.</param>
        public static void LogMessage(string msg)
        {
            string message = String.Format(System.Globalization.CultureInfo.CurrentCulture,
                                             "{0} - {1}{2} ", DateTime.Now, msg, Environment.NewLine);
            Console.Write(message);
        }

        /// <summary>
        /// Handles the domain unhandled exception.
        /// </summary>
        /// <param name="sender">The exception source.</param>
        /// <param name="e">The <see cref="System.UnhandledExceptionEventArgs"/> instance containing the event data.</param>
        internal static void DomainUnhandledExceptionHandler(object sender, UnhandledExceptionEventArgs e)
        {
            Exception unhandledException = e.ExceptionObject as Exception;
            if (unhandledException != null) LogMessage("DomainUnhandledExceptionHandler" + unhandledException.ToString());
            else LogMessage("DomainUnhandledExceptionHandler - null cast=" + e.ExceptionObject.ToString());

            throw unhandledException;
        }
    }
}
