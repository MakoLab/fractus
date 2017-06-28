using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class representing a mapper with methods necessary to operate on configuration.
    /// </summary>
    public class ConfigurationMapper : Mapper
    {
        /// <summary>
        /// Instance of <see cref="ConfigurationMapper"/>.
        /// </summary>
        private static ConfigurationMapper instance = new ConfigurationMapper();

        /// <summary>
        /// Gets the instance of <see cref="ConfigurationMapper"/>.
        /// </summary>
        public static ConfigurationMapper Instance
        {
            get { return ConfigurationMapper.instance; }
        }

		#region Supported types

		private BidiDictionary<BusinessObjectType, Type> cachedSupportedBusinessObjectTypes;

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get
			{
				if (cachedSupportedBusinessObjectTypes == null)
				{
					cachedSupportedBusinessObjectTypes = new BidiDictionary<BusinessObjectType, Type>()
					{
						{ BusinessObjectType.Configuration, typeof(Configuration) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		#endregion
		
		/// <summary>
        /// Gets a value indicating whether every transaction should be rollbacked.
        /// </summary>
        public bool ForceRollbackTransaction { get; private set; }

        /// <summary>
        /// Gets a value indicating whether communication to the database (via mappers) should be logged.
        /// </summary>
        public bool LogDatabaseCommunication { get; private set; }

        /// <summary>
        /// Gets a path to a destination file where communication to the database should be logged.
        /// </summary>
        public string DatabaseCommunicationLogPath { get; private set; }

        /// <summary>
        /// Gets or sets cached business objects templates.
        /// </summary>
        /// <remarks>
        /// BusinessObjectType->TemplateName->value(XElement).
        /// </remarks>
        public Dictionary<BusinessObjectType, Dictionary<string, XElement>> Templates { get; private set; }

        /// <summary>
        /// Gets or sets the database id that is needed for communication.
        /// </summary>
        public Guid DatabaseId { get; private set; }

        public bool IsHeadquarter { get; set; }

        public int CatalogueLimit { get; private set; }

        public Guid SystemCurrencyId { get; private set; }

        public bool ExtendedJournal { get; private set; }

        public bool IsWmsEnabled { get; private set; }

        public bool IsExternalSystemOrderPricesEnabled { get; private set; }

        public Uri ExternalSystemOrderPricesUri { get; private set; }
        public string ExternalSystemOrderPricesContractorCode { get; private set; }

        public bool IsRemoteOrderSendingEnabled { get; private set; }

        public bool BlockInvaluatedOutcomes { get; private set; }

        public IDictionary<string, XElement> Processes { get; private set; }

		public IDictionary<string, XElement> DictionariesMetadata { get; private set; }

		public IDictionary<string, XElement> ConvertersConfig { get; private set; }

        public bool LogHandledExceptions { get; private set; }

        private string PrintServiceAddress { get; set; }

        public string B2bReservationDocumentTemplate { get; private set; }
        public string OutcomeShiftOrderTemplate { get; private set; }

        public SalesPriceBelowPurchasePriceValidation SalesPriceBelowPurchasePriceValidation { get; private set; }

        public bool OnePositionFinancialDocuments { get; private set; }

        public IDictionary<string, XElement> Profiles { get; private set; }

        public XElement DefaultProfile { get; private set; }

        public bool MinimalProfitMarginValidation { get; set; }

        public Guid CurrentBranchId { get; set; }

        public DateTime? SystemStartDate { get; private set; }

        public bool PreventDocumentCorrectionBeforeSystemStart { get; private set; }

		public string OnCommitDocumentCustomValidationProcedure { get; private set; }

		public char[] BarcodeCharacters { get; private set; }

		public int UpdateDictionaryIndexTimeout { get; private set; }

		public int GlobalSqlCommandTimeout { get; private set; }

		public bool ItemsAllowOneGroupMembership
		{
			get
			{
				Configuration conf = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "items.allowOneGroupMembership").FirstOrDefault();
				return conf != null && conf.Value.Value.ToUpperInvariant() == "TRUE";
			}
		}

		public bool TestStepsLoggingEnabled { get; private set; }

		public HashSet<string> TestStepsLoggedCommands { get; private set; }

		public Guid SystemClientId { get; private set; }
		
		/// <summary>
        /// Initializes a new instance of the <see cref="ConfigurationMapper"/> class.
        /// </summary>
        protected ConfigurationMapper()
            : base()
        {
            FractusKernelSectionHandler handler = (FractusKernelSectionHandler)System.Configuration.ConfigurationManager.GetSection("fractusKernel");
            
            this.ForceRollbackTransaction = handler.ForceRollbackTransaction;
            this.LogDatabaseCommunication = handler.LogDatabaseCommunication;
            this.DatabaseCommunicationLogPath = handler.DatabaseCommunicationLogPath;
            this.CatalogueLimit = handler.CatalogueLimit;
            this.ExtendedJournal = handler.ExtendedJournal;
            this.LogHandledExceptions = handler.LogHandledExceptions;
            this.PrintServiceAddress = handler.PrintServiceAddress;
            this.SalesPriceBelowPurchasePriceValidation = new SalesPriceBelowPurchasePriceValidation();
        }

        /// <summary>
        /// Loads configuration data that is to be cached, eg. document templates.
        /// </summary>
        public void LoadCachedConfigurationData()
        {
            this.LoadTemplates();
            this.LoadProcesses();
			this.LoadDictionariesMetadata();
			this.LoadConvertersConfig();
			this.InitConstants();

            XDocument b = this.ExecuteStoredProcedure(null, StoredProcedure.configuration_p_getCurrentBranchId, true, null);

			if (String.IsNullOrEmpty(b.Root.Value))
				throw new ClientException(ClientExceptionId.MissingCurrentBranchId);

            this.CurrentBranchId = new Guid(b.Root.Value);
            
            //load DatabaseId
            XDocument xml = this.ExecuteStoredProcedure(null, this.CurrentBranchId, StoredProcedure.configuration_p_getConfiguration, true,
                XDocument.Parse(@"<root>
                                    <entry>communication.databaseId</entry>
                                    <entry>system.isHeadquarter</entry>
                                    <entry>document.defaults.systemCurrencyId</entry>
                                    <entry>warehouse.isWmsEnabled</entry>
                                    <entry>document.externalSystemOrderPrices.enabled</entry>
                                    <entry>document.externalSystemOrderPrices.address</entry>
                                    <entry>document.externalSystemOrderPrices.contractorCode</entry>
                                    <entry>document.remoteOrderSendingEnabled</entry>
                                    <entry>document.validation.blockInvaluatedOutcomes</entry>
                                    <entry>b2b.document.reservationDocumentTemplate</entry>
                                    <entry>document.validation.salesPriceBelowPurchasePrice</entry>
                                    <entry>document.financial.onePositionDocuments</entry>
                                    <entry>system.profiles</entry>
                                    <entry>system.clientId</entry>
                                    <entry>document.validation.minimalProfitMargin</entry>
                                    <entry>system.startDate</entry>
                                    <entry>document.validation.preventDocumentCorrectionBeforeSystemStart</entry>
                                    <entry>document.outcomeShiftOrderTemplate</entry>
                                    <entry>document.validation.onCommitDocumentCustomValidationProcedure</entry>
                                    <entry>system.updateDictionaryIndexSqlCommandTimeout</entry>
									<entry>system.globalSqlCommandTimeout</entry>
                                    <entry>tests.testStepsLoggingEnabled</entry>
                                    <entry>tests.testStepsLoggedCommands</entry>
                                </root>"));

			XElement configurationElement = xml.Root.Element("configuration");

            this.DatabaseId = new Guid(GetTextValueFromConfigurationEntry(configurationElement, "communication.databaseId", false));
            this.SystemCurrencyId 
				= new Guid(GetTextValueFromConfigurationEntry(configurationElement, "document.defaults.systemCurrencyId", false));
            this.IsHeadquarter = Convert.ToBoolean(GetTextValueFromConfigurationEntry(configurationElement, "system.isHeadquarter", false), CultureInfo.InvariantCulture);

            string isWmsEnabled = GetTextValueFromConfigurationEntry(configurationElement, "warehouse.isWmsEnabled");
            if (isWmsEnabled != null)
                this.IsWmsEnabled = Convert.ToBoolean(isWmsEnabled, CultureInfo.InvariantCulture);

            XElement isExternalSystemOrderPricesEnabled = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.externalSystemOrderPrices.enabled").FirstOrDefault();

            if (isExternalSystemOrderPricesEnabled != null)
                this.IsExternalSystemOrderPricesEnabled = Convert.ToBoolean(isExternalSystemOrderPricesEnabled.Element("textValue").Value, CultureInfo.InvariantCulture);

            if (this.IsExternalSystemOrderPricesEnabled)
            {
                this.ExternalSystemOrderPricesUri = new Uri(xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.externalSystemOrderPrices.address").FirstOrDefault().Element("textValue").Value);
                this.ExternalSystemOrderPricesContractorCode = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.externalSystemOrderPrices.contractorCode").FirstOrDefault().Element("textValue").Value;
            }

            XElement remoteOrder = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.remoteOrderSendingEnabled").FirstOrDefault();
            
            if (remoteOrder != null)
                this.IsRemoteOrderSendingEnabled = Convert.ToBoolean(remoteOrder.Element("textValue").Value, CultureInfo.InvariantCulture);

            XElement blockInvaluatedOutcomes = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.validation.blockInvaluatedOutcomes").FirstOrDefault();

            if (blockInvaluatedOutcomes != null)
                this.BlockInvaluatedOutcomes = Convert.ToBoolean(blockInvaluatedOutcomes.Element("textValue").Value, CultureInfo.InvariantCulture);

            XElement element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "b2b.document.reservationDocumentTemplate").FirstOrDefault();

            if (element != null)
                this.B2bReservationDocumentTemplate = element.Element("textValue").Value;

            element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.validation.salesPriceBelowPurchasePrice").FirstOrDefault();

            if (element != null)
            {
                if (element.Element("xmlValue").Element("root").Element("belowPurchasePrice") != null)
                    this.SalesPriceBelowPurchasePriceValidation.SalesPriceBelowPurchasePrice = (ErrorLevel)Enum.Parse(typeof(ErrorLevel), element.Element("xmlValue").Element("root").Element("belowPurchasePrice").Value, true);

                if (element.Element("xmlValue").Element("root").Element("invaluatedOutcome") != null)
                    this.SalesPriceBelowPurchasePriceValidation.InvaluatedOutcomes = (ErrorLevel)Enum.Parse(typeof(ErrorLevel), element.Element("xmlValue").Element("root").Element("invaluatedOutcome").Value, true);
            }

            element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.financial.onePositionDocuments").FirstOrDefault();

            if (element != null && element.Element("textValue").Value.ToUpperInvariant() == "TRUE")
                this.OnePositionFinancialDocuments = true;

            element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "system.profiles").FirstOrDefault();

            if (element != null)
            {
                Dictionary<string, XElement> profiles = new Dictionary<string, XElement>();

                foreach (var profile in element.Element("xmlValue").Element("root").Elements("profile"))
                {
                    if (profile.Attribute("name") != null)
                        profiles.Add(profile.Attribute("name").Value, new XElement(profile));
                    else
                        this.DefaultProfile = profile;
                }

                this.Profiles = profiles;
            }

            element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.validation.minimalProfitMargin").FirstOrDefault();

            if (element != null)
            {
                var branchXml = element.Element("xmlValue").Element("root").Elements().Where(x => x.Attribute("id").Value == this.CurrentBranchId.ToUpperString()).FirstOrDefault();

                if (branchXml != null && branchXml.Attribute("value") != null && branchXml.Attribute("value").Value.ToUpperInvariant() == "TRUE")
                    this.MinimalProfitMarginValidation = true;
            }

            element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "system.startDate").FirstOrDefault();

            if (element != null)
                this.SystemStartDate = DateTime.Parse(element.Element("textValue").Value, CultureInfo.InvariantCulture);

            element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.validation.preventDocumentCorrectionBeforeSystemStart").FirstOrDefault();

            if (element != null && element.Element("textValue").Value.ToUpperInvariant() == "TRUE")
                this.PreventDocumentCorrectionBeforeSystemStart = true;

            element = xml.Root.Element("configuration").Elements("entry").Where(e => e.Element("key").Value == "document.outcomeShiftOrderTemplate").FirstOrDefault();

            if (element != null)
                this.OutcomeShiftOrderTemplate = element.Element("textValue").Value;

            this.OnCommitDocumentCustomValidationProcedure = GetTextValueFromConfigurationEntry(configurationElement,
				"document.validation.onCommitDocumentCustomValidationProcedure");

			#region UpdateDictionaryIndexTimeout
			
			string updateDictionaryIndexSqlCommandTimeoutText = GetTextValueFromConfigurationEntry(configurationElement,
				"system.updateDictionaryIndexSqlCommandTimeout");
			int updateDictionaryIndexTimeout = -1;
			if (!Int32.TryParse(updateDictionaryIndexSqlCommandTimeoutText, out updateDictionaryIndexTimeout))
			{
				updateDictionaryIndexTimeout = 30;
			}

			this.UpdateDictionaryIndexTimeout = updateDictionaryIndexTimeout;

			#endregion

			#region GlobalSqlCommandTimeout

			string globalSqlCommandTimeoutText = GetTextValueFromConfigurationEntry(configurationElement, "system.globalSqlCommandTimeout");
			int globalSqlCommandTimeout = -1;
			if (!Int32.TryParse(updateDictionaryIndexSqlCommandTimeoutText, out globalSqlCommandTimeout))
			{
				globalSqlCommandTimeout = 500;
			}

			this.GlobalSqlCommandTimeout = globalSqlCommandTimeout;

			#endregion

			#region TestStepsLoggingEnabled

			string testStepsLoggingEnabledText 
				= GetTextValueFromConfigurationEntry(configurationElement, "tests.testStepsLoggingEnabled");
			bool testStepsLoggingEnabled = this.TestStepsLoggingEnabled = false;
			if (Boolean.TryParse(testStepsLoggingEnabledText, out testStepsLoggingEnabled))
			{
				this.TestStepsLoggingEnabled = testStepsLoggingEnabled;
			}

			#endregion

			#region TestStepsLoggedCommands

			XElement testStepsLoggedCommands
				= GetXmlValueFromConfigurationEntry(configurationElement, "tests.testStepsLoggedCommands");

			this.LoadTestStepsLoggedCommands(testStepsLoggedCommands);

			#endregion

			string clienIdString = GetTextValueFromConfigurationEntry(configurationElement, "system.clientId");
			if (clienIdString != null)
			{
				this.SystemClientId = new Guid(clienIdString);
			}
		}

        //Helper that reads text value configuration entry
		private static string GetTextValueFromConfigurationEntry(XElement configElement, string key, bool allowNull = true)
		{
			XElement entryElement = _GetEntryForKey(configElement, key);
			if (!allowNull && entryElement == null)
			{
				throw new ClientException(ClientExceptionId.InvalidConfigurationEntry, null, "name:" + key);
			}
			return entryElement != null ? entryElement.Element("textValue").Value : null;
		}

		private static XElement GetXmlValueFromConfigurationEntry(XElement configElement, string key, bool allowNull = true)
		{
			XElement entryElement = _GetEntryForKey(configElement, key);
			if (!allowNull && entryElement == null)
			{
				throw new ClientException(ClientExceptionId.InvalidConfigurationEntry, null, "name:" + key);
			}
			return entryElement != null ? entryElement.Element("xmlValue") : null;
		}

		private static XElement _GetEntryForKey(XElement configElement, string key)
		{
			return configElement.Elements("entry").Where(e => e.Element("key").Value == key).FirstOrDefault();
		}

        private void LoadProcesses()
        {
            this.Processes = new Dictionary<string, XElement>();
			this.LoadConfigurationDictionary("processes", this.Processes);
        }

		private void LoadDictionariesMetadata()
		{
			this.DictionariesMetadata = new Dictionary<string, XElement>();
			this.LoadConfigurationDictionary("dictionaries.metaData", this.DictionariesMetadata);
		}

		private void LoadConvertersConfig()
		{
			this.ConvertersConfig = new Dictionary<string, XElement>();
			this.LoadConfigurationDictionary("converters", this.ConvertersConfig);
		}

		private void LoadConfigurationDictionary(string keyPrefix, IDictionary<string, XElement> initializedDictionary)
		{
			XDocument result = this.ExecuteStoredProcedure(null, StoredProcedure.configuration_p_getConfiguration, true,
				XDocument.Parse(String.Format(@"<root><entry>{0}.*</entry></root>", keyPrefix)));

			foreach (XElement entry in result.Root.Element(XmlName.Configuration).Elements())
			{
				initializedDictionary.Add(entry.Element(XmlName.Key).Value, (XElement)entry.Element(XmlName.XmlValue).FirstNode);
			}
		}

        /// <summary>
        /// Loads the documents' templates into cache.
        /// </summary>
        private void LoadTemplates()
        {
            XDocument xml = this.ExecuteStoredProcedure(null, StoredProcedure.configuration_p_getConfiguration, true,
                XDocument.Parse(@"<root><entry>templates.CommercialDocument.*</entry>
                                        <entry>templates.WarehouseDocument.*</entry>
                                        <entry>templates.FinancialDocument.*</entry>
                                        <entry>templates.Item.*</entry>
                                        <entry>templates.Contractor.*</entry>
                                        <entry>templates.ServiceDocument.*</entry>
                                        <entry>templates.ComplaintDocument.*</entry>
                                        <entry>templates.InventoryDocument.*</entry>
                                        <entry>templates.OfferDocument.*</entry>
                                  </root>"));

            this.Templates = new Dictionary<BusinessObjectType, Dictionary<string, XElement>>();

            foreach (XElement entry in xml.Root.Element("configuration").Elements().OrderBy(c => Convert.ToInt32(c.Element("xmlValue").Element("root").Element("order").Value, CultureInfo.InvariantCulture)))
            {
                string[] splitted = entry.Element("key").Value.Split('.');
                BusinessObjectType type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), splitted[1], true);
                string templateName = splitted[2];

                if (!this.Templates.ContainsKey(type))
                    this.Templates.Add(type, new Dictionary<string, XElement>());

                this.Templates[type].Add(templateName, (XElement)entry.Element("xmlValue").FirstNode);
            }
        }

		private void InitConstants()
		{
			List<char> tmpColl = new List<char>();
			for (char c = '0'; c <= '9'; c++)
				tmpColl.Add(c);
			for (char c = 'A'; c <= 'Z'; c++)
				tmpColl.Add(c);

			this.BarcodeCharacters = tmpColl.ToArray();
		}

		private void LoadTestStepsLoggedCommands(XElement xmlValue)
		{
			xmlValue = xmlValue != null ? xmlValue.Element("root") : null;
			if (xmlValue != null)
			{
				this.TestStepsLoggedCommands = new HashSet<string>();
				foreach (XElement commandElement in xmlValue.Elements("command"))
				{
					if (!this.TestStepsLoggedCommands.Contains(commandElement.Value))
					{
						this.TestStepsLoggedCommands.Add(commandElement.Value);
					}
				}
				XElement executeCustomProcedureElement = xmlValue.Element("executeCustomProcedure");
				if (executeCustomProcedureElement != null)
				{
					string executeCustomProcedurePrefix = "ExecuteCustomProcedure_";
					foreach (XElement storedProcedureElement in executeCustomProcedureElement.Elements("storedProcedure"))
					{
						string commandName = String.Concat(executeCustomProcedurePrefix, storedProcedureElement.Value);
						if (!this.TestStepsLoggedCommands.Contains(commandName))
						{
							this.TestStepsLoggedCommands.Add(commandName);
						}
					}
				}
			}
		}

		public XDocument DeleteConfiguration(string key, ConfigurationLevel level)
        {
            XDocument xml = XDocument.Parse(XmlName.EmptyRoot);
            xml.Root.Add(new XElement(XmlName.Key, key));
            xml.Root.Add(new XElement(XmlName.Level, level.ToString().ToUpperInvariant()));
            
            xml.Root.Add(new XElement(XmlName.LocalTransactionId, SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));
            xml.Root.Add(new XElement(XmlName.DeferredTransactionId, SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));
            xml.Root.Add(new XElement(XmlName.DatabaseId, ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

            this.ExecuteStoredProcedure(StoredProcedure.configuration_p_deleteConfiguration, false, xml);

			return xml;
        }

        /// <summary>
        /// Gets a single configuration entry.
        /// </summary>
        /// <param name="key">Configuration key.</param>
        /// <returns><see cref="Configuration"/> object if found; otherwise <c>null</c>.</returns>
        internal Configuration GetSingleConfigurationEntry(string key)
        {
            ICollection<Configuration> confs = this.GetConfiguration(SessionManager.User, key);

            if (confs.Count == 0)
                return null;
            else if (confs.Count > 1)
                throw new InvalidDataException("Too many configuration entries");
            else
                return confs.First();
        }

        /// <summary>
        /// Gets the configuration using specified configuration keys.
        /// </summary>
        /// <param name="user">The user that wants to get the configuration elements.</param>
        /// <param name="keys">List of configuration keys to get. May contain * character.</param>
        /// <returns>A collection of configuration entries.</returns>
        internal ICollection<Configuration> GetConfiguration(User user, params string[] keys)
        {
            return this.GetConfiguration(user, null, keys);
        }

        internal ICollection<Configuration> GetConfiguration(User user, Guid? userProfileId, params string[] keys)
        {
            //generate proper input xml
            XDocument xml = XDocument.Parse("<root></root>");

            foreach (string key in keys)
            {
                xml.Root.Add(new XElement("entry", key));
            }

            //execute the procedure
            xml = this.ExecuteStoredProcedure(user, ConfigurationMapper.Instance.CurrentBranchId, userProfileId, StoredProcedure.configuration_p_getConfiguration, true, xml);

            List<Configuration> entries = new List<Configuration>();

            //convert from return xml to collection of objects
            foreach (XElement element in xml.Root.Element("configuration").Elements())
            {
                XDocument convertedXml = this.ConvertDBToBoXmlFormat(xml, new Guid(element.Element("id").Value));
                Configuration bo = (Configuration)this.ConvertToBusinessObject(convertedXml.Root.Element("configuration"), null);

                if (bo.Key == "services.printService.address" && !String.IsNullOrEmpty(this.PrintServiceAddress))
                    bo.Value.Value = this.PrintServiceAddress;

                entries.Add(bo);
            }

            return entries;
        }

		internal ICollection<Configuration> GetConfigurationKeys()
		{
			//execute the procedure
			XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.configuration_p_getConfigurationKeys);

			List<Configuration> entries = new List<Configuration>();

			//convert from return xml to collection of objects
			foreach (XElement element in xml.Root.Element("configuration").Elements())
			{
				XDocument convertedXml = this.ConvertDBToBoXmlFormat(xml, new Guid(element.Element("id").Value));
				Configuration bo = (Configuration)this.ConvertToBusinessObject(convertedXml.Root.Element("configuration"), null);
				entries.Add(bo);
			}

			return entries;
		}

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
        }

        /// <summary>
        /// Updates the templates version.
        /// </summary>
        public void UpdateConfigurationVersion()
        {
            this.ExecuteStoredProcedure(StoredProcedure.configuration_p_updateConfigurationVersion, false, null);
        }

        /// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            if (type != BusinessObjectType.Configuration)
                throw new InvalidOperationException("ConfigurationMapper can only create configuration.");

            Configuration conf = new Configuration();
            return conf;
        }

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id.
        /// </summary>
        /// <param name="type">Type of <see cref="BusinessObject"/> to load.</param>
        /// <param name="id"><see cref="IBusinessObject"/>'s id indicating which <see cref="BusinessObject"/> to load.</param>
        /// <returns>
        /// Loaded <see cref="IBusinessObject"/> object.
        /// </returns>
        public override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.configuration_p_getConfigurationById, true, "@id", id);

            if (xdoc.Root.Element("configuration").Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, id);

            return this.ConvertToBusinessObject(xdoc.Root.Element("configuration"), null);
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            Configuration configuration = (Configuration)obj;

            if (configuration.Key == "contractors.group" || configuration.Key == "items.group" ||
                configuration.Key.StartsWith("permissions.", StringComparison.Ordinal) || configuration.Key == "document.validation.minimalProfitMargin")
            {
                Guid localTransactionId = SessionManager.VolatileElements.LocalTransactionId.Value;
                Guid deferredTransactionId = SessionManager.VolatileElements.DeferredTransactionId.Value;

                this.CreateCommunicationXmlForVersionedBusinessObject(configuration, localTransactionId, deferredTransactionId, StoredProcedure.communication_p_createConfigurationPackage);
            }
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            XDocument retXml = XDocument.Parse("<root><configuration></configuration></root>");

            XElement configurationElement = (XElement)retXml.Root.FirstNode;

            var entry = from node in xml.Root.Element("configuration").Elements()
                        where node.Element("id").Value == id.ToUpperString()
                        select node;

            foreach (XElement element in entry.ElementAt(0).Elements())
            {
                if (element.Name.LocalName != "textValue" && element.Name.LocalName != "xmlValue")
                {
                    configurationElement.Add(element);
                }
                else
                {
                    configurationElement.Add(new XElement("value", element.FirstNode));
                }
            }

            return retXml;
        }

        /// <summary>
        /// Converts a <see cref="BusinessObject"/> from its xml to <see cref="BusinessObject"/> form.
        /// </summary>
        /// <param name="objectXml">Xml rootElement containing <see cref="IBusinessObject"/>.</param>
        /// <param name="options">Xml containing options for the object during save operation.</param>
        /// <returns>
        /// Converted <see cref="IBusinessObject"/>.
        /// </returns>
        public override IBusinessObject ConvertToBusinessObject(XElement objectXml, XElement options)
        {
            Configuration bo = (Configuration)this.CreateNewBusinessObject(BusinessObjectType.Configuration, null);

            bo.Deserialize(objectXml);

            return bo;
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
        }

        /// <summary>
        /// Creates communication xml for objects that are in the xml operations list.
        /// </summary>
        /// <param name="operations"></param>
        public override void CreateCommunicationXml(XDocument operations)
        {
            throw new NotImplementedException();
        }

		/// <summary>
		/// Saves configuration using specified connectionManager
		/// </summary>
		/// <param name="configurationXml"></param>
		/// <param name="connectionManager"></param>
		public void SaveConfiguration(XDocument configurationXml, SqlConnectionManager connectionManager)
		{
			XDocument insertsDocument = new XDocument(configurationXml);
			insertsDocument.Root.RemoveAll();
			XDocument updatesDocument = new XDocument(insertsDocument);

			foreach (XElement configEntry in configurationXml.Root.Elements())
			{
				//Oceniam czy to edycja czy wstawienie nowego wpisu po id
				Guid id = new Guid(configEntry.Element("id").Value);
				XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.configuration_p_getConfigurationById, true, "@id", id
					, null, null, null, null, null, null, null, null, null, connectionManager.Command);
				bool isNew = xdoc.Root.Element("configuration").Elements().Count() == 0;

				XElement _versionElement = configEntry.Element("_version");
				if (_versionElement == null)
				{
					XElement versionElement = configEntry.Element("version");
					configEntry.Add(new XElement("_version", versionElement != null ? versionElement.Value : Guid.NewGuid().ToUpperString()));
				}

				if (isNew)
					insertsDocument.Root.Add(configEntry);
				else
					updatesDocument.Root.Add(configEntry);
			}

			if (insertsDocument.Root.HasElements)
			{
				XDocument paramXml = XDocument.Parse("<root/>");
				paramXml.Root.Add(insertsDocument.Root);
				this.ExecuteStoredProcedure(SessionManager.User, null, null
					, StoredProcedure.configuration_p_insertConfiguration, false, paramXml, null, connectionManager.Command);
			}

			if (updatesDocument.Root.HasElements)
			{
				XDocument paramXml = XDocument.Parse("<root/>");
				paramXml.Root.Add(updatesDocument.Root);
				this.ExecuteStoredProcedure(SessionManager.User, null, null
					, StoredProcedure.configuration_p_updateConfiguration, false, paramXml, null, connectionManager.Command);
			}
		}
    }
}
