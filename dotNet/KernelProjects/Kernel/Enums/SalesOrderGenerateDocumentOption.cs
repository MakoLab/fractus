using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Exceptions;
using System.Globalization;

namespace Makolab.Fractus.Kernel.Enums
{
	public class SalesOrderGenerateDocumentOption
	{
		public const string Sales = "1";
		public const string Cost = "2";
		public const string SalesReservation = "3";
		public const string CostReservation = "4";

		public static bool IsSales(string value)
		{
			return value == SalesOrderGenerateDocumentOption.Sales || value == SalesOrderGenerateDocumentOption.SalesReservation;
		}

		public static bool IsCost(string value)
		{
			return value == SalesOrderGenerateDocumentOption.Cost || value == SalesOrderGenerateDocumentOption.CostReservation;
		}

		internal static string GetOption(CommercialDocumentLine line)
		{
			DocumentLineAttrValue sogdoAttr = line.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];
			if (sogdoAttr == null)
				throw new ClientException(ClientExceptionId.MissingLineAttribute, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));
			return sogdoAttr.Value.Value;
		}
		
		internal static string TryGetOption(CommercialDocumentLine line)
		{
			DocumentLineAttrValue sogdoAttr = line.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];
			return sogdoAttr == null ? null : sogdoAttr.Value.Value;
		}
	}
}
