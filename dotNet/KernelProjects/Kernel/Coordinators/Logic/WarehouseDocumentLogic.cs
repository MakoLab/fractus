using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class WarehouseDocumentLogic
    {
        protected DocumentMapper mapper;
        protected DocumentCoordinator coordinator;

        public WarehouseDocumentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        public void ExecuteDocumentOptions(WarehouseDocument document)
        {
            foreach (IDocumentOption option in document.DocumentOptions)
            {
                option.Execute(document);
            }
        }

        protected void DeliverySelectionCheck(WarehouseDocument document)
        {
            Guid warehouseId = document.WarehouseId;
            bool isDeliverySelection = DictionaryMapper.Instance.GetWarehouse(warehouseId).ValuationMethod == ValuationMethod.DeliverySelection;

            if (!isDeliverySelection && document.ShiftTransaction != null)
                throw new ClientException(ClientExceptionId.DeliveriesInNonDeliverySelectedWarehouseError);

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                if (!isDeliverySelection && line.IsNew && line.IncomeOutcomeRelations.Children.Count != 0)
                    throw new ClientException(ClientExceptionId.DeliveriesInNonDeliverySelectedWarehouseError);
            }
        }

        private void CreateValidationDictionaries(WarehouseDocument document, ref Dictionary<Guid, Dictionary<Guid, decimal>> dctRelated, ref Dictionary<Guid, decimal> dctUnrelated)
        {
            List<Guid> linesId = new List<Guid>();

            foreach (WarehouseDocumentLine whLine in document.Lines.Children)
            {
                foreach (IncomeOutcomeRelation rel in whLine.IncomeOutcomeRelations.Children)
                {
                    linesId.Add(rel.RelatedLine.Id.Value);
                }
            }

            XElement xml = DependencyContainerManager.Container.Get<WarehouseMapper>().GetShiftsForIncomeWarehouseLines(linesId);

            //id linii przychodowej->id shifta->quantity
            dctRelated = new Dictionary<Guid, Dictionary<Guid, decimal>>();

            //id linii przychodowej->ilosc nieprzypisanych do kontenerow
            dctUnrelated = new Dictionary<Guid, decimal>();

            /*
               <root> 
                  <line id="..."quantity="..."> 
                    <shift id="..." quantity="..." /> 
                    <shift id="..." quantity="..." /> 
                    .... 
                  </line> 
                  <line id="..."quantity="..."> 
                    <shift id="..." quantity="..." /> 
                    .... 
                  </line> 
                ... 
               </root> 
             */
            foreach (XElement lineElement in xml.Elements())
            {
                Dictionary<Guid, decimal> innerDict = new Dictionary<Guid, decimal>();

                Guid lineId = new Guid(lineElement.Attribute("id").Value);

                dctRelated.Add(lineId, innerDict);

                decimal relatedQty = 0;

                foreach (XElement shiftElement in lineElement.Elements())
                {
                    decimal qty = Convert.ToDecimal(shiftElement.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                    innerDict.Add(new Guid(shiftElement.Attribute("id").Value), qty);
                    relatedQty += qty;
                }

                decimal totalQty = Convert.ToDecimal(lineElement.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                dctUnrelated.Add(lineId, totalQty - relatedQty);
            }

            //jezeli dokument jest edytowany to dodajemy to co bylo
            if (document.AlternateVersion != null)
            {
                WarehouseDocument alternateDocument = (WarehouseDocument)document.AlternateVersion;

                //zliczamy ilosci nie powiazane z shiftami
                foreach (WarehouseDocumentLine line in alternateDocument.Lines.Children)
                {
                    foreach (IncomeOutcomeRelation rel in line.IncomeOutcomeRelations.Children)
                    {
                        decimal unrelatedQty = rel.Quantity;

                        if (alternateDocument.ShiftTransaction != null)
                        {
                            //wszystkie shifty wskazujace na line i sciagajace z dostawy rel
                            decimal relatedQty = alternateDocument.ShiftTransaction.Shifts.Children.Where(s => s.RelatedWarehouseDocumentLine == line && s.IncomeWarehouseDocumentLineId == rel.RelatedLine.Id.Value).Sum(sh => sh.Quantity);
                            unrelatedQty -= relatedQty;
                        }

                        if (dctUnrelated.ContainsKey(rel.RelatedLine.Id.Value))
                            dctUnrelated[rel.RelatedLine.Id.Value] += unrelatedQty;
                        else
                            dctUnrelated.Add(rel.RelatedLine.Id.Value, unrelatedQty);
                    }
                }

                //zliczamy ilosci powiazane
                if (alternateDocument.ShiftTransaction != null)
                {
                    foreach (Shift shift in alternateDocument.ShiftTransaction.Shifts.Children)
                    {
                        Dictionary<Guid, decimal> innerDict = null;

                        if (dctRelated.ContainsKey(shift.IncomeWarehouseDocumentLineId))
                            innerDict = dctRelated[shift.IncomeWarehouseDocumentLineId];
                        else
                        {
                            innerDict = new Dictionary<Guid, decimal>();
                            dctRelated.Add(shift.IncomeWarehouseDocumentLineId, innerDict);
                        }

                        if (innerDict.ContainsKey(shift.SourceShiftId.Value))
                            innerDict[shift.SourceShiftId.Value] += shift.Quantity;
                        else
                            innerDict.Add(shift.SourceShiftId.Value, shift.Quantity);
                    }
                }
            }
        }

        protected void ValidateShiftsToLinesRelations(WarehouseDocument document)
        {
            if (document.WarehouseDirection != WarehouseDirection.Outcome &&
                document.WarehouseDirection != WarehouseDirection.OutcomeShift)
                return;

            bool isDeliverySelection = DictionaryMapper.Instance.GetWarehouse(document.WarehouseId).ValuationMethod == ValuationMethod.DeliverySelection;

            if (isDeliverySelection && ConfigurationMapper.Instance.IsWmsEnabled)
            {
                Dictionary<Guid, Dictionary<Guid, decimal>> dctRelated = null;
                Dictionary<Guid, decimal> dctUnrelated = null;
                this.CreateValidationDictionaries(document, ref dctRelated, ref dctUnrelated);

                //sprawdzamy ilosci niepowiazane z shiftami
                foreach (WarehouseDocumentLine line in document.Lines.Children)
                {
                    foreach (IncomeOutcomeRelation rel in line.IncomeOutcomeRelations.Children)
                    {
                        decimal unrelatedQty = rel.Quantity;

                        if (document.ShiftTransaction != null)
                        {
                            decimal relatedQty = document.ShiftTransaction.Shifts.Children.Where(s => s.RelatedWarehouseDocumentLine == line && s.IncomeWarehouseDocumentLineId == rel.RelatedLine.Id.Value).Sum(sh => sh.Quantity);
                            unrelatedQty -= relatedQty;
                        }

                        dctUnrelated[rel.RelatedLine.Id.Value] -= unrelatedQty;

                        //ciągłe kłopoty z wms
                        //if (dctUnrelated[rel.RelatedLine.Id.Value] < 0)
                        //    throw new ClientException(ClientExceptionId.ContainerUnrelatedQuantityExceeded);
                    }
                }

                if (document.ShiftTransaction != null)
                {
                    foreach (Shift shift in document.ShiftTransaction.Shifts.Children)
                    {
                        //CzarekW - wogole nie mam pojęcia skąd założenie że każdy shift musi mieć SourceShiftId dlatego dodałem warunek
                        //if (shift.SourceShiftId != null)
                        //{

                            //if (!dctRelated[shift.IncomeWarehouseDocumentLineId].ContainsKey(shift.SourceShiftId.Value))
                            //{
                            //    string containerName = DependencyContainerManager.Container.Get<WarehouseMapper>().GetContainerSymbolByShiftId(shift.SourceShiftId.Value);

                            //    throw new ClientException(ClientExceptionId.ContainerRelatedQuantityExceeded, null, "containerName:" + containerName);
                            //}

                            dctRelated[shift.IncomeWarehouseDocumentLineId][shift.SourceShiftId.Value] -= shift.Quantity;

                            //if (dctRelated[shift.IncomeWarehouseDocumentLineId][shift.SourceShiftId.Value] < 0)
                            //{
                            //    string containerName = DependencyContainerManager.Container.Get<WarehouseMapper>().GetContainerSymbolByShiftId(shift.SourceShiftId.Value);

                            //    throw new ClientException(ClientExceptionId.ContainerRelatedQuantityExceeded, null, "containerName:" + containerName);
                            //}
                        //}
                        //else
                        //{
                        //    throw new ClientException(ClientExceptionId.NoContainerIdOnShift, null, "containerName: BRAK " );
                        //}
                    }
                }
            }
        }
    }
}
