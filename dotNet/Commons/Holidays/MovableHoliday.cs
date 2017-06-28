using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Commons.Holidays
{
	public abstract class MovableHoliday : Holiday
	{
		public int Year { get; set; }

		protected MovableHoliday() { }

		protected abstract void CalculateMonthAndDay();

		public static bool operator ==(DateTime date, MovableHoliday holiday)
		{
			holiday.Year = date.Year;
			holiday.CalculateMonthAndDay();
			return date.Month == holiday.Month && date.Day == holiday.Day && date.Year == holiday.Year;
		}

		public static bool operator !=(DateTime date, MovableHoliday holiday)
		{
			return !(date == holiday);
		}

		public static bool operator ==(MovableHoliday holiday, DateTime date)
		{
			return date == holiday;
		}

		public static bool operator !=(MovableHoliday holiday, DateTime date)
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
