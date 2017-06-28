namespace Makolab.Fractus.Communication.Logging
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using log4net;
    using Makolab.Commons.Communication;

    /// <summary>
    /// Class that writes messages to log.
    /// </summary>
    public class CommunicationLog : ICommunicationLog
    {
        /// <summary>
        /// Last log message.
        /// </summary>
        private LogMessage lastMessage;

        /// <summary>
        /// Data that is written to log with every message.
        /// </summary>
        private Dictionary<string, object> properties = new Dictionary<string, object>();

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationLog"/> class.
        /// </summary>
        /// <param name="log">The log sink.</param>
        public CommunicationLog(ILog log)
        {
            Log = log;
        }

        /// <summary>
        /// Gets or sets the log.
        /// </summary>
        /// <value>The log.</value>
        public ILog Log { get; set; }

        /// <summary>
        /// Pops the last message.
        /// </summary>
        /// <returns>Last message.</returns>
        public LogMessage PopLastMessage()
        { 
            lock (this)
            {
                LogMessage lm = this.lastMessage;
                this.lastMessage = null;
                return lm;
            }
        }

        /// <summary>
        /// Sets the property.
        /// </summary>
        /// <param name="key">The property key.</param>
        /// <param name="value">The property value.</param>
        public void SetProperty(string key, object value)
        {
            this.properties[key] = value;
        }

        /// <summary>
        /// Gets the specified property.
        /// </summary>
        /// <param name="key">The property key.</param>
        /// <returns>The specified property value.</returns>
        public object GetProperty(string key)
        { 
            object result = null;
            this.properties.TryGetValue(key, out result);
            return result;
        }

        /// <summary>
        /// Writes error message.
        /// </summary>
        /// <param name="message">The message.</param>
        public void Error(string message)
        {
            Error(message, true);
        }

        /// <summary>
        /// Writes error message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="sendToCentralLog">if set to <c>true</c> then message is send to web service.</param>
        public void Error(string message, bool sendToCentralLog)
        {
            if (sendToCentralLog) SetLastMessage("ERROR - " + message);

            Log.Error(String.Format(System.Globalization.CultureInfo.CurrentCulture, 
                                    "{0} - {1}{2} ", 
                                    DateTime.Now, message, 
                                    Environment.NewLine));
        }

        /// <summary>
        /// Writes information message.
        /// </summary>
        /// <param name="message">The message.</param>
        public void Info(string message)
        {
            Info(message, true);
        }

        /// <summary>
        /// Writes information message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="sendToCentralLog">if set to <c>true</c> [send to central log].</param>
        public void Info(string message, bool sendToCentralLog)
        {
            if (sendToCentralLog) SetLastMessage("INFO - " + message);

            Log.Info(String.Format(System.Globalization.CultureInfo.CurrentCulture, 
                                    "{0} - {1}{2} ",
                                    DateTime.Now, message, 
                                    Environment.NewLine));
        }

        /// <summary>
        /// Sets the last message.
        /// </summary>
        /// <param name="message">The message.</param>
        private void SetLastMessage(string message)
        {
            lock (this)
            {
                this.lastMessage = new LogMessage(message);
            }
        }
    }
}
