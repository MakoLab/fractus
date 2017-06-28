using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Commons;
using System.Xml.Linq;
using System.Globalization;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
	internal class UpdateLastPurchasePriceRequest : UpdateStockRequest
	{
		#region Data
		/// <summary>
		/// Request item
		/// </summary>
		private class RequestItem : UpdateStockRequestEntry
		{
			internal decimal LastPurchaseNetPrice { get; set; }

			internal override XElement Serialize()
			{
				XElement result = base.Serialize();
				result.Add(new XAttribute("lastPurchaseNetPrice", this.LastPurchaseNetPrice.ToString(CultureInfo.InvariantCulture)));
				return result;
			}
		}

		private DateTime issueDate;

		#endregion

		#region Properties

		internal override StoredProcedure UpdateStockProcedure
		{
			get
			{
				return StoredProcedure.document_p_updateLastPurchasePrice;
			}
		}

		internal override XDocument RequestXml
		{
			get
			{
				XDocument result = base.RequestXml;
				result.Root.Add(new XAttribute("issueDate", issueDate.ToIsoString()));
				return result;
			}
		}

		#endregion

		#region Internal Methods

		internal UpdateLastPurchasePriceRequest(CommercialDocument commercialDocument)
		{
			//for each unique pair itemId and warehouse Id finds last record and sets its netPrice as lastPurchaseNetPrice
			this.requestItems = commercialDocument.Lines.Where(line => line.WarehouseId.HasValue).
				GroupBy(line => new { line.WarehouseId, line.ItemId }).
				Select(group => new RequestItem() { 
					ItemId = group.Key.ItemId, 
					WarehouseId = group.Key.WarehouseId.Value, 
					UnitId = group.Last().UnitId, 
					LastPurchaseNetPrice = commercialDocument.GetValueInSystemCurrency(group.Last().NetPrice) 
				}).ToArray();

			this.issueDate = commercialDocument.IssueDate;
		}

		internal UpdateLastPurchasePriceRequest(WarehouseDocument warehouseDocument)
		{
			//for each unique pair itemId and warehouse Id finds last record and sets its netPrice as lastPurchaseNetPrice
			this.requestItems = warehouseDocument.Lines.GroupBy(line => new { line.WarehouseId, line.ItemId }).
				Select(group => new RequestItem() {
					ItemId = group.Key.ItemId,
					WarehouseId = group.Key.WarehouseId,
					UnitId = group.Last().UnitId,
					LastPurchaseNetPrice = group.Last().Price
				}).ToArray();

			this.issueDate = (warehouseDocument.InitialCorrectedDocument ?? warehouseDocument).IssueDate;
		}

		internal void UpdateIssueDateForCorrectiveDocument(CommercialDocument correctiveDocument)
		{
			if (correctiveDocument != null && correctiveDocument.IsCorrectiveDocument())
			{
				this.issueDate = correctiveDocument.InitialCorrectedDocument.IssueDate;
			}
		}

		#endregion
	}
}
