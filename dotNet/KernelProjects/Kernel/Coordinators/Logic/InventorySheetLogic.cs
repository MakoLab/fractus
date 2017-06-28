using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    internal class InventorySheetLogic
    {
        private DocumentMapper mapper;
        private DocumentCoordinator coordinator;
        private ItemMapper itemMapper = DependencyContainerManager.Container.Get<ItemMapper>();

        public InventorySheetLogic(DocumentCoordinator coordinator)
        {
            this.mapper = (DocumentMapper)coordinator.Mapper;
            this.coordinator = coordinator;
        }

        private void ProcessInventoryHeaderOperations(InventorySheet sheet)
        {
            if (sheet.Status == BusinessObjectStatus.New) //sprawdzamy czy wersja sie zgadza
            {
                if (String.IsNullOrEmpty(sheet.Tag))
                    throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:tag");
                 
                Guid previousVersion = new Guid(sheet.Tag);

                try
                {
                    this.mapper.CheckInventoryDocumentVersion(previousVersion);
                }
                catch (SqlException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:75");
                    throw new ClientException(ClientExceptionId.VersionMismatch, null, "objType:InventoryDocument");
                }
            }
            
            //InventorySheet alternateSheet = sheet.AlternateVersion as InventorySheet;

            //przeiterowanie po liniach nowych i zablokowanie ich i wpisanie stanu aktualnego
            //procka musi zwracac blad jezeli chceby blokowac towar ktory jest juz zablokowany i zwracac ich stan
            if (sheet.DocumentStatus == DocumentStatus.Saved)
            {
                XElement blockXml = new XElement("root");
                DateTime currentDateTime = SessionManager.VolatileElements.CurrentDateTime;

                foreach (var line in sheet.Lines)
                {
                    if (line.IsNew)
                    {
                        line.SystemDate = currentDateTime;
                        blockXml.Add(new XElement("entry", new XAttribute("itemId", line.ItemId.ToUpperString()), new XAttribute("warehouseId", sheet.WarehouseId.ToUpperString())));
                    }
                }

                blockXml = this.itemMapper.BlockItems(blockXml);

                //przetwarzamy wynik
                if (blockXml != null)
                {
                    foreach (var entry in blockXml.Elements())
                    {
                        Guid itemId = new Guid(entry.Attribute("itemId").Value);
                        var line = sheet.Lines.Children.Where(l => l.ItemId == itemId && l.Direction > 0).First();

                        if (entry.Attribute("alreadyBlocked") != null && entry.Attribute("alreadyBlocked").Value == "1")
                        {
                            string whSymbol = DictionaryMapper.Instance.GetWarehouse(new Guid(entry.Attribute("warehouseId").Value)).Symbol;
                            throw new ClientException(ClientExceptionId.ItemBlockError, null, "itemName:" + line.ItemName, "whSymbol:" + whSymbol);
                        }
                        else
                        {
                            decimal quantity = Convert.ToDecimal(entry.Attribute("quantity").Value, CultureInfo.InvariantCulture);
                            line.SystemQuantity = quantity;
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
        public XDocument SaveBusinessObject(InventorySheet sheet)
        {
            DictionaryMapper.Instance.CheckForChanges();

            //load alternate version
            if (!sheet.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.mapper.LoadBusinessObject(sheet.BOType, sheet.Id.Value);
                sheet.SetAlternateVersion(alternateBusinessObject);
            }

            //update status
            sheet.UpdateStatus(true);

            if (sheet.AlternateVersion != null)
                sheet.AlternateVersion.UpdateStatus(false);

            //validate
            sheet.Validate();

            if (sheet.DocumentStatus == DocumentStatus.Canceled)
            {
                foreach (var line in sheet.Lines) //jak anulujemy arkusz to zerujemy direction na pozycjach
                    line.Direction = 0;
            }

            //update status
            sheet.UpdateStatus(true);

            if (sheet.AlternateVersion != null)
                sheet.AlternateVersion.UpdateStatus(false);

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.mapper.CheckBusinessObjectVersion(sheet);

                this.ProcessInventoryHeaderOperations(sheet);

                //Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                sheet.SaveChanges(operations);

                if (sheet.AlternateVersion != null)
                    sheet.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    this.mapper.ExecuteOperations(operations);
                    //this.mapper.CreateCommunicationXml(sheet);
                    //this.mapper.UpdateDictionaryIndex(sheet);
                }

                if (!sheet.SkipItemsUnblock && //jezeli nie mamy pominac odblokowywania bo np. dokument inwentaryzacji to zrobi za nas
                    sheet.Lines.Children.Where(l => l.Direction == 0 && (l.IsNew || ((InventorySheetLine)l.AlternateVersion).Direction > 0)).FirstOrDefault() != null) //jezeli jakas linia zostala anulowana
                {
                    itemMapper.UnblockItems();
                }

                Coordinator.LogSaveBusinessObjectOperation();

                operations = XDocument.Parse("<root/>");

                if (operations.Root.HasElements)
                    this.mapper.ExecuteOperations(operations);                         

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", sheet.Id.ToUpperString()));

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:76");
                Coordinator.ProcessSqlException(sqle, sheet.BOType, this.coordinator.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:77");
                if (this.coordinator.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }
    }
}
