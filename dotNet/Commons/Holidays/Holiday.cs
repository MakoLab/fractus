using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Commons.Holidays
{
	public class Holiday
	{
		public int Month { get; set; }
		public int Day { get; set; }

		public Holiday(int month, int day)
		{
			Month = month;
			Day = day;
		}

		protected Holiday() { }

		public static bool operator ==(DateTime date, Holiday holiday)
		{
			return date.Month == holiday.Month && date.Day == holiday.Day;
		}
		
		public static bool operator !=(DateTime date, Holiday holiday)
		{
			return !(date == holiday);
		}

		public static bool operator ==(Holiday holiday, DateTime date)
		{
			return date == holiday;
		}

		public static bool operator !=(Holiday holiday, DateTime date)
		{
			return !(date == holiday);
		}

		public override bool Equals(object obj)
		{
			return base.Equals(obj);
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}
	}
}
