using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Messenger
{
    public class MessengerConfiguration
    {
        public string ServiceName { get; set; }

        public string SmsServiceProvider { get; set; }

        public string MessageDBConnectionString { get; set; }

        public int RetryInterval { get; set; }

        public int SendInterval { get; set; }

        public int RetrieveMessageInterval { get; set; }

        public int RetryLimit { get; set; }

        public int ReloadMessageLimit { get; set; }

        public Dictionary<string, string> SmsServiceParameters { get; set; }

        public MailServerConfiguration MailServer { get; set; }

        public string GetMessageStoredProcedure { get; set; }

		public string GetMessageAttachmentsStoredProcedure { get; set; }

        public string SetMessageTransmissionSuccessStoredProcedure { get; set; }

        public string SetMessageTransmissionErrorStoredProcedure { get; set; }

        public TimeSpan BeginSmsTransmissionPeriod { get; set; }

        public TimeSpan EndSmsTransmissionPeriod { get; set; }
    }
}
