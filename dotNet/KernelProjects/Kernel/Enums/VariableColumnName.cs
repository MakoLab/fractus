using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Kernel.Enums
{
	public class VariableColumnName
	{
		public const string TextValue = "textValue";
		public const string DecimalValue = "decimalValue";
		public const string DateValue = "dateValue";
		public const string XmlValue = "xmlValue";
		public const string GuidValue = "guidValue";

		public static bool IsVariableColumnName(string name)
		{
			return name == VariableColumnName.TextValue || name == VariableColumnName.DecimalValue ||
						name == VariableColumnName.DateValue || name == VariableColumnName.XmlValue ||
						name == VariableColumnName.GuidValue;
		}
	}
}
