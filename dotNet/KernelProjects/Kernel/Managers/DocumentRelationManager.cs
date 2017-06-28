using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.Managers
{
    internal static class DocumentRelationManager
    {
        public static void GetColumnNames(DocumentRelation relation, ref string parentColumnName, ref string relatedDocumentColumnName)
        {
            Document parent = (Document)relation.Parent;
            DocumentRelationType relationType = relation.RelationType;

            switch (relationType)
            {
                case DocumentRelationType.SalesDocumentToSimulatedInvoice:
                    if (parent.DocumentType.CommercialDocumentOptions.SimulatedInvoice != null)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondCommercialDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.InvoiceToBill:
                    if (parent.DocumentType.CommercialDocumentOptions.IsInvoiceAppendable) //parent relacji to paragon
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondCommercialDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.ServiceToOutcomeShift:
                    if (parent.BOType == BusinessObjectType.ServiceDocument)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondWarehouseDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondWarehouseDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.ServiceToInvoice:
                    if (parent.BOType == BusinessObjectType.ServiceDocument)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondCommercialDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.ServiceToInternalOutcome:
                    if (parent.BOType == BusinessObjectType.ServiceDocument)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondWarehouseDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondWarehouseDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.ComplaintToInternalOutcome:
                    if (parent.BOType == BusinessObjectType.ComplaintDocument)
                    {
                        parentColumnName = "firstComplaintDocumentHeaderId";
                        relatedDocumentColumnName = "secondWarehouseDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondWarehouseDocumentHeaderId";
                        relatedDocumentColumnName = "firstComplaintDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.InventoryToWarehouse:
                    if (parent.BOType == BusinessObjectType.InventoryDocument)
                    {
                        parentColumnName = "firstInventoryDocumentHeaderId";
                        relatedDocumentColumnName = "secondWarehouseDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondWarehouseDocumentHeaderId";
                        relatedDocumentColumnName = "firstInventoryDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.SalesOrderToInvoice:
                case DocumentRelationType.SalesOrderToCorrectiveCommercialDocument:
				case DocumentRelationType.SalesOrderToSimulatedInvoice:
                    if (parent.Attributes[DocumentFieldName.Attribute_ProcessObject] != null && parent.Attributes[DocumentFieldName.Attribute_ProcessObject].Value.Value == ProcessObjectName.SalesOrder)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondCommercialDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.SalesOrderToWarehouseDocument:
                    if (parent.BOType == BusinessObjectType.CommercialDocument)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondWarehouseDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondWarehouseDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.SalesOrderToOutcomeFinancialDocument:
                    if (parent.BOType == BusinessObjectType.CommercialDocument)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondFinancialDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondFinancialDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                case DocumentRelationType.ProductionOrderToIncome:
                case DocumentRelationType.ProductionOrderToOutcome:
                    if (parent.BOType == BusinessObjectType.CommercialDocument)
                    {
                        parentColumnName = "firstCommercialDocumentHeaderId";
                        relatedDocumentColumnName = "secondWarehouseDocumentHeaderId";
                    }
                    else
                    {
                        parentColumnName = "secondWarehouseDocumentHeaderId";
                        relatedDocumentColumnName = "firstCommercialDocumentHeaderId";
                    }
                    break;
                default:
                    throw new InvalidOperationException("Unknown DocumentRelationType");
            }
        }

        public static Document DeserializeRelatedDocument(DocumentRelation relation, XElement relatedDocument)
        {
            Document parent = (Document)relation.Parent;
            DocumentRelationType relationType = relation.RelationType;

            Document retDocument = null;

			if (relatedDocument == null)
			{
				throw new ClientException(ClientExceptionId.IncompleteRelation);
			}

            switch (relationType)
            {
                case DocumentRelationType.SalesDocumentToSimulatedInvoice:
                case DocumentRelationType.InvoiceToBill:
                    retDocument = new CommercialDocument();
                    retDocument.Deserialize(relatedDocument);
                    break;
                case DocumentRelationType.ServiceToOutcomeShift:
                    if (parent.BOType == BusinessObjectType.ServiceDocument)
                    {
                        retDocument = new WarehouseDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new ServiceDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                case DocumentRelationType.ServiceToInvoice:
                    if (parent.BOType == BusinessObjectType.ServiceDocument)
                    {
                        retDocument = new CommercialDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new ServiceDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                case DocumentRelationType.ServiceToInternalOutcome:
                    if (parent.BOType == BusinessObjectType.ServiceDocument)
                    {
                        retDocument = new WarehouseDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new ServiceDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                case DocumentRelationType.ComplaintToInternalOutcome:
                    if (parent.BOType == BusinessObjectType.ComplaintDocument)
                    {
                        retDocument = new WarehouseDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new ComplaintDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                case DocumentRelationType.InventoryToWarehouse:
                    if (parent.BOType == BusinessObjectType.InventoryDocument)
                    {
                        retDocument = new WarehouseDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new InventoryDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                case DocumentRelationType.SalesOrderToInvoice:
                case DocumentRelationType.SalesOrderToCorrectiveCommercialDocument:
				case DocumentRelationType.SalesOrderToSimulatedInvoice:
                    retDocument = new CommercialDocument();
                    retDocument.Deserialize(relatedDocument);
                    break;
                case DocumentRelationType.SalesOrderToWarehouseDocument:
                    if (parent.BOType == BusinessObjectType.CommercialDocument)
                    {
                        retDocument = new WarehouseDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new CommercialDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                case DocumentRelationType.SalesOrderToOutcomeFinancialDocument:
                    if (parent.BOType == BusinessObjectType.CommercialDocument)
                    {
                        retDocument = new FinancialDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new CommercialDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                case DocumentRelationType.ProductionOrderToIncome:
                case DocumentRelationType.ProductionOrderToOutcome:
                    if (parent.BOType == BusinessObjectType.CommercialDocument)
                    {
                        retDocument = new WarehouseDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    else
                    {
                        retDocument = new CommercialDocument();
                        retDocument.Deserialize(relatedDocument);
                    }
                    break;
                default:
                    throw new InvalidOperationException("Unknown DocumentRelationType");
            }

            return retDocument;
        }
    }
}
