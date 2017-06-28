using System;
using Makolab.Fractus.Kernel.Mappers;
using System.Linq;
using System.Xml.Linq;
using System.Globalization;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using System.Collections.Generic;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
    /// <summary>
    /// Input parameter class for <see cref="DocumentMapper.UpdateStock"/> method.
    /// </summary>
    internal class UpdateStockRequest
	{
		#region Data

		private class RequestItem : UpdateStockRequestEntry
		{
			/// <summary>
			/// Gets or sets the differential quantity.
			/// </summary>
			internal decimal DifferentialQuantity { get; set; }

			/// <summary>
			/// Initializes a new instance of the <see cref="UpdateStockRequest"/> class.
			/// </summary>
			/// <param name="itemId">The item id.</param>
			/// <param name="warehouseId">The warehouse id.</param>
			/// <param name="unitId">The unit id.</param>
			/// <param name="differentialQuantity">The differential quantity.</param>
			internal RequestItem(Guid itemId, Guid warehouseId, Guid unitId, decimal differentialQuantity)
			{
				this.ItemId = itemId;
				this.WarehouseId = warehouseId;
				this.UnitId = unitId;
				this.DifferentialQuantity = differentialQuantity;
			}

			internal override XElement Serialize()
			{
				XElement element = base.Serialize();
				element.Add(new XAttribute("differentialQuantity", this.DifferentialQuantity.ToString(CultureInfo.InvariantCulture)));
				return element;
			}
		}

		protected UpdateStockRequestEntry[] requestItems;

		#endregion

		#region Properties

		/// <summary>
		/// Stored Procedure to call with serilized request as parameter
		/// </summary>
		internal virtual StoredProcedure UpdateStockProcedure
		{
			get
			{
				return StoredProcedure.document_p_updateStock;
			}
		}

		/// <summary>
		/// Serialize request to be called with specified Stored Procedure
		/// </summary>
		/// <returns></returns>
		internal virtual XDocument RequestXml
		{
			get
			{
				XDocument result = XDocument.Parse(@"<root/>");

				foreach (var item in requestItems)
				{
					result.Root.Add(item.Serialize());
				}

				return result;
			}
		}

		/// <summary>
		/// Creates communication xml for request
		/// </summary>
		/// <returns></returns>
		internal virtual XDocument CommunicationXml
		{
			get
			{
				XDocument commXml = XDocument.Parse("<root></root>");

				foreach (UpdateStockRequestEntry entry in requestItems)
				{
					commXml.Root.Add(entry.CommXmlElement());
				}

				return commXml;
			}
		}

		#endregion

		#region Methods

		protected UpdateStockRequest() { }

		/// <summary>
		/// Builds request based on <see cref="WarehouseDocument"/>
		/// </summary>
		/// <param name="warehouseDocument"></param>
		internal UpdateStockRequest(WarehouseDocument warehouseDocument)
		{
			List<RequestItem> requests = new List<RequestItem>();

			//TODO: sprawdzic czy nie trzeba zmienic znaku na przeciwny w tych miejscach bo nei pamietam czy to jest wartosc
			//roznicowa wzgledem magazynu czy wzgledem direction jakie te pozycje maja
			foreach (WarehouseDocumentLine line in warehouseDocument.Lines.Children)
			{
				RequestItem req = requests.Where(x => x.ItemId == line.ItemId && x.WarehouseId == line.WarehouseId).FirstOrDefault();

				if (line.Status == BusinessObjectStatus.New)
				{
					if (req == null)
						requests.Add(new RequestItem(line.ItemId, line.WarehouseId, line.UnitId, line.Direction * line.Quantity));
					else
						req.DifferentialQuantity += line.Direction * line.Quantity;
				}
				else if (line.Status == BusinessObjectStatus.Modified)
				{
					WarehouseDocumentLine alternateLine = (WarehouseDocumentLine)line.AlternateVersion;

					if (req == null)
						requests.Add(new RequestItem(line.ItemId, line.WarehouseId, line.UnitId, line.Direction * line.Quantity - (alternateLine.Direction * alternateLine.Quantity)));
					else
						req.DifferentialQuantity += line.Direction * line.Quantity - (alternateLine.Direction * alternateLine.Quantity);
				}
				else if (line.Status == BusinessObjectStatus.Unchanged)
				{
					if (req == null)
						requests.Add(new RequestItem(line.ItemId, line.WarehouseId, line.UnitId, 0));
				}
			}

			if (warehouseDocument.AlternateVersion != null)
			{
				WarehouseDocument alternate = (WarehouseDocument)warehouseDocument.AlternateVersion;

				var deletedLines = alternate.Lines.Children.Where(l => l.Status == BusinessObjectStatus.Deleted);

				foreach (WarehouseDocumentLine deletedLine in deletedLines)
				{
					RequestItem request = requests.Where(r => r.ItemId == deletedLine.ItemId && r.WarehouseId == deletedLine.WarehouseId).FirstOrDefault();

					WarehouseDirection direction = warehouseDocument.WarehouseDirection;

					if (request == null)
					{
						if (direction == WarehouseDirection.Income || direction == WarehouseDirection.IncomeShift)
							requests.Add(new RequestItem(deletedLine.ItemId, deletedLine.WarehouseId, deletedLine.UnitId, -deletedLine.Quantity));
						else if (direction == WarehouseDirection.Outcome || direction == WarehouseDirection.OutcomeShift)
							requests.Add(new RequestItem(deletedLine.ItemId, deletedLine.WarehouseId, deletedLine.UnitId, deletedLine.Quantity));
					}
					else
					{
						if (direction == WarehouseDirection.Income || direction == WarehouseDirection.IncomeShift)
							request.DifferentialQuantity -= deletedLine.Quantity;
						else if (direction == WarehouseDirection.Outcome || direction == WarehouseDirection.OutcomeShift)
							request.DifferentialQuantity += deletedLine.Quantity;
					}
				}
			}

			this.requestItems = requests.ToArray();
		}
	}
	#endregion
}
