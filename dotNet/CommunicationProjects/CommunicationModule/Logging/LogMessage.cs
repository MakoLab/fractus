namespace Makolab.Fractus.Communication.Logging
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Class that represents message that is written to log.
    /// </summary>
    public class LogMessage
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="LogMessage"/> class.
        /// </summary>
        /// <param name="message">The log message.</param>
        public LogMessage(string message)
        {
            this.Message = message;
            this.MessageTime = DateTime.Now;
        }

        /// <summary>
        /// Gets or sets the message that is written to log.
        /// </summary>
        /// <value>The message.</value>
        public string Message { get; set; }

        /// <summary>
        /// Gets or sets time when message was created.
        /// </summary>
        /// <value>The message's time.</value>
        public DateTime MessageTime { get; set; }
    }
}
