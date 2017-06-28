namespace Makolab.Fractus.Communication.Logging
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using log4net.Appender;

    /// <summary>
    /// Appender that doesn't log messages.
    /// </summary>
    public class EmptyAppender : IAppender
    {
        #region IAppender Members

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        /// <value>The name.</value>
        public string Name { get; set; }

        /// <summary>
        /// Closes this instance.
        /// </summary>
        public void Close()
        {
        }

        /// <summary>
        /// Does the append.
        /// </summary>
        /// <param name="loggingEvent">The logging event.</param>
        public void DoAppend(log4net.Core.LoggingEvent loggingEvent)
        {
        }

        #endregion
    }
}
