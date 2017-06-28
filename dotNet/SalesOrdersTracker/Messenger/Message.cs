using System;
using System.Collections.Generic;

namespace Makolab.Fractus.Messenger
{
    public class Message
    {
        public string Body { get; set; }

        public string Error { get; set; }

        public Guid Id { get; set; }

        public string Recipient { get; set; }

        public string Sender { get; set; }

        public MessageState State { get; set; }

        public MessageType Type { get; set; }

        public string Subject { get; set; }

		public List<MessageAttachment> Attachments { get; set; }

        public string CC { get; set; }
    }

}