using System;
using System.Collections.Generic;
using System.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.OutcomeStrategies
{
    /// <summary>
    /// Implements FIFO outcome strategy for warehouses.
    /// </summary>
    internal class DeliverySelectionStrategy : IOutcomeStrategy
    {
        /// <summary>
        /// Name of the warehouse currently processed.
        /// </summary>
        private string warehouseName;

        /// <summary>
        /// Initializes a new instance of the <see cref="FifoStrategy"/> class.
        /// </summary>
        /// <param name="warehouseName">Name of the warehouse that is currently processed.</param>
        public DeliverySelectionStrategy(string warehouseName)
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

                var validDeliveries = deliveryResponse.Deliveries.Where(d => this.IsValidDelivery(d.IssueDate, warehouseDocument.IssueDate));

                decimal originalAvailableQuantity = deliveryResponse.AvailableQuantity;

                //tutaj zliczam wszystkie nowe na wypadek edycji bo wtedy powinny zostac wszystkie relacje usuniete i na nowo utworzone
                decimal lineDeliveriesSelected = line.IncomeOutcomeRelations.Children.Where(rr => rr.IsNew).Sum(r => r.Quantity);

				if (lineDeliveriesSelected != Math.Abs(line.Quantity))
				{
					if (warehouseDocument.IsBeforeSystemStartOutcomeCorrection)
					{
						throw new ClientException(ClientExceptionId.NotEnoughQuantityContainerSlot);
					}
					else
					{
						throw new ClientException(ClientExceptionId.NotEnoughDeliveriesSelected, null, "itemName:" + line.ItemName ?? line.ItemId.ToString());
					}
				}

                foreach(IncomeOutcomeRelation relation in line.IncomeOutcomeRelations.Children.Where(c => c.IsNew))
                {
                    //odszukujemy dostawe
                    var del = validDeliveries.Where(d => d.IncomeWarehouseDocumentLineId == relation.RelatedLine.Id.Value).FirstOrDefault();

                    if (del == null || del.Quantity == 0 || del.Quantity < relation.Quantity)
                    {
                        string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(line.ItemId);
                        throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + this.warehouseName);
                    }

                    //ustawiamy income date na relacji
                    relation.IncomeDate = del.IncomeDate;
                    relation.Status = BusinessObjectStatus.New;
                    line.IncomeDate = del.IncomeDate;
                    deliveryResponse.AvailableQuantity -= relation.Quantity;
                    del.Quantity -= relation.Quantity;
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
                WarehouseDocument warehouseDocument = line.Parent as WarehouseDocument;

                var deliveryResponse = (from del in deliveryResponses
                                        where del.ItemId == line.ItemId && del.WarehouseId == line.WarehouseId
                                        select del).FirstOrDefault();

                var validDeliveries = deliveryResponse.Deliveries.Where(d => this.IsValidDelivery(d.IssueDate, warehouseDocument.IssueDate));

                decimal originalAvailableQuantity = deliveryResponse.AvailableQuantity;

                //tutaj zliczam wszystkie nowe na wypadek edycji bo wtedy powinny zostac wszystkie relacje usuniete i na nowo utworzone
                decimal lineDeliveriesSelected = line.IncomeOutcomeRelations.Children.Where(rr => rr.IsNew).Sum(r => r.Quantity);

                if (lineDeliveriesSelected != line.Quantity)
                    throw new ClientException(ClientExceptionId.NotEnoughDeliveriesSelected, null, "itemName:" + line.ItemName);

                foreach (IncomeOutcomeRelation relation in line.IncomeOutcomeRelations.Children.Where(c => c.IsNew))
                {
                    //odszukujemy dostawe
                    var del = validDeliveries.Where(d => d.IncomeWarehouseDocumentLineId == relation.RelatedLine.Id.Value).FirstOrDefault();

                    if (del == null || del.Quantity == 0 || del.Quantity < relation.Quantity)
                    {
                        string itemName = DependencyContainerManager.Container.Get<ItemMapper>().GetItemName(line.ItemId);
                        throw new ClientException(ClientExceptionId.NoItemInStock, null, "itemName:" + itemName, "warehouseName:" + this.warehouseName);
                    }

                    WarehouseDocumentLine dstLine = destinationDocument.Lines.CreateNew();
                    dstLine.SourceOutcomeShiftLine = line;
                    //ustawiamy income date na relacji

                    dstLine.ItemId = line.ItemId;
                    dstLine.OutcomeDate = destinationDocument.IssueDate;
                    dstLine.Price = line.Price;
                    dstLine.Quantity = relation.Quantity;
                    dstLine.UnitId = line.UnitId;
                    dstLine.WarehouseId = destinationDocument.WarehouseId;
                    dstLine.IncomeDate = del.IncomeDate;

                    IncomeOutcomeRelation rel = dstLine.IncomeOutcomeRelations.CreateNew(BusinessObjectStatus.New, WarehouseDirection.Outcome);

                    if (relation.Quantity == del.Quantity)
                        rel.OutcomeDate = dstLine.OutcomeDate;

                    rel.IncomeDate = del.IncomeDate;
                    rel.Quantity = relation.Quantity;
                    rel.RelatedLine.Id = del.IncomeWarehouseDocumentLineId;

                    deliveryResponse.AvailableQuantity -= relation.Quantity;
                    del.Quantity -= relation.Quantity;
                }

                //dla wz-tow realizujacych rezerwacje pomijamy ilosci zarezerwowane. bierzemy pod uwage tylko ilosc na stanie i koniec
                if (!line.CommercialWarehouseRelations.Children.Any(r => r.IsOrderRelation) && deliveryResponse.AvailableQuantity < 0)
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

            //przepinamy shifty do nowo podzielonych linii
            if (destinationDocument.ShiftTransaction != null)
            {
                foreach (Shift shift in destinationDocument.ShiftTransaction.Shifts.Children)
                {
                    var foundLine = destinationDocument.Lines.Children.Where(l => 
                        l.IncomeOutcomeRelations.Children.First().RelatedLine.Id.Value == shift.IncomeWarehouseDocumentLineId 
                        && shift.LineOrdinalNumber.Value == l.SourceOutcomeShiftLine.OrdinalNumber).FirstOrDefault();
                    shift.RelatedWarehouseDocumentLine = foundLine;
                }
            }
        }
    }
}
