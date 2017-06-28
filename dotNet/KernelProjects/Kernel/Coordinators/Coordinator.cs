using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Coordinators.Plugins;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Base class for all Coordinators.
    /// </summary>
	public abstract class Coordinator : IDisposable
    {
        /// <summary>
        /// Gets or sets the main <see cref="Mapper"/>.
        /// </summary>
        public Mapper Mapper { get; protected set; }

        /// <summary>
        /// Gets the value that indicates whether <see cref="Dispose(bool)"/> has been called.
        /// </summary>
        protected bool IsDisposed { get; set; }

        /// <summary>
        /// Collection of plugins attached to the <see cref="Coordinator"/>.
        /// </summary>
        private List<Plugin> plugins;

        /// <summary>
        /// Gets the collection of plugins attached to the <see cref="Coordinator"/>.
        /// </summary>
        public ICollection<Plugin> Plugins
        { get { return this.plugins; } }

        /// <summary>
        /// Value indicating if the read lock on <see cref="DictionaryMapper"/> is aquired;
        /// </summary>
        protected bool IsReadLockAquired;

        /// <summary>
        /// Gets or sets a value indicating whether the <see cref="Coordinator"/> can commit main transaction.
        /// </summary>
        public bool CanCommitTransaction { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="Coordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        protected Coordinator(bool aquireDictionaryLock, bool canCommitTransaction)
        {
            this.plugins = new List<Plugin>();
            Debug.WriteLine(String.Format(CultureInfo.InvariantCulture, "{0} has been created with: {1} {2}", this.GetType().ToString(), aquireDictionaryLock, canCommitTransaction));
            if (aquireDictionaryLock)
            {
                DictionaryMapper.Instance.DictionaryLock.EnterReadLock();
                this.IsReadLockAquired = true;
            }

            this.CanCommitTransaction = canCommitTransaction;
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>LoadObjects</c> phase.
        /// </summary>
        /// <param name="param">Phase's optional parameter.</param>
        public virtual void LoadObjectPhase(object param)
        {
            var plugs = from p in this.plugins
                        orderby p.LoadObjectsPriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnLoadObjects(param);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>PreValidate</c> phase.
        /// </summary>
        /// <param name="param">Phase's optional parameter.</param>
        public virtual void PreValidatePhase(object param)
        {
            var plugs = from p in this.plugins
                        orderby p.PreValidatePriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnPreValidate(param);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>ExecuteLogic</c> phase.
        /// </summary>
        /// <param name="businessObject">Main business object currently processed.</param>
        public virtual void ExecuteLogicPhase(IBusinessObject businessObject)
        {
            var plugs = from p in this.plugins
                        orderby p.ExecuteLogicPriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnExecuteLogic(businessObject);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>ValidateLogic</c> phase.
        /// </summary>
        /// <param name="param">Phase's optional parameter.</param>
        public virtual void ValidateLogicPhase(object param)
        {
            var plugs = from p in this.plugins
                        orderby p.ValidateLogicPriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnValidateLogic(param);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>BeginTransaction</c> phase.
        /// </summary>
        /// <param name="businessObject">Main business object currently processed.</param>
        public virtual void BeginTransactionPhase(IBusinessObject businessObject)
        {
            var plugs = from p in this.plugins
                        orderby p.BeginTransactionPriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnBeginTransaction(businessObject);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>ValidateTransaction</c> phase.
        /// </summary>
        /// <param name="param">Phase's optional parameter.</param>
        public virtual void ValidateTransactionPhase(IBusinessObject businessObject)
        {
            var plugs = from p in this.plugins
                        orderby p.ValidateTransactionPriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnValidateTransaction(businessObject);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>BeforeSave</c> phase.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObject"/> that is to be saved.</param>
        public virtual void BeforeSavePhase(IBusinessObject businessObject)
        {
            var plugs = from p in this.plugins
                        orderby p.BeforeSavePriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnBeforeSave(businessObject);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>AfterSave</c> phase.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObject"/> that has just been saved to database.</param>
        public virtual void AfterExecuteOperationPhase(IBusinessObject businessObject)
        {
            var plugs = from p in this.plugins
                        orderby p.AfterExecuteOperationsPriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnAfterExecuteOperations(businessObject);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>AfterSave</c> phase.
        /// </summary>
        /// <param name="operationsList">The operations list.</param>
        /// <param name="returnXml">Xml that will be returned to the client.</param>
        public virtual void AfterSavePhase(XDocument operationsList, XDocument returnXml)
        {
            var plugs = from p in this.plugins
                        orderby p.AfterSavePriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnAfterSave(operationsList, returnXml);
            }
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>AfterCreate</c> phase.
        /// </summary>
        /// <param name="businessObject">Created <see cref="IBusinessObject"/> so far.</param>
        /// <param name="requestXml">Client's request Xml containing info about source document.</param>
        public virtual void AfterCreatePhase(IBusinessObject businessObject, XDocument requestXml)
        {
            var plugs = from p in this.plugins
                        orderby p.AfterCreatePriority ascending
                        select p;

            foreach (Plugin plug in plugs)
            {
                plug.OnAfterCreate(businessObject, requestXml);
            }
        }

        /// <summary>
        /// Creates a new <see cref="IBusinessObject"/>.
        /// </summary>
        /// <param name="type">Type of the <see cref="IBusinessObject"/> to create.</param>
        /// <param name="template">The template name for business object creation.</param>
        /// <returns>A newly created <see cref="IBusinessObject"/>.</returns>
        internal virtual IBusinessObject CreateNewBusinessObject(BusinessObjectType type, string template, XElement source)
        {
            this.LoadPlugins(CoordinatorPluginPhase.CreateObject, null);

            IBusinessObject createdObject = null;

            if (template != null)
            {
                if (template == "employee") // Tutaj jest sztywne przypisanie bo flex nie zwraca uwagi na contractorType
                    type = BusinessObjectType.Employee;

                IBusinessObject bo = this.Mapper.CreateNewBusinessObject(type, null);

                //if (!ConfigurationMapper.Instance.Templates.ContainsKey(type) || !ConfigurationMapper.Instance.Templates[type].ContainsKey(template))
                //    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, 
                //        "Template '{0}' not found for business object '{1}'.", template, type.ToString()));
                if (template == "employee") // Tutaj jest sztywne przypisanie bo flex nie zwraca uwagi na contractorType
                    type = BusinessObjectType.Contractor;
                XElement templateXml = (XElement)ConfigurationMapper.Instance.Templates[type][template];

                bo.Deserialize((XElement)templateXml.FirstNode);

                createdObject = bo;
            }
            else
                createdObject = this.Mapper.CreateNewBusinessObject(type, SessionManager.VolatileElements.ClientRequest);

            this.AfterCreatePhase(createdObject, SessionManager.VolatileElements.ClientRequest);

            return createdObject;
        }

		/// <summary>
		/// Creates a new <see cref="IBusinessObject"/> of type T.
		/// </summary>
		/// <param name="T">Type of the <see cref="IBusinessObject"/> to create.</param>
		/// <param name="template">The template name for business object creation.</param>
		/// <returns>A newly created <see cref="IBusinessObject"/> of type T.</returns>
		public virtual T CreateNewBusinessObject<T>(string template) where T : class, IBusinessObject
		{
			return this.CreateNewBusinessObject<T>(template, null);
		}

		/// <summary>
		/// Creates a new <see cref="IBusinessObject"/> of type T.
		/// </summary>
		/// <param name="T">Type of the <see cref="IBusinessObject"/> to create.</param>
		/// <param name="template">The template name for business object creation.</param>
		/// <param name="source">Xml element with source specification.</param>
		/// <returns>A newly created <see cref="IBusinessObject"/> of type T.</returns>
		public virtual T CreateNewBusinessObject<T>(string template, XElement source) where T : class, IBusinessObject
		{
			Type type = typeof(T);
			if (this.Mapper.SupportsType(type))
				return (T)this.CreateNewBusinessObject(this.Mapper.GetBusinessObjectTypeName(type), template, source);
			else
				throw new InvalidOperationException("Type not supported.");
		}

        /// <summary>
        /// Creates a new <see cref="BusinessObject"/> according to the client's request.
        /// </summary>
        /// <param name="requestXml">Client's request containing initial parameters.</param>
        /// <returns>A new <see cref="BusinessObject"/>'s xml.</returns>
        public XDocument CreateNewBusinessObject(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;
            BusinessObjectType type;

            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), requestXml.Root.Element("type").Value);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:9");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + requestXml.Root.Element("type").Value);
            }

            string template = null;

            if (requestXml.Root.Element("template") != null)
                template = requestXml.Root.Element("template").Value;

            return this.CreateNewBusinessObject(type, template, requestXml.Root.Element("source")).FullXml;
        }

        internal virtual IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            return this.Mapper.LoadBusinessObject(type, id);
        }

		public virtual T LoadBusinessObject<T>(Guid id) where T : class, IBusinessObject
		{
			return (T)LoadBusinessObject(this.Mapper.GetBusinessObjectTypeName(typeof(T)), id);
		}

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id.
        /// </summary>
        /// <param name="requestXml">Client's request containing information about what object type to load and what's the object id.</param>
        /// <returns>Loaded <see cref="BusinessObject"/> xml.</returns>
        public virtual XDocument LoadBusinessObject(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;
            BusinessObjectType type;

            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), requestXml.Root.Element("type").Value);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:10");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + requestXml.Root.Element("type").Value);
            }

            XDocument retXml = this.LoadBusinessObject(type, new Guid(requestXml.Root.Element("id").Value)).FullXml;

            return retXml;
        }

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id for printing.
        /// </summary>
        /// <param name="requestXml">Client's request containing information about what object type to load and what's the object id.</param>
        /// <returns>Loaded <see cref="BusinessObject"/> xml with additional localized labels for printing.</returns>
		public virtual XDocument LoadBusinessObjectForPrinting(XDocument requestXml)
		{
			return this.LoadBusinessObjectForPrinting(requestXml, null);
		}
		public virtual XDocument LoadBusinessObjectForPrinting(XDocument requestXml, string customLabelsLanguage)
		{
            SessionManager.VolatileElements.ClientRequest = requestXml;
            BusinessObjectType type;

            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), requestXml.Root.Element("type").Value);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:11");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + requestXml.Root.Element("type").Value);
            }

            DictionaryMapper.Instance.CheckForChanges();

            IBusinessObject bo = this.LoadBusinessObject(type, new Guid(requestXml.Root.Element("id").Value));

            CommercialDocument document = bo as CommercialDocument;

            if (document != null)
            {
                DocumentCategory category = document.DocumentType.DocumentCategory;

                if (category == DocumentCategory.SalesCorrection || category == DocumentCategory.PurchaseCorrection)
                {
                    List<CommercialDocumentLine> linesToDelete = new List<CommercialDocumentLine>();


                    foreach (CommercialDocumentLine line in document.Lines.Children)
                    {
                        if (line.DiscountGrossValue == line.CorrectedLine.DiscountGrossValue &&
                                line.DiscountNetValue == line.CorrectedLine.DiscountNetValue &&
                                line.DiscountRate == line.CorrectedLine.DiscountRate &&
                                line.GrossPrice == line.CorrectedLine.GrossPrice &&
                                line.GrossValue == line.CorrectedLine.GrossValue &&
                                line.InitialGrossPrice == line.CorrectedLine.InitialGrossPrice &&
                                line.InitialGrossValue == line.CorrectedLine.InitialGrossValue &&
                                line.InitialNetPrice == line.CorrectedLine.InitialNetPrice &&
                                line.InitialNetValue == line.CorrectedLine.InitialNetValue &&
                                line.NetPrice == line.CorrectedLine.NetPrice &&
                                line.NetValue == line.CorrectedLine.NetValue &&
                                line.Quantity == line.CorrectedLine.Quantity &&
                                line.VatValue == line.CorrectedLine.VatValue)
                            linesToDelete.Add(line);
                    }

                    foreach (CommercialDocumentLine line in linesToDelete)
                        document.Lines.Children.Remove(line);

                    document.Lines.UpdateOrder();

                    foreach (CommercialDocumentLine line in document.Lines.Children)
                        line.CorrectedLine.Order = line.Order;
                }
            }

            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(bo.Serialize());
            BusinessObjectHelper.GetPrintXml(xml, customLabelsLanguage);

            return xml;
        }

        /// <summary>
        /// Performs initial validation.
        /// </summary>
        /// <param name="requestXml">Client's request containing <see cref="BusinessObject"/>'s xml and its options.</param>
        protected virtual void PerformInitialValidation(XDocument requestXml)
        { }

        /// <summary>
        /// Loads plugins for the current coordinator.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="businessObject">Main business object currently processed.</param>
        protected virtual void LoadPlugins(CoordinatorPluginPhase pluginPhase, IBusinessObject businessObject)
        {
            this.Plugins.Clear();
        }

        /// <summary>
        /// Deletes business object.
        /// </summary>
        /// <param name="requestXml">Client's request containing <see cref="BusinessObject"/>'s id to delete.</param>
        public virtual void DeleteBusinessObject(XDocument requestXml)
        {
            throw new InvalidOperationException("This business object does not support delete operation.");
        }

        /// <summary>
        /// Saves a collection of business objects. All <see cref="BusinessObject"/>s are saved in one transaction and therefore every logic is performed in transaction.
        /// </summary>
        /// <param name="businessObjects">Collection of business objects to save.</param>
        public void SaveBusinessObjects(params IBusinessObject[] businessObjects)
        {
            DictionaryMapper.Instance.CheckForChanges();
            Mapper mapper = null;
            SqlConnectionManager.Instance.BeginTransaction();

            foreach (IBusinessObject businessObject in businessObjects)
            {
                mapper = Mapper.GetMapperForSpecifiedBusinessObjectType(businessObject.BOType);

                #region Load AlternateVersion
                if (!businessObject.IsNew)
                {
                    IBusinessObject alternateBusinessObject = mapper.LoadBusinessObject(businessObject.BOType, businessObject.Id.Value);
                    businessObject.SetAlternateVersion(alternateBusinessObject);
                }
                #endregion

                #region UpdateStatus
                businessObject.UpdateStatus(true);

                if (businessObject.AlternateVersion != null)
                    businessObject.AlternateVersion.UpdateStatus(false);
                #endregion

                this.LoadPlugins(CoordinatorPluginPhase.SaveObject, businessObject);

                this.LoadObjectPhase(null);

                this.PreValidatePhase(null);

                //Get all errors together and put it to the client

                this.ExecuteLogicPhase(null);

                this.ValidateLogicPhase(null);

                businessObject.Validate();

                try
                {
                    DictionaryMapper.Instance.CheckForChanges();
                    mapper.CheckBusinessObjectVersion(businessObject);

                    this.BeginTransactionPhase(businessObject);

                    this.ValidateTransactionPhase(businessObject);

                    this.BeforeSavePhase(businessObject);

                    #region Make operations list
                    XDocument operations = XDocument.Parse("<root/>");

                    businessObject.SaveChanges(operations);

                    if (businessObject.AlternateVersion != null)
                        businessObject.AlternateVersion.SaveChanges(operations);
                    #endregion

                    if (operations.Root.HasElements)
                    {
                        mapper.ExecuteOperations(operations);

                        this.AfterExecuteOperationPhase(businessObject);
						Coordinator.LogSaveBusinessObjectOperation();

                        mapper.CreateCommunicationXml(businessObject);
                        mapper.UpdateDictionaryIndex(businessObject);
                    }

                    XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", businessObject.Id.ToUpperString()));

                    this.AfterSavePhase(operations, returnXml);
                }
                catch (SqlException sqle)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:12");
                    Coordinator.ProcessSqlException(sqle, businessObject.BOType, this.CanCommitTransaction);
                    throw;
                }
                catch (Exception)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:13");
                    if (this.CanCommitTransaction)
                        SqlConnectionManager.Instance.RollbackTransaction();
                    throw;
                }
            }

            if (this.CanCommitTransaction)
            {
                if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
                    SqlConnectionManager.Instance.CommitTransaction();
                else
                    SqlConnectionManager.Instance.RollbackTransaction();
            }
        }

		public TimeSpan? SaveLargeQuantityOfBusinessObjects<T>(bool updateDictionaryIndex, params T[] businessObjects) 
			where T : IBusinessObject
		{
			if (businessObjects == null || businessObjects.Count() == 0)
				return null;

			Stopwatch updateDictionaryIndexWatch = new Stopwatch();

			T bo = businessObjects[0];

			DictionaryMapper.Instance.CheckForChanges();
			Mapper mapper = Mapper.GetMapperForSpecifiedBusinessObjectType(bo.BOType);
			SqlConnectionManager.Instance.BeginTransaction();

			foreach (T businessObject in businessObjects)
			{
				#region Load AlternateVersion
				if (!businessObject.IsNew)
				{
					IBusinessObject alternateBusinessObject = mapper.LoadBusinessObject(businessObject.BOType, businessObject.Id.Value);
					businessObject.SetAlternateVersion(alternateBusinessObject);
				}
				#endregion

				#region UpdateStatus
				businessObject.UpdateStatus(true);

				if (businessObject.AlternateVersion != null)
					businessObject.AlternateVersion.UpdateStatus(false);
				#endregion

				this.LoadPlugins(CoordinatorPluginPhase.SaveObject, businessObject);

				this.LoadObjectPhase(null);

				this.PreValidatePhase(null);

				//Get all errors together and put it to the client

				this.ExecuteLogicPhase(null);

				this.ValidateLogicPhase(null);

				businessObject.Validate();
			}
			try
			{
				DictionaryMapper.Instance.CheckForChanges();
				foreach (T businessObject in businessObjects)
				{
					mapper.CheckBusinessObjectVersion(businessObject);

					this.BeginTransactionPhase(businessObject);

					this.ValidateTransactionPhase(businessObject);

					this.BeforeSavePhase(businessObject);
				}

				#region Make operations list
				XDocument operations = XDocument.Parse("<root/>");

				foreach (T businessObject in businessObjects)
				{
					businessObject.SaveChanges(operations);

					if (businessObject.AlternateVersion != null)
						businessObject.AlternateVersion.SaveChanges(operations);
				}
				#endregion

				if (operations.Root.HasElements)
				{
					mapper.ExecuteOperations(operations);

					foreach (IBusinessObject businessObject in businessObjects)
					{
						this.AfterExecuteOperationPhase(businessObject);
						Coordinator.LogSaveBusinessObjectOperation();

						mapper.CreateCommunicationXml(businessObject);
						if (updateDictionaryIndex)
						{
							updateDictionaryIndexWatch.Start();
							mapper.UpdateDictionaryIndex(businessObject);
							updateDictionaryIndexWatch.Stop();
						}
					}
				}

				foreach (IBusinessObject businessObject in businessObjects)
				{
					XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", businessObject.Id.ToUpperString()));

					this.AfterSavePhase(operations, returnXml);
				}
			}
			catch (SqlException sqle)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:14");
				Coordinator.ProcessSqlException(sqle, bo.BOType, this.CanCommitTransaction);
				throw;
			}
			catch (Exception)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:15");
				if (this.CanCommitTransaction)
					SqlConnectionManager.Instance.RollbackTransaction();
				throw;
			}

			if (this.CanCommitTransaction)
			{
				if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
					SqlConnectionManager.Instance.CommitTransaction();
				else
					SqlConnectionManager.Instance.RollbackTransaction();
			}

			return updateDictionaryIndexWatch.Elapsed;
		}

		public void UpdateDictionaryIndexLargeQuantity(object businessObjectsAsObject)
		{
			IBusinessObject[] businessObjects = (IBusinessObject[])businessObjectsAsObject;
			if (businessObjects == null || businessObjects.Count() == 0)
				return;

			IBusinessObject bo = businessObjects[0];

			Mapper mapper = Mapper.GetMapperForSpecifiedBusinessObjectType(bo.BOType);

			foreach (IBusinessObject businessObject in businessObjects)
			{
				SessionManager.VolatileElements.TransactionRepeatCounter = 0;
				this.UpdateDictionaryIndexLargeQuantity(businessObject, mapper, bo.BOType);
			}
		}

		private void UpdateDictionaryIndexLargeQuantity<T>(T businessObject, Mapper mapper, BusinessObjectType boType) where T : IBusinessObject
		{
			SqlConnectionManager.Instance.BeginTransaction();
			try
			{
				mapper.UpdateDictionaryIndex(businessObject);
			}
			catch (SqlException sqle)
			{
				if (sqle.Number == 1205)
				{
					if (SessionManager.VolatileElements.TransactionRepeatCounter <= 3)
					{
						int repeatCounter = SessionManager.VolatileElements.TransactionRepeatCounter;
						SqlConnectionManager.Instance.RollbackTransaction();
						Thread.Sleep(500);
						SessionManager.VolatileElements.TransactionRepeatCounter = (repeatCounter+1);
						this.UpdateDictionaryIndexLargeQuantity<T>(businessObject, mapper, boType);
						return;
					}
				}
				Coordinator.ProcessSqlException(sqle, boType, this.CanCommitTransaction);
				throw;
			}
			catch (Exception)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:16");
				if (this.CanCommitTransaction)
					SqlConnectionManager.Instance.RollbackTransaction();
				throw;
			}
			if (this.CanCommitTransaction)
			{
				if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
					SqlConnectionManager.Instance.CommitTransaction();
				else
					SqlConnectionManager.Instance.RollbackTransaction();
			}
		}

        /// <summary>
        /// Processes the <see cref="BusinessObject"/> according to its options and finally saves it to database.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObject"/> to save.</param>
        /// <returns>Xml containing operation results.</returns>
        public virtual XDocument SaveBusinessObject(IBusinessObject businessObject)
        {
            DictionaryMapper.Instance.CheckForChanges();

            #region Load AlternateVersion
            if (!businessObject.IsNew)
            {
                IBusinessObject alternateBusinessObject = this.Mapper.LoadBusinessObject(businessObject.BOType, businessObject.Id.Value);
                businessObject.SetAlternateVersion(alternateBusinessObject);
            }
            #endregion

            #region UpdateStatus
            businessObject.UpdateStatus(true);

            if (businessObject.AlternateVersion != null)
                businessObject.AlternateVersion.UpdateStatus(false);
            #endregion

            this.LoadPlugins(CoordinatorPluginPhase.SaveObject, businessObject);

            this.LoadObjectPhase(null);

            this.PreValidatePhase(null);

            //Get all errors together and put it to the client

            this.ExecuteLogicPhase(businessObject);

            this.ValidateLogicPhase(null);

            businessObject.Validate();

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                this.Mapper.CheckBusinessObjectVersion(businessObject);

                this.BeginTransactionPhase(businessObject);

                this.ValidateTransactionPhase(businessObject);

                this.BeforeSavePhase(businessObject);

                #region Make operations list
                XDocument operations = XDocument.Parse("<root/>");

                businessObject.SaveChanges(operations);

                if (businessObject.AlternateVersion != null)
                    businessObject.AlternateVersion.SaveChanges(operations);
                #endregion

                if (operations.Root.HasElements)
                {
                    this.Mapper.ExecuteOperations(operations);

                    this.AfterExecuteOperationPhase(businessObject);

                    this.Mapper.CreateCommunicationXml(businessObject);
                    this.Mapper.UpdateDictionaryIndex(businessObject);
                }

                Coordinator.LogSaveBusinessObjectOperation(businessObject.Id);

                XDocument returnXml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, "<root><id>{0}</id></root>", businessObject.Id.ToUpperString()));

                this.AfterSavePhase(operations, returnXml);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:17");
                Coordinator.ProcessSqlException(sqle, businessObject.BOType, this.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:18");
                if (this.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        /// <summary>
        /// Processes the SQL exception during main transaction and throws <see cref="ClientException"/> if its a known exception.
        /// </summary>
        /// <param name="sqle">The <see cref="SqlException"/> to process.</param>
        /// <param name="type">The type of <see cref="BusinessObject"/> that caused the exception.</param>
        internal static void ProcessSqlException(SqlException sqle, BusinessObjectType type, bool canCommitTransaction)
        {
            if (canCommitTransaction)
                SqlConnectionManager.Instance.RollbackTransaction();

			if (sqle.Number == 50012)
				throw new ClientException(ClientExceptionId.VersionMismatch, sqle, "objType:" + type.ToString());
			else if (sqle.Number == 1205)
				throw new ClientException(ClientExceptionId.Deadlock, sqle);
			else if (sqle.Number == 2627)
				throw new ClientException(ClientExceptionId.ObjectAlreadyExists, null);
			else if (sqle.Number == 50015)
				throw new ClientException(ClientExceptionId.CorrectedCorrectionCancellationError);
			else if (sqle.Number == 17142 || sqle.Number == 10054)
				throw new ClientException(ClientExceptionId.SqlConnectionError);
			else if (sqle.Number == 50000) //custom message from database
				throw new ClientException(ClientExceptionId.ForwardError, null, String.Concat("message:", sqle.Message));
        }

		internal static void LogSaveBusinessObjectOperation()
		{
			Coordinator.LogSaveBusinessObjectOperation(null);
		}

		internal static void LogSaveDictionaryOperation()
		{
			XDocument clientXml = SessionManager.VolatileElements.ClientRequest;

			XElement firstElement = (XElement)clientXml.Root.FirstNode;
			string dictName = firstElement.Name.LocalName;

			XDocument journalXml = ConfigurationMapper.Instance.ExtendedJournal ? 
				new XDocument(clientXml) : XDocument.Parse(String.Format("<root><dictionary>{0}</dictionary></root>", dictName));
			JournalManager.AddJournalTransactionAttributes(journalXml.Root);
			JournalManager.Instance.LogToJournal(JournalAction.Dictionary_Save, journalXml);
		}

		internal static void LogRelateDocumentsOperation(Guid commercialDocumentId, List<Guid> warehouseDocumentsIds)
		{
			XDocument clientXml = SessionManager.VolatileElements.ClientRequest;

			if (clientXml != null)
			{
				XDocument jXml = ConfigurationMapper.Instance.ExtendedJournal ? new XDocument(clientXml) : XDocument.Parse(XmlName.EmptyRoot);
				JournalManager.AddJournalTransactionAttributes(jXml.Root);

				int wDocsCount = warehouseDocumentsIds != null ? warehouseDocumentsIds.Count : 0;
				Guid? wDocId1 = wDocsCount > 0 ? (Guid?)warehouseDocumentsIds[0] : null;
				Guid? wDocId2 = wDocsCount > 1 ? (Guid?)warehouseDocumentsIds[1] : null;

				JournalManager.Instance.LogToJournal(JournalAction.Documents_Relate, commercialDocumentId, wDocId1, wDocId2, jXml);
			}
		}

        internal static void LogSaveBusinessObjectOperation(Guid? id)
        {
            XDocument clientXml = SessionManager.VolatileElements.ClientRequest;

            if (clientXml != null && !SessionManager.VolatileElements.WasOperationLogged)
            {
                SessionManager.VolatileElements.WasOperationLogged = true;
				bool processStateChange = clientXml.Root.Element(XmlName.DocumentType) != null;
                XElement firstElement = (XElement)clientXml.Root.FirstNode;
                string boNodeName = processStateChange ? clientXml.Root.Element(XmlName.DocumentType).Value.ToUpperInvariant() : firstElement.Name.LocalName.ToUpperInvariant();
				bool documentStatusChange = boNodeName.EndsWith("documentid", true, CultureInfo.InvariantCulture);
				bool fiscalizeDocument = boNodeName == "ID";
                bool isNew = (firstElement.Element("version") == null) && !documentStatusChange && !processStateChange;

				Guid? boId = null;
				if (documentStatusChange)
				{
					boId = new Guid(firstElement.Value);
					boNodeName = boNodeName.SubstringBefore("ID");
				}
				else if (fiscalizeDocument)
				{
					boId = new Guid(firstElement.Value);
					boNodeName = "COMMERCIALDOCUMENT";
				}
				else if (processStateChange)
				{
					boId = new Guid(clientXml.Root.Element(XmlName.DocumentId).Value);
				}
				else if (firstElement.Element("id") != null)
					boId = new Guid(firstElement.Element("id").Value);
				else if (id.HasValue)
					boId = id;
				else
					return;

				JournalAction action = JournalManager.GetJournalAction(boNodeName, isNew);

                if (action != JournalAction.Unspecified)
                {
                    if (ConfigurationMapper.Instance.ExtendedJournal)
                    {
						JournalManager.AddJournalTransactionAttributes(clientXml.Root);
                        JournalManager.Instance.LogToJournal(action, boId, null, null, clientXml);
						JournalManager.RemoveJournalTransactionAttributes(clientXml.Root);
                    }
                    else
                    {
                        XDocument xml = XDocument.Parse(XmlName.EmptyRoot);
						JournalManager.AddJournalTransactionAttributes(xml.Root);
                        JournalManager.Instance.LogToJournal(action, boId, null, null, xml);
                    }
                }
            }
        }

        /// <summary>
        /// Processes the <see cref="BusinessObject"/> according to its options and finally saves it to database.
        /// </summary>
        /// <param name="requestXml">Client's request containing <see cref="BusinessObject"/>'s xml and its options.</param>
        /// <returns>Xml containing operation results.</returns>
        public XDocument SaveBusinessObject(XDocument requestXml)
        {
            try
            {
                SessionManager.VolatileElements.ClientRequest = requestXml;
                this.PerformInitialValidation(requestXml);

                IBusinessObject businessObject = this.Mapper.ConvertToBusinessObject((XElement)requestXml.Root.FirstNode, requestXml.Root.Element("options"));

                XDocument result = this.SaveBusinessObject(businessObject);

                if (businessObject is Document)
                {
                    Guid mainDocId = new Guid(result.Root.Element("id").Value);

                    result.Root.Add(SessionManager.VolatileElements.GetSavedDocuments(mainDocId));
				}
				if (SessionManager.VolatileElements.HasWarnings)
				{
					result.Root.Add(SessionManager.VolatileElements.WarningsToXmlElement());
				}

                return result;
            }
            catch (ClientException ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:19");
                int repeatCounter = SessionManager.VolatileElements.TransactionRepeatCounter;
                if (ex.Id == ClientExceptionId.Deadlock && repeatCounter <= 3)
                {
                    SessionManager.ResetVolatileContainer();
                    SessionManager.VolatileElements.TransactionRepeatCounter = (repeatCounter + 1);
                    SqlConnectionManager.Instance.RollbackTransaction();
                    Random r = new Random();
                    Thread.Sleep(r.Next(500));
                    return this.SaveBusinessObject(requestXml);
                }
                else
                    throw;
            }
        }

        /// <summary>
        /// Gets the proper <see cref="Coordinator"/> for the specified <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="type">Type of the <see cref="BusinessObject"/>.</param>
        /// <returns>Proper <see cref="Coordinator"/>.</returns>
        public static Coordinator GetCoordinatorForSpecifiedType(BusinessObjectType type)
        {
            return Coordinator.GetCoordinatorForSpecifiedType(type, true, true);
        }

        public static Coordinator GetCoordinatorForSpecifiedType(BusinessObjectType type, bool aquireDictionaryLock, bool canCommitTransaction)
        {
            Coordinator c = null;

            switch (type)
            {
                case BusinessObjectType.Bank:
                case BusinessObjectType.Contractor:
                case BusinessObjectType.Employee:
                case BusinessObjectType.ApplicationUser:
                    c = new ContractorCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.Item:
                    c = new ItemCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.FileDescriptor:
                    c = new RepositoryCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.CommercialDocument:
                case BusinessObjectType.WarehouseDocument:
                case BusinessObjectType.FinancialDocument:
                case BusinessObjectType.FinancialReport:
                case BusinessObjectType.Payment:
                case BusinessObjectType.ServiceDocument:
                case BusinessObjectType.ComplaintDocument:
                case BusinessObjectType.InventoryDocument:
                case BusinessObjectType.InventorySheet:
				case BusinessObjectType.OfferDocument:
                    c = new DocumentCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.Configuration:
                    c = new ConfigurationCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.ContractorField:
                case BusinessObjectType.ContractorRelationType:
                case BusinessObjectType.Country:
                case BusinessObjectType.Currency:
                case BusinessObjectType.DocumentField:
                case BusinessObjectType.DocumentType:
                case BusinessObjectType.IssuePlace:
                case BusinessObjectType.ItemField:
                case BusinessObjectType.ItemRelationAttrValueType:
                case BusinessObjectType.ItemRelationType:
                case BusinessObjectType.ItemType:
                case BusinessObjectType.MimeType:
                case BusinessObjectType.PaymentMethod:
                case BusinessObjectType.Repository:
                case BusinessObjectType.Unit:
                case BusinessObjectType.UnitType:
                case BusinessObjectType.VatRate:
                case BusinessObjectType.DocumentNumberComponent:
                case BusinessObjectType.NumberSetting:
                case BusinessObjectType.VatRegister:
                case BusinessObjectType.FinancialRegister:
                case BusinessObjectType.ServicePlace:
                    c = new DictionaryCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.ShiftTransaction:
                case BusinessObjectType.Container:
                    c = new WarehouseCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.Custom:
                    c = new ListCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
                case BusinessObjectType.ServicedObject:
                    c = new ServiceCoordinator(aquireDictionaryLock, canCommitTransaction);
                    break;
            }

            return c;
        }

        /// <summary>
        /// Processes the <see cref="BusinessObject"/> according to its options and finally saves it to database.
        /// </summary>
        /// <typeparam name="T">Type of the <see cref="IVersionedBusinessObject"/> objects.</typeparam>
        /// <param name="collection">Collection of business objects to save.</param>
        internal void SaveMassiveBusinessObjectCollection<T>(MassiveBusinessObjectCollection<T> collection, MassiveBusinessObjectCollection<T> previousCollection) where T : class, IVersionedBusinessObject
        {
            DictionaryMapper.Instance.CheckForChanges();

            foreach (IVersionedBusinessObject businessObject in collection.Children)
            {
                businessObject.Validate();

                businessObject.UpdateStatus(true);

                if (businessObject.AlternateVersion != null)
                    businessObject.AlternateVersion.UpdateStatus(false);
            }

            foreach (IVersionedBusinessObject businessObject in previousCollection.Children)
            {
                businessObject.UpdateStatus(false);
            }

            SqlConnectionManager.Instance.BeginTransaction();

            try
            {
                DictionaryMapper.Instance.CheckForChanges();
                XDocument operations = XDocument.Parse("<root/>");

                foreach (IVersionedBusinessObject businessObject in collection.Children)
                {
                    this.Mapper.CheckBusinessObjectVersion(businessObject);

                    #region Make operations list
                    businessObject.SaveChanges(operations);

                    if (businessObject.AlternateVersion != null)
                        businessObject.AlternateVersion.SaveChanges(operations);
                    #endregion
                }

                foreach (IVersionedBusinessObject businessObject in previousCollection.Children)
                {
                    this.Mapper.CheckBusinessObjectVersion(businessObject);
                    businessObject.SaveChanges(operations);
                }

                if (operations.Root.HasElements)
                {
                    this.Mapper.ExecuteOperations(operations);
                    this.Mapper.CreateCommunicationXml(operations);
 //                   this.Mapper.UpdateDictionaryIndex(businessObject);
                }

				Coordinator.LogSaveDictionaryOperation();

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:20");
                Coordinator.ProcessSqlException(sqle, collection.Type, this.CanCommitTransaction);
                throw;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:21");
                if (this.CanCommitTransaction)
                    SqlConnectionManager.Instance.RollbackTransaction();
                throw;
            }
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="Coordinator"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (!this.IsDisposed)
            {
                if (disposing)
                {
                    Debug.WriteLine(String.Format(CultureInfo.InvariantCulture, "{0} has been disposed", this.GetType().ToString()));
                    if (this.IsReadLockAquired)
                    {
                        DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                        this.IsReadLockAquired = false;
                    }
                    //Dispose only managed resources here
                }
            }
            // Code to dispose the unmanaged resources 
            // held by the class
            this.IsDisposed = true;
        }

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion
    }
}
