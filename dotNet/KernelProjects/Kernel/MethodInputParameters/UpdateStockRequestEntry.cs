using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
	internal abstract class UpdateStockRequestEntry
	{
		/// <summary>
		/// Gets or sets the item id.
		/// </summary>
		internal Guid ItemId { get; set; }

		/// <summary>
		/// Gets or sets the warehouse id.
		/// </summary>
		internal Guid WarehouseId { get; set; }

		/// <summary>
		/// Gets or sets the unit id.
		/// </summary>
		internal Guid UnitId { get; set; }

		internal virtual XElement Serialize()
		{
			return XElement.Parse(String.Format(@"<item itemId=""{0}"" warehouseId=""{1}"" unitId=""{2}""/>",
				this.ItemId.ToUpperString(), this.WarehouseId.ToUpperString(), this.UnitId.ToUpperString()));
		}

		internal XElement CommXmlElement()
		{
			return new XElement("entry", new XElement("itemId", this.ItemId.ToUpperString()), new XElement("warehouseId", this.WarehouseId.ToUpperString()));
		}
	}
}
