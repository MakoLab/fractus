using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using System.Collections;
using System.Globalization;
using TrackerDataAccessLayer;
using TrackerDataAccessLayer.Enums;

namespace SalesOrderTracker.Messages
{
	public class SOTMessage
	{
		public Message InnerMessage { get; private set; }

		public SOTMessage(EventName eventName, MessageType messageType, string sender, string recipient
			, params string[] parameters)
		{
			XElement eventElement = TemplatesCache.MessagesXml.Root.Elements("event")
				.Where(el => el.GetAtributeValueOrNull("name") == eventName.ToString().Decapitalize()).FirstOrDefault();

			if (eventElement != null)
			{
				XElement messageElement = eventElement.Elements("message")
					.Where(el => el.GetAtributeValueOrNull("type") == messageType.ToString().ToLower()).FirstOrDefault();

				if (messageElement != null)
				{
					InnerMessage = new Message() { MessageType = messageType, Sender = sender, Recipient = recipient, CreationDate = DateTime.Now };
					InnerMessage.MessageText = Utils.ResolveMessage(messageElement.Value, parameters).Replace("\\n", Environment.NewLine);
					if (messageElement.Attribute("title") != null)
					{
						InnerMessage.Subject = Utils.ResolveMessage(messageElement.Attribute("title").Value, parameters);
					}
					if (messageType == MessageType.Sms)
					{
						InnerMessage.MessageText = InnerMessage.MessageText.ReplaceLocalCharacters();
					}
				}
			}
		}
	}
}
