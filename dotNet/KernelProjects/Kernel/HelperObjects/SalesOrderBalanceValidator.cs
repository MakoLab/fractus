using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Kernel.HelperObjects
{
	/// <summary>
	/// Validates settlement Invoice Ballance Margin
	/// </summary>
	public class SalesOrderBalanceValidator
	{
		private decimal MaxSettlementDifference { get; set; }
		private decimal GrossBalance { get; set; }
		private decimal NetBalance { get; set; }
		private decimal VatBalance { get; set; }

		public SalesOrderBalanceValidator(decimal maxDiff, SalesOrderSettlement settlement)
		{
			MaxSettlementDifference = maxDiff;
			GrossBalance = settlement.GrossValue;
			NetBalance = settlement.NetValue;
			VatBalance = settlement.VatValue;
		}

		public SalesOrderBalanceValidator(decimal maxDiff, decimal gross, decimal net, decimal vat)
		{
			MaxSettlementDifference = maxDiff;
			GrossBalance = gross;
			NetBalance = net;
			VatBalance = vat;
		}

		/// <summary>
		/// Nadpłata w granicach błędu
		/// </summary>
		public bool IsAcceptableOverPayment
		{
			get
			{
				return -GrossBalance <= MaxSettlementDifference && GrossBalance < 0
								|| -NetBalance <= MaxSettlementDifference && NetBalance < 0
								|| -VatBalance <= MaxSettlementDifference && VatBalance < 0;
			}
		}

		/// <summary>
		/// Nadpłata powyżej granicy błędu
		/// </summary>
		public bool IsIllegalOverPayment
		{
			get
			{
				return -GrossBalance > MaxSettlementDifference && GrossBalance < 0
								|| -NetBalance > MaxSettlementDifference && NetBalance < 0
								|| -VatBalance > MaxSettlementDifference && VatBalance < 0;
			}
		}
	}
}
