using System;
using System.Data.SqlClient;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Documents.Options;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class DocumentStatusChangeLogic
    {
        private DocumentCoordinator coordinator;
        private DocumentMapper mapper;

        public DocumentStatusChangeLogic(DocumentCoordinator coordinator)
        {
            this.coordinator = coordinator;
            this.mapper = (DocumentMapper)coordinator.Mapper;
        }

        private void ResetCommercialDocumentLinesFlags(CommercialDocument document)
        {
            foreach (CommercialDocumentLine line in document.Lines.Children)
            {
                line.CommercialDirection = 0;
                line.OrderDirection = 0;
				DocumentStatusChangeLogic.TryRemoveCommercialDocumentToSalesOrderRelations(line);
                //zakomentowane bo p_unrelateCommercialDocumentFromWarehouseDocument juz to zrobi
                //line.CommercialWarehouseRelations.RemoveAll();
                //line.CommercialWarehouseValuations.RemoveAll();
            }

            foreach (Payment pt in document.Payments.Children)
            {
                pt.Settlements.RemoveAll();
                pt.Direction = 0;
            }
        }

        private void ResetWarehouseDocumentLinesFlags(WarehouseDocument document)
        {
            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                line.Direction = 0;
                line.CommercialWarehouseRelations.RemoveAll();
                line.CommercialWarehouseValuations.RemoveAll();
            }

            document.Relations.RemoveAll();
        }

        public static void CancelFinancialDocument(FinancialDocument document)
        {
            document.Relations.RemoveAll();
            document.DocumentStatus = DocumentStatus.Canceled;

            foreach (Payment pt in document.Payments.Children)
            {
                pt.Settlements.RemoveAll();
                pt.Direction = 0;
                pt.ForceSave = true;//napewno trzeba ten stan zapisać
            }
        }

		internal static void TryRemoveCommercialDocumentToSalesOrderRelations(CommercialDocumentLine documentLine)
		{
			DocumentLineAttrValue rsoliAttr = documentLine.Attributes[DocumentFieldName.LineAttribute_RealizedSalesOrderLineId];
			if (rsoliAttr != null)
			{
				documentLine.Attributes.Remove(rsoliAttr);
			}
		}

        public void ChangeDocumentStatus(Document document, DocumentStatus requestedStatus)
        {
            WarehouseDocument warehouseDocument = document as WarehouseDocument;
            FinancialDocument financialDocument = document as FinancialDocument;
            ServiceDocument serviceDocument = document as ServiceDocument;
            InventoryDocument inventoryDocument = document as InventoryDocument;
            ComplaintDocument complaintDocument = document as ComplaintDocument;
            CommercialDocument commercialDocument = document as CommercialDocument;

            DocumentStatus actualStatus = document.DocumentStatus;
            Guid documentId = document.Id.Value;

			bool useStandardCancelProcessing = false;

			#region MM+
			if (warehouseDocument != null && warehouseDocument.WarehouseDirection == WarehouseDirection.IncomeShift) //MM+
			{
				if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Committed)
				{
					warehouseDocument.DocumentStatus = DocumentStatus.Committed;
					warehouseDocument.IssueDate = SessionManager.VolatileElements.CurrentDateTime;

					foreach (WarehouseDocumentLine line in warehouseDocument.Lines.Children)
					{
						line.Direction = 1;
						line.IncomeDate = SessionManager.VolatileElements.CurrentDateTime;
					}

					this.coordinator.SaveBusinessObject(warehouseDocument);
				}
				else if ((actualStatus == DocumentStatus.Committed || actualStatus == DocumentStatus.Saved) && requestedStatus == DocumentStatus.Canceled)
				{
					useStandardCancelProcessing = true;
				}
			}
			#endregion
			#region MM-
			else if (warehouseDocument != null && warehouseDocument.WarehouseDirection == WarehouseDirection.OutcomeShift) //MM-
			{
				if (actualStatus == DocumentStatus.Committed && requestedStatus == DocumentStatus.Canceled)
				{
					useStandardCancelProcessing = true;

					foreach (var line in warehouseDocument.Lines)
					{
						line.IncomeOutcomeRelations.RemoveAll();
					}
				}
			}
			#endregion
			#region FinancialDocument
			else if (financialDocument != null)
			{
				if (actualStatus == DocumentStatus.Committed && requestedStatus == DocumentStatus.Canceled)
				{
					DocumentStatusChangeLogic.CancelFinancialDocument(financialDocument);

					this.coordinator.SaveBusinessObject(financialDocument);
				}
			}
			#endregion
			#region WarehouseDocumentCorrection
			else if (warehouseDocument != null && (warehouseDocument.DocumentType.DocumentCategory == DocumentCategory.IncomeWarehouseCorrection ||
				warehouseDocument.DocumentType.DocumentCategory == DocumentCategory.OutcomeWarehouseCorrection))
			{
				SqlConnectionManager.Instance.BeginTransaction();

				try
				{
					if (ConfigurationMapper.Instance.IsWmsEnabled)
						DependencyContainerManager.Container.Get<WarehouseMapper>().DeleteShiftsForDocument(warehouseDocument.Id.Value);

					this.mapper.CancelWarehouseDocument(warehouseDocument.Id.Value);
					Coordinator.LogSaveBusinessObjectOperation();

					if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
						SqlConnectionManager.Instance.CommitTransaction();
					else
						SqlConnectionManager.Instance.RollbackTransaction();
				}
				catch (SqlException sqle)
				{
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:59");
					Coordinator.ProcessSqlException(sqle, document.BOType, true);
					throw;
				}
				catch (Exception)
				{
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:60");
					SqlConnectionManager.Instance.RollbackTransaction();
					throw;
				}
			}
			#endregion
			#region ServiceDocument
			else if (serviceDocument != null)
			{
				if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Canceled)
				{
					using (DocumentCoordinator c = new DocumentCoordinator(false, true))
					{
						c.CancelServiceDocument(serviceDocument);
					}
				}
			}
			#endregion
			#region InventoryDocument
			else if (inventoryDocument != null)
			{
				if (actualStatus == DocumentStatus.Saved && (requestedStatus == DocumentStatus.Committed || requestedStatus == DocumentStatus.Canceled))
				{
					inventoryDocument.DocumentStatus = requestedStatus;

					using (DocumentCoordinator c = new DocumentCoordinator(false, true))
					{
						c.SaveBusinessObject(inventoryDocument);
					}
				}
			}
			#endregion
			#region ComplaintDocument
			else if (complaintDocument != null)
            {
                if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Canceled)
                {
                    SqlConnectionManager.Instance.BeginTransaction();
                    this.coordinator.CanCommitTransaction = false;

                    foreach (DocumentRelation relation in complaintDocument.Relations)
                    {
                        if (relation.RelationType == DocumentRelationType.ComplaintToInternalIncome ||
                            relation.RelationType == DocumentRelationType.ComplaintToInternalOutcome)
                        {
                            using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                            {
                                XDocument xml = new XDocument(new XElement("root"));
                                xml.Root.Add(new XElement("warehouseDocumentId", relation.RelatedDocument.Id.ToUpperString()));
                                xml.Root.Add(new XElement("status", "-20"));
                                c.ChangeDocumentStatus(xml);
                            }
                        }
                    }

                    complaintDocument.DocumentStatus = DocumentStatus.Canceled;
                    complaintDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "closed";

                    try
                    {
                        this.coordinator.SaveBusinessObject(complaintDocument);

                        if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
                            SqlConnectionManager.Instance.CommitTransaction();
                        else
                            SqlConnectionManager.Instance.RollbackTransaction();
                    }
                    catch (SqlException sqle)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:61");
                        Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                        throw;
                    }
                    catch (Exception)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:62");
                        SqlConnectionManager.Instance.RollbackTransaction();
                        throw;
                    }
                }
                else if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Committed)
                {
                    if (complaintDocument.DocumentOptions.Where(o => o is CloseProcessOption).FirstOrDefault() == null)
                        complaintDocument.DocumentOptions.Add(new CloseProcessOption());

                    this.coordinator.SaveBusinessObject(complaintDocument);
                }
            }
			#endregion
			#region SalesOrder
			else if (commercialDocument != null && commercialDocument.DocumentType.DocumentCategory == DocumentCategory.SalesOrder)
			{
				if (actualStatus == DocumentStatus.Committed && requestedStatus == DocumentStatus.Saved) //anulowanie rozliczenia
				{
					SalesOrderFactory.OpenSalesOrder(commercialDocument);
					commercialDocument.Attributes.Remove(commercialDocument.Attributes[DocumentFieldName.Attribute_SettlementDate]);
					commercialDocument.DocumentStatus = DocumentStatus.Saved;
				}
				else if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Canceled)
				{
					commercialDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "canceled";
					commercialDocument.DocumentStatus = DocumentStatus.Canceled;

					foreach (CommercialDocumentLine line in commercialDocument.Lines.Children)
					{
						line.CommercialDirection = 0;
						line.OrderDirection = 0;
						line.CommercialWarehouseRelations.RemoveAll();
					}
				}
				else if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Committed)
				{
					bool result = SalesOrderFactory.TryCloseSalesOrder(commercialDocument);

					if (!result)
						throw new ClientException(ClientExceptionId.ErrorClosingSalesOrder);
				}

				this.coordinator.SaveBusinessObject(document);
			}
			#endregion
			#region ProductionOrder
			else if (commercialDocument != null && commercialDocument.DocumentType.DocumentCategory == DocumentCategory.ProductionOrder)
			{
				if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Committed)
				{
					commercialDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "closed";
					commercialDocument.DocumentStatus = DocumentStatus.Committed;
				}
				else if (actualStatus == DocumentStatus.Saved && requestedStatus == DocumentStatus.Canceled)
				{
					commercialDocument.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value = "canceled";
					commercialDocument.DocumentStatus = DocumentStatus.Canceled;
				}

				this.coordinator.SaveBusinessObject(document);
			}
			#endregion
            else if (actualStatus == DocumentStatus.Committed && requestedStatus == DocumentStatus.Canceled)
            {
				useStandardCancelProcessing = true;
            }

			//standardowa część anulowania dokumentu
			if (useStandardCancelProcessing)
			{
				SqlConnectionManager.Instance.BeginTransaction();
				this.coordinator.CanCommitTransaction = false;

				document.DocumentStatus = DocumentStatus.Canceled;

				if (document.BOType == BusinessObjectType.CommercialDocument)
				{
					commercialDocument.ValidateSalesOrderRealizedLines(false);//muszę najpierw sprawdzić są pow. z ZS bo potem usuwam atrybut
					this.ResetCommercialDocumentLinesFlags(commercialDocument);
				}
				else
				{
					warehouseDocument.CheckDoesRealizeClosedSalesOrder(coordinator);//sprawdzenie przed usunięciem relacji
					this.ResetWarehouseDocumentLinesFlags(warehouseDocument);
				}
				document.Relations.RemoveAll();

				try
				{
					this.coordinator.SaveBusinessObject(document);

					if (document.BOType == BusinessObjectType.CommercialDocument)
						this.mapper.UnrelateCommercialDocumentFromWarehouseDocuments(documentId);
					else
						this.mapper.DeleteWarehouseDocumentRelations((WarehouseDocument)document);

					if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
						SqlConnectionManager.Instance.CommitTransaction();
					else
						SqlConnectionManager.Instance.RollbackTransaction();
				}
				catch (SqlException sqle)
				{
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:63");
					Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
					throw;
				}
				catch (Exception)
				{
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:64");
					SqlConnectionManager.Instance.RollbackTransaction();
					throw;
				}
			}
        }
    }
}
