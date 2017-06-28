using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
	internal class CommercialCorrectiveDocumentFactory
	{
		private static void CalculateLineAfterCorrection(CommercialDocumentLine line)
		{
			if (line.CorrectedLine != null)
			{
				CommercialDocument parent = (CommercialDocument)line.Parent;

				//if the corrected line is in the same document so it already has been corrected so dont do it again
				if (parent.Lines.Children.Where(l => l.Id.Value == line.CorrectedLine.Id.Value).FirstOrDefault() == null)
					CommercialCorrectiveDocumentFactory.CalculateLineAfterCorrection(line.CorrectedLine);

				line.DiscountGrossValue += line.CorrectedLine.DiscountGrossValue;
				line.DiscountNetValue += line.CorrectedLine.DiscountNetValue;
				line.DiscountRate += line.CorrectedLine.DiscountRate;
				line.GrossPrice += line.CorrectedLine.GrossPrice;
				line.GrossValue += line.CorrectedLine.GrossValue;
				line.InitialGrossPrice += line.CorrectedLine.InitialGrossPrice;
				line.InitialGrossValue += line.CorrectedLine.InitialGrossValue;
				line.InitialNetPrice += line.CorrectedLine.InitialNetPrice;
				line.InitialNetValue += line.CorrectedLine.InitialNetValue;
				line.NetPrice += line.CorrectedLine.NetPrice;
				line.NetValue += line.CorrectedLine.NetValue;
				line.VatValue += line.CorrectedLine.VatValue;
				line.Quantity += line.CorrectedLine.Quantity;
			}
		}

		private static void CalculateHeaderAndVatTableAfterCorrection(CommercialDocument document)
		{
			CommercialDocumentLine firstLine = document.Lines.Children.First();

			if (firstLine.CorrectedLine != null)
			{
				CommercialDocument previousDoc = (CommercialDocument)firstLine.CorrectedLine.Parent;
				CommercialCorrectiveDocumentFactory.CalculateHeaderAndVatTableAfterCorrection(previousDoc);

				decimal netValue = previousDoc.NetValue;
				decimal grossValue = previousDoc.GrossValue;
				decimal vatValue = previousDoc.VatValue;

				if (previousDoc.IsSettlementDocument)
				{
					netValue = previousDoc.VatTableEntries.Where(ss => ss.NetValue > 0 && ss.GrossValue > 0 && ss.VatValue > 0).Sum(s => s.NetValue);
					grossValue = previousDoc.VatTableEntries.Where(ss => ss.NetValue > 0 && ss.GrossValue > 0 && ss.VatValue > 0).Sum(s => s.GrossValue);
					vatValue = previousDoc.VatTableEntries.Where(ss => ss.NetValue > 0 && ss.GrossValue > 0 && ss.VatValue > 0).Sum(s => s.VatValue);
				}

				document.NetValue += netValue;
				document.GrossValue += grossValue;
				document.VatValue += vatValue;

				foreach (CommercialDocumentVatTableEntry vtEntry in previousDoc.VatTableEntries.Children)
				{
					if (previousDoc.IsSettlementDocument && (vtEntry.NetValue < 0 || vtEntry.GrossValue < 0 || vtEntry.VatValue < 0))
						continue;

					CommercialDocumentVatTableEntry currentVtEntry = document.VatTableEntries.Children.Where(v => v.VatRateId == vtEntry.VatRateId).FirstOrDefault();

					if (currentVtEntry != null)
					{
						currentVtEntry.GrossValue += vtEntry.GrossValue;
						currentVtEntry.NetValue += vtEntry.NetValue;
						currentVtEntry.VatValue += vtEntry.VatValue;
					}
				}
			}
		}

		public static void CalculateDocumentsAfterCorrection(CommercialDocument lastCorrectiveDocument)
		{
			foreach (CommercialDocumentLine line in lastCorrectiveDocument.Lines.Children)
			{
				CommercialCorrectiveDocumentFactory.CalculateLineAfterCorrection(line);
			}

			CommercialCorrectiveDocumentFactory.CalculateHeaderAndVatTableAfterCorrection(lastCorrectiveDocument);
		}

		public static void CreateCorrectiveDocument(XElement source, CommercialDocument destination)
		{
			Guid sourceDocumentId = new Guid(source.Element("correctedDocumentId").Value);
			DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();

			ICollection<Guid> previousDocumentsId = mapper.GetCommercialCorrectiveDocumentsId(sourceDocumentId);

			CommercialDocument sourceDocument = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, sourceDocumentId);

			CommercialDocument lastDoc = sourceDocument;

			foreach (Guid corrId in previousDocumentsId)
			{
				CommercialDocument correctiveDoc = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, corrId);

				CommercialCorrectiveDocumentFactory.RelateTwoCorrectiveDocuments(lastDoc, correctiveDoc, true);

				lastDoc = correctiveDoc;
			}

			CommercialCorrectiveDocumentFactory.CalculateDocumentsAfterCorrection(lastDoc);
			CommercialCorrectiveDocumentFactory.CreateNextCorrectiveDocument(lastDoc, destination);
			DuplicableAttributeFactory.DuplicateAttributes(lastDoc, destination);

			var salesOrderRelation = sourceDocument.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault();

			if (salesOrderRelation != null) //dokument jest do ZS wiec korekte tez tam podpinamy
			{
				var relation = destination.Relations.CreateNew();
				relation.RelationType = DocumentRelationType.SalesOrderToCorrectiveCommercialDocument;
				relation.RelatedDocument = salesOrderRelation.RelatedDocument;
			}
		}

		/// <summary>
		/// Wiąże dwa dokumenty, z których conajmniej jeden może być korektą. 
		/// </summary>
		/// <param name="previousDocument"></param>
		/// <param name="nextDocument"></param>
		/// <param name="last">true jeśli jest to próba powiązania z korygowanym dokumentem - wtedy już musimy powiązanie stworzyć</param>
		/// <returns>true jeśli udało się powiązać dokumenty, false jeśli nie</returns>
		public static bool RelateTwoCorrectiveDocuments(CommercialDocument previousDocument, CommercialDocument nextDocument, bool last)
		{
			nextDocument.CorrectedDocument = previousDocument;

			foreach (CommercialDocumentLine line in nextDocument.Lines.Children)
			{
				CommercialDocumentLine correctedLine = previousDocument.Lines.Children.Where(l => l.Id.Value == line.CorrectedLine.Id.Value).FirstOrDefault();

				if (correctedLine != null)
					line.CorrectedLine = correctedLine;
				else
				{
					correctedLine = nextDocument.Lines.Children.Where(l => l.Id.Value == line.CorrectedLine.Id.Value).FirstOrDefault();

					if (correctedLine != null)
						line.CorrectedLine = correctedLine;
					else if (last)
						throw new InvalidOperationException("Cannot find corrected line");
					else
						return false;
				}
			}

			return true;
		}

		private static void CreateNextCorrectiveDocument(CommercialDocument lastCorrectiveDoc, CommercialDocument destination)
		{
			destination.CorrectedDocument = lastCorrectiveDoc;

			//copy header
			destination.CalculationType = lastCorrectiveDoc.CalculationType;
			destination.DocumentCurrencyId = lastCorrectiveDoc.DocumentCurrencyId;
			destination.GrossValue = lastCorrectiveDoc.GrossValue;
			destination.NetValue = lastCorrectiveDoc.NetValue;
			destination.SummationType = lastCorrectiveDoc.SummationType;
			destination.VatValue = lastCorrectiveDoc.VatValue;
			//Jednak event date powinien być podpowiadany jako bieżąca data
			destination.EventDate = SessionManager.VolatileElements.CurrentDateTime;//lastCorrectiveDoc.EventDate;

			if (lastCorrectiveDoc.Contractor != null)
			{
				ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
				Contractor contractor = (Contractor)contractorMapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, lastCorrectiveDoc.Contractor.Id.Value);

				destination.Contractor = contractor;
				destination.ContractorAddressId = lastCorrectiveDoc.ContractorAddressId;
			}

			//copy attributes if specified
			foreach (DocumentAttrValue attr in lastCorrectiveDoc.Attributes.Children)
			{
				if (attr.DocumentFieldName == DocumentFieldName.Attribute_SupplierDocumentDate ||
					attr.DocumentFieldName == DocumentFieldName.Attribute_SupplierDocumentNumber)
				{
					DocumentAttrValue dstAttr = destination.Attributes.CreateNew();
					dstAttr.DocumentFieldName = attr.DocumentFieldName;
					dstAttr.Value = new XElement(attr.Value);
				}
			}

			//create vat tables
			foreach (CommercialDocumentVatTableEntry vtEntry in lastCorrectiveDoc.VatTableEntries.Children)
			{
				if (lastCorrectiveDoc.IsSettlementDocument && (vtEntry.GrossValue < 0 || vtEntry.NetValue < 0 || vtEntry.VatValue < 0))
					continue;

				if (vtEntry.GrossValue != 0 || vtEntry.NetValue != 0 || vtEntry.VatValue != 0)
				{
					CommercialDocumentVatTableEntry dstVtEntry = destination.VatTableEntries.CreateNew();

					dstVtEntry.GrossValue = vtEntry.GrossValue;
					dstVtEntry.NetValue = vtEntry.NetValue;
					dstVtEntry.VatValue = vtEntry.VatValue;
					dstVtEntry.VatRateId = vtEntry.VatRateId;
				}
			}

			if (lastCorrectiveDoc.IsSettlementDocument)
			{
				destination.NetValue = destination.VatTableEntries.Sum(s => s.NetValue);
				destination.GrossValue = destination.VatTableEntries.Sum(s => s.GrossValue);
				destination.VatValue = destination.VatTableEntries.Sum(s => s.VatValue);
			}

			//create only these lines that werent corrected inside the same document
			var linesToCopy = from line in lastCorrectiveDoc.Lines.Children
							  where (lastCorrectiveDoc.Lines.Children.Where(w => w.CorrectedLine != null).Select(s => s.CorrectedLine.Id.Value)).Contains(line.Id.Value) == false
							  select line;

			foreach (CommercialDocumentLine srcLine in linesToCopy)
			{
				CommercialDocumentLine line = destination.Lines.CreateNew();
				line.CorrectedLine = srcLine;
				line.DiscountGrossValue = srcLine.DiscountGrossValue;
				line.DiscountNetValue = srcLine.DiscountNetValue;
				line.DiscountRate = srcLine.DiscountRate;
				line.GrossPrice = srcLine.GrossPrice;
				line.GrossValue = srcLine.GrossValue;
				line.InitialGrossPrice = srcLine.InitialGrossPrice;
				line.InitialGrossValue = srcLine.InitialGrossValue;
				line.InitialNetPrice = srcLine.InitialNetPrice;
				line.InitialNetValue = srcLine.InitialNetValue;
				line.ItemId = srcLine.ItemId;
				line.ItemName = srcLine.ItemName;
				line.ItemVersion = srcLine.ItemVersion;
				line.NetPrice = srcLine.NetPrice;
				line.NetValue = srcLine.NetValue;
				line.Quantity = srcLine.Quantity;
				line.UnitId = srcLine.UnitId;
				line.VatRateId = srcLine.VatRateId;
				line.VatValue = srcLine.VatValue;
				line.WarehouseId = srcLine.WarehouseId;
				line.ItemCode = srcLine.ItemCode;
				line.ItemTypeId = srcLine.ItemTypeId;
			}
		}
	}
}
