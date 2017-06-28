using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TrackerDataAccessLayer
{
	public partial class Message
	{
		public MessageType MessageType
		{
			get
			{
				return (MessageType)Enum.Parse(typeof(MessageType), this.Type, true);
			}
			set
			{
				this.Type = value.ToString().ToLower();
			}
		}
	}
}
