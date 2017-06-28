using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.Coordinators.Plugins;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Class that coordinates business logic of Configuration's BusinessObject
    /// </summary>
    public class ConfigurationCoordinator : TypedCoordinator<ConfigurationMapper>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ConfigurationCoordinator"/> class.
        /// </summary>
        public ConfigurationCoordinator() : this(true, true)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ConfigurationCoordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        public ConfigurationCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<ConfigurationMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:5");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        public XDocument GetConfiguration(string keys)
        {
            return this.GetConfiguration(keys, null);
        }

        public XDocument GetConfiguration(string keys, string userProfileId)
        {
            string[] keysTab = keys.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            Guid? userProfId = null;

            if (!String.IsNullOrEmpty(userProfileId))
                userProfId = new Guid(userProfileId);

            ICollection<Configuration> configValues = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, userProfId, keysTab);

			return this.GetConfigurationXDocument(configValues, true);
        }

		/// <summary>
		/// Gets configuration for specified branch. It queries branch database.
		/// </summary>
		/// <param name="keys">Configuration keys that identifies records to return</param>
		/// <param name="branchId">Branch identifier</param>
		/// <returns></returns>
		public XDocument GetConfiguration(string keys, Guid branchId)
		{
			string[] keysTab = keys.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

			string branchIdString = branchId.ToUpperString();

            throw new InvalidOperationException("REFACTORINDICATOR error");

            //if (SqlConnectionManager.BranchesConnectionManagers.ContainsKey(branchId))
            //{
            //    //connection manager for branch
            //    SqlConnectionManager branchSqlConnectionManager = SqlConnectionManager.BranchesConnectionManagers[branchId];
            //    try
            //    {
            //        branchSqlConnectionManager.InitializePrivilegedConnection(3);
            //        if (branchSqlConnectionManager.Connection.State != System.Data.ConnectionState.Open)
            //        {
            //            throw new ClientException(ClientExceptionId.UnableToEstablishConnectionWithBranch, null
            //                , "branchId:" + branchIdString) { XmlData = new XElement("branchId", branchIdString) };
            //        }

            //        //generate proper input xml
            //        XDocument xml = XDocument.Parse(@"<root></root>");
            //        foreach (string key in keysTab)
            //        {
            //            xml.Root.Add(new XElement("entry", key));
            //        }

            //        //execute the procedure for specified branch
            //        xml = this.Mapper.ExecuteStoredProcedure(null, null, null, StoredProcedure.configuration_p_getConfigurationSet, true, xml, null
            //            , branchSqlConnectionManager.Command);
            //        xml.Root.Add(new XAttribute("branchId", branchIdString));
            //        return xml;
            //    }
            //    catch (Exception ex)
            //    {
            //        throw new ClientException(ClientExceptionId.UnableToEdtiConfigurationAtBranch, ex, "branchId:" + branchIdString)
            //        {
            //            XmlData = new XElement("branchId", branchIdString)
            //        };
            //    }
            //    finally
            //    {
            //        branchSqlConnectionManager.ReleasePrivilegedConnection();
            //    }
            //}
			//else
			//{
			//	throw new ClientException(ClientExceptionId.UnableToEstablishConnectionWithBranch, null
			//		, "branchId:" + branchIdString) { XmlData = new XElement("branchId", branchIdString) };
			//}
		}
		
		/// <summary>
		/// Gets xml with all configuration keys. 
		/// </summary>
		/// <returns>Result format is similar to GetConfiguration result except it doesn't contain xmlValue.</returns>
		public XDocument GetConfigurationKeys()
		{
			ICollection<Configuration> configValues = ConfigurationMapper.Instance.GetConfigurationKeys();

			return this.GetConfigurationXDocument(configValues, false);
		}

        public override void DeleteBusinessObject(XDocument requestXml)
        {
            string key = requestXml.Root.Element("key").Value;
            ConfigurationLevel level = (ConfigurationLevel)Enum.Parse(typeof(ConfigurationLevel), requestXml.Root.Element("level").Value, true);

			this.DeleteConfiguration(key, level);
        }

		public void DeleteConfiguration(string key, ConfigurationLevel level)
		{
			SqlConnectionManager.Instance.BeginTransaction();

			try
			{
				XDocument journalXml = ((ConfigurationMapper)this.Mapper).DeleteConfiguration(key, level);
				JournalManager.Instance.LogToJournal(JournalAction.ConfigValue_Delete, journalXml);

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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:6");
				Coordinator.ProcessSqlException(sqle, BusinessObjectType.Configuration, this.CanCommitTransaction);
				throw;
			}
			catch (Exception)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:7");
				if (this.CanCommitTransaction)
					SqlConnectionManager.Instance.RollbackTransaction();
				throw;
			}
		}

        /// <summary>
        /// Saves the configuration.
        /// </summary>
        /// <param name="requestXml">Client request xml containing configuration entry to save.</param>
        /// <returns>Xml containing operation results.</returns>
        public XDocument SaveConfiguration(string requestXml)
        {
            XDocument reqXml = XDocument.Parse(requestXml);
			SessionManager.VolatileElements.ClientRequest = reqXml;

            XAttribute attrLevel = reqXml.Root.Element("configValue").Attribute("level");

            if (attrLevel == null)
                throw new InvalidOperationException("Configuration level attribute is missing.");

            ConfigurationLevel level = (ConfigurationLevel)Enum.Parse(typeof(ConfigurationLevel), attrLevel.Value, true);

            string configurationKey = reqXml.Root.Element("configValue").Attribute("key").Value;

            Configuration conf = this.FindConfigurationEntryForTheSpecifiedLevel(configurationKey, level);

            if (conf == null) //create new configuration
            {
                conf = (Configuration)this.Mapper.CreateNewBusinessObject(BusinessObjectType.Configuration, null);
                conf.Key = configurationKey;

                if (level == ConfigurationLevel.User)
                    conf.UserId = SessionManager.User.UserId;
            }

            if (reqXml.Root.Element("configValue").FirstNode is XElement)
                conf.Value = (XElement)reqXml.Root.Element("configValue").FirstNode;
            else
                conf.Value.Value = reqXml.Root.Element("configValue").Value;

            return this.SaveBusinessObject(conf);
        }

		/// <summary>
		/// Saves configuration in specified branch.
		/// </summary>
		/// <param name="requestXml"></param>
		/// <returns></returns>
		public XDocument SaveConfigurationByBranch(string requestXml)
		{
			XDocument reqXml = XDocument.Parse(requestXml);
			SessionManager.VolatileElements.ClientRequest = reqXml;

			XDocument configurationXml = new XDocument(reqXml.Root.Element("configuration"));
			if (reqXml.Root.Element("branchId") == null)
			{
				throw new ArgumentNullException("branchId");
			}
			Guid branchId = new Guid(reqXml.Root.Element("branchId").Value);

            throw new InvalidOperationException("REFACTORINDICATOR");
            //if (SqlConnectionManager.BranchesConnectionManagers.ContainsKey(branchId))
            //{
            //    //connection manager for branch
            //    SqlConnectionManager branchSqlConnectionManager = SqlConnectionManager.BranchesConnectionManagers[branchId];
            //    try
            //    {
            //        branchSqlConnectionManager.InitializePrivilegedConnection(3);
            //        if (branchSqlConnectionManager.Connection.State != System.Data.ConnectionState.Open)
            //        {
            //            throw new ClientException(ClientExceptionId.UnableToEstablishConnectionWithBranch, null, "branchId:" + branchId.ToUpperString());
            //        }
            //        branchSqlConnectionManager.BeginTransaction();

            //        this.MapperTyped.SaveConfiguration(configurationXml, branchSqlConnectionManager);

            //        if (this.CanCommitTransaction)
            //        {
            //            if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
            //                branchSqlConnectionManager.CommitTransaction();
            //            else
            //                branchSqlConnectionManager.RollbackTransaction();
            //        }
            //    }
            //    catch (Exception)
            //    {
            //        if (this.CanCommitTransaction)
            //        {
            //            branchSqlConnectionManager.RollbackTransaction();
            //        }
            //        throw;
            //    }
            //    finally
            //    {
            //        branchSqlConnectionManager.ReleasePrivilegedConnection();
            //    }
            //}
            //else
            //{
            //    throw new ClientException(ClientExceptionId.UnableToEstablishConnectionWithBranch, null, "branchId:" + branchId.ToUpperString());
            //}
			
			return XDocument.Parse("<root>TRUE</root>");

		}

        /// <summary>
        /// Loads plugins for the current coordinator.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="businessObject">Main business object currently processed.</param>
        protected override void LoadPlugins(CoordinatorPluginPhase pluginPhase, IBusinessObject businessObject)
        {
            base.LoadPlugins(pluginPhase, businessObject);

            Configuration conf = (Configuration)businessObject;
            ContractorsGroupDefinitionPlugin.Initialize(pluginPhase, this, conf);
            ConfigurationRefreshPlugin.Initialize(pluginPhase, this, conf);
        }

        /// <summary>
        /// Finds the configuration entry for the specified level.
        /// </summary>
        /// <param name="key">Configuration key.</param>
        /// <param name="level">Configuration level.</param>
        /// <returns><see cref="Configuration"/> object if found; otherwise <c>null</c>.</returns>
        private Configuration FindConfigurationEntryForTheSpecifiedLevel(string key, ConfigurationLevel level)
        {
            XDocument xml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                "<root><entry>{0}</entry></root>", key));

            xml = this.Mapper.ExecuteStoredProcedure(StoredProcedure.configuration_p_getConfigurationSet, true, xml);

            IEnumerable<XElement> entry = null;

            if (level == ConfigurationLevel.User)
            {
                entry = from node in xml.Root.Element("configuration").Elements()
                        where node.Element("applicationUserId") != null && node.Element("applicationUserId").Value == SessionManager.User.UserId.ToUpperString()
                        select node;
            }
            else if (level == ConfigurationLevel.System)
            {
                entry = from node in xml.Root.Element("configuration").Elements()
                        where node.Element("applicationUserId") == null &&
                        node.Element("companyContractorId") == null &&
                        node.Element("pointId") == null &&
                        node.Element("userProfileId") == null &&
                        node.Element("workstationid") == null
                        select node;
            }

            if (entry.Elements().Count() > 0)
            {
                XElement boElement = (XElement)this.Mapper.ConvertDBToBoXmlFormat(xml, new Guid(entry.ElementAt(0).Element("id").Value)).Root.FirstNode;
                Configuration conf = (Configuration)this.Mapper.ConvertToBusinessObject(boElement, null);
                return conf;
            }
            else
                return null;
        }

		private XDocument GetConfigurationXDocument(ICollection<Configuration> configValues, bool validateNull)
		{
			XDocument retXml = XDocument.Parse("<root></root>");
			foreach (Configuration conf in configValues.Where(conf => conf.Key != null))
			{
				retXml.Root.Add(this.GetConfigurationXElement(conf, validateNull));
			}

			return retXml;
		}

		private XElement GetConfigurationXElement(Configuration conf, bool validateNull)
		{
			XElement configElement = new XElement("configValue");
			configElement.Add(new XAttribute("key", conf.Key));

			if (validateNull && conf.Value == null)
				throw new InvalidOperationException(String.Format("Nieprawidłowy wpis konfiguracji: {0}", conf.Key));

			if (conf.Value == null)
				configElement.Add("NULL");
			else if (conf.Value.HasElements || conf.Value.Name.LocalName != "value")
				configElement.Add(conf.Value);
			else
				configElement.Add(conf.Value.Value);

			if (conf.UserId != null)
				configElement.Add(new XAttribute("level", ConfigurationLevel.User.ToString()));
			else if (conf.UserProfileId != null)
				configElement.Add(new XAttribute("level", ConfigurationLevel.UserProfile.ToString()));
			else if (conf.CompanyId != null)
				configElement.Add(new XAttribute("level", ConfigurationLevel.Company.ToString()));
			else
				configElement.Add(new XAttribute("level", ConfigurationLevel.System.ToString()));

			return configElement;
		}

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="ConfigurationCoordinator"/> and optionally releases the managed resources.
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
