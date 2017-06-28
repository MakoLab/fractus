using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
	internal class WarehouseCorrectiveDocumentFactory
	{
		public static void CreateCorrectiveDocument(XElement source, WarehouseDocument destination)
		{
			Guid sourceDocumentId = new Guid(source.Element("correctedDocumentId").Value);
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			WarehouseDocument sourceDocument = (WarehouseDocument)mapper.LoadBusinessObject(BusinessObjectType.WarehouseDocument, sourceDocumentId);
			WarehouseDirection direction = sourceDocument.WarehouseDirection;

			if (ConfigurationMapper.Instance.PreventDocumentCorrectionBeforeSystemStart &&
				sourceDocument.IsBeforeSystemStart)
				throw new ClientException(ClientExceptionId.DocumentCorrectionBeforeSystemStartError);

			destination.Contractor = sourceDocument.Contractor;
			destination.WarehouseId = sourceDocument.WarehouseId;

			DuplicableAttributeFactory.DuplicateAttributes(sourceDocument, destination);

			foreach (WarehouseDocumentLine line in sourceDocument.Lines.Children)
			{
				WarehouseDocumentLine correctedLine = mapper.GetWarehouseDocumentLineAfterCorrection(line, direction);

				if (correctedLine != null)
					destination.Lines.AppendChild(correctedLine);
			}

			if (destination.Lines.Children.Count == 0)
				throw new ClientException(ClientExceptionId.FullyCorrectedCorrectionError);

			destination.InitialCorrectedDocument = sourceDocument;
		}
	}
}
