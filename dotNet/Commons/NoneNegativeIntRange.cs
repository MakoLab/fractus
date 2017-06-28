using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;

namespace Makolab.Fractus.Commons
{
	/// <summary>
	/// Zakres intów parsowany z zapisy x,y gdzie x,y przedział łącznie z krańcami
	/// y może być pominięty np. x,
	/// Zapis x oznacza dokładnie jedną wartość
	/// </summary>
	public class NoneNegativeIntRange
	{
		public int Min { get; set; }
		public int Max { get; set; }
		public bool IsUndefined { get; private set; }
		public bool IsMaxInfinity { get; private set; }
		public bool IsSingleValue { get; private set; }

		public NoneNegativeIntRange(string rangeString)
		{
			string COMA = ",";
			int min = 0;
			int max = 0;
			this.IsUndefined = true;
			if (rangeString == null)
				return;
			if (rangeString.Contains(COMA))
			{
				string first = rangeString.SubstringBefore(COMA);
				string second = rangeString.SubstringAfter(COMA);
				if (Int32.TryParse(first, out min))
				{
					this.Min = min;
				}
				else return;

				if (second.Length == 0)
				{
					this.IsMaxInfinity = true;
				}
				else if (Int32.TryParse(second, out max))
				{
					this.Max = max;
				}
				else return;
			}
			else
			{
				if (Int32.TryParse(rangeString, out min))
				{
					this.Min = min;
					this.IsSingleValue = true;
				}
				else return;
			}
			if (this.Min < 0)
				Min = 0;
			if (this.Max < 0)
				Max = 0;

			this.IsUndefined = !this.IsSingleValue && !this.IsMaxInfinity && this.Max < this.Min;
		}

		public string Serialize()
		{
			if (!this.IsUndefined)
			{
				if (this.IsSingleValue)
				{
					return this.Min.ToString(CultureInfo.InvariantCulture);
				}
				else
				{
					return String.Format("{0},{1}", this.Min.ToString(CultureInfo.InvariantCulture),
						this.IsMaxInfinity ? String.Empty : this.Max.ToString(CultureInfo.InvariantCulture));
				}
			}
			return String.Empty;
		}

		public bool IsInRange(int x)
		{
			if (!this.IsUndefined)
			{
				if (this.IsSingleValue)
					return this.Min == x;

				if (x < this.Min || !this.IsMaxInfinity && x > this.Max)
					return false;

				return true;
			}
			return false;
		}
	}
}
