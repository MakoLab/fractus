using System;
using System.Collections.Generic;
using System.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;
using Makolab.Fractus.Kernel.Coordinators.Logic;

namespace Makolab.Fractus.Kernel.OutcomeStrategies
{
    /// <summary>
    /// Implements FIFO outcome strategy for warehouses.
    /// </summary>
    internal class FifoStrategy : IOutcomeStrategy
    {
        /// <summary>
        /// Name of the warehouse currently processed.
        /// </summary>
        private string warehouseName;

        /// <summary>
        /// Initializes a new instance of the <see cref="FifoStrategy"/> class.
        /// </summary>
        /// <param name="warehouseName">Name of the warehouse that is currently processed.</param>
        public FifoStrategy(string warehouseName)
        {
            this.warehouseName = warehouseName;
        }

        /// <summary>
        /// Creates the outcomes for the specifies lines using specified deliveries.
        /// </summary>
        /// <param name="lines">The lines for which to create the outcomes. They have to be from the same warehouse.</param>
        /// <param name="deliveryResponses">Collection of delivery responses. Can contain deliveries from other warehouses too.</param>
        public void CreateOutcomes(ICollection<WarehouseDocumentLine> lines, ICollection<DeliveryResponse> deliveryResponses)
        {
            foreach (WarehouseDocumentLine line in lines)
            {
                WarehouseDocument warehouseDocument = line.Parent as WarehouseDocument;

                var deliveryResponse = (from del in deliveryResponses
                                        where del.ItemId == line.ItemId && del.WarehouseId == line.WarehouseId
                                        select del).FirstOrDefault();
                
                var sortedDeliveries = from del in deliveryResponse.Deliveries
                                       where IsValidDelivery(del.IssueDate, warehouseDocument.IssueDate) == true
                                       orderby del.IncomeDate ascending, del.OrdinalNumber ascending
                                       select del;

                decimal originalAvailableQuantity = deliveryResponse.AvailableQuantity;

                decimal quantityToGo = Math.Abs(line.Quantity);

                while (quantityToGo > 0)
                {
                    if (sortedDeliveries.Count() == 0)
                    {
                        string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(line.ItemId);
                        throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + this.warehouseName);
                    }
                    else
                    {
                        DeliveryResponse.SingleDelivery del = sortedDeliveries.First();
                        
                        if (del.Quantity >= quantityToGo)
                        {
                            IncomeOutcomeRelation rel = line.IncomeOutcomeRelations.CreateNew(BusinessObjectStatus.New, WarehouseDirection.Outcome);
                            rel.Quantity = quantityToGo;
                            rel.RelatedLine.Id = del.IncomeWarehouseDocumentLineId;
                            rel.IncomeDate = del.IncomeDate;
                            line.IncomeDate = rel.IncomeDate;
                            del.Quantity -= quantityToGo;
                            deliveryResponse.AvailableQuantity -= quantityToGo;
                            quantityToGo = 0;

                            if (del.Quantity == 0)
                            {
                                rel.OutcomeDate = line.OutcomeDate;
                                deliveryResponse.Deliveries.Remove(del);
                            }
                        }
                        else //del.Quantity < quantityToGo
                        {
                            IncomeOutcomeRelation rel = line.IncomeOutcomeRelations.CreateNew(BusinessObjectStatus.New, WarehouseDirection.Outcome);
                            rel.OutcomeDate = line.OutcomeDate;
                            rel.IncomeDate = del.IncomeDate;
                            line.IncomeDate = rel.IncomeDate;
                            rel.Quantity = del.Quantity;
                            deliveryResponse.AvailableQuantity -= del.Quantity; ;
                            rel.RelatedLine.Id = del.IncomeWarehouseDocumentLineId;
                            quantityToGo -= del.Quantity;
                            deliveryResponse.Deliveries.Remove(del);
                        }
                    }
                }

                //dla wz-tow realizujacych rezerwacje pomijamy ilosci zarezerwowane. bierzemy pod uwage tylko ilosc na stanie i koniec
                if ((!line.CommercialWarehouseRelations.Children.Any(r => r.IsOrderRelation) ||
                    warehouseDocument.SkipReservedQuantityCheck) && deliveryResponse.AvailableQuantity < 0)
                {
                    WarehouseDocumentLine altLine = line.AlternateVersion as WarehouseDocumentLine;

                    /*
                     * tutaj ten if jest w celu obsluzenia takiego przypadku:
                     * Mamy na magazynie 0 sztuk, a zarezerwowane 2
                     * Edytujemy dokument, ktory ma 3 szt. wiec zwalniamy powiazania i tworzymy je na nowo
                     * W tej sytuacji bez tego if'a wyskoczy nam ze mozemy tylko 1 szt. zabrac, a mozemy w praktyce wziasc
                     * wszystkie 3 bo te 3 zostaly przez naz zwolnione
                     */
                    if (altLine == null || altLine.Quantity - originalAvailableQuantity < deliveryResponse.AvailableQuantity)
                    {
                        string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(line.ItemId);
                        throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + this.warehouseName);
                    }
                }
            }
        }

        /// <summary>
        /// Determines whether delivery can be used for outcome by validating dates.
        /// </summary>
        /// <param name="deliveryDate">The delivery issue date.</param>
        /// <param name="outcomeDocumentDate">The outcome document issue date.</param>
        /// <returns>
        /// 	<c>true</c> if TODO [is valid delivery] [the specified delivery date]; otherwise, <c>false</c>.
        /// </returns>
        private bool IsValidDelivery(DateTime deliveryDate, DateTime outcomeDocumentDate)
        {
            DateTime trimmedDeliveryDate = new DateTime(deliveryDate.Year, deliveryDate.Month, deliveryDate.Day, 0, 0, 0);
            DateTime trimmedOutcomeDocumentDate = new DateTime(outcomeDocumentDate.Year, outcomeDocumentDate.Month, outcomeDocumentDate.Day, 0, 0, 0);

            if (trimmedDeliveryDate <= trimmedOutcomeDocumentDate) return true;
            else return false;
        }

        public void CreateLinesForOutcomeShiftDocument(ICollection<WarehouseDocumentLine> sourceLines, ICollection<DeliveryResponse> deliveryResponses, WarehouseDocument destinationDocument)
        {
            foreach (WarehouseDocumentLine line in sourceLines)
            {
                var deliveryResponse = (from del in deliveryResponses
                                        where del.ItemId == line.ItemId && del.WarehouseId == line.WarehouseId
                                        select del).FirstOrDefault();

                var sortedDeliveries = from del in deliveryResponse.Deliveries
                                       where IsValidDelivery(del.IssueDate, destinationDocument.IssueDate) == true
                                       orderby del.IncomeDate ascending
                                       select del;

				decimal originalAvailableQuantity = deliveryResponse.AvailableQuantity;
				
				decimal quantityToGo = line.Quantity;

                while (quantityToGo > 0)
                {
                    if (sortedDeliveries.Count() == 0)
                    {
                        string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(line.ItemId);
                        throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + this.warehouseName);
                    }
                    else
                    {
                        DeliveryResponse.SingleDelivery del = sortedDeliveries.First();

                        if (del.Quantity >= quantityToGo)
                        {
                            //tworzymy linie na dokumencie docelowym
                            WarehouseDocumentLine dstLine = destinationDocument.Lines.CreateNew();
                            dstLine.ItemId = line.ItemId;
                            dstLine.OutcomeDate = destinationDocument.IssueDate;
                            dstLine.Price = line.Price;
                            dstLine.Quantity = quantityToGo;
                            dstLine.UnitId = line.UnitId;
                            dstLine.WarehouseId = destinationDocument.WarehouseId;

                            IncomeOutcomeRelation rel = dstLine.IncomeOutcomeRelations.CreateNew(BusinessObjectStatus.New, WarehouseDirection.Outcome);
                            rel.Quantity = quantityToGo;
                            rel.RelatedLine.Id = del.IncomeWarehouseDocumentLineId;
                            rel.IncomeDate = del.IncomeDate;
                            dstLine.IncomeDate = rel.IncomeDate;
                            del.Quantity -= quantityToGo;
                            deliveryResponse.AvailableQuantity -= quantityToGo;
                            quantityToGo = 0;

                            if (del.Quantity == 0)
                            {
                                rel.OutcomeDate = line.OutcomeDate;
                                deliveryResponse.Deliveries.Remove(del);
                            }
                        }
                        else //del.Quantity < quantityToGo
                        {
                            //tworzymy linie na dokumencie docelowym
                            WarehouseDocumentLine dstLine = destinationDocument.Lines.CreateNew();
                            dstLine.ItemId = line.ItemId;
                            dstLine.OutcomeDate = destinationDocument.IssueDate;
                            dstLine.Price = line.Price;
                            dstLine.Quantity = del.Quantity;
                            dstLine.UnitId = line.UnitId;
                            dstLine.WarehouseId = destinationDocument.WarehouseId;

                            IncomeOutcomeRelation rel = dstLine.IncomeOutcomeRelations.CreateNew(BusinessObjectStatus.New, WarehouseDirection.Outcome);
                            rel.OutcomeDate = dstLine.OutcomeDate;
                            rel.IncomeDate = del.IncomeDate;
                            dstLine.IncomeDate = rel.IncomeDate;
                            rel.Quantity = del.Quantity;
                            deliveryResponse.AvailableQuantity -= del.Quantity;
                            rel.RelatedLine.Id = del.IncomeWarehouseDocumentLineId;
                            quantityToGo -= del.Quantity;
                            deliveryResponse.Deliveries.Remove(del);
                        }
                    }
                }

				//W sytuacji gdy MM- realizuje zamówienie, opcja, która nada odpowiednie powiązanie jest wykonywana po tej metodzie. Dlatego sprawdzane jest tu czy taka opcja jest xml zawarta a potem relacja zostanie dodana
				if ((!destinationDocument.DoesRealizeOrder ||
					destinationDocument.SkipReservedQuantityCheck) && deliveryResponse.AvailableQuantity < 0)
                {
					WarehouseDocumentLine altLine = line.AlternateVersion as WarehouseDocumentLine;
					if (altLine == null || altLine.Quantity - originalAvailableQuantity < deliveryResponse.AvailableQuantity)
					{
						string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(line.ItemId);
						throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + this.warehouseName);
					}
                }
            }
        }
    }
}
