using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class IncomeShiftWarehouseDocumentLogic : IncomeWarehouseDocumentLogic
    {
        public IncomeShiftWarehouseDocumentLogic(DocumentCoordinator coordinator)
            : base(coordinator)
        { }

        private void ProcessLocalIncomeShift(WarehouseDocument document)
        {
            if (document.Status != BusinessObjectStatus.New && document.Status != BusinessObjectStatus.Modified)
                return;

            if (document.IsLocalShift()) //mamy MMke lokalna
            {
                Guid outcomeShiftId = new Guid(document.Attributes.Children.Where(aa => aa.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId).First().Value.Value);

                using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                {
                    WarehouseDocument outcomeShift = (WarehouseDocument)c.LoadBusinessObject(BusinessObjectType.WarehouseDocument, outcomeShiftId);

                    var oppositeDocAttr = outcomeShift.Attributes.Children.Where(o => o.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId).FirstOrDefault();

                    if (oppositeDocAttr == null)
                    {
                        oppositeDocAttr = outcomeShift.Attributes.CreateNew();
                        oppositeDocAttr.DocumentFieldName = DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId;
                        oppositeDocAttr.Value.Value = document.Id.ToUpperString();
                    }

                    var oppositeStatusAttr = outcomeShift.Attributes.Children.Where(s => s.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentStatus).FirstOrDefault();

                    if (oppositeStatusAttr == null)
                    {
                        oppositeStatusAttr = outcomeShift.Attributes.CreateNew();
                        oppositeStatusAttr.DocumentFieldName = DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentStatus;
                    }

                    oppositeStatusAttr.Value.Value = ((int)document.DocumentStatus).ToString(CultureInfo.InvariantCulture);

                    c.SaveBusinessObject(outcomeShift);
                }
            }
        }

        private void ProcessShiftOrder(WarehouseDocument document)
        {
            var attr = document.Attributes[DocumentFieldName.Attribute_IncomeShiftOrderId];

            if (attr != null && document.IsNew)
            {
                CommercialDocument shiftOrder = (CommercialDocument)this.mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(attr.Value.Value));

                foreach (var whLine in document.Lines)
                {
                    decimal quantityToGo = whLine.Quantity;

                    foreach (var comLine in shiftOrder.Lines)
                    {
                        if (quantityToGo == 0) break;

                        if (whLine.ItemId == comLine.ItemId)
                        {
                            decimal unrealizedQty = comLine.Quantity - comLine.CommercialWarehouseRelations.Sum(r => r.Quantity);

                            if (unrealizedQty > quantityToGo)
                            {
                                var relation = whLine.CommercialWarehouseRelations.CreateNew();
                                relation.RelatedLine = comLine;
                                relation.IsOrderRelation = true;
                                relation.Quantity = quantityToGo;

                                relation = comLine.CommercialWarehouseRelations.CreateNew();
                                relation.RelatedLine = whLine;
                                relation.IsOrderRelation = true;
                                relation.Quantity = quantityToGo;
                                relation.DontSave = true;
                                quantityToGo = 0;
                            }
                            else if(unrealizedQty > 0) //unrealizedQty <= quantityToGo
                            {
                                var relation = whLine.CommercialWarehouseRelations.CreateNew();
                                relation.RelatedLine = comLine;
                                relation.IsOrderRelation = true;
                                relation.Quantity = unrealizedQty;

                                relation = comLine.CommercialWarehouseRelations.CreateNew();
                                relation.RelatedLine = whLine;
                                relation.IsOrderRelation = true;
                                relation.Quantity = unrealizedQty;
                                relation.DontSave = true;
                                quantityToGo -= unrealizedQty;
                            }
                        }
                    }
                }
            }
        }

        public override XDocument SaveBusinessObject(WarehouseDocument document)
        {
            DictionaryMapper.Instance.CheckForChanges();

            this.DeliverySelectionCheck(document);

            //validate
            document.Validate();

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            this.ProcessShiftOrder(document);

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(document);

                if (document.DocumentStatus == DocumentStatus.Canceled && ConfigurationMapper.Instance.IsWmsEnabled)
                    DependencyContainerManager.Container.Get<WarehouseMapper>().DeleteShiftsForDocument(document.Id.Value);

				if (document.DocumentType.WarehouseDocumentOptions.UpdateLastPurchasePrice)
				{
					UpdateLastPurchasePriceRequest updateLastPurchasePriceRequest = new UpdateLastPurchasePriceRequest(document);
					this.mapper.UpdateStock(updateLastPurchasePriceRequest);
				}
				
				//Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    this.coordinator.UpdateStock(document);
                    //this.mapper.UpdateStockForCanceledDocument(document);

                    this.mapper.ExecuteOperations(operations);

                    this.mapper.CreateCommunicationXml(document);
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations);
                    this.mapper.UpdateDictionaryIndex(document);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((WarehouseDocument)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow
                }

                this.mapper.ValuateIncomeWarehouseDocument(document, false);

                this.ProcessLocalIncomeShift(document);

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", document.Id.ToUpperString()));

				//Custom validation
				this.mapper.ExecuteOnCommitValidationCustomProcedure(document);

				if (this.coordinator.CanCommitTransaction)
                {
                    if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
                        SqlConnectionManager.Instance.CommitTransaction();
                    else
                        SqlConnectionManager.Instance.RollbackTransaction();
                }

                return returnXml;
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:69");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:70");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
