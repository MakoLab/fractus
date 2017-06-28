using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Provides a mechanism to write the log message to configured sink.
    /// </summary>
    public interface ICommunicationLog
    {
        /// <summary>
        /// Writes information message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="sendToCentralLog">if set to <c>true</c> sends log message to central branch.</param>
        void Info(string message, bool sendToCentralLog);

        /// <summary>
        /// Writes information message.
        /// </summary>
        /// <param name="message">The message.</param>
        void Info(string message);

        /// <summary>
        /// Writes error message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="sendToCentralLog">if set to <c>true</c> sends log message to central branch.</param>
        void Error(string message, bool sendToCentralLog);

        /// <summary>
        /// Writes error message.
        /// </summary>
        /// <param name="message">The message.</param>
        void Error(string message);

        /// <summary>
        /// Gets the property.
        /// </summary>
        /// <param name="key">The property key.</param>
        /// <returns></returns>
        object GetProperty(string key);

        /// <summary>
        /// Sets the property.
        /// </summary>
        /// <param name="key">The property key.</param>
        /// <param name="value">The property value.</param>
        void SetProperty(string key, object value);
    }
}
