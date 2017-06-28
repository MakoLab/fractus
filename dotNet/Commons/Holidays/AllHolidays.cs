using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Commons.Holidays
{
	public class AllHolidays
	{
		private static List<Holiday> holidays;

		public static List<Holiday> Holidays
		{
			get
			{
				if (holidays == null)
				{
					holidays = new List<Holiday>();
				}
				return holidays;
			}
		}
	}
}
