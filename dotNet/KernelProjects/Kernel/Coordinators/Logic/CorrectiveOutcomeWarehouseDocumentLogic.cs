using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class CorrectiveOutcomeWarehouseDocumentLogic : CorrectiveWarehouseDocumentLogic
    {
        public CorrectiveOutcomeWarehouseDocumentLogic(DocumentCoordinator coordinator)
            : base(coordinator)
        { }

        public XDocument ProcessWarehouseCorrectiveDocument(WarehouseDocument document)
        {
            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();

                this.MakeDifferentialDocument(document);

                document.AlternateVersion = null;
                this.coordinator.UpdateStock(document);

                WarehouseDocument targetDocument = (WarehouseDocument)this.coordinator.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, document.Source.Attribute("template").Value, null);
				targetDocument.Contractor = document.Contractor;
                targetDocument.WarehouseId = document.WarehouseId;
				DuplicableAttributeFactory.CopyAttributes(document, targetDocument);
				targetDocument.UpdateStatus(true);
                this.SaveDocumentHeaderAndAttributes(targetDocument);

                int ordinalNumber = 0;
                XDocument xml = null;
                XDocument operations = XDocument.Parse("<root><incomeOutcomeRelation/><commercialWarehouseRelation/><commercialWarehouseValuation/></root>");

                foreach (WarehouseDocumentLine line in document.Lines.Children)
                {
                    Guid? commercialCorrectiveLineId = null;

                    if (line.CommercialCorrectiveLine != null)
                        commercialCorrectiveLineId = line.CommercialCorrectiveLine.Id;
                    
                    xml = this.mapper.CreateOutcomeQuantityCorrection(line.Id.Value, line.Version.Value, targetDocument.Id.Value, line.Quantity, ordinalNumber, commercialCorrectiveLineId);
                    ordinalNumber = Convert.ToInt32(xml.Root.Element("ordinalNumber").Value, CultureInfo.InvariantCulture);

                    if (xml.Root.Element("incomeOutcomeRelation") != null)
                        operations.Root.Element("incomeOutcomeRelation").Add(xml.Root.Element("incomeOutcomeRelation").Elements());

                    if (xml.Root.Element("commercialWarehouseRelation") != null)
                        operations.Root.Element("commercialWarehouseRelation").Add(xml.Root.Element("commercialWarehouseRelation").Elements());
                    
                    if (xml.Root.Element("commercialWarehouseValuation") != null)
                        operations.Root.Element("commercialWarehouseValuation").Add(xml.Root.Element("commercialWarehouseValuation").Elements());
                }

                this.mapper.ValuateOutcomeWarehouseDocument(targetDocument);
                this.mapper.CreateCommunicationXml(targetDocument);
                this.mapper.CreateCommunicationXmlForDocumentRelations(operations);

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", targetDocument.Id.ToUpperString()));

				//Custom validation
				this.mapper.ExecuteOnCommitValidationCustomProcedure(targetDocument);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:57");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:58");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
