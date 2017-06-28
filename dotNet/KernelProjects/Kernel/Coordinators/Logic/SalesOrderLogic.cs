using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using System.Collections.Generic;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class SalesOrderLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        public SalesOrderLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        private void ExecuteCustomLogic(CommercialDocument document)
        {
            //create new contractor and attach him to the document if its neccesary
            if (document.ReceivingPerson != null && document.ReceivingPerson.IsNew &&
                (document.ReceivingPerson != null && document.Contractor == null) == false)
            {
                using (ContractorCoordinator contractorCoordinator = new ContractorCoordinator(false, false))
                {
                    Contractor newContractor = (Contractor)contractorCoordinator.CreateNewBusinessObject(BusinessObjectType.Contractor, null, null);

                    newContractor.ShortName = document.ReceivingPerson.ShortName;
                    newContractor.FullName = document.ReceivingPerson.FullName;
                    newContractor.IsBusinessEntity = document.ReceivingPerson.IsBusinessEntity;
                    newContractor.Status = BusinessObjectStatus.New;
                    document.ReceivingPerson = newContractor;

                    //load full document contractor data (maybe its not necessary, but we dont know if we already have full info about contractor)
                    Contractor documentContractor = (Contractor)contractorCoordinator.LoadBusinessObject(document.Contractor.BOType,
                        document.Contractor.Id.Value);
                    document.Contractor = documentContractor;
                }
            }

            this.mapper.AddItemsToItemTypesCache(document);
            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;
            if (document.DocumentType.Options.Descendants("template").Attributes("LineAttribute_SalesOrderGenerateDocumentOption").Count() > 0)
            {


                foreach (var line in document.Lines)
                {
                    var attr = line.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];

                    if (attr == null)
                        throw new ClientException(ClientExceptionId.MissingLineAttribute, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

                    Guid itemTypeId = cache[line.ItemId];
                    ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                    if (!itemType.IsWarehouseStorable)
                        continue;

                    string option = attr.Value.Value;

                    if (document.DocumentStatus != DocumentStatus.Canceled)
                    {
                        if (option == "3" || option == "4")
                            line.OrderDirection = -1;
                        else
                            line.OrderDirection = 0;
                    }
                    else
                        line.OrderDirection = 0;
                }
            }

            if (!document.IsNew)
            {
                CommercialDocument alternateDocument = (CommercialDocument)document.AlternateVersion;

                if (document.DocumentStatus == DocumentStatus.Committed && alternateDocument.DocumentStatus != DocumentStatus.Committed)
                {
                    var attr = document.Attributes.CreateNew(BusinessObjectStatus.New);
                    attr.DocumentFieldName = DocumentFieldName.Attribute_SettlementDate;
                    attr.Value.Value = SessionManager.VolatileElements.CurrentDateTime.ToIsoString();
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

        /// <summary>
        /// Executes the custom logic during transaction.
        /// </summary>
        /// <param name="document">The document to execute custom logic for.</param>
        private void ExecuteCustomLogicDuringTransaction(CommercialDocument document)
        {
            if (document.ReceivingPerson != null && document.ReceivingPerson.IsNew)
            {
                using (ContractorCoordinator contractorCoordinator = new ContractorCoordinator(false, false))
                {
                    Contractor documentContractor = (Contractor)document.Contractor;
                    Contractor receivingContractor = (Contractor)document.ReceivingPerson;

                    ContractorRelation relation = documentContractor.Relations.CreateNew();
                    relation.ContractorRelationTypeName = ContractorRelationTypeName.Contractor_ContactPerson;
                    relation.RelatedObject = receivingContractor;

                    contractorCoordinator.SaveBusinessObject(documentContractor);

                    document.ReceivingPerson.Version = receivingContractor.NewVersion;
                }
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
            }
        }

        private void ValidateDuringTransaction(CommercialDocument document)
        {
			this.ValidateServicesLines(document);
            if (document.Attributes[DocumentFieldName.Attribute_ProcessState] != null)
            {

                if (document.Attributes[DocumentFieldName.Attribute_ProcessState].Value.Value == "closed"
                    && document.Relations.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null)
                {
                    XElement prepaidsXml = this.mapper.GetSalesOrderSettledAmount(document.Id.Value);
                    decimal maxSettlementDifference = ProcessManager.Instance.GetMaxSettlementDifference(document);

                    decimal difference;

                    foreach (var vtEntry in document.VatTableEntries)
                    {
                        XElement prepaidXml = prepaidsXml.Elements().Where(x => x.Attribute("id").Value == vtEntry.VatRateId.ToUpperString()).FirstOrDefault();

                        if (prepaidXml == null)
                            throw new ClientException(ClientExceptionId.SalesOrderSettlementUnderpaidError, null, "value:" + vtEntry.GrossValue.ToString(CultureInfo.InvariantCulture).Replace('.', ','));

                        decimal prepaidValue = Convert.ToDecimal(prepaidXml.Attribute("grossValue").Value, CultureInfo.InvariantCulture);
                        difference = vtEntry.GrossValue - prepaidValue;

                        if (difference > 0 && difference > maxSettlementDifference)
                            throw new ClientException(ClientExceptionId.SalesOrderSettlementUnderpaidError, null, "value:" + difference.ToString(CultureInfo.InvariantCulture).Replace('.', ','));
                        else if (difference < 0 && -difference > maxSettlementDifference)
                            throw new ClientException(ClientExceptionId.SalesOrderSettlementOverpaidError, null, "value:" + difference.ToString(CultureInfo.InvariantCulture).Replace('.', ','));

                        prepaidXml.Remove();
                    }

                    if (prepaidsXml.HasElements)
                    {
                        decimal sum = prepaidsXml.Elements().Sum(xx => Convert.ToDecimal(xx.Attribute("grossValue").Value, CultureInfo.InvariantCulture));
                        throw new ClientException(ClientExceptionId.SalesOrderSettlementOverpaidError, null, "value:" + sum.ToString(CultureInfo.InvariantCulture).Replace('.', ','));
                    }

                }
            }
        }

		private void ValidateServicesLines(CommercialDocument document)
		{
			this.mapper.AddItemsToItemTypesCache(document);

			//Zamówienie sprzedazowe nie może posiadać więcej niż jednej pozycji zawierającej usługę na ilość 1. Ponadto pozycja ta nie może generować kosztu.
			//pomijamy te linie, które posiadają nieaktualną stawkę VAT - istotne dla FVR gdy zmieniają się obowiązujace stawki VAT
			IEnumerable<CommercialDocumentLine> relevantServicesLines = 
				document.Lines.Where(line => 
					!DictionaryMapper.Instance.GetItemType(SessionManager.VolatileElements.ItemTypesCache[line.ItemId]).IsWarehouseStorable);
			int servicesSalesLinesCount = 0;
			foreach(CommercialDocumentLine line in relevantServicesLines)
			{
				string sogdOption = SalesOrderGenerateDocumentOption.GetOption(line);
				if (SalesOrderGenerateDocumentOption.IsSales(sogdOption) && line.Quantity <= 1)
				{
					if (DictionaryMapper.Instance.GetVatRate(line.VatRateId).IsEventDateValid(document.EventDate))
						servicesSalesLinesCount++;
				}
				else
				{
					throw new ClientException(ClientExceptionId.SalesOrderMoreThanOneServiceLineError);
				}
			}
			if (servicesSalesLinesCount > 1)
			{
				throw new ClientException(ClientExceptionId.SalesOrderMoreThanOneServiceLineError);
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
                this.ExecuteCustomLogicDuringTransaction(document);

                DocumentLogicHelper.AssignNumber(document, this.mapper);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                document.SaveChanges(operations);

                if (document.AlternateVersion != null)
                    document.AlternateVersion.SaveChanges(operations);

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

                this.ValidateDuringTransaction(document);

                this.mapper.UpdateReservationAndOrderStock(document);

                if (operations.Root.HasElements)
                    this.mapper.CreateCommunicationXmlForDocumentRelations(operations); //generowanie paczek dla relacji dokumentow

                if (document.DraftId != null)
                    this.mapper.DeleteDraft(document.DraftId.Value);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:87");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:86");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
