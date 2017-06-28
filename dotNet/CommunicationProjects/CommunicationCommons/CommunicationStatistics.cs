using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Encapsulates the communication packages transfer statistics.
    /// </summary>
    [DataContract]
    public class CommunicationStatistics
    {
        /// <summary>
        /// Gets or sets the amount of packages to send.
        /// </summary>
        /// <value>The packages to send.</value>
        [DataMember(IsRequired = true)]
        public int PackagesToSend { get; set; }

        /// <summary>
        /// Gets or sets the amount of packages to execute.
        /// </summary>
        /// <value>The packages to execute.</value>
        [DataMember(IsRequired = true)]
        public int PackagesToExecute { get; set; }

        /// <summary>
        /// Gets or sets the time of statistics.
        /// </summary>
        /// <value>The current time.</value>
        [DataMember(IsRequired = true)]
        public DateTime CurrentTime { get; set; }

        /// <summary>
        /// Gets or sets the time of system.
        /// </summary>
        /// <value>The current time.</value>
        [DataMember(IsRequired = false)]
        public DateTime SystemTime { get; set; }

        /// <summary>
        /// Gets or sets the last time of communication package execution.
        /// </summary>
        /// <value>The last execution time.</value>
        [DataMember(IsRequired = false)]
        public DateTime? LastExecutionTime { get; set; }

        /// <summary>
        /// Gets or sets the last message of communication package execution.
        /// </summary>
        /// <value>The last execution message.</value>
        [DataMember(IsRequired = false)]
        public MessageData LastExecutionMessage { get; set; }

        /// <summary>
        /// Gets or sets the last response from receive communication package request.
        /// </summary>
        /// <value>The last receive message.</value>
        [DataMember(IsRequired = false)]
        public MessageData LastReceiveMessage { get; set; }

        /// <summary>
        /// Gets or sets the last response from send communication package request.
        /// </summary>
        /// <value>The last send message.</value>
        [DataMember(IsRequired = false)]
        public MessageData LastSendMessage { get; set; }

        /// <summary>
        /// Gets or sets the additional information send with communication statistics.
        /// </summary>
        /// <value>The additional information send with communication statistics.</value>
        [DataMember(IsRequired = false)]
        public string AdditionalData { get; set; }

        /// <summary>
        /// Returns a <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </returns>
        public override string ToString()
        {
            string unsendPackagesType           = typeof(int).Name;
            string unexecutedPackagesType       = typeof(int).Name;
            string timeType                     = typeof(DateTime).Name;
            string exceptionType                = typeof(MessageData).Name;
            return String.Format(CultureInfo.InvariantCulture, 
                                    @"<UnsendPackages type='{0}'>{1}</UnsendPackages><UnexecutedPackages type='{2}'>{3}</UnexecutedPackages>
                                    <CurrentTime type='{4}'>{5}</CurrentTime><LastExecutionTime type='{6}'>{7}</LastExecutionTime>
                                    <LastExecutionMessage type='{8}'>{9}</LastExecutionMessage><LastReceiveMessage type='{10}'>{11}</LastReceiveMessage>
                                    <LastSendMessage type='{12}'>{13}</LastSendMessage>",
                                unsendPackagesType, PackagesToSend, unexecutedPackagesType, PackagesToExecute, 
                                timeType, CurrentTime, timeType, LastExecutionTime, exceptionType, LastExecutionMessage, 
                                exceptionType, LastReceiveMessage, exceptionType, LastSendMessage);            
        }
    }
}
