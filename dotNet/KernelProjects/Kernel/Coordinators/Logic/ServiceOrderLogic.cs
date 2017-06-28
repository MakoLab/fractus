using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class ServiceOrderLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;

        public ServiceOrderLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        /// <summary>
        /// Executes the custom logic.
        /// </summary>
        /// <param name="document">The document to execute custom logic for.</param>
        private void ExecuteCustomLogic(ServiceOrder document)
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
        }

        private void ExecuteDocumentOptions(ServiceOrder document)
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
        private void ExecuteCustomLogicDuringTransaction(ServiceOrder document)
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

                    document.ReceivingPerson.Version = receivingContractor.Version;
                }
            }
        }

        public XDocument SaveBusinessObject(ServiceOrder document)
        {
            DictionaryMapper.Instance.CheckForChanges();

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

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

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", document.Id.ToUpperString()));

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
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
