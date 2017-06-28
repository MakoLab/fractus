using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Repository;
using Makolab.Fractus.Kernel.Coordinators.Plugins;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Class that coordinates business logic of Item's BusinessObject
    /// </summary>
    public class RepositoryCoordinator : TypedCoordinator<RepositoryMapper>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="RepositoryCoordinator"/> class.
        /// </summary>
        public RepositoryCoordinator() : this(true, true)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="RepositoryCoordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        public RepositoryCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<RepositoryMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:92");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        /// <summary>
        /// Deletes business object.
        /// </summary>
        /// <param name="requestXml">Client's request containing <see cref="BusinessObject"/>'s id to delete.</param>
        public override void DeleteBusinessObject(XDocument requestXml)
        {
            BusinessObjectType type = BusinessObjectType.Other;

            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), requestXml.Root.Element("type").Value);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:93");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + requestXml.Root.Element("type").Value);
            }

            Guid id = new Guid(requestXml.Root.Element("id").Value);

            this.Mapper.DeleteBusinessObject(type, id);
        }

        /// <summary>
        /// Loads plugins for the current coordinator.
        /// </summary>
        /// <param name="pluginPhase">Coordinator plugin phase.</param>
        /// <param name="businessObject">Main business object currently processed.</param>
        protected override void LoadPlugins(CoordinatorPluginPhase pluginPhase, IBusinessObject businessObject)
        {
            base.LoadPlugins(pluginPhase, businessObject);
            FileDescriptorPlugin.Initialize(pluginPhase, this);
        }

        /// <summary>
        /// Notifies that the <see cref="Coordinator"/> enters the <c>BeforeSave</c> phase.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObject"/> that is to be saved.</param>
        public override void BeforeSavePhase(IBusinessObject businessObject)
        {
            base.BeforeSavePhase(businessObject);

            FileDescriptor fd = businessObject as FileDescriptor;

            if (fd != null)
            {
                fd.ModificationDate = SessionManager.VolatileElements.CurrentDateTime;
                fd.ModificationUserId = SessionManager.User.UserId;
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
