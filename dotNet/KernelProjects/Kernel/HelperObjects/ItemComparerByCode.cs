using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Items;

namespace Makolab.Fractus.Kernel.HelperObjects
{
	public class ItemComparerByCode : IEqualityComparer<Item>
	{
		private static readonly ItemComparerByCode _Intance = new ItemComparerByCode();

		public static ItemComparerByCode Instance { get { return _Intance; } }

		public bool Equals(Item item1, Item item2)
		{
			return item1.Code.Equals(item2.Code);
		}

		public int GetHashCode(Item item)
		{
			return item.Code.GetHashCode();
		}
	}
}
