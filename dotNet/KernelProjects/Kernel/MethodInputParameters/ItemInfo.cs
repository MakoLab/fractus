using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
	//Wykorzystuję deserializację dla własnej wygody
	[XmlSerializable(XmlField = "line")]
	public class ItemInfo : BusinessObject
	{
		[XmlSerializable(XmlField = "ean")]
		public string Barcode { get; set; }
		[XmlSerializable(XmlField = "itemGroupFamilyCode")]
		public string Family { get; set; }
		[XmlSerializable(XmlField = "code")]
		public string Code { get; set; }
		[XmlSerializable(XmlField = "name")]
		public string Name { get; set; }
		//[XmlSerializable(XmlField = "price")]
		//public decimal Price { get; set; }

        [XmlSerializable(XmlField = "defaultPrice")]
        public decimal DefaultPrice { get; set; }

		public ItemInfo() : base(null) { }

		public override void ValidateConsistency()
		{
			throw new NotImplementedException();
		}

		public override void SaveChanges(System.Xml.Linq.XDocument document)
		{
			throw new NotImplementedException();
		}
	}
}
