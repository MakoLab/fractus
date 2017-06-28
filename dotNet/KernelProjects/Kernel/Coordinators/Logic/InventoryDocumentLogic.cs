using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;
using System.Linq;
using System.Xml.XPath;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class InventoryDocumentLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;
        private ItemMapper itemMapper = DependencyContainerManager.Container.Get<ItemMapper>();

        public InventoryDocumentLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        private void ExecuteCustomLogic(InventoryDocument document)
        {
            InventoryDocument alternateDocument = document.AlternateVersion as InventoryDocument;

            if (alternateDocument != null)
            {
                if (alternateDocument.DocumentStatus == DocumentStatus.Saved &&
                    (document.DocumentStatus == DocumentStatus.Committed || document.DocumentStatus == DocumentStatus.Canceled))
                {
                    //wczytujemy wszystkie arkusze
                    foreach (InventorySheet s in document.Sheets)
                    {
                        InventorySheet sheet = (InventorySheet)this.mapper.LoadBusinessObject(BusinessObjectType.InventorySheet, s.Id.Value);

                        if (sheet.DocumentStatus == DocumentStatus.Saved)
                        {
                            sheet.DocumentStatus = document.DocumentStatus;
                            sheet.SkipItemsUnblock = true;
                            document.SheetsToSave.Add(sheet);
                        }
                    }

                    document.UnblockItems = true;

                    if (document.DocumentStatus == DocumentStatus.Committed)
                    {
                        var whDocs = InventoryDocumentFactory.GenerateDifferentialDocuments(document, document.SheetsToSave);
                                                
                        foreach (var whDoc in whDocs)
                        {
                            //Wycena pozycji przychodowych na podstawie ceny ostatniego zakupu
                            //Zrobiłem tak bo nie znam kernela a nie mamy obecnie kernelowca
                            if (whDoc.WarehouseDirection == WarehouseDirection.Income)
                            {
                                XDocument par = new XDocument(  new XElement( "root",
                                                                                new XElement("warehouseId",whDoc.WarehouseId.ToString()),
                                                                                whDoc.Lines.Serialize()));
                                XDocument priceList = null;
                                decimal headerSumation = 0;
                                priceList = new XDocument(this.mapper.ExecuteCustomProcedure("document.p_getWarehouseStock", true, par, true, 120, "xml"));
                                foreach (var item in whDoc.Lines)
                                {
                                    decimal lastPrice;
                                    

                                    lastPrice = decimal.Parse( 
                                                (from i in priceList.Descendants("line")
                                                 where i.Element("itemId").Value.ToLower() == item.ItemId.ToString().ToLower()
                                                 select i.Element("lastPurchaseNetPrice").Value).FirstOrDefault().Replace(".",",")
                                                 );
                                    
                                   item.Value = lastPrice * item.Quantity;
                                   item.Price = lastPrice;
                                   headerSumation = headerSumation + (lastPrice * item.Quantity);
                                }
                                whDoc.Value = headerSumation;
                            }

                            document.AddRelatedObject(whDoc);

                            DocumentRelation relation = document.Relations.CreateNew();
                            relation.RelationType = DocumentRelationType.InventoryToWarehouse;
                            relation.RelatedDocument = whDoc;

                            relation = whDoc.Relations.CreateNew();
                            relation.RelationType = DocumentRelationType.InventoryToWarehouse;
                            relation.RelatedDocument = document;
                            relation.DontSave = true;
                        }                      
                    }
                }
            }
        }

        private void ExecuteDocumentOptions(Document document)
        {
            foreach (IDocumentOption option in document.DocumentOptions)
            {
                option.Execute(document);
            }
        }

        /// <summary>
        /// Saves the business object.
        /// </summary>
        /// <param name="document"><see cref="CommercialDocument"/> to save.</param>
        /// <returns>Xml containing result of oper</returns>
        public XDocument SaveBusinessObject(InventoryDocument document)
        {
            DictionaryMapper.Instance.CheckForChanges();

            //load alternate version
            if (!document.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(document.BOType, document.Id.Value);
                document.SetAlternateVersion(alternateBusinessObject);
            }

            foreach (var sheet in document.Sheets)
            {
                sheet.SkipLinesSave = true;

                InventorySheet alternateSheet = sheet.AlternateVersion as InventorySheet;

                if (alternateSheet != null && alternateSheet.DocumentStatus != sheet.DocumentStatus && sheet.DocumentStatus == DocumentStatus.Canceled)
                {
                    //jezeli anulowalismy arkusz z poziomu inwentaryzacji to nalezy caly arkusz wczytac, zmienic jego status i dodac do zapisu zeby
                    //wykonala sie tez inna jego logika zwiazana ze zmiana statusu
                    InventorySheet sh = (InventorySheet)this.mapper.LoadBusinessObject(BusinessObjectType.InventorySheet, sheet.Id.Value);
                    sh.DocumentStatus = DocumentStatus.Canceled;
                    document.AddRelatedObject(sh);
                }
            }

            //update status
            document.UpdateStatus(true);

            if (document.AlternateVersion != null)
                document.AlternateVersion.UpdateStatus(false);

            document.Validate();

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

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
					if (document.DocumentStatus == DocumentStatus.Committed)
						this.mapper.CreateCommunicationXml(document);
                    this.mapper.UpdateDictionaryIndex(document);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                foreach (var sheet in document.SheetsToSave)
                {
                    using (DocumentCoordinator c = new DocumentCoordinator(false, false))
                    {
                        c.SaveBusinessObject(sheet);
                    }
                }

                if (document.UnblockItems)
                    this.itemMapper.UnblockItems();

                document.SaveRelatedObjects();

                operations = XDocument.Parse("<root/>");

                document.SaveRelations(operations);

                if (document.AlternateVersion != null)
                    ((InventoryDocument)document.AlternateVersion).SaveRelations(operations);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:72");
                Coordinator.ProcessSqlException(sqle, document.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:73");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
