using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TrackerDataAccessLayer
{
	public static class Extensions
	{
		public static string ToCurrency(this decimal? number)
		{
			return number.HasValue ? String.Format("{0:N} PLN", number) : String.Empty;
		}

		public static string ToShortDate(this DateTime? date)
		{
			return date.HasValue ? date.Value.ToShortDateString() : String.Empty;
		}
	}
}
