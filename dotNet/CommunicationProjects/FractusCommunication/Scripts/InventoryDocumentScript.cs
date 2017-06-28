using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;

namespace Makolab.Fractus.Communication.Scripts
{
    public class InventoryDocumentScript : SnapshotScript
    {
        private DocumentRepository repo;

        public InventoryDocumentScript(IUnitOfWork unitOfWork, ExecutionController controller) : base(unitOfWork)
        {
            this.repo = new DocumentRepository(unitOfWork, controller);
        }

        public override string MainObjectTag
        {
            get { return "inventoryDocumentHeader"; }
        }

        public override void ExecuteChangeset(DBLayer.DBXml changeset)
        {
            this.repo.ExecuteOperations(changeset);
        }

        public override DBLayer.DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.repo.FindInventoryDocumentSnapshot(objectId);
            return GetSnapshotOrNull(snapshot);            
        }
    }
}
