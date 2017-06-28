namespace Makolab.Fractus.Communication.Logging
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using log4net.Core;
    using log4net;

    /// <summary>
    /// Class that manages messages logging.
    /// </summary>
    public sealed class CommunicationModuleLogger
    {
        /// <summary>
        /// Log sink.
        /// </summary>
        private static ILog logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationModuleLogger"/> class.
        /// </summary>
        private CommunicationModuleLogger() { }

        /// <summary>
        /// Log configuration.
        /// </summary>
        private static LoggingStrategy strategy;

        /// <summary>
        /// Gets or sets the logging strategy.
        /// </summary>
        /// <value>The logging strategy.</value>
        public static LoggingStrategy Strategy 
        {
            get { return strategy; }
            set
            {
                strategy = value;
                Configure();
            }
        }

        /// <summary>
        /// Writes specified message to log.
        /// </summary>
        /// <param name="msg">Message to log.</param>
        public static void LogMessage(string msg)
        {
            logger.Info(String.Format(System.Globalization.CultureInfo.CurrentCulture, 
                                      "{0} - {1}{2} ", 
                                      DateTime.Now, 
                                      msg, 
                                      Environment.NewLine));
        }

        /// <summary>
        /// Creates the log.
        /// </summary>
        /// <returns>Created log.</returns>
        public static CommunicationLog CreateLog()
        {
            return new CommunicationLog(logger);
        }

        /// <summary>
        /// Configures log.
        /// </summary>
        private static void Configure()
        {
            if (strategy.Appender != null) log4net.Config.BasicConfigurator.Configure(strategy.Appender);
            //else log4net.Config.BasicConfigurator.Configure();

            logger = LogManager.GetLogger(typeof(CommunicationModuleLogger));
        }
    }
}
