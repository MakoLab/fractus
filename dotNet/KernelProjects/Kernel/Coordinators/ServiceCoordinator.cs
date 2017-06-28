using System;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators
{
    public class ServiceCoordinator : TypedCoordinator<ServiceMapper>
    {
        public ServiceCoordinator()
            : this(true, true)
        {
        }

        public ServiceCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<ServiceMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:94");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

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
