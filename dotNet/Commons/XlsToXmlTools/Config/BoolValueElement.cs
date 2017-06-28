using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace XlsToXmlTools.Config
{
	[Serializable]
	public class BoolValueElement
	{
		[XmlAttribute("value")]
		public bool Value { get; set; }
	}
}
