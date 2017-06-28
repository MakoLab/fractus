using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace Makolab.Printing.Text
{
	public static class Utility
	{
		public static string GetAtributeValueOrNull(XmlElement element, string attrName)
		{
			if (element != null)
			{
				XmlAttribute attr = element.Attributes[attrName];
				if (attr != null)
				{
					return attr.Value;
				}
			}
			return null;
		}
	}
}
