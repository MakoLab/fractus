using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal abstract class CorrectiveWarehouseDocumentLogic
    {
        protected DocumentMapper mapper;
        protected DocumentCoordinator coordinator;

        public CorrectiveWarehouseDocumentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        protected void SaveDocumentHeaderAndAttributes(WarehouseDocument document)
        {
            DocumentLogicHelper.AssignNumber(document, mapper);
            XDocument operations = XDocument.Parse("<root/>");
            document.SaveChanges(operations);

			operations.Root.Elements().Where(e => e.Name.LocalName != "warehouseDocumentHeader" && e.Name.LocalName != "documentAttrValue").Remove();

            this.mapper.ExecuteOperations(operations);
        }

        protected void MakeDifferentialDocument(WarehouseDocument document)
        {
            WarehouseDocument whDoc = (WarehouseDocument)this.coordinator.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument,
                document.Source.Attribute("template").Value, new XElement(document.Source));

            document.SetAlternateVersion(whDoc);
            document.UpdateStatus(true);

            List<WarehouseDocumentLine> linesToDelete = new List<WarehouseDocumentLine>();

            foreach (WarehouseDocumentLine line in document.Lines.Children)
            {
                if (line.Status != BusinessObjectStatus.Modified)
                    linesToDelete.Add(line);
                else
                {
                    //sprawdzamy czy nie jest to korekta na plus
                    if (line.Quantity > ((WarehouseDocumentLine)line.AlternateVersion).Quantity)
                        throw new ClientException(ClientExceptionId.QuantityOnCorrectionAboveZero);
                }
            }

            foreach (WarehouseDocumentLine line in linesToDelete)
            {
                document.Lines.Children.Remove(line);
            }

			if (whDoc.InitialCorrectedDocument != null)
			{
				document.InitialCorrectedDocument = whDoc.InitialCorrectedDocument;
			}
        }
    }
}
