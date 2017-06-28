using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators
{
    internal class WarehouseCoordinator : TypedCoordinator<WarehouseMapper>
    {
        public WarehouseCoordinator() : this(true, true)
        {
        }

        public WarehouseCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<WarehouseMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:95");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        public void SaveWarehouseMap(XDocument xml)
        {
			SessionManager.VolatileElements.ClientRequest = xml;

            WarehouseMapper mapper = (WarehouseMapper)this.Mapper;
            MassiveBusinessObjectCollection<Container> modifiedCollection = new MassiveBusinessObjectCollection<Container>();
            MassiveBusinessObjectCollection<Container> originalCollection = mapper.GetAllContainers();

            int order = 1;

            foreach (XElement containerElement in xml.Root.Descendants("slot"))
            {
                Container c = modifiedCollection.CreateNew();
                c.ContainerTypeId = new Guid(containerElement.Attribute("containerTypeId").Value);
                c.Id = new Guid(containerElement.Attribute("id").Value);
                c.Labels = XElement.Parse("<labels><label lang=\"pl\">" + containerElement.Attribute("label").Value + "</label></labels>");
                c.Order = order++;
                c.Symbol = containerElement.Attribute("symbol").Value;

                var orig = originalCollection.Children.Where(cc => cc.Id.Value == c.Id.Value).FirstOrDefault();

                if (orig != null)
                    c.Version = orig.Version.Value;
            }

            modifiedCollection.SetAlternateVersion(originalCollection);

            DictionaryMapper.Instance.CheckForChanges();

            foreach (IVersionedBusinessObject businessObject in modifiedCollection.Children)
            {
                businessObject.Validate();
                businessObject.UpdateStatus(true);
            }

            foreach (IVersionedBusinessObject businessObject in originalCollection.Children)
            {
                businessObject.UpdateStatus(false);
            }

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                XDocument operations = XDocument.Parse("<root/>");

                foreach (IVersionedBusinessObject businessObject in modifiedCollection.Children)
                {
                    this.Mapper.CheckBusinessObjectVersion(businessObject);

                    #region Make operations list
                    businessObject.SaveChanges(operations);

                    if (businessObject.AlternateVersion != null)
                        businessObject.AlternateVersion.SaveChanges(operations);
                    #endregion
                }

                //sprawdzamy czy jakis kontener jest do usuniecia
                var containersToDelete = originalCollection.Children.Where(o => o.Status == BusinessObjectStatus.Deleted);
                
                if (containersToDelete.FirstOrDefault() != null)
                {
                    bool areEmpty = ((WarehouseMapper)this.Mapper).AreContainersEmpty(containersToDelete);

                    if (!areEmpty)
                        throw new ClientException(ClientExceptionId.NotEmptyContainerRemoval);

                    foreach (Container c in originalCollection.Children)
                    {
                        if (c.Status == BusinessObjectStatus.Deleted)
                        {
                            c.Status = BusinessObjectStatus.Modified;
                            c.IsActive = false;
                            c.SaveChanges(operations);
                        }
                    }
                }

                if (operations.Root.HasElements)
                    this.Mapper.ExecuteOperations(operations);

                //zapisujemy xml do konfiguracji
                using (var c = new ConfigurationCoordinator(false, false))
                {
                    var collection = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "warehouse.warehouseMap");

                    Configuration conf = null;

                    if (collection.Count == 0)
                    {
                        conf = (Configuration)c.CreateNewBusinessObject(BusinessObjectType.Configuration, null, null);
                        conf.Key = "warehouse.warehouseMap";
                    }
                    else
                        conf = collection.First();

                    conf.Value = xml.Root;
                    c.SaveBusinessObject(conf);
                }

                if (this.CanCommitTransaction)
                {
                    if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
                        SqlConnectionManager.Instance.CommitTransaction();
                    else
                        SqlConnectionManager.Instance.RollbackTransaction();
                }
            }
            catch (SqlException sqle)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:96");
                Coordinator.ProcessSqlException(sqle, BusinessObjectType.Container, this.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:97");
                if (this.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        private void ProcessTransactionResult(XElement result)
        {
            //if (result.HasElements)
            //{
            //    if (result.Element("shift") != null)
            //    {
            //        string sourceShiftId = result.Element("shift").Element("id").Value;

            //        string containerName = DependencyContainerManager.Container.Get<WarehouseMapper>().GetContainerSymbolByShiftId(new Guid(sourceShiftId));

            //        throw new ClientException(ClientExceptionId.InsufficientQuantityOnContainer, null, "containerName:" + containerName);
            //    }
            //    else if (result.Element("unassignedQuantityExceeded") != null)
            //    {
            //        throw new ClientException(ClientExceptionId.ContainerUnassignedQuantityExceeded);
            //    }
            //    else if (result.Element("sourceQuantityExceeded") != null)
            //    {
            //        throw new ClientException(ClientExceptionId.SourceQuantityExceeded);
            //    }
            //}
        }

        internal static void ProcessWarehouseManagamentSystem(ShiftTransaction transaction)
        {
            if (transaction == null || !ConfigurationMapper.Instance.IsWmsEnabled) return;

            //ustawiamy odpowiednie id'ki jezeli jest powiazanie z linia
            /*
             * incomeWarehosueDocumentLineId - dla PZ i FZ kernel. WZ i FZ to panel
             * warehouseDocumentLineId - zawsze kernel
             * warehouseId - jezeli jest powiazanie z linia to jadro. moze byc null
             */ 
            foreach (Shift shift in transaction.Shifts.Children)
            {
                if (shift.RelatedWarehouseDocumentLine != null)
                {
                    if (shift.RelatedWarehouseDocumentLine.Parent.BOType == BusinessObjectType.WarehouseDocument
                        && ((WarehouseDocument)shift.RelatedWarehouseDocumentLine.Parent).WarehouseDirection == WarehouseDirection.Income)
                        shift.IncomeWarehouseDocumentLineId = shift.RelatedWarehouseDocumentLine.Id.Value;

                    shift.WarehouseDocumentLineId = shift.RelatedWarehouseDocumentLine.Id.Value;
                    shift.WarehouseId = shift.RelatedWarehouseDocumentLine.WarehouseId;
                }
            }

            using (WarehouseCoordinator c = new WarehouseCoordinator(false, false))
            {
                c.SaveBusinessObject(transaction);
            }
        }

        public XDocument GetShiftTransactionByShiftId(XDocument requestXml)
        {
            if (requestXml.Root.Element("shiftId") == null)
                throw new ArgumentException("No shiftId node in xml");

            ShiftTransaction st = ((WarehouseMapper)this.Mapper).GetShiftTransactionByShiftId(new Guid(requestXml.Root.Element("shiftId").Value));

            return st.FullXml;
        }

        public override XDocument SaveBusinessObject(IBusinessObject businessObject)
        {
            if (businessObject.BOType == BusinessObjectType.Container)
                return base.SaveBusinessObject(businessObject);

            DictionaryMapper.Instance.CheckForChanges();

            if (!businessObject.IsNew && businessObject.AlternateVersion == null)
            {
                IBusinessObject alternateBusinessObject = this.Mapper.LoadBusinessObject(businessObject.BOType, businessObject.Id.Value);
                businessObject.SetAlternateVersion(alternateBusinessObject);
            }

            businessObject.UpdateStatus(true);

            if (businessObject.AlternateVersion != null)
                businessObject.AlternateVersion.UpdateStatus(false);

            businessObject.Validate();

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.Mapper.CheckBusinessObjectVersion(businessObject);

                XDocument operations = XDocument.Parse("<root/>");

                businessObject.SaveChanges(operations);

                if (businessObject.AlternateVersion != null)
                    businessObject.AlternateVersion.SaveChanges(operations);

                if (operations.Root.HasElements)
                {
                    XDocument headerOperation = XDocument.Parse("<root/>");

                    if (businessObject.Status == BusinessObjectStatus.New || businessObject.Status == BusinessObjectStatus.Modified)
                    {
                        headerOperation.Root.Add(operations.Root.Element("shiftTransaction")); //auto-cloning
                    }

                    //sprawdzamy czy sa jakies delety
                    if (operations.Root.Element("shift") != null)
                    {
                        var deletes = operations.Root.Element("shift").Elements().Where(e => e.Attribute("action") != null && e.Attribute("action").Value == "delete");

                        if (deletes.Count() > 0)
                            headerOperation.Root.Add(new XElement("shift", deletes));
                    }

                    if (operations.Root.Element("shiftAttrValue") != null)
                    {
                        var deletes = operations.Root.Element("shiftAttrValue").Elements().Where(s => s.Attribute("action") != null && s.Attribute("action").Value == "delete");

                        if (deletes.Count() > 0)
                            headerOperation.Root.Add(new XElement("shiftAttrValue", deletes));
                    }

                    this.Mapper.ExecuteOperations(headerOperation);

                    WarehouseMapper mapper = (WarehouseMapper)this.Mapper;

                    XDocument createTransactionParam = XDocument.Parse("<root><shift/><containerShift/></root>");

                    if (operations.Root.Element("shift") != null)
                        createTransactionParam.Root.Element("shift").Add(operations.Root.Element("shift").Elements().Where(s => s.Attribute("action").Value == "insert"));

                    if (operations.Root.Element("containerShift") != null)
                        createTransactionParam.Root.Element("containerShift").Add(operations.Root.Element("containerShift").Elements().Where(s => s.Attribute("action").Value == "insert"));

                    if (createTransactionParam.Root.Element("shift").HasElements || createTransactionParam.Root.Element("containerShift").HasElements)
                    {
                        XElement result = mapper.CreateShiftTransaction(createTransactionParam);
                        this.ProcessTransactionResult(result);
                    }

                    XDocument editTransactionParam = XDocument.Parse("<root><shift/><containerShift/></root>");

                    if (operations.Root.Element("shift") != null)
                        editTransactionParam.Root.Element("shift").Add(operations.Root.Element("shift").Elements().Where(s => s.Attribute("action").Value == "update"));

                    if (operations.Root.Element("containerShift") != null)
                        editTransactionParam.Root.Element("containerShift").Add(operations.Root.Element("containerShift").Elements().Where(s => s.Attribute("action").Value == "update"));

                    if (editTransactionParam.Root.Element("shift").HasElements || editTransactionParam.Root.Element("containerShift").HasElements)
                    {
                        XElement result = mapper.EditShiftTransaction(editTransactionParam);
                        this.ProcessTransactionResult(result);
                    }

                    //insert or update attributes
                    if (operations.Root.Element("shiftAttrValue") != null)
                    {
                        XDocument attributes = XDocument.Parse("<root><shiftAttrValue/></root>");

                        attributes.Root.Element("shiftAttrValue").Add(operations.Root.Element("shiftAttrValue").Elements().Where(entry => entry.Attribute("action") == null || entry.Attribute("action").Value != "delete"));
                        this.Mapper.ExecuteOperations(attributes);
                    }

                    if (businessObject.IsNew)
                        ((WarehouseMapper)this.Mapper).DuplicateShiftAttributes(businessObject.Id.Value);
                }

                Coordinator.LogSaveBusinessObjectOperation();

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", businessObject.Id.ToUpperString()));

                if (this.CanCommitTransaction)
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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:98");
                Coordinator.ProcessSqlException(sqle, businessObject.BOType, this.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:99");
                if (this.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="ContractorCoordinator"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (!this.IsDisposed)
            {
                if (disposing)
                {
                    //Dispose only managed resources here
                    SqlConnectionManager.Instance.ReleaseConnection();
                }
            }

            base.Dispose(disposing);
        }
    }
}
