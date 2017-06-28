using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
	internal class SalesOrderSalesType
	{
		internal const string ItemSale = "itemSale";
		internal const string ItemSaleReservation = "itemSaleReservation";
		internal const string ServiceSale = "serviceSale";
		internal const string ServiceSaleReservation = "serviceSaleReservation";

		private bool Reservation;
		private bool Items;
		private bool Services { get { return !Items; } }
		
		internal string Type { get; set; }

		private void Parse()
		{
			this.Items = this.Type == SalesOrderSalesType.ItemSale || this.Type == SalesOrderSalesType.ItemSaleReservation;
			this.Reservation = this.Type == SalesOrderSalesType.ItemSaleReservation || this.Type == SalesOrderSalesType.ServiceSaleReservation;
		}

		internal SalesOrderSalesType(string type) 
		{ 
			this.Type = type; 
			this.Parse(); 
		}

		internal string GetSalesOrderGenerateDocumentOption(bool isWarehouseStorable)
		{
			if (this.Services && isWarehouseStorable)
			{
				return this.Reservation ? SalesOrderGenerateDocumentOption.CostReservation : SalesOrderGenerateDocumentOption.Cost;
			}
			else
			{
				return this.Reservation ? SalesOrderGenerateDocumentOption.SalesReservation : SalesOrderGenerateDocumentOption.Sales;
			}
		}
	}
}
