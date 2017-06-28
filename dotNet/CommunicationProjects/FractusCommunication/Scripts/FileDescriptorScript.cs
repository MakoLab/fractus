using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;

namespace Makolab.Fractus.Communication.Scripts
{
    public class FileDescriptorScript : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;

        public FileDescriptorScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.repository.ExecutionController = controller;
        }

        public override string MainObjectTag
        {
            get { return "fileDescriptor"; }
        }

        public override void ExecuteChangeset(DBXml changeset)
        {
            this.repository.ExecuteOperations(changeset);
        }

        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            return this.repository.FindFileDescriptor(objectId);
        }
    }
}
