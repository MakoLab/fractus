namespace Makolab.Fractus.Communication.Logging
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using log4net.Appender;
    using log4net.Layout;

    /// <summary>
    /// Class that represents logging sink. 
    /// </summary>
    public class LoggingStrategy
    {
        /// <summary>
        /// Gets the build from configuration file.
        /// </summary>
        /// <value>The build from configuration file.</value>
        public static LoggingStrategy BuildFromConfigurationFile
        {
            get { return new LoggingStrategy(); }
        }

        /// <summary>
        /// Gets the log to console.
        /// </summary>
        /// <value>The log to console.</value>
        public static LoggingStrategy LogToConsole
        {
            get
            {
                ConsoleAppender console = new ConsoleAppender();
                console.Layout = new SimpleLayout();
                return new LoggingStrategy { Appender = console };
            }
        }

        /// <summary>
        /// Gets the log to memory.
        /// </summary>
        /// <value>The log to memory.</value>
        public static LoggingStrategy LogToMemory
        {
            get { return new LoggingStrategy { Appender = new MemoryAppender() }; }
        }

        /// <summary>
        /// Gets the disable logging.
        /// </summary>
        /// <value>The disable logging.</value>
        public static LoggingStrategy DisableLogging
        {
            get { return new LoggingStrategy { Appender = new EmptyAppender() }; }
        }

        /// <summary>
        /// Gets or sets the appender.
        /// </summary>
        /// <value>The appender.</value>
        public IAppender Appender { get; set; }
    }
}
