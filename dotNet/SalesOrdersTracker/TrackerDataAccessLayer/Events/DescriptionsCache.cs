using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using System.IO;
using System.Xml.Linq;
using System.Configuration;
using System.Xml;

namespace TrackerDataAccessLayer.Events
{
	public class DescriptionsCache : IConfigurationSectionHandler
	{
		private static XDocument _MessagesXml;

		public static XDocument MessagesXml
		{
			get
			{
				if (_MessagesXml == null)
				{
					var section = (DescriptionsCache)ConfigurationManager.GetSection("salesOrdersTracker.Descriptions");
				}
				return _MessagesXml;
			}
		}

		public object Create(object parent, object configContext, XmlNode section)
		{
			if (section != null)
			{
				lock (typeof(DescriptionsCache))
				{
					_MessagesXml = XDocument.Parse(section.OuterXml);
				}
			}
			return this;
		}
	}
}
