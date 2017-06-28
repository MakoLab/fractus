using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    /// <summary>
    /// Class that contains logic of commercial documents.
    /// </summary>
    internal class ProductionLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        /// <summary>
        /// Initializes a new instance of the <see cref="CommercialDocumentLogic"/> class.
        /// </summary>
        /// <param name="coordinator">The parent coordinator.</param>
        public ProductionLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        /// <summary>
        /// Executes the custom logic.
        /// </summary>
        /// <param name="document">The document to execute custom logic for.</param>
        private void ExecuteCustomLogic(CommercialDocument document)
        {
            //sprawdzamy czy zlecenie/technologia nie posiada pozycji uslugowych
            this.mapper.AddItemsToItemTypesCache(document);
            var cache = SessionManager.VolatileElements.ItemTypesCache;

            //foreach (var line in document.Lines)
            //{
            //    Guid itemTypeId = cache[line.ItemId];
            //    // Tutaj jest walidacja typów produktów ale nie potrzebnie, usługa w kontekście robocizny, powinna dać się zapisać w 
            //    // procesie produkcyjnym
            //    if (!DictionaryMapper.Instance.GetItemType(itemTypeId).IsWarehouseStorable)
            //        throw new ClientException(ClientExceptionId.InvalidItemType);
            //}

            CommercialDocument alternateDocument = document.AlternateVersion as CommercialDocument;

			//zamykanie ZP
            if (alternateDocument != null && alternateDocument.DocumentStatus == DocumentStatus.Saved && 
                document.DocumentStatus == DocumentStatus.Committed && document.DocumentType.DocumentCategory == DocumentCategory.ProductionOrder)
            {
                Dictionary<Guid, CommercialDocument> technologies = new Dictionary<Guid, CommercialDocument>();
                WarehouseDocument internalOutcome = null;
                WarehouseDocument internalIncome = null;
                WarehouseDocument internalIncomeByproduct = null;

                using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                {
                    internalOutcome = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, ProcessManager.Instance.GetDocumentTemplate(document, "internalOutcome"), null);
                    internalIncome = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, ProcessManager.Instance.GetDocumentTemplate(document, "internalIncome"), null);
                    internalIncomeByproduct = (WarehouseDocument)c.CreateNewBusinessObject(BusinessObjectType.WarehouseDocument, ProcessManager.Instance.GetDocumentTemplate(document, "internalIncomeByproduct"), null);
                }

                ProcessManager.Instance.AppendProcessAttributes(internalIncome, document.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value,
                    "internalIncome", null, null);

                internalIncome.WarehouseId = ProcessManager.Instance.GetProductWarehouse(document);

                ProcessManager.Instance.AppendProcessAttributes(internalOutcome, document.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value,
                    "internalOutcome", null, null);

                internalOutcome.WarehouseId = ProcessManager.Instance.GetMaterialWarehouse(document);

                ProcessManager.Instance.AppendProcessAttributes(internalIncomeByproduct, document.Attributes[DocumentFieldName.Attribute_ProcessType].Value.Value,
                    "internalIncomeByproduct", null, null);

                internalIncomeByproduct.WarehouseId = ProcessManager.Instance.GetByproductWarehouse(document);

                //wczytujemy wszystkie technologie
                //generujemy jeden wielki RW i PW dla wzsystkich technologii i podczepiamy go do zlecenia produkcyjnego

                foreach (CommercialDocumentLine line in document.Lines)
                {
                    var attr = line.Attributes[DocumentFieldName.LineAttribute_ProductionTechnologyName];

                    Guid technologyId = new Guid(attr.Value.Value);

                    if (!technologies.ContainsKey(technologyId))
                    {
                        CommercialDocument t = (CommercialDocument)this.mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, technologyId);
                        technologies.Add(technologyId, t);
                    }

                    this.ProcessTechnology(technologies[technologyId], line.Quantity, internalIncome, internalOutcome, internalIncomeByproduct, line.OrdinalNumber);
                }

                DocumentRelation relation = null;

                relation = internalOutcome.Relations.CreateNew();
                relation.RelationType = DocumentRelationType.ProductionOrderToOutcome;
                relation.RelatedDocument = document;

                relation = document.Relations.CreateNew();
                relation.RelationType = DocumentRelationType.ProductionOrderToOutcome;
                relation.RelatedDocument = internalOutcome;
                relation.DontSave = true;
				DuplicableAttributeFactory.DuplicateAttributes(document, internalOutcome);
                document.AddRelatedObject(internalOutcome);

                relation = internalIncome.Relations.CreateNew();
                relation.RelationType = DocumentRelationType.ProductionOrderToIncome;
                relation.RelatedDocument = document;

                relation = document.Relations.CreateNew();
                relation.RelationType = DocumentRelationType.ProductionOrderToIncome;
                relation.RelatedDocument = internalIncome;
                relation.DontSave = true;
				DuplicableAttributeFactory.DuplicateAttributes(document, internalIncome);
				document.AddRelatedObject(internalIncome);

                if (internalIncomeByproduct.Lines.Children.Count > 0)
                {
                    relation = internalIncomeByproduct.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.ProductionOrderToIncome;
                    relation.RelatedDocument = document;

                    relation = document.Relations.CreateNew();
                    relation.RelationType = DocumentRelationType.ProductionOrderToIncome;
                    relation.RelatedDocument = internalIncomeByproduct;
                    relation.DontSave = true;
					DuplicableAttributeFactory.DuplicateAttributes(document, internalIncomeByproduct);
                    document.AddRelatedObject(internalIncomeByproduct);
                }
            }
        }

        private void ProcessTechnology(CommercialDocument technology, decimal quantity, WarehouseDocument income, WarehouseDocument outcome, WarehouseDocument byproductIncome, int ordinalNumber)
        {
            List<Guid> outcomeLinesId = new List<Guid>();

            foreach (var line in technology.Lines)
            {
                string lineType = line.Attributes[DocumentFieldName.LineAttribute_ProductionItemType].Value.Value; //material/product/byproduct

                WarehouseDocumentLine whLine = null;
                //Tutaj należy zadać pytanie co zrobić dla labor
                if (lineType == "material")
                {
                    whLine = outcome.Lines.CreateNew();
                    whLine.GenerateId();
                    outcomeLinesId.Add(whLine.Id.Value);
                }
                else if (lineType == "byproduct")
                    whLine = byproductIncome.Lines.CreateNew();
                else if (lineType == "labor")
                    line.Quantity = line.Quantity;
                else// if (lineType == "product")
                {
                    whLine = income.Lines.CreateNew();
                    whLine.ValuateFromOutcomeDocumentLinesId = outcomeLinesId;
                    income.ValuateFromOutcomeDocumentId = outcome.Id.Value;

                    if (quantity % line.Quantity != 0)
                        throw new ClientException(ClientExceptionId.ProductionOrderQuantityError, null, "ordinalNumber:" + ordinalNumber.ToString(CultureInfo.InvariantCulture),
                            "quantity:" + line.Quantity.ToString(CultureInfo.InvariantCulture));

                }

                if (lineType != "labor")
                {
                    whLine.ItemId = line.ItemId;
                    whLine.ItemName = line.ItemName;
                    whLine.UnitId = line.UnitId;
                    whLine.Quantity += quantity * line.Quantity;
                }
            }
        }

        private void ExecuteDocumentOptions(CommercialDocument document)
        {
            foreach (IDocumentOption option in document.DocumentOptions)
            {
                option.Execute(document);
            }
        }

        private void CheckDateDifference(CommercialDocument document)
        {
            if (document.AlternateVersion != null)
            {
                CommercialDocument alternate = (CommercialDocument)document.AlternateVersion;

                if (document.IssueDate > alternate.IssueDate) //zmieniono date na przyszlosc
                    document.IssueDate = new DateTime(document.IssueDate.Year, document.IssueDate.Month, document.IssueDate.Day, 0, 0, 0, 0);
                else if (document.IssueDate < alternate.IssueDate)
                    document.IssueDate = new DateTime(document.IssueDate.Year, document.IssueDate.Month, document.IssueDate.Day, 23, 59, 59, 500);

                if (document.EventDate > alternate.EventDate) //zmieniono date na przyszlosc
                    document.EventDate = new DateTime(document.EventDate.Year, document.EventDate.Month, document.EventDate.Day, 0, 0, 0, 0);
                else if (document.EventDate < alternate.EventDate)
                    document.EventDate = new DateTime(document.EventDate.Year, document.EventDate.Month, document.EventDate.Day, 23, 59, 59, 500);
            }
        }

		/// <summary>
		/// Check if name of technology name is unique
		/// </summary>
		/// <param name="document"></param>
		private void _CheckTechnologyNameExistence(CommercialDocument document)
		{
			if (document.DocumentType.DocumentCategory == DocumentCategory.Technology)
			{
				DocumentAttrValue technologyNameAttribute = document.Attributes[DocumentFieldName.Attribute_ProductionTechnologyName];
				if (technologyNameAttribute != null)
				{
					//gdy nowy to walidujemy, gdy edytowany będziemy walidować tylko gdy nazwa się zmieniła
					bool validateTechnologyName = document.IsNew;
					string technologyName = technologyNameAttribute.Value.Value;
					if (!document.IsNew && document.AlternateVersion != null)
					{
						DocumentAttrValue altTechnologyNameAttribute = ((CommercialDocument)document.AlternateVersion).Attributes[DocumentFieldName.Attribute_ProductionTechnologyName];
						if (altTechnologyNameAttribute != null && technologyName == altTechnologyNameAttribute.Value.Value)
						{
							validateTechnologyName = false;
						}
					}
					if (validateTechnologyName)
					{
						XDocument xml = XDocument.Parse(String.Format("<root><name>{0}</name></root>", technologyName));

						xml = this.mapper.ExecuteStoredProcedure(StoredProcedure.document_p_checkTechnologyNameExistence, true, xml);

						string result = xml.Root.Value;

						if (result == "TRUE")
						{
							throw new ClientException(ClientExceptionId.ExistingTechnologyName, null, "name:" + technologyName);
						}
					}
				}
			}
		}

        /// <summary>
        /// Saves the business object.
        /// </summary>
        /// <param name="document"><see cref="CommercialDocument"/> to save.</param>
        /// <returns>Xml containing result of oper</returns>
        public XDocument SaveBusinessObject(CommercialDocument document)
        {
            DictionaryMapper.Instance.CheckForChanges();

			this._CheckTechnologyNameExistence(document);

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            this.CheckDateDifference(document);

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            this.ExecuteCustomLogic(document);
            this.ExecuteDocumentOptions(document);

            //validate
            document.Validate();

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(document);

                DocumentLogicHelper.AssignNumber(document, this.mapper);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

                DocumentCategory category = document.DocumentType.DocumentCategory;

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    this.mapper.UpdateDocumentInfoOnPayments(document);
                    this.mapper.CreateCommunicationXml(document);
                    this.mapper.UpdateDictionaryIndex(document);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((CommercialDocument)document.AlternateVersion).SaveRelations(operations);

                if (operations.Root.HasElements)
                    this.mapper.ExecuteOperations(operations);

                if (operations.Root.HasElements)
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:84");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:85");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
