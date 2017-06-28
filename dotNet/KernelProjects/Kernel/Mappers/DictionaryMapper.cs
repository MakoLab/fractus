using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Xml.Linq;
using System.Xml.XPath;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using System.Text.RegularExpressions;
using Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class caching all dicionaries from database.
    /// </summary>
    internal class DictionaryMapper : Mapper, IDisposable
    {
        /// <summary>
        /// Instance of <see cref="DictionaryMapper"/>.
        /// </summary>
        private static DictionaryMapper instance = new DictionaryMapper();

        /// <summary>
        /// Gets the instance of <see cref="DictionaryMapper"/>.
        /// </summary>
        public static DictionaryMapper Instance
        {
            get { return DictionaryMapper.instance; }
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
						{ BusinessObjectType.ContractorField, typeof(ContractorField) },
						{ BusinessObjectType.ContractorRelationType, typeof(ContractorRelationType) },
						{ BusinessObjectType.Country, typeof(Country) },
						{ BusinessObjectType.Currency, typeof(Currency) },
						{ BusinessObjectType.DocumentField, typeof(DocumentField) },
						{ BusinessObjectType.DocumentFieldRelation, typeof(DocumentFieldRelation) },
						{ BusinessObjectType.DocumentType, typeof(DocumentType) },
						{ BusinessObjectType.IssuePlace, typeof(IssuePlace) },
						{ BusinessObjectType.ItemField, typeof(ItemField) },
						{ BusinessObjectType.ItemRelationAttrValueType, typeof(ItemRelationAttrValueType) },
						{ BusinessObjectType.ItemRelationType, typeof(ItemRelationType) },
						{ BusinessObjectType.ItemType, typeof(ItemType) },
						{ BusinessObjectType.MimeType, typeof(MimeType) },
						{ BusinessObjectType.PaymentMethod, typeof(PaymentMethod) },
						{ BusinessObjectType.Repository, typeof(Makolab.Fractus.Kernel.BusinessObjects.Dictionaries.Repository) },
						{ BusinessObjectType.JobPosition, typeof(JobPosition) },
						{ BusinessObjectType.Unit, typeof(Unit) },
						{ BusinessObjectType.UnitType, typeof(UnitType) },
						{ BusinessObjectType.VatRate, typeof(VatRate) },
						{ BusinessObjectType.DocumentNumberComponent, typeof(DocumentNumberComponent) },
						{ BusinessObjectType.NumberSetting, typeof(NumberSetting) },
						{ BusinessObjectType.Warehouse, typeof(Warehouse) },
						{ BusinessObjectType.Branch, typeof(Branch) },
						{ BusinessObjectType.Company, typeof(Company) },
						{ BusinessObjectType.VatRegister, typeof(VatRegister) },
						{ BusinessObjectType.FinancialRegister, typeof(FinancialRegister) },
						{ BusinessObjectType.ShiftField, typeof(ShiftField) },
						{ BusinessObjectType.ServicePlace, typeof(ServicePlace) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		#endregion

        /// <summary>
        /// Gets the value that indicates whether <see cref="Dispose(bool)"/> has been called.
        /// </summary>
        protected bool IsDisposed { get; set; }

        /// <summary>
        /// Thread that awakes by the <see cref="updaterWakeUpEvt"/> and updates the changed dictionaries.
        /// </summary>
        private Thread updaterThread;

        /// <summary>
        /// Event used to wake up <see cref="updaterThread"/>.
        /// </summary>
        private ManualResetEvent updaterWakeUpEvt;

        /// <summary>
        /// Event used to indicate that the <see cref="updaterThread"/> aquired write lock.
        /// </summary>
        private ManualResetEvent updaterEnteredLockEvt;

        /// <summary>
        /// Gets or sets the lock used for blocking dictionary reads and writes.
        /// </summary>
        public ReaderWriterLockSlim DictionaryLock { get; private set; }

        #region Dictionaries xml
        /// <summary>
        /// Countries dictionary.
        /// </summary>
        private XDocument countriesXml;

        /// <summary>
        /// Branches dictionary.
        /// </summary>
        private XDocument branchesXml;

        /// <summary>
        /// Companies dictionary.
        /// </summary>
        private XDocument companiesXml;

        /// <summary>
        /// Job positions dictionary.
        /// </summary>
        private XDocument jobPositionsXml;

        /// <summary>
        /// Contractor relation types dictionary.
        /// </summary>
        private XDocument contractorRelationTypesXml;

        /// <summary>
        /// Versions of all dictionaries.
        /// </summary>
        private XDocument dictionariesVersionsXml;

        /// <summary>
        /// Version of dictionaries (merged).
        /// </summary>
        private int dictionariesVersion;

        /// <summary>
        /// Gets the sum of all dictionaries versions.
        /// </summary>
        public int DictionariesVersion { get { return this.dictionariesVersion; } }

        /// <summary>
        /// Contractor fields dictionary.
        /// </summary>
        private XDocument contractorFieldsXml;

        /// <summary>
        /// Item fields dictionary.
        /// </summary>
        private XDocument itemFieldsXml;

        /// <summary>
        /// Item relation attr value types dictionary.
        /// </summary>
        private XDocument itemRelationAttrValueTypesXml;

        /// <summary>
        /// Item relation types dictionary.
        /// </summary>
        private XDocument itemRelationTypesXml;

        /// <summary>
        /// Item types dictionary.
        /// </summary>
        private XDocument itemTypesXml;

        /// <summary>
        /// Units dictionary.
        /// </summary>
        private XDocument unitsXml;

        /// <summary>
        /// Unit types dictionary.
        /// </summary>
        private XDocument unitTypesXml;

        /// <summary>
        /// Languages dictionary.
        /// </summary>
        private XDocument languagesXml;

        /// <summary>
        /// Mime types dictionary.
        /// </summary>
        private XDocument mimeTypesXml;

        /// <summary>
        /// Repositories dictionary.
        /// </summary>
        private XDocument repositoriesXml;

        /// <summary>
        /// Vat rates dictionary.
        /// </summary>
        private XDocument vatRatesXml;

        /// <summary>
        /// Document fields dictionary.
        /// </summary>
        private XDocument documentFieldsXml;

        /// <summary>
        /// Currencies dictionary.
        /// </summary>
        private XDocument currenciesXml;

        /// <summary>
        /// Issue places dictionary.
        /// </summary>
        private XDocument issuePlacesXml;

        /// <summary>
        /// Payment methods dictionary.
        /// </summary>
        private XDocument paymentMethodsXml;

        /// <summary>
        /// Document types dictionary.
        /// </summary>
        private XDocument documentTypesXml;

        /// <summary>
        /// Document field relations dictionary.
        /// </summary>
        private XDocument documentFieldRelationsXml;

        /// <summary>
        /// Document number component xml.
        /// </summary>
        private XDocument documentNumberComponentsXml;

        /// <summary>
        /// Number settings dictionary.
        /// </summary>
        private XDocument numberSettingsXml;

        /// <summary>
        /// Definitions of print profiles.
        /// </summary>
        private XDocument printProfilesDefinitionsXml;

        /// <summary>
        /// Warehouse dictionary.
        /// </summary>
        private XDocument warehousesXml;

        private XDocument documentStatusesXml;

        private XDocument accountingJournalsXml;
        private XDocument accountingRulesXml;
        private XDocument vatRegistersXml;
        private XDocument financialRegistersXml;
        private XDocument containerTypesXml;
        private XDocument shiftFieldsXml;
        private XDocument servicePlacesXml;
        private XElement itemsGroupsXml;
		private Dictionary<string, List<Guid>> itemsGroupsCodePatterns;

		//Dictionary for new dictionaries - I am trying to write more generic code for loading and caching Dictionary xml documents
		private Dictionary<Type, XDocument> dictionaryCache;
		private int dictionaryCacheSize = 1;

		private XDocument GetCachedXml(Type type)
		{
			if (this.dictionaryCache == null)
			{
				this.dictionaryCache = new Dictionary<Type, XDocument>(this.dictionaryCacheSize);
			}
			if (this.dictionaryCache.ContainsKey(type))
			{
				return this.dictionaryCache[type];
			}

			return null;
		}

		private void SetCachedXml(Type type, XDocument xml)
		{
			if (this.dictionaryCache == null)
			{
				this.dictionaryCache = new Dictionary<Type, XDocument>(this.dictionaryCacheSize);
			}
			if (this.dictionaryCache.ContainsKey(type))
			{
				this.dictionaryCache[type] = xml;
			}
			else
			{
				this.dictionaryCache.Add(type, xml);
			}
		}

		private List<Type> cachedTypes = new List<Type>();

        #endregion

        /// <summary>
        /// Initializes a new instance of the <see cref="DictionaryMapper"/> class using privileged connection to the database.
        /// </summary>
        protected DictionaryMapper()
            : base()
        {
            this.LoadDictionaries();
            this.updaterWakeUpEvt = new ManualResetEvent(false);
            this.updaterEnteredLockEvt = new ManualResetEvent(false);
            this.DictionaryLock = new ReaderWriterLockSlim();
            this.updaterThread = new Thread(new ThreadStart(this.Updater));
            this.updaterThread.IsBackground = true;
            this.updaterThread.Start();
        }

		private Dictionary<string, List<Guid>> GetItemsGroupsCodePatterns()
		{
			Dictionary<string, List<Guid>> result = new Dictionary<string, List<Guid>>();

			string codePatternPath = @"attributes/attribute[@name=""codePattern""]";

			var itemGroupsWithCodePatterns = this.itemsGroupsXml.XPathSelectElements(
				String.Format(@"//group[count({0}) > 0]", codePatternPath));

			foreach (XElement groupElement in itemGroupsWithCodePatterns)
			{
				XAttribute idAttr = groupElement.Attribute(XmlName.Id);
				if (idAttr == null)
					throw new ClientException(ClientExceptionId.InvalidConfigurationEntry, null, "name:items.group");
				Guid id = new Guid(idAttr.Value);
				XElement codePatternElement = groupElement.XPathSelectElement(codePatternPath);
				if (codePatternElement != null && !String.IsNullOrEmpty(codePatternElement.Value))
				{
					string key = codePatternElement.Value;
					List<Guid> guids = null;
					if (result.ContainsKey(key))
					{
						guids = result[key];
					}
					else
					{
						guids = new List<Guid>();
						result[key] = guids;
					}
					guids.Add(id);
				}
			}

			return result;
		}

		public List<Guid> GetItemGroupsIds(string code)
		{
			List<Guid> result = null;
			foreach (string pattern in this.itemsGroupsCodePatterns.Keys)
			{
				Match match = Regex.Match(code, pattern);
				if (match.Success)
				{
					result = result ?? new List<Guid>();
					result.AddRange(this.itemsGroupsCodePatterns[pattern]);
				}
			}

			return result != null ? result.Distinct().ToList() : null;
		}

		public string GetItemGroupMembershipPath(string itemGroupId)
		{
			XElement groupElement = this.itemsGroupsXml.DescendantsAndSelf(XmlName.Group)
				.Where(gr => gr.Attribute(XmlName.Id) != null && gr.Attribute(XmlName.Id).Value == itemGroupId)
				.FirstOrDefault();

			if (groupElement != null)
			{
				List<string> labels = new List<string>();
				while (groupElement != null)
				{
					XElement labelsElement = groupElement.Element(XmlName.Labels);
					if (labelsElement != null)
					{
						labels.Add(BusinessObjectHelper.GetXmlLabelInUserLanguage(labelsElement).Value);
					}
					groupElement = groupElement.Parent; //subgroups
					if (groupElement != null)
						groupElement = groupElement.Parent; //ancestor group
				}

				if (labels.Count > 0)
				{
					labels.Reverse();
					return String.Join("\\", labels.ToArray());
				}
			}

			return null;
		}

        public decimal? GetMinimalMarginForGroup(Guid itemGroupId)
        {
            XElement groupXml = this.itemsGroupsXml.Descendants().Where(x => x.Name.LocalName == "group" && x.Attribute("id").Value == itemGroupId.ToUpperString()).FirstOrDefault();

            XElement ptr = groupXml;

            while (ptr != null)
            {
                if (ptr.Element("minimalMargin") != null)
                    return Convert.ToDecimal(ptr.Element("minimalMargin").Value, CultureInfo.InvariantCulture);
                else
                    ptr = ptr.Parent;
            }

            return null;
        }

		public decimal? GetMaximalDiscountForGroup(Guid itemGroupId, bool special)
		{
			XElement groupXml = this.itemsGroupsXml.Descendants(XmlName.Group).Where(e => e.Attribute(XmlName.Id).Value == itemGroupId.ToUpperString()).FirstOrDefault();
			XElement ptr = groupXml;

			while (ptr != null)
			{
				if (special && ptr.Element(XmlName.SpecialMaximalDiscount) != null)
				{
					return Convert.ToDecimal(ptr.Element(XmlName.SpecialMaximalDiscount).Value, CultureInfo.InvariantCulture);
				}
				else if (ptr.Element(XmlName.MaximalDiscount) != null)
					return Convert.ToDecimal(ptr.Element(XmlName.MaximalDiscount).Value, CultureInfo.InvariantCulture);
				else
					ptr = ptr.Parent;
			}

			return null;
		}

        /// <summary>
        /// Loads all dictionaries from database.
        /// </summary>
        private void LoadDictionaries()
        {
            SqlConnectionManager.Instance.InitializeConnection();

            this.LoadSingleDictionary(ref this.dictionariesVersionsXml, StoredProcedure.dictionary_p_getDictionariesVersions);
            this.LoadSingleDictionary(ref this.countriesXml, StoredProcedure.dictionary_p_getCountries);
            this.LoadSingleDictionary(ref this.jobPositionsXml, StoredProcedure.dictionary_p_getJobPositions);
            this.LoadSingleDictionary(ref this.contractorRelationTypesXml, StoredProcedure.dictionary_p_getContractorRelationTypes);
            this.LoadSingleDictionary(ref this.contractorFieldsXml, StoredProcedure.dictionary_p_getContractorFields);
            this.LoadSingleDictionary(ref this.itemFieldsXml, StoredProcedure.dictionary_p_getItemFields);
            this.LoadSingleDictionary(ref this.itemRelationAttrValueTypesXml, StoredProcedure.dictionary_p_getItemRelationAttrValueTypes);
            this.LoadSingleDictionary(ref this.itemRelationTypesXml, StoredProcedure.dictionary_p_getItemRelationTypes);
            this.LoadSingleDictionary(ref this.itemTypesXml, StoredProcedure.dictionary_p_getItemTypes);
            this.LoadSingleDictionary(ref this.unitsXml, StoredProcedure.dictionary_p_getUnits);
            this.LoadSingleDictionary(ref this.unitTypesXml, StoredProcedure.dictionary_p_getUnitTypes);
            this.LoadSingleDictionary(ref this.mimeTypesXml, StoredProcedure.dictionary_p_getMimeTypes);
            this.LoadSingleDictionary(ref this.repositoriesXml, StoredProcedure.dictionary_p_getRepositories);
            this.LoadSingleDictionary(ref this.vatRatesXml, StoredProcedure.dictionary_p_getVatRates);
            this.LoadSingleDictionary(ref this.documentFieldsXml, StoredProcedure.dictionary_p_getDocumentFields);
            this.LoadSingleDictionary(ref this.currenciesXml, StoredProcedure.dictionary_p_getCurrencies);
            this.LoadSingleDictionary(ref this.issuePlacesXml, StoredProcedure.dictionary_p_getIssuePlaces);
            this.LoadSingleDictionary(ref this.paymentMethodsXml, StoredProcedure.dictionary_p_getPaymentMethods);
            this.LoadSingleDictionary(ref this.documentTypesXml, StoredProcedure.dictionary_p_getDocumentTypes);
            this.LoadSingleDictionary(ref this.documentFieldRelationsXml, StoredProcedure.dictionary_p_getDocumentFieldRelations);
            this.LoadSingleDictionary(ref this.documentNumberComponentsXml, StoredProcedure.dictionary_p_getDocumentNumberComponents);
            this.LoadSingleDictionary(ref this.numberSettingsXml, StoredProcedure.dictionary_p_getNumberSettings);
            this.LoadSingleDictionary(ref this.warehousesXml, StoredProcedure.dictionary_p_getWarehouses);
            this.LoadSingleDictionary(ref this.branchesXml, StoredProcedure.dictionary_p_getBranches);
            this.LoadSingleDictionary(ref this.companiesXml, StoredProcedure.dictionary_p_getCompanies);
            this.LoadSingleDictionary(ref this.documentStatusesXml, StoredProcedure.dictionary_p_getDocumentStatuses);
            this.LoadSingleDictionary(ref this.accountingJournalsXml, StoredProcedure.dictionary_p_getAccountingJournals);
            this.LoadSingleDictionary(ref this.accountingRulesXml, StoredProcedure.dictionary_p_getAccountingRules);
            this.LoadSingleDictionary(ref this.vatRegistersXml, StoredProcedure.dictionary_p_getVatRegisters);
            this.LoadSingleDictionary(ref this.financialRegistersXml, StoredProcedure.dictionary_p_getFinancialRegisters);
            this.LoadSingleDictionary(ref this.containerTypesXml, StoredProcedure.dictionary_p_getContainerTypes);
            this.LoadSingleDictionary(ref this.shiftFieldsXml, StoredProcedure.dictionary_p_getShiftFields);
            this.LoadSingleDictionary(ref this.servicePlacesXml, StoredProcedure.dictionary_p_getServicePlaces);
			foreach(Type type in this.cachedTypes)
			{
				this.LoadSingleDictionary(type);
			}
            ConfigurationMapper.Instance.LoadCachedConfigurationData();
            this.LoadPrintProfilesDefinitions();

            this.languagesXml = XDocument.Parse(@"<root><language>
                                            <entry>
                                            <id>1</id>
                                            <name>pl</name>
                                            <label lang=""pl"">Polski</label>
                                            </entry>
                                            <entry>
                                            <id>2</id>
                                            <name>en</name>
                                            <label lang=""pl"">Angielski</label>
                                            </entry>
                                            <entry>
                                            <id>3</id>
                                            <name>ru</name>
                                            <label lang=""pl"">Rosyjski</label>
                                            </entry>
                                            <entry>
                                            <id>4</id>
                                            <name>de</name>
                                            <label lang=""pl"">Niemiecki</label>
                                            </entry>
                                            </language>
                                            </root>");

            this.UpdateDictionaryVersion();

            this.itemsGroupsXml = ConfigurationMapper.Instance.GetConfiguration(null, "items.group").First().Value;
			this.itemsGroupsCodePatterns = this.GetItemsGroupsCodePatterns();

            SqlConnectionManager.Instance.ReleaseConnection();
        }

        /// <summary>
        /// Loads the print profiles definitions.
        /// </summary>
        private void LoadPrintProfilesDefinitions()
        {
            XDocument xml = this.ExecuteStoredProcedure(null, StoredProcedure.configuration_p_getConfiguration, true,
                XDocument.Parse("<root><entry>printing.profiles.*</entry></root>"));

            this.printProfilesDefinitionsXml = XDocument.Parse("<root><printProfile></printProfile></root>");

            foreach (XElement entry in xml.Root.Element("configuration").Elements())
            {
                string[] splitted = entry.Element("key").Value.Split('.');
                XElement profileElement = entry.Element("xmlValue").Element("profile");
                string supportedBusinessObjectType = profileElement.Element("supportedBusinessObjectType").Value;
                string name = splitted[2];
                XElement labels = new XElement(profileElement.Element("labels"));
                this.printProfilesDefinitionsXml.Root.Element("printProfile").Add(new XElement("entry", new XElement("supportedBusinessObjectType", supportedBusinessObjectType),
                    new XElement("xmlLabels", labels), new XElement("name", name)));
            }
        }

        /// <summary>
        /// Updates <see cref="dictionariesVersion"/>.
        /// </summary>
        private void UpdateDictionaryVersion()
        {
            this.dictionariesVersion = (from node in this.dictionariesVersionsXml.Root.Element("dictionaryVersion").Elements()
                                        select Convert.ToInt32(node.Element("versionNumber").Value, CultureInfo.InvariantCulture)).Sum();
        }

        /// <summary>
        /// Gets all dictionaries with filtered language version.
        /// </summary>
        /// <returns>Xml containing dictionaries</returns>
        public XDocument GetDictionaries()
        {
            this.CheckForChanges();

            XDocument retXml = XDocument.Parse("<root version=\"" + this.dictionariesVersion.ToString(CultureInfo.InvariantCulture) + "\"/>");

            //list of dictionaries to be merged and transformed
            XDocument[] dictsToProcess = new XDocument[]{ this.contractorFieldsXml, this.contractorRelationTypesXml,
                this.countriesXml, this.itemFieldsXml, this.itemRelationAttrValueTypesXml, this.itemRelationTypesXml,
                this.itemTypesXml, this.jobPositionsXml, this.unitsXml, this.unitTypesXml, this.languagesXml,
                this.repositoriesXml, this.mimeTypesXml, this.vatRatesXml, this.documentFieldsXml, this.currenciesXml,
                this.issuePlacesXml, this.paymentMethodsXml, this.documentTypesXml, this.documentFieldRelationsXml,
                this.documentNumberComponentsXml, this.numberSettingsXml, this.printProfilesDefinitionsXml, this.warehousesXml,
                this.companiesXml, this.branchesXml, this.documentStatusesXml, this.accountingJournalsXml, this.accountingRulesXml,
                this.vatRegistersXml, this.financialRegistersXml, this.containerTypesXml, this.shiftFieldsXml, this.servicePlacesXml };

            string language = SessionManager.Language;

            //merge every single dictionary to one big and filter language version
            foreach (XDocument dict in dictsToProcess) //foreach table
            {
                XElement srcTable = (XElement)dict.Root.FirstNode;

                XElement dstTable = new XElement(srcTable.Name.LocalName);

                retXml.Root.Add(dstTable);

                foreach (XElement entry in srcTable.Elements()) //foreach row
                {
                    XElement dstEntry = new XElement("entry");
                    dstTable.Add(dstEntry);

                    foreach (XElement entryElement in entry.Elements()) //foreach column
                    {
                        if (entryElement.Name.LocalName != "xmlLabels" && entryElement.Name.LocalName != "xmlMetadata")
                            dstEntry.Add(entryElement); //auto-cloning
                        else if (entryElement.Name.LocalName == "xmlLabels" && entryElement.HasElements)
                        {
                            //filter the proper language version
                            var preferredLang = from node in entryElement.Element("labels").Elements()
                                                // tymczasowo wywywala
                                                // where node.Attribute("lang").Value == language
                                                select node;

                            dstEntry.Add(preferredLang.ElementAt(0));
                            if (preferredLang.Count() > 1)
                                dstEntry.Add(preferredLang.ElementAt(1));
                            else if (entryElement.FirstNode != null) //if doesn't exist - get the first one
                                dstEntry.Add(entryElement.FirstNode);
                            else
                                dstEntry.Add("<label lang=\"pl\">!!!!!<label>");
                            //preferred language exists
                            //if (preferredLang.Count() > 0)
                            //    dstEntry.Add(preferredLang.ElementAt(0));
                            //else if (entryElement.FirstNode != null) //if doesn't exist - get the first one
                            //    dstEntry.Add(entryElement.FirstNode);
                            //else
                            //    dstEntry.Add("<label lang=\"pl\">!!!!!<label>");
						}
                        else if (entryElement.Name.LocalName == "xmlMetadata" && entryElement.HasElements)
                        {
                            dstEntry.Add(entryElement.FirstNode);
                        }
                    }
                }
            }

            return retXml;
        }

        /// <summary>
        /// Loads single dictionary.
        /// </summary>
        /// <param name="dictionaryXml"><see cref="XDocument"/> where the dictionary is to be stored.</param>
        /// <param name="procedure">Stored procedure to load the dictionary.</param>
        protected virtual void LoadSingleDictionary(ref XDocument dictionaryXml, StoredProcedure procedure)
        {
            dictionaryXml = this.ExecuteStoredProcedure(procedure);
        }

		/// <summary>
		/// Loads single dictionary.
		/// </summary>
		/// <param name="type">Type of dictionary to be stored.</param>
		private void LoadSingleDictionary(Type type)
		{
			DatabaseMappingCache dbCache = BusinessObject.ClassDatabaseMappingCache[type][0];
			if (dbCache.Attribute.GetData != StoredProcedure.Unknown)
				this.SetCachedXml(type, this.ExecuteStoredProcedure(dbCache.Attribute.GetData));
		}

        /// <summary>
        /// Method used by the <see cref="updaterThread"/>.
        /// </summary>
        private void Updater()
        {
            while (true)
            {
                this.updaterWakeUpEvt.WaitOne();
                Debug.WriteLine("DictionaryUpdater: thread awaken, waiting for WriteLock...");
                this.DictionaryLock.EnterWriteLock();
                Debug.WriteLine("DictionaryUpdater: WriteLock acquired");
                this.updaterEnteredLockEvt.Set();

                SqlConnectionManager.Instance.InitializeConnection();

                try
                {
                    //perform dictionary update
                    XDocument dictionaries = this.ExecuteStoredProcedure(StoredProcedure.dictionary_p_getDictionariesVersions);

                    IEnumerator<XElement> newDictEnum = dictionaries.Root.Element("dictionaryVersion").Elements().GetEnumerator();
                    IEnumerator<XElement> oldDictEnum = this.dictionariesVersionsXml.Root.Element("dictionaryVersion").Elements().GetEnumerator();

                    while (oldDictEnum.MoveNext())
                    {
                        newDictEnum.MoveNext();
                        
                        if (oldDictEnum.Current.Element("versionNumber").Value != newDictEnum.Current.Element("versionNumber").Value ||
                            oldDictEnum.Current.Element("version").Value != newDictEnum.Current.Element("version").Value)
                        {
                            //something has changed. determine what is it and update it

							string tableName = oldDictEnum.Current.Element("tableName").Value;
                            switch (tableName)
                            {
                                case "document.validation.minimalProfitMargin":
                                    Configuration el = ConfigurationMapper.Instance.GetConfiguration(null, "document.validation.minimalProfitMargin").FirstOrDefault();

                                    if (el != null)
                                    {
                                        var branchXml = el.Value.Elements().Where(x => x.Attribute("id").Value == ConfigurationMapper.Instance.CurrentBranchId.ToUpperString()).FirstOrDefault();

                                        if (branchXml != null && branchXml.Attribute("value") != null && branchXml.Attribute("value").Value.ToUpperInvariant() == "TRUE")
                                            ConfigurationMapper.Instance.MinimalProfitMarginValidation = true;
                                        else
                                            ConfigurationMapper.Instance.MinimalProfitMarginValidation = false;
                                    }
                                    break;
                                case "items.group":
                                    Debug.WriteLine("DictionaryUpdater: updating items.group...");
                                    this.itemsGroupsXml = ConfigurationMapper.Instance.GetConfiguration(null, "items.group").First().Value;
 									this.itemsGroupsCodePatterns = this.GetItemsGroupsCodePatterns();
                                   break;
                                case "MimeType":
                                    Debug.WriteLine("DictionaryUpdater: updating MimeType...");
                                    this.LoadSingleDictionary(ref this.mimeTypesXml, StoredProcedure.dictionary_p_getMimeTypes);
                                    break;
                                case "Repository":
                                    Debug.WriteLine("DictionaryUpdater: updating Repository...");
                                    this.LoadSingleDictionary(ref this.repositoriesXml, StoredProcedure.dictionary_p_getRepositories);
                                    break;
                                case "ContractorField":
                                    Debug.WriteLine("DictionaryUpdater: updating ContractorField...");
                                    this.LoadSingleDictionary(ref this.contractorFieldsXml, StoredProcedure.dictionary_p_getContractorFields);
                                    break;
                                case "ContractorRelationType":
                                    Debug.WriteLine("DictionaryUpdater: updating ContractorRelationType...");
                                    this.LoadSingleDictionary(ref this.contractorRelationTypesXml, StoredProcedure.dictionary_p_getContractorRelationTypes);
                                    break;
                                case "Country":
                                    Debug.WriteLine("DictionaryUpdater: updating Country...");
                                    this.LoadSingleDictionary(ref this.countriesXml, StoredProcedure.dictionary_p_getCountries);
                                    break;
                                case "ItemField":
                                    Debug.WriteLine("DictionaryUpdater: updating ItemField...");
                                    this.LoadSingleDictionary(ref this.itemFieldsXml, StoredProcedure.dictionary_p_getItemFields);
                                    break;
                                case "ItemRelationAttrValueType":
                                    Debug.WriteLine("DictionaryUpdater: updating ItemRelationAttrValueType...");
                                    this.LoadSingleDictionary(ref this.itemRelationAttrValueTypesXml, StoredProcedure.dictionary_p_getItemRelationAttrValueTypes);
                                    break;
                                case "ItemRelationType":
                                    Debug.WriteLine("DictionaryUpdater: updating ItemRelationType...");
                                    this.LoadSingleDictionary(ref this.itemRelationTypesXml, StoredProcedure.dictionary_p_getItemRelationTypes);
                                    break;
                                case "ItemType":
                                    Debug.WriteLine("DictionaryUpdater: updating ItemType...");
                                    this.LoadSingleDictionary(ref this.itemTypesXml, StoredProcedure.dictionary_p_getItemTypes);
                                    break;
                                case "JobPosition":
                                    Debug.WriteLine("DictionaryUpdater: updating JobPosition...");
                                    this.LoadSingleDictionary(ref this.jobPositionsXml, StoredProcedure.dictionary_p_getJobPositions);
                                    break;
                                case "Unit":
                                    Debug.WriteLine("DictionaryUpdater: updating Unit...");
                                    this.LoadSingleDictionary(ref this.unitsXml, StoredProcedure.dictionary_p_getUnits);
                                    break;
                                case "UnitType":
                                    Debug.WriteLine("DictionaryUpdater: updating UnitType...");
                                    this.LoadSingleDictionary(ref this.unitTypesXml, StoredProcedure.dictionary_p_getUnitTypes);
                                    break;
                                case "VatRate":
                                    Debug.WriteLine("DictionaryUpdater: updating VatRate...");
                                    this.LoadSingleDictionary(ref this.vatRatesXml, StoredProcedure.dictionary_p_getVatRates);
                                    break;
                                case "DocumentField":
                                    Debug.WriteLine("DictionaryUpdater: updating DocumentField...");
                                    this.LoadSingleDictionary(ref this.documentFieldsXml, StoredProcedure.dictionary_p_getDocumentFields);
                                    break;
                                case "Currency":
                                    Debug.WriteLine("DictionaryUpdater: updating Currency...");
                                    this.LoadSingleDictionary(ref this.currenciesXml, StoredProcedure.dictionary_p_getCurrencies);
                                    break;
                                case "IssuePlace":
                                    Debug.WriteLine("DictionaryUpdater: updating IssuePlace...");
                                    this.LoadSingleDictionary(ref this.issuePlacesXml, StoredProcedure.dictionary_p_getIssuePlaces);
                                    break;
                                case "PaymentMethod":
                                    Debug.WriteLine("DictionaryUpdater: updating PaymentMethod...");
                                    this.LoadSingleDictionary(ref this.paymentMethodsXml, StoredProcedure.dictionary_p_getPaymentMethods);
                                    break;
                                case "DocumentType":
                                    Debug.WriteLine("DictionaryUpdater: updating DocumentType...");
                                    this.LoadSingleDictionary(ref this.documentTypesXml, StoredProcedure.dictionary_p_getDocumentTypes);
                                    break;
                                case "DocumentFieldRelation":
                                    Debug.WriteLine("DictionaryUpdater: updating DocumentFieldRelation...");
                                    this.LoadSingleDictionary(ref this.documentFieldRelationsXml, StoredProcedure.dictionary_p_getDocumentFieldRelations);
                                    break;
                                case "DocumentNumberComponent":
                                    Debug.WriteLine("DictionaryUpdater: updating DocumentNumberComponent...");
                                    this.LoadSingleDictionary(ref this.documentNumberComponentsXml, StoredProcedure.dictionary_p_getDocumentNumberComponents);
                                    break;
                                case "NumberSetting":
                                    Debug.WriteLine("DictionaryUpdater: updating NumberSetting...");
                                    this.LoadSingleDictionary(ref this.numberSettingsXml, StoredProcedure.dictionary_p_getNumberSettings);
                                    break;
                                case "Configuration":
                                    Debug.WriteLine("DictionaryUpdater: updating Configuration...");
                                    ConfigurationMapper.Instance.LoadCachedConfigurationData();
                                    this.LoadPrintProfilesDefinitions();
                                    break;
                                case "Warehouse":
                                    Debug.WriteLine("DictionaryUpdater: updating Warehouse...");
                                    this.LoadSingleDictionary(ref this.warehousesXml, StoredProcedure.dictionary_p_getWarehouses);
                                    break;
                                case "Company":
                                    Debug.WriteLine("DictionaryUpdater: updating Company...");
                                    this.LoadSingleDictionary(ref this.companiesXml, StoredProcedure.dictionary_p_getCompanies);
                                    break;
                                case "Branch":
                                    Debug.WriteLine("DictionaryUpdater: updating Branch...");
                                    this.LoadSingleDictionary(ref this.branchesXml, StoredProcedure.dictionary_p_getBranches);
                                    break;
                                case "DocumentStatus":
                                    Debug.WriteLine("DictionaryUpdater: updating DocumentStatus...");
                                    this.LoadSingleDictionary(ref this.documentStatusesXml, StoredProcedure.dictionary_p_getDocumentStatuses);
                                    break;
                                case "AccountingJournal":
                                    Debug.WriteLine("DictionaryUpdater: updating AccountingJournal...");
                                    this.LoadSingleDictionary(ref this.accountingJournalsXml, StoredProcedure.dictionary_p_getAccountingJournals);
                                    break;
                                case "AccountingRule":
                                    Debug.WriteLine("DictionaryUpdater: updating AccountingRule...");
                                    this.LoadSingleDictionary(ref this.accountingRulesXml, StoredProcedure.dictionary_p_getAccountingRules);
                                    break;
                                case "VatRegister":
                                    Debug.WriteLine("DictionaryUpdater: updating VatRegister...");
                                    this.LoadSingleDictionary(ref this.vatRegistersXml, StoredProcedure.dictionary_p_getVatRegisters);
                                    break;
                                case "FinancialRegister":
                                    Debug.WriteLine("DictionaryUpdater: updating FinancialRegister...");
                                    this.LoadSingleDictionary(ref this.financialRegistersXml, StoredProcedure.dictionary_p_getFinancialRegisters);
                                    break;
                                case "ContainerType":
                                    Debug.WriteLine("DictionaryUpdater: updating ContainerType...");
                                    this.LoadSingleDictionary(ref this.containerTypesXml, StoredProcedure.dictionary_p_getContainerTypes);
                                    break;
                                case "ShiftField":
                                    Debug.WriteLine("DictionaryUpdater: updating ShiftField...");
                                    this.LoadSingleDictionary(ref this.shiftFieldsXml, StoredProcedure.dictionary_p_getShiftFields);
                                    break;
                                case "ServicePlace":
                                    Debug.WriteLine("DictionaryUpdater: updating ServicePlace...");
                                    this.LoadSingleDictionary(ref this.servicePlacesXml, StoredProcedure.dictionary_p_getServicePlaces);
                                    break;
								default:
									Type dictionaryType = this.cachedTypes.Where(t => t.Name == tableName).FirstOrDefault();
									if (dictionaryType != null)
									{
										Debug.WriteLine(String.Format("DictionaryUpdater: updating {0}...", tableName));
										this.LoadSingleDictionary(dictionaryType);
									}
									break;
                            }
                        }
                    }

                    //update version list
                    this.dictionariesVersionsXml = dictionaries;
                    this.UpdateDictionaryVersion();
                }
                finally
                {
                    SqlConnectionManager.Instance.ReleaseConnection();
                    this.updaterWakeUpEvt.Reset();
                    this.DictionaryLock.ExitWriteLock();
                    Debug.WriteLine("DictionaryUpdater: WriteLock released");
                    this.updaterEnteredLockEvt.Reset();
                }
            }
        }

        /// <summary>
        /// Checks if any of dictionaries has been changed and sends notification to the <see cref="updaterThread"/>
        /// if something has changed. Invoke this method <c>only</c> with ReadLock acquired on <see cref="DictionaryLock"/>!
        /// </summary>
        public virtual void CheckForChanges()
        {
            SqlTransaction transaction = SqlConnectionManager.Instance.Transaction;

            if (SessionManager.VolatileElements.IsDictionaryCheckPassed && transaction == null) //if transaction is not null - force to check
                return;

            if (SessionManager.VolatileElements.IsDictionaryCheckPassedDuringTransaction && transaction != null)
                return;

            XDocument dictionaries = this.ExecuteStoredProcedure(StoredProcedure.dictionary_p_getDictionariesVersions);

            IEnumerator<XElement> newDictEnum = dictionaries.Root.Element("dictionaryVersion").Elements().GetEnumerator();
            IEnumerator<XElement> oldDictEnum = this.dictionariesVersionsXml.Root.Element("dictionaryVersion").Elements().GetEnumerator();

            while (oldDictEnum.MoveNext())
            {
                newDictEnum.MoveNext();

                if (oldDictEnum.Current.Element("versionNumber").Value != newDictEnum.Current.Element("versionNumber").Value && oldDictEnum.Current.Element("tableName").Value != "items.group")
                {
                    this.updaterWakeUpEvt.Set(); //wake up the updater thread

                    if (!SessionManager.VolatileElements.IsDictionaryCheckPassed && transaction == null) //it's the first time we've been using a dictionary
                    {
                        this.DictionaryLock.ExitReadLock(); //give an opportunity to the updater thread to update the cache
                        this.updaterEnteredLockEvt.WaitOne(); //wait until updater aquires write lock
                        this.DictionaryLock.EnterReadLock(); //wait until it updates the cache
                    }
                    else
                        throw new ClientException(ClientExceptionId.DictionaryChanged);
                }
                else if (
                    (oldDictEnum.Current.Element("tableName").Value == "items.group" || 
                    oldDictEnum.Current.Element("tableName").Value == "document.validation.minimalProfitMargin")
                    && oldDictEnum.Current.Element("version").Value != newDictEnum.Current.Element("version").Value)
                {
                    this.updaterWakeUpEvt.Set(); //wake up the updater thread

                    if (!SessionManager.VolatileElements.IsDictionaryCheckPassed && transaction == null) //it's the first time we've been using a dictionary
                    {
                        this.DictionaryLock.ExitReadLock(); //give an opportunity to the updater thread to update the cache
                        this.updaterEnteredLockEvt.WaitOne(); //wait until updater aquires write lock
                        this.DictionaryLock.EnterReadLock(); //wait until it updates the cache
                    }
                    else
                        throw new ClientException(ClientExceptionId.DictionaryChanged);
                }
            }

            SessionManager.VolatileElements.IsDictionaryCheckPassed = true;

            if (transaction != null)
                SessionManager.VolatileElements.IsDictionaryCheckPassedDuringTransaction = true;
        }
        
        #region Getters for cached dictionary items
        /// <summary>
        /// Gets all dictionary business objects.
        /// </summary>
        /// <param name="dictionary">Xml containing whole dictionary.</param>
        /// <param name="type">Type of the single dictionary element.</param>
        /// <returns>Complete dictionary in masive BO xml format.</returns>
        private XDocument GetAllDictionaryBusinessObjects(XDocument dictionary, BusinessObjectType type)
        {
            XDocument xdoc = new XDocument(dictionary);

            XElement table = (XElement)xdoc.Root.FirstNode;
            string tableName = table.Name.LocalName;

            foreach (XElement entry in table.Elements())
            {
                entry.Name = tableName;
                entry.Add(new XAttribute("type", type.ToString()));
            }

            return xdoc;
        }

		/// <summary>
		/// Gets list of all dictionary objects ids
		/// </summary>
		/// <param name="dictionary"></param>
		/// <returns></returns>
		private List<Guid> GetAllDictionaryBusinessObjectsIds(XDocument dictionary)
		{
			XElement table = (XElement)dictionary.Root.FirstNode;
			return table.Elements().Select(entry => new Guid(entry.Element("id").Value)).ToList();
		}
		
		public XDocument GetFinancialRegisters()
        {
            return this.GetAllDictionaryBusinessObjects(this.financialRegistersXml, BusinessObjectType.FinancialRegister);
        }

        public XDocument GetContainerTypes()
        {
            return this.GetAllDictionaryBusinessObjects(this.containerTypesXml, BusinessObjectType.ContainerType);
        }

        /// <summary>
        /// Gets all contractor fields in database format.
        /// </summary>
        /// <returns>Contractor fields xml</returns>
        public XDocument GetContractorFields()
        {
            return this.GetAllDictionaryBusinessObjects(this.contractorFieldsXml, BusinessObjectType.ContractorField);
        }

        /// <summary>
        /// Gets all contractor relation types in database format.
        /// </summary>
        /// <returns>Contractor relation types xml</returns>
        public XDocument GetContractorRelationTypes()
        {
            return this.GetAllDictionaryBusinessObjects(this.contractorRelationTypesXml, BusinessObjectType.ContractorRelationType);
        }

        /// <summary>
        /// Gets all countries in database format.
        /// </summary>
        /// <returns>Countries xml</returns>
        public XDocument GetCountries()
        {
            return this.GetAllDictionaryBusinessObjects(this.countriesXml, BusinessObjectType.Country);
        }

        public XDocument GetShiftFields()
        {
            return this.GetAllDictionaryBusinessObjects(this.shiftFieldsXml, BusinessObjectType.ShiftField);
        }

        /// <summary>
        /// Gets all currencies in database format.
        /// </summary>
        /// <returns>Currencies xml</returns>
        public XDocument GetCurrencies()
        {
            return this.GetAllDictionaryBusinessObjects(this.currenciesXml, BusinessObjectType.Currency);
        }

        /// <summary>
        /// Gets all document fields in database format.
        /// </summary>
        /// <returns>Document fields xml</returns>
        public XDocument GetDocumentFields()
        {
            return this.GetAllDictionaryBusinessObjects(this.documentFieldsXml, BusinessObjectType.DocumentField);
        }

        /// <summary>
        /// Gets all document field relations in database format.
        /// </summary>
        /// <returns>Document field relations xml</returns>
        public XDocument GetDocumentFieldRelations()
        {
            return this.GetAllDictionaryBusinessObjects(this.documentFieldRelationsXml, BusinessObjectType.DocumentFieldRelation);
        }

        /// <summary>
        /// Gets all document number components in database format.
        /// </summary>
        /// <returns>Document number components xml</returns>
        public XDocument GetDocumentNumberComponents()
        {
            return this.GetAllDictionaryBusinessObjects(this.documentNumberComponentsXml, BusinessObjectType.DocumentNumberComponent);
        }

        /// <summary>
        /// Gets all document types in database format.
        /// </summary>
        /// <returns>Document types xml</returns>
        public XDocument GetDocumentTypes()
        {
            return this.GetAllDictionaryBusinessObjects(this.documentTypesXml, BusinessObjectType.DocumentType);
        }

        /// <summary>
        /// Gets all issue places in database format.
        /// </summary>
        /// <returns>Issue places xml</returns>
        public XDocument GetIssuePlaces()
        {
            return this.GetAllDictionaryBusinessObjects(this.issuePlacesXml, BusinessObjectType.IssuePlace);
        }

        /// <summary>
        /// Gets all item fields in database format.
        /// </summary>
        /// <returns>Item fields xml</returns>
        public XDocument GetItemFields()
        {
            return this.GetAllDictionaryBusinessObjects(this.itemFieldsXml, BusinessObjectType.ItemField);
        }

        /// <summary>
        /// Gets all item relation attr value types in database format.
        /// </summary>
        /// <returns>Item relation attr value types xml</returns>
        public XDocument GetItemRelationAttrValueTypes()
        {
            return this.GetAllDictionaryBusinessObjects(this.itemRelationAttrValueTypesXml, BusinessObjectType.ItemRelationAttrValueType);
        }

        /// <summary>
        /// Gets all item relation types in database format.
        /// </summary>
        /// <returns>Item relation types xml</returns>
        public XDocument GetItemRelationTypes()
        {
            return this.GetAllDictionaryBusinessObjects(this.itemRelationTypesXml, BusinessObjectType.ItemRelationType);
        }

        /// <summary>
        /// Gets all item types in database format.
        /// </summary>
        /// <returns>Item types xml</returns>
        public XDocument GetItemTypes()
        {
            return this.GetAllDictionaryBusinessObjects(this.itemTypesXml, BusinessObjectType.ItemType);
        }

        /// <summary>
        /// Gets all job positions in database format.
        /// </summary>
        /// <returns>Job positions xml</returns>
        public XDocument GetJobPositions()
        {
            return this.GetAllDictionaryBusinessObjects(this.jobPositionsXml, BusinessObjectType.JobPosition);
        }

        /// <summary>
        /// Gets all number settings in database format.
        /// </summary>
        /// <returns>Number settings xml</returns>
        public XDocument GetNumberSettings()
        {
            return this.GetAllDictionaryBusinessObjects(this.numberSettingsXml, BusinessObjectType.NumberSetting);
        }

        /// <summary>
        /// Gets all payment methods in database format.
        /// </summary>
        /// <returns>Payment methods xml</returns>
        public XDocument GetPaymentMethods()
        {
            return this.GetAllDictionaryBusinessObjects(this.paymentMethodsXml, BusinessObjectType.PaymentMethod);
        }

        /// <summary>
        /// Gets all units in database format.
        /// </summary>
        /// <returns>Units xml</returns>
        public XDocument GetUnits()
        {
            return this.GetAllDictionaryBusinessObjects(this.unitsXml, BusinessObjectType.Unit);
        }

        /// <summary>
        /// Gets all unit types in database format.
        /// </summary>
        /// <returns>Unit types xml</returns>
        public XDocument GetUnitTypes()
        {
            return this.GetAllDictionaryBusinessObjects(this.unitTypesXml, BusinessObjectType.UnitType);
        }

        /// <summary>
        /// Gets all vat rates in database format.
        /// </summary>
        /// <returns>Vat rates xml</returns>
        public XDocument GetVatRates()
        {
            return this.GetAllDictionaryBusinessObjects(this.vatRatesXml, BusinessObjectType.VatRate);
        }

        /// <summary>
        /// Returns a <see cref="ItemField"/>.
        /// </summary>
        /// <param name="name"><see cref="ItemField"/>'s name.</param>
        /// <returns><see cref="ItemField"/> if found; otherwise <c>null</c>.</returns>
        public ItemField GetItemField(ItemFieldName name)
        {
            return this.GetDictionaryObject<ItemField>(this.itemFieldsXml, "itemField", "name", name.ToString());
        }

        /// <summary>
        /// Returns a <see cref="ItemField"/>.
        /// </summary>
        /// <param name="id"><see cref="ItemField"/>'s Id.</param>
        /// <returns><see cref="ItemField"/> if found; otherwise <c>null</c>.</returns>
        public ItemField GetItemField(Guid id)
        {
            return this.GetDictionaryObject<ItemField>(this.itemFieldsXml, "itemField", "id", id.ToUpperString());
        }

        public ShiftField GetShiftField(Guid id)
        {
            return this.GetDictionaryObject<ShiftField>(this.shiftFieldsXml, "shiftField", "id", id.ToUpperString());
        }

        public ServicePlace GetServicePlace(Guid id)
        {
            return this.GetDictionaryObject<ServicePlace>(this.servicePlacesXml, "servicePlace", "id", id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="DocumentNumberComponent"/>.
        /// </summary>
        /// <param name="id"><see cref="DocumentNumberComponent"/>'s Id.</param>
        /// <returns><see cref="DocumentNumberComponent"/> if found; otherwise <c>null</c>.</returns>
        public DocumentNumberComponent GetDocumentNumberComponent(Guid id)
        {
            return this.GetDictionaryObject<DocumentNumberComponent>(this.documentNumberComponentsXml, "documentNumberComponent", "id", id.ToUpperString());
        }

        public bool IsPaymentMethodSupportedByRegister(Guid paymentMethodId, Guid branchId)
        {
            string paymentId = paymentMethodId.ToUpperString();
            string brId = branchId.ToUpperString();

            var query = this.financialRegistersXml.Root.Element("financialRegister").Elements().Where(x => x.Element("branchId").Value == brId &&
                           x.Element("xmlOptions") != null &&
                           x.Element("xmlOptions").Element("root").Element("register").Element("paymentMethods").Elements().FirstOrDefault(idElement => idElement.Value == paymentId) != null);

            /*if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile) 
                || ConfigurationMapper.Instance.DefaultProfile != null)
            {
                List<string> allowedSymbols = new List<string>();

                XElement profile = ConfigurationMapper.Instance.DefaultProfile;

                if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile))
                    profile = ConfigurationMapper.Instance.Profiles[SessionManager.Profile];

                foreach (var fr in profile.Element("financialRegisters").Elements())
                    allowedSymbols.Add(fr.Value);

                query = query.Where(xx => allowedSymbols.Contains(xx.Element("symbol").Value));
            }*/

            var register = query.FirstOrDefault();

            if (register != null)
                return true;
            else
                return false;
        }

        public FinancialRegister GetFinancialRegisterForSpecifiedPaymentMethod(Guid paymentMethodId, Guid branchId, Guid currencyId)
        {
			string paymentId = paymentMethodId.ToUpperString();
			string brId = branchId.ToUpperString();

			var query = financialRegistersXml.Root.Element("financialRegister").Elements().Where(x => x.Element("branchId").Value == brId &&
							x.Element("currencyId").Value == currencyId.ToUpperString() && 
							x.Element("xmlOptions") != null &&
							x.Element("xmlOptions").Element("root").Element("register").Element("paymentMethods").Elements().FirstOrDefault(idElement => idElement.Value == paymentId) != null);

            if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile)
                || ConfigurationMapper.Instance.DefaultProfile != null)
            {
                List<string> allowedSymbols = new List<string>();

				XElement profile = this.GetProfile();

                foreach (var fr in profile.Element("financialRegisters").Elements())
                    allowedSymbols.Add(fr.Value);

                query = query.Where(xx => allowedSymbols.Contains(xx.Element("symbol").Value));
            }

            var register = query.FirstOrDefault();

            if (register != null)
            {
                FinancialRegister reg = new FinancialRegister();
                reg.Deserialize(register);
                return reg;
            }
            else
                return null;
        }

		public XElement GetProfile()
		{
			XElement profile = ConfigurationMapper.Instance.DefaultProfile;

			if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile))
				profile = ConfigurationMapper.Instance.Profiles[SessionManager.Profile];

			return profile;
		}

        public Guid? GetFirstFinancialRegisterId(int registerCategory)
        {
            string branchId = SessionManager.User.BranchId.ToUpperString();
            var query = this.financialRegistersXml.Root.Element("financialRegister").Elements().Where(
                x => x.Element("registerCategory").Value == registerCategory.ToString(CultureInfo.InvariantCulture)
                && x.Element("branchId").Value == branchId);

            if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile)
                || ConfigurationMapper.Instance.DefaultProfile != null)
            {
                List<string> allowedSymbols = new List<string>();

                XElement profile = ConfigurationMapper.Instance.DefaultProfile;

                if (SessionManager.Profile != null && ConfigurationMapper.Instance.Profiles.ContainsKey(SessionManager.Profile))
                    profile = ConfigurationMapper.Instance.Profiles[SessionManager.Profile];

                foreach (var fr in profile.Element("financialRegisters").Elements())
                    allowedSymbols.Add(fr.Value);

                query = query.Where(xx => allowedSymbols.Contains(xx.Element("symbol").Value));
            }

            string reg = query.Select(s => s.Element("id").Value).FirstOrDefault();

            if (reg == null)
                return null;
            else
                return new Guid(reg);
        }

        public FinancialRegister GetFinancialRegister(Guid id)
        {
            return this.GetDictionaryObject<FinancialRegister>(this.financialRegistersXml, "financialRegister", "id", id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="NumberSetting"/>.
        /// </summary>
        /// <param name="id"><see cref="NumberSetting"/>'s Id.</param>
        /// <returns><see cref="NumberSetting"/> if found; otherwise <c>null</c>.</returns>
        public NumberSetting GetNumberSetting(Guid id)
        {
            return this.GetDictionaryObject<NumberSetting>(this.numberSettingsXml, "numberSetting", "id", id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="ContractorField"/>.
        /// </summary>
        /// <param name="id"><see cref="ContractorField"/>'s Id.</param>
        /// <returns><see cref="ContractorField"/> if found; otherwise <c>null</c>.</returns>
        public ContractorField GetContractorField(Guid id)
        {
            return this.GetDictionaryObject<ContractorField>(this.contractorFieldsXml, "contractorField", "id", id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="VatRate"/>.
        /// </summary>
        /// <param name="id"><see cref="VatRate"/>'s Id.</param>
        /// <returns><see cref="VatRate"/> if found; otherwise <c>null</c>.</returns>
        public VatRate GetVatRate(Guid id)
        {
            return (this.GetDictionaryObject<VatRate>(this.vatRatesXml, "vatRate", "id", id.ToUpperString())).InitMetadata();
        }

        public VatRate GetVatRate(string symbol)
        {
            return this.GetDictionaryObject<VatRate>(this.vatRatesXml, "vatRate", "symbol", symbol);
        }

        /// <summary>
        /// Returns a <see cref="DocumentField"/>.
        /// </summary>
        /// <param name="id"><see cref="DocumentField"/>'s Id.</param>
        /// <returns><see cref="DocumentField"/> if found; otherwise <c>null</c>.</returns>
        public DocumentField GetDocumentField(Guid id)
        {
            return this.GetDictionaryObject<DocumentField>(this.documentFieldsXml, "documentField", "id", id.ToUpperString());
        }

        public DocumentField GetDocumentField(string name)
        {
            return this.GetDictionaryObject<DocumentField>(this.documentFieldsXml, "documentField", "name", name);
        }

        public ShiftField GetShiftField(ShiftFieldName name)
        {
            return this.GetDictionaryObject<ShiftField>(this.shiftFieldsXml, "shiftField", "name", name.ToString());
        }

        /// <summary>
        /// Returns a <see cref="DocumentField"/>.
        /// </summary>
        /// <param name="name"><see cref="DocumentField"/>'s name.</param>
        /// <returns><see cref="DocumentField"/> if found; otherwise <c>null</c>.</returns>
        public DocumentField GetDocumentField(DocumentFieldName name)
        {
            return this.GetDictionaryObject<DocumentField>(this.documentFieldsXml, "documentField", "name", name.ToString());
        }

        /// <summary>
        /// Returns a <see cref="Currency"/>.
        /// </summary>
        /// <param name="id"><see cref="Currency"/>'s Id.</param>
        /// <returns><see cref="Currency"/> if found; otherwise <c>null</c>.</returns>
        public Currency GetCurrency(Guid id)
        {
            return this.GetDictionaryObject<Currency>(this.currenciesXml, "currency", "id", id.ToUpperString());
        }

        public Currency GetCurrency(string symbol)
        {
            return this.GetDictionaryObject<Currency>(this.currenciesXml, "currency", "symbol", symbol);
        }

        /// <summary>
        /// Returns a <see cref="IssuePlace"/>.
        /// </summary>
        /// <param name="id"><see cref="IssuePlace"/>'s Id.</param>
        /// <returns><see cref="IssuePlace"/> if found; otherwise <c>null</c>.</returns>
        public IssuePlace GetIssuePlace(Guid id)
        {
            return this.GetDictionaryObject<IssuePlace>(this.issuePlacesXml, "issuePlace", "id", id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="PaymentMethod"/>.
        /// </summary>
        /// <param name="id"><see cref="PaymentMethod"/>'s Id.</param>
        /// <returns><see cref="PaymentMethod"/> if found; otherwise <c>null</c>.</returns>
        public PaymentMethod GetPaymentMethod(Guid id)
        {
            return this.GetDictionaryObject<PaymentMethod>(this.paymentMethodsXml, "paymentMethod", "id", id.ToUpperString());
        }

		/// <summary>
		/// Gets the dictionary object using specified value.
		/// </summary>
		/// <typeparam name="DictionaryType">Type of dictionary to return</typeparam>
		/// <param name="keyElementValue">The xml key element value to compare.</param>
		/// <returns>Object derived from <see cref="BusinessObject"/> if found; otherwise <c>null</c>.</returns>
		private DictionaryType GetDictionaryObject<DictionaryType>(string keyElementValue) where DictionaryType : BusinessObject
		{
			Type type = typeof(DictionaryType);
			var dbCache = BusinessObject.ClassDatabaseMappingCache[type][0];
			return this.GetDictionaryObject<DictionaryType>(this.GetCachedXml(type), dbCache.Attribute.TableName, "id", keyElementValue);
		}

		/// <summary>
		/// Gets the dictionary object using specified value.
		/// </summary>
		/// <typeparam name="DictionaryType">Type of dictionary to return</typeparam>
		/// <param name="dictionary">Dictionary to get the object from.</param>
		/// <param name="keyElementValue">The xml key element value to compare.</param>
		/// <returns>Object derived from <see cref="BusinessObject"/> if found; otherwise <c>null</c>.</returns>
		private DictionaryType GetDictionaryObject<DictionaryType>(XDocument dictionary, string keyElementValue) where DictionaryType : BusinessObject
		{
			var dbCache = BusinessObject.ClassDatabaseMappingCache[typeof(DictionaryType)][0];
			return this.GetDictionaryObject<DictionaryType>(dictionary, dbCache.Attribute.TableName, "id", keyElementValue);
		}

        /// <summary>
        /// Gets the dictionary object.
        /// </summary>
        /// <param name="type">Type of dictionary object.</param>
        /// <param name="dictionary">Dictionary to get the object from.</param>
        /// <param name="elementName">Name of the xml element in dictionary.</param>
        /// <param name="keyElementName">Name of the xml key element to compare.</param>
        /// <param name="keyElementValue">The xml key element value to compare.</param>
		/// <returns>Object derived from <see cref="BusinessObject"/> if found; otherwise <c>null</c>.</returns>
        private DictionaryType GetDictionaryObject<DictionaryType>(XDocument dictionary, string elementName, string keyElementName, string keyElementValue) 
			where DictionaryType : BusinessObject
        {
            this.CheckForChanges();

            DictionaryType ret = null;

            string keyElementValueUpper = keyElementValue.ToUpperInvariant();

            var bo = from node in dictionary.Root.Element(elementName).Elements()
                     where node.Element(keyElementName).Value.ToUpperInvariant() == keyElementValueUpper
                     select node;

            if (bo.Count() >= 1)
            {
                XElement rootElement = new XElement(bo.ElementAt(0)); //cloning
                rootElement.Name = elementName;
                ret = (DictionaryType)Activator.CreateInstance(typeof(DictionaryType));
                ret.Deserialize(rootElement);
            }

            return ret;
        }

        /// <summary>
        /// Gets the collection of dictionary objects.
        /// </summary>
        /// <param name="type">Type of dictionary objects.</param>
        /// <param name="dictionary">Dictionary to get the object from.</param>
        /// <param name="elementName">Name of the xml element in dictionary.</param>
        /// <param name="keyElementName">Name of the xml key element to compare.</param>
        /// <param name="keyElementValue">The xml key element value to compare.</param>
        /// <returns><see cref="ICollection&lt;IBusinessObject&gt;"/> if found; otherwise <c>null</c>.</returns>
        private ICollection<IBusinessObject> GetDictionaryObjects(Type type, XDocument dictionary, string elementName, string keyElementName, string keyElementValue)
        {
            this.CheckForChanges();

            ICollection<IBusinessObject> ret = null;

            var bo = from node in dictionary.Root.Element(elementName).Elements()
                     where node.Element(keyElementName).Value == keyElementValue
                     select node;

            if (bo.Count() > 1)
            {
                ret = new List<IBusinessObject>(bo.Count());

                foreach (XElement element in bo)
                {
                    XElement rootElement = new XElement(element); //cloning
                    rootElement.Name = elementName;
                    ret.Add((IBusinessObject)Activator.CreateInstance(type));
                }
            }

            return ret;
        }

        /// <summary>
        /// Returns a <see cref="ContractorField"/>.
        /// </summary>
        /// <param name="name"><see cref="ContractorField"/>'s name.</param>
        /// <returns><see cref="ContractorField"/> if found; otherwise <c>null</c>.</returns>
        public ContractorField GetContractorField(ContractorFieldName name)
        {
            return this.GetDictionaryObject<ContractorField>(this.contractorFieldsXml, "contractorField", "name", name.ToString());
        }

        /// <summary>
        /// Returns a <see cref="ContractorField"/>.
        /// </summary>
        /// <param name="name"><see cref="ContractorField"/>'s name.</param>
        /// <returns><see cref="ContractorField"/> if found; otherwise <c>null</c>.</returns>
        public ContractorField GetContractorField(string name)
        {
            return this.GetDictionaryObject<ContractorField>(this.contractorFieldsXml, "contractorField", "name", name);
        }

        /// <summary>
        /// Returns a <see cref="ContractorRelationType"/>.
        /// </summary>
        /// <param name="id"><see cref="ContractorRelationType"/>'s Id.</param>
        /// <returns><see cref="ContractorRelationType"/> if found; otherwise <c>null</c>.</returns>
        public ContractorRelationType GetContractorRelationType(Guid id)
        {
            return this.GetDictionaryObject<ContractorRelationType>(this.contractorRelationTypesXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="ItemRelationAttrValueTypeName"/>.
        /// </summary>
         /// <param name="name"><see cref="ItemRelationAttrValueTypeName"/>'s name.</param>
        /// <returns><see cref="ItemRelationAttrValueTypeName"/> if found; otherwise <c>null</c>.</returns>
        public ItemRelationAttrValueType GetItemRelationAttrValueType(ItemRelationAttrValueTypeName name)
        {
            return this.GetDictionaryObject<ItemRelationAttrValueType>(this.itemRelationAttrValueTypesXml, "itemRelationAttrValueType", "name", name.ToString());
        }

        /// <summary>
        /// Returns a <see cref="ItemRelationAttrValueTypeName"/>.
        /// </summary>
        /// <param name="id"><see cref="ItemRelationAttrValueTypeName"/>'s id.</param>
        /// <returns><see cref="ItemRelationAttrValueTypeName"/> if found; otherwise <c>null</c>.</returns>
        public ItemRelationAttrValueType GetItemRelationAttrValueType(Guid id)
        {
            return this.GetDictionaryObject<ItemRelationAttrValueType>(this.itemRelationAttrValueTypesXml, "itemRelationAttrValueType", "id", id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="ItemRelationType"/>.
        /// </summary>
        /// <param name="name"><see cref="ItemRelationType"/>'s name.</param>
        /// <returns><see cref="ItemRelationType"/> if found; otherwise <c>null</c>.</returns>
        public ItemRelationType GetItemRelationType(ItemRelationTypeName name)
        {
            return this.GetDictionaryObject<ItemRelationType>(this.itemRelationTypesXml, "itemRelationType", "name", name.ToString());
        }

        /// <summary>
        /// Returns a <see cref="ItemRelationType"/>.
        /// </summary>
        /// <param name="id"><see cref="ItemRelationType"/>'s id.</param>
        /// <returns><see cref="ItemRelationType"/> if found; otherwise <c>null</c>.</returns>
        public ItemRelationType GetItemRelationType(Guid id)
        {
            return this.GetDictionaryObject<ItemRelationType>(this.itemRelationTypesXml, "itemRelationType", "id", id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="ItemType"/>.
        /// </summary>
        /// <param name="id"><see cref="ItemType"/>'s id.</param>
        /// <returns><see cref="ItemType"/> if found; otherwise <c>null</c>.</returns>
        public ItemType GetItemType(Guid id)
        {
            return this.GetDictionaryObject<ItemType>(this.itemTypesXml, "itemType", "id", id.ToUpperString());
        }

        public Unit GetUnit(string symbol)
        {
            XElement dict = this.unitsXml.Root.Element("unit").Elements().Where(
                u => u.Element("xmlLabels").Element("labels").Elements().Where(
                    l => l.Attribute("symbol").Value == symbol).FirstOrDefault() != null).FirstOrDefault();

            if (dict == null)
                return null;
            else
            {
                Unit unit = new Unit();
                dict = new XElement(dict); //cloning
                dict.Name = "unit";
                unit.Deserialize(dict);
                return unit;
            }
        }

        public PaymentMethod GetPaymentMethod(string label)
        {
            XElement dict = this.paymentMethodsXml.Root.Element("paymentMethod").Elements().Where(
                u => u.Element("xmlLabels").Element("labels").Elements().Where(
                    l => l.Value.ToUpperInvariant() == label.ToUpperInvariant()).FirstOrDefault() != null).FirstOrDefault();

            if (dict == null)
                return null;
            else
            {
                PaymentMethod pm = new PaymentMethod();
                dict = new XElement(dict); //cloning
                dict.Name = "paymentMethod";
                pm.Deserialize(dict);
                return pm;
            }
        }

        /// <summary>
        /// Returns a <see cref="Unit"/>.
        /// </summary>
        /// <param name="id"><see cref="Unit"/>'s id.</param>
        /// <returns><see cref="Unit"/> if found; otherwise <c>null</c>.</returns>
        public Unit GetUnit(Guid id)
        {
            return this.GetDictionaryObject<Unit>(this.unitsXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="UnitType"/>.
        /// </summary>
        /// <param name="id"><see cref="UnitType"/>'s id.</param>
        /// <returns><see cref="UnitType"/> if found; otherwise <c>null</c>.</returns>
        public UnitType GetUnitType(Guid id)
        {
            return this.GetDictionaryObject<UnitType>(this.unitsXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="ContractorRelationType"/>.
        /// </summary>
        /// <param name="name"><see cref="ContractorRelationType"/>'s name.</param>
        /// <returns><see cref="ContractorRelationType"/> if found; otherwise <c>null</c>.</returns>
        public ContractorRelationType GetContractorRelationType(ContractorRelationTypeName name)
        {
            return this.GetDictionaryObject<ContractorRelationType>(this.contractorRelationTypesXml, "contractorRelationType", "name", name.ToString());
        }

        /// <summary>
        /// Returns a <see cref="JobPosition"/>.
        /// </summary>
        /// <param name="id"><see cref="JobPosition"/>'s Id.</param>
        /// <returns><see cref="JobPosition"/> if found; otherwise <c>null</c>.</returns>
        public JobPosition GetJobPosition(Guid id)
        {
            return this.GetDictionaryObject<JobPosition>(this.jobPositionsXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="Country"/>.
        /// </summary>
        /// <param name="id"><see cref="Country"/>'s Id.</param>
        /// <returns><see cref="Country"/> if found; otherwise <c>null</c>.</returns>
        public Country GetCountry(Guid id)
        {
            return this.GetDictionaryObject<Country>(this.countriesXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="Country"/>.
        /// </summary>
        /// <param name="symbol"><see cref="Country"/>'s symbol.</param>
        /// <returns><see cref="Country"/> if found; otherwise <c>null</c>.</returns>
        public Country GetCountry(string symbol)
        {
            return this.GetDictionaryObject<Country>(this.countriesXml, "country", "symbol", symbol);
        }

        /// <summary>
        /// Returns a <see cref="DocumentType"/>.
        /// </summary>
        /// <param name="id"><see cref="DocumentType"/>'s Id.</param>
        /// <returns><see cref="DocumentType"/> if found; otherwise <c>null</c>.</returns>
        public DocumentType GetDocumentType(Guid id)
        {
            return this.GetDictionaryObject<DocumentType>(this.documentTypesXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="DocumentType"/>.
        /// </summary>
        /// <param name="symbol"><see cref="DocumentType"/>'s symbol.</param>
        /// <returns><see cref="DocumentType"/> if found; otherwise <c>null</c>.</returns>
        public DocumentType GetDocumentType(string symbol)
        {
            return this.GetDictionaryObject<DocumentType>(this.documentTypesXml, "documentType", "symbol", symbol);
        }

        /// <summary>
        /// Returns a <see cref="Repository"/>.
        /// </summary>
        /// <param name="id"><see cref="Repository"/>'s Id.</param>
        /// <returns><see cref="Repository"/> if found; otherwise <c>null</c>.</returns>
		public Makolab.Fractus.Kernel.BusinessObjects.Dictionaries.Repository GetRepository(Guid id)
        {
            return this.GetDictionaryObject<Makolab.Fractus.Kernel.BusinessObjects.Dictionaries.Repository>(this.repositoriesXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="Warehouse"/>.
        /// </summary>
        /// <param name="id"><see cref="Warehouse"/>'s Id.</param>
        /// <returns><see cref="Warehouse"/> if found; otherwise <c>null</c>.</returns>
        public Warehouse GetWarehouse(Guid id)
        {
            return this.GetDictionaryObject<Warehouse>(this.warehousesXml, id.ToUpperString());
        }

        /// <summary>
        /// Gets all warehouses in database format.
        /// </summary>
        /// <returns>Warehouses xml</returns>
        public XDocument GetWarehouses()
        {
            return this.GetAllDictionaryBusinessObjects(this.warehousesXml, BusinessObjectType.Warehouse);
        }

        /// <summary>
        /// Returns a <see cref="MimeType"/>.
        /// </summary>
        /// <param name="id"><see cref="MimeType"/>'s Id.</param>
        /// <returns><see cref="MimeType"/> if found; otherwise <c>null</c>.</returns>
        public MimeType GetMimeType(Guid id)
        {
            return this.GetDictionaryObject<MimeType>(this.mimeTypesXml, id.ToUpperString());
        }

        /// <summary>
        /// Returns a <see cref="Company"/>.
        /// </summary>
        /// <param name="id"><see cref="Company"/>'s Id.</param>
        /// <returns><see cref="Company"/> if found; otherwise <c>null</c>.</returns>
        public Company GetCompany(Guid id)
        {
            return this.GetDictionaryObject<Company>(this.companiesXml, "company", "contractorId", id.ToUpperString());
        }

        /// <summary>
        /// Gets all companies in database format.
        /// </summary>
        /// <returns>Companies xml</returns>
        public XDocument GetCompanies()
        {
            return this.GetAllDictionaryBusinessObjects(this.companiesXml, BusinessObjectType.Company);
        }

        /// <summary>
        /// Returns a <see cref="Branch"/>.
        /// </summary>
        /// <param name="id"><see cref="Branch"/>'s Id.</param>
        /// <returns><see cref="Branch"/> if found; otherwise <c>null</c>.</returns>
        public Branch GetBranch(Guid id)
        {
            return this.GetDictionaryObject<Branch>(this.branchesXml, id.ToUpperString());
        }

        public Branch GetFirstBranchByDatabaseId(Guid databaseId)
        {
            return this.GetDictionaryObject<Branch>(this.branchesXml, "branch", "databaseId", databaseId.ToUpperString());
        }

        public Warehouse GetFirstWarehouseByBranchId(Guid branchId)
        {
            return this.GetDictionaryObject<Warehouse>(this.warehousesXml, "warehouse", "branchId", branchId.ToUpperString());
        }

        public ContainerType GetContainerType(Guid containerTypeId)
        {
            return this.GetDictionaryObject<ContainerType>(this.containerTypesXml, containerTypeId.ToUpperString());
        }

        /// <summary>
        /// Gets all branches in database format.
        /// </summary>
        /// <returns>Branches xml</returns>
        public XDocument GetBranches()
        {
            return this.GetAllDictionaryBusinessObjects(this.branchesXml, BusinessObjectType.Branch);
        }

		public List<Guid> GetBranchesIds()
		{
			return this.GetAllDictionaryBusinessObjectsIds(this.branchesXml);
		}

        #endregion

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            if (obj.IsNew) return;

            StoredProcedure? sp = null;

            switch (obj.BOType)
            {
                case BusinessObjectType.Branch:
                    sp = StoredProcedure.dictionary_p_checkBranchVersion;
                    break;
                case BusinessObjectType.Company:
                    sp = StoredProcedure.dictionary_p_checkCompanyVersion;
                    break;
                case BusinessObjectType.ContainerType:
                    sp = StoredProcedure.dictionary_p_checkContainerTypeVersion;
                    break;
                case BusinessObjectType.ContractorField:
                    sp = StoredProcedure.dictionary_p_checkContractorFieldVersion;
                    break;
                case BusinessObjectType.ContractorRelationType:
                    sp = StoredProcedure.dictionary_p_checkContractorRelationTypeVersion;
                    break;
                case BusinessObjectType.Country:
                    sp = StoredProcedure.dictionary_p_checkCountryVersion;
                    break;
                case BusinessObjectType.Currency:
                    sp = StoredProcedure.dictionary_p_checkCurrencyVersion;
                    break;
                case BusinessObjectType.DocumentField:
                    sp = StoredProcedure.dictionary_p_checkDocumentFieldVersion;
                    break;
                case BusinessObjectType.DocumentType:
                    sp = StoredProcedure.dictionary_p_checkDocumentTypeVersion;
                    break;
                case BusinessObjectType.IssuePlace:
                    sp = StoredProcedure.dictionary_p_checkIssuePlaceVersion;
                    break;
                case BusinessObjectType.ItemField:
                    sp = StoredProcedure.dictionary_p_checkItemFieldVersion;
                    break;
                case BusinessObjectType.ItemRelationAttrValueType:
                    sp = StoredProcedure.dictionary_p_checkItemRelationAttrValueTypeVersion;
                    break;
                case BusinessObjectType.ItemRelationType:
                    sp = StoredProcedure.dictionary_p_checkItemRelationTypeVersion;
                    break;
                case BusinessObjectType.ItemType:
                    sp = StoredProcedure.dictionary_p_checkItemTypeVersion;
                    break;
                case BusinessObjectType.JobPosition:
                    sp = StoredProcedure.dictionary_p_checkJobPositionVersion;
                    break;
                case BusinessObjectType.MimeType:
                    sp = StoredProcedure.dictionary_p_checkMimeTypeVersion;
                    break;
                case BusinessObjectType.NumberSetting:
                    sp = StoredProcedure.dictionary_p_checkNumberSettingVersion;
                    break;
                case BusinessObjectType.Repository:
                    sp = StoredProcedure.dictionary_p_checkRepositoryVersion;
                    break;
                case BusinessObjectType.Unit:
                    sp = StoredProcedure.dictionary_p_checkUnitVersion;
                    break;
                case BusinessObjectType.UnitType:
                    sp = StoredProcedure.dictionary_p_checkUnitTypeVersion;
                    break;
                case BusinessObjectType.VatRate:
                    sp = StoredProcedure.dictionary_p_checkVatRateVersion;
                    break;
                case BusinessObjectType.VatRegister:
                    sp = StoredProcedure.dictionary_p_checkVatRegisterVersion;
                    break;
                case BusinessObjectType.Warehouse:
                    sp = StoredProcedure.dictionary_p_checkWarehouseVersion;
                    break;
                case BusinessObjectType.ShiftField:
                    sp = StoredProcedure.dictionary_p_checkShiftFieldVersion;
                    break;
                case BusinessObjectType.ServicePlace:
                    sp = StoredProcedure.dictionary_p_checkServicePlaceVersion;
                    break;
            }

            if (sp != null)
                this.ExecuteStoredProcedure(sp.Value, false, "@version", obj.Version);
        }

        /// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            IBusinessObject bo = null;

            switch (type)
            {
                case BusinessObjectType.ContractorField:
                case BusinessObjectType.ContractorRelationType:
                case BusinessObjectType.Country:
                case BusinessObjectType.Currency:
                case BusinessObjectType.DocumentField:
                case BusinessObjectType.DocumentFieldRelation:
                case BusinessObjectType.DocumentType:
                case BusinessObjectType.IssuePlace:
                case BusinessObjectType.ItemField:
                case BusinessObjectType.ItemRelationAttrValueType:
                case BusinessObjectType.ItemRelationType:
                case BusinessObjectType.ItemType:
                case BusinessObjectType.MimeType:
				case BusinessObjectType.OfferStatus:
                case BusinessObjectType.PaymentMethod:
                case BusinessObjectType.Repository:
                case BusinessObjectType.JobPosition:
                case BusinessObjectType.Unit:
                case BusinessObjectType.UnitType:
                case BusinessObjectType.VatRate:
                case BusinessObjectType.DocumentNumberComponent:
                case BusinessObjectType.NumberSetting:
                case BusinessObjectType.Warehouse:
                case BusinessObjectType.Branch:
                case BusinessObjectType.Company:
                case BusinessObjectType.VatRegister:
                case BusinessObjectType.FinancialRegister:
                case BusinessObjectType.ShiftField:
                case BusinessObjectType.ServicePlace:
                    bo = this.CreateNewDictionaryObject(type);
                    break;
                default:
                    throw new InvalidOperationException("DictionaryMapper cannot create this type of BusinessObject.");
            }

            bo.GenerateId();
            return bo;
        }

        private IBusinessObject CreateNewDictionaryObject(BusinessObjectType type)
        {
            string typeName = type.ToString();

            IBusinessObject bo = (IBusinessObject)Activator.CreateInstance(Type.GetType("Makolab.Fractus.Kernel.BusinessObjects.Dictionaries." + typeName));

            return bo;
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
            IBusinessObject bo = null;

            switch (type)
            {
                case BusinessObjectType.Branch:
                    bo = this.GetBranch(id);
                    break;
                case BusinessObjectType.Company:
                    bo = this.GetCompany(id);
                    break;
                case BusinessObjectType.ContractorField:
                    bo = this.GetContractorField(id);
                    break;
                case BusinessObjectType.ContractorRelationType:
                    bo = this.GetContractorRelationType(id);
                    break;
                case BusinessObjectType.Country:
                    bo = this.GetCountry(id);
                    break;
                case BusinessObjectType.Currency:
                    bo = this.GetCurrency(id);
                    break;
                case BusinessObjectType.DocumentField:
                    bo = this.GetDocumentField(id);
                    break;
                case BusinessObjectType.DocumentType:
                    bo = this.GetDocumentType(id);
                    break;
                case BusinessObjectType.IssuePlace:
                    bo = this.GetIssuePlace(id);
                    break;
                case BusinessObjectType.ItemField:
                    bo = this.GetItemField(id);
                    break;
                case BusinessObjectType.ItemRelationAttrValueType:
                    bo = this.GetItemRelationAttrValueType(id);
                    break;
                case BusinessObjectType.ItemRelationType:
                    bo = this.GetItemRelationType(id);
                    break;
                case BusinessObjectType.ItemType:
                    bo = this.GetItemType(id);
                    break;
                case BusinessObjectType.MimeType:
                    bo = this.GetMimeType(id);
                    break;
                case BusinessObjectType.PaymentMethod:
                    bo = this.GetPaymentMethod(id);
                    break;
                case BusinessObjectType.Repository:
                    bo = this.GetRepository(id);
                    break;
                case BusinessObjectType.Unit:
                    bo = this.GetUnit(id);
                    break;
                case BusinessObjectType.UnitType:
                    bo = this.GetUnitType(id);
                    break;
                case BusinessObjectType.VatRate:
                    bo = this.GetVatRate(id);
                    break;
                case BusinessObjectType.DocumentNumberComponent:
                    bo = this.GetDocumentNumberComponent(id);
                    break;
                case BusinessObjectType.NumberSetting:
                    bo = this.GetNumberSetting(id);
                    break;
                case BusinessObjectType.Warehouse:
                    bo = this.GetWarehouse(id);
                    break;
                case BusinessObjectType.JobPosition:
                    bo = this.GetJobPosition(id);
                    break;
                case BusinessObjectType.ShiftField:
                    bo = this.GetShiftField(id);
                    break;
                case BusinessObjectType.ServicePlace:
                    bo = this.GetServicePlace(id);
                    break;
                default:
                    throw new ClientException(ClientExceptionId.ObjectNotFound);
            }

            return bo;
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            //this method is not necessary and should not be used.
            throw new NotSupportedException();
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
            if (operations.Root.HasElements)
            {
                string dictionaryName = ((XElement)operations.Root.FirstNode).Name.LocalName;

                XDocument xml = XDocument.Parse("<root><entry><entryName>dictionary." + dictionaryName + "</entryName><packageName>DictionaryPackage</packageName></entry></root>");

                xml.Root.Element("entry").Add(new XElement("localTransactionId", SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));
                xml.Root.Element("entry").Add(new XElement("deferredTransactionId", SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));
                xml.Root.Element("entry").Add(new XElement("databaseId", ConfigurationMapper.Instance.DatabaseId.ToUpperString()));

                this.ExecuteStoredProcedure(StoredProcedure.communication_p_createTablePackage, false, xml);
            }
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="DictionaryMapper"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected void Dispose(bool disposing)
        {
            if (!this.IsDisposed)
            {
                if (disposing)
                {
                    //Dispose only managed resources here
                    this.updaterThread.Abort();
                    this.updaterThread.Join();
                    this.DictionaryLock.Dispose();
                    this.updaterWakeUpEvt.Close();
                    this.updaterEnteredLockEvt.Close();
                }
            }
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
