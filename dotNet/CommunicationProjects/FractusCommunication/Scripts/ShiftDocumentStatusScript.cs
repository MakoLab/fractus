using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Commons.Communication;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Communication.DBLayer;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process ShiftDocumentStatus communication package.
    /// </summary>
    public class ShiftDocumentStatusScript : ExecutingScript
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ShiftDocumentStatusScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        /// <param name="changesetBuffer">The changeset buffer.</param>
        public ShiftDocumentStatusScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Executes the communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            try
            {
                using(var wrapper = this.UnitOfWork.ConnectionManager.SynchronizeConnection())
	            {
                    SqlConnectionManager.Instance.SetConnection(wrapper.Connection, this.UnitOfWork.Transaction as SqlTransaction);
	            }
                XDocument commPkg = XDocument.Parse(communicationPackage.XmlData.Content);
                SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
                SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

                this.ExecutionController.ExecuteCommand(() => UpdateDocumentStatus(commPkg));
                return true;
            }
            catch (SqlException e)
            {
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected.");
                }
                else
                {
                    this.Log.Error("ShiftDocumentStatusScript:ExecutePackage " + e.ToString());
                    return false;
                }
            }
        }

        private static void UpdateDocumentStatus(XDocument commPkg)
        {
            using (DocumentCoordinator cord = new DocumentCoordinator(false, false))
            {
                Guid documentId = new Guid(commPkg.Root.Element("shiftDocumentStatus").Attribute("outcomeShiftId").Value);
                WarehouseDocument outcomeShiftDocument = (WarehouseDocument)cord.LoadBusinessObject(Makolab.Fractus.Kernel.Enums.BusinessObjectType.WarehouseDocument, documentId);
                DocumentAttrValue oppositeDocStatus = outcomeShiftDocument.Attributes.Children.Where(attr => attr.DocumentFieldName == Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentStatus).SingleOrDefault();
                if (oppositeDocStatus == null)
                {
                    oppositeDocStatus = outcomeShiftDocument.Attributes.CreateNew();
                    oppositeDocStatus.DocumentFieldName = Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentStatus;
                }
                DocumentAttrValue oppositeDocId = outcomeShiftDocument.Attributes.Children.Where(attr => attr.DocumentFieldName == Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId).SingleOrDefault();
                if (oppositeDocId == null)
                {
                    oppositeDocId = outcomeShiftDocument.Attributes.CreateNew();
                    oppositeDocId.DocumentFieldName = Makolab.Fractus.Kernel.Enums.DocumentFieldName.ShiftDocumentAttribute_OppositeDocumentId;
                    oppositeDocId.Value.Value = commPkg.Root.Element("shiftDocumentStatus").Attribute("incomeShiftId").Value;
                }
                oppositeDocStatus.Value.Value = commPkg.Root.Element("shiftDocumentStatus").Attribute("status").Value;
                cord.SaveBusinessObject(outcomeShiftDocument);
            }
        }
    }
}
