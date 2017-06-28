using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.Coordinators.Plugins;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Class that coordinates business logic of Contractor's BusinessObject.
    /// </summary>
    public class ContractorCoordinator : TypedCoordinator<ContractorMapper>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorCoordinator"/> class.
        /// </summary>
        public ContractorCoordinator() : this(true, true)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorCoordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        public ContractorCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<ContractorMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:8");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        public override void DeleteBusinessObject(XDocument requestXml)
        {
            this.Mapper.DeleteBusinessObject(BusinessObjectType.Contractor, new Guid(requestXml.Root.Element("id").Value));
			JournalManager.Instance.LogToJournalWithTransaction(JournalAction.Contractor_Delete, requestXml);
        }

        /// <summary>
        /// Loads plugins for the current coordinator.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="businessObject">Main business object currently processed.</param>
        protected override void LoadPlugins(CoordinatorPluginPhase pluginPhase, IBusinessObject businessObject)
        {
            base.LoadPlugins(pluginPhase, businessObject);
            ApplicationUserPlugin.Initialize(pluginPhase, this, businessObject as Contractor);
            ContractorCodeExistenceCheckPlugin.Initialize(pluginPhase, this);
        }

        /// <summary>
        /// Performs initial validation.
        /// </summary>
        /// <param name="requestXml">Client's request containing <see cref="BusinessObject"/>'s xml and its options.</param>
        protected override void PerformInitialValidation(XDocument requestXml)
        {
            string boType = ((XElement)requestXml.Root.FirstNode).Attribute("type").Value;

            if (boType != BusinessObjectType.Bank.ToString() && boType != BusinessObjectType.Contractor.ToString()
                && boType != BusinessObjectType.Employee.ToString() && boType != BusinessObjectType.ApplicationUser.ToString())
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + boType);
        }

		public override XDocument LoadBusinessObject(XDocument requestXml)
        {
            XDocument xml = base.LoadBusinessObject(requestXml);

            if (xml.Root.Element("contractor") != null && xml.Root.Element("contractor").Attribute("type").Value == "ApplicationUser"
                && xml.Root.Element("contractor").Element("password") != null)
                xml.Root.Element("contractor").Element("password").Remove();

            return xml;
        }

		/// <summary>
		/// Loads the <see cref="BusinessObject"/> with a specified Id. It appends modification user name.
		/// </summary>
		/// <param name="type">The type of <see cref="IBusinessObject"/> to load.</param>
		/// <param name="id">The id of the <see cref="IBusinessObject"/> to load.</param>
		/// <returns>Loaded <see cref="BusinessObject"/></returns>
		internal override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
		{
			Contractor result = this.MapperTyped.LoadBusinessObject(id);

			if (result.ModificationUserId.HasValue)
			{
				Contractor modificationUser = this.MapperTyped.LoadBusinessObject(result.ModificationUserId.Value);
				result.ModificationUser = modificationUser.FullName;
			}

			if (result.CreationUserId.HasValue)
			{
				Contractor creationUser = this.MapperTyped.LoadBusinessObject(result.CreationUserId.Value);
				result.CreationUser = creationUser.FullName;
			}

			return result;
		}

        internal Contractor GetContractorByFullNameAndPostCode(string fullName, string postCode)
        {
            return ((ContractorMapper)this.Mapper).GetContractorByFullNameAndPostCode(fullName, postCode);
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
