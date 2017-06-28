using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Messenger
{
	public class MessageAttachment
	{
		public Guid Id { get; set; }
		public Guid MessageId { get; set; }
		public string Name { get; set; }
		public byte[] Content { get; set; }
		public string ContentType { get; set; }
	}
}
