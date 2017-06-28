using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Encapsulates communication response message data.
    /// Usually used to log error massages from all branches in headquarter branch.
    /// </summary>
    [DataContract]
    public class MessageData
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="MessageData"/> class.
        /// </summary>
        public MessageData() {  }

        /// <summary>
        /// Initializes a new instance of the <see cref="MessageData"/> class.
        /// </summary>
        /// <param name="message">The message.</param>
        public MessageData(string message) : this(message, DateTime.Now)
        {  }

        /// <summary>
        /// Initializes a new instance of the <see cref="MessageData"/> class.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="messageTime">The message time.</param>
        public MessageData(string message, DateTime messageTime)
        {
            Message     = message;
            Time        = messageTime;
        }

        /// <summary>
        /// Gets or sets the message.
        /// </summary>
        /// <value>The message.</value>
        [DataMember(IsRequired = false)]
        public string Message { get; set; }

        /// <summary>
        /// Gets or sets the message time.
        /// </summary>
        /// <value>The time.</value>
        [DataMember(IsRequired = true)]
        public DateTime? Time { get; set; }

        /// <summary>
        /// Returns a <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </returns>
        public override string ToString()
        {
            string messageType = typeof(string).Name;
            string timeType = typeof(DateTime).Name;

            return String.Format(CultureInfo.InvariantCulture, 
                                    @"<Message type='{0}'>{1}</Message><Time type='{2}'>{3}</Time>",
                                    messageType, Message, timeType, Time);
        }
    }
}
