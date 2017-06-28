using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using System.IO;
using System.Xml.Linq;
using System.Configuration;

namespace SalesOrderTracker.Messages
{
	public class TemplatesCache : IConfigurationSectionHandler
	{
		private static XDocument _MessagesXml;

		public static XDocument MessagesXml
		{
			get
			{
				if (_MessagesXml == null)
				{
					var section = (TemplatesCache)ConfigurationManager.GetSection("salesOrdersTracker.Messages");
				}
				return _MessagesXml;
			}
		}

		private static string _EmailSender;

		public static string EmailSender
		{
			get
			{
				if (_EmailSender == null)
				{
					_EmailSender = ConfigurationManager.AppSettings["emailSender"];
				}
				return _EmailSender;
			}
		}

		private static string _SmsSender;

		public static string SmsSender
		{
			get
			{
				if (_SmsSender == null)
				{
					_SmsSender = ConfigurationManager.AppSettings["smsSender"];
				}
				return _SmsSender;
			}
		}

		private static DateTime? _StartDate;

		public static DateTime StartDate
		{
			get
			{
				if (_StartDate == null)
				{
					_StartDate = Convert.ToDateTime(ConfigurationManager.AppSettings["startDate"]);
				}
				return _StartDate.Value;
			}
		}

		public object Create(object parent, object configContext, System.Xml.XmlNode section)
		{
			if (section != null)
			{
				lock (typeof(TemplatesCache))
				{
					_MessagesXml = XDocument.Parse(section.OuterXml);
				}
			}
			return this;
		}
	}
}
