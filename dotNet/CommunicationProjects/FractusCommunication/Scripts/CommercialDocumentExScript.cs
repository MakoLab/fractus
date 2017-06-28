using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Managers;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;

namespace Makolab.Fractus.Communication.Scripts
{
    public class CommercialDocumentExScript : CommercialDocumentScript
    {
        protected bool IsHeadquarter;
        private DBXml dbSnapshot;


        public CommercialDocumentExScript(IUnitOfWork unitOfWork, ExecutionController controller, bool isHeadquarter) : base(unitOfWork, controller)
        {
            this.IsHeadquarter = isHeadquarter;
        }

        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
            SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

            try
            {
                if (this.IsHeadquarter == true)
                {
                    if (base.ExecutePackage(communicationPackage) == false) return false;
                }
                else this.CurrentPackage = new DBXml(XDocument.Parse(communicationPackage.XmlData.Content));

                if (this.CurrentPackage.Table("documentAttrValue") == null) throw new Exception("CommercialDocumentExScript: Brak atrybutu Attribute_TargetBranchId");

                string targetBranch = PackageExecutionHelper.GetDocumentAttrValue(this.CurrentPackage.Table("documentAttrValue").Xml,
                                                                                  Makolab.Fractus.Kernel.Enums.DocumentFieldName.Attribute_TargetBranchId,
                                                                                  "textValue");
                if (targetBranch == null) throw new Exception("CommercialDocumentExScript: Brak atrybutu Attribute_TargetBranchId");

                Guid targetBranchId = new Guid(targetBranch);
                if (PackageExecutionHelper.IsSameDatabase(Makolab.Fractus.Kernel.Mappers.ConfigurationMapper.Instance.DatabaseId, targetBranchId) == true)
                {
                    using (Kernel.Coordinators.DocumentCoordinator coordinator = new Makolab.Fractus.Kernel.Coordinators.DocumentCoordinator(false, false))
                    {
                        coordinator.CreateOrUpdateReservationFromOrder(this.CurrentPackage.Xml.Root);
                    }
                }
                else if (this.IsHeadquarter == true && MustForwardPackage()) ForwardPackage(communicationPackage, targetBranchId);
            }
            catch (SqlException e)
            {
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + this.CurrentPackage.Table(this.MainObjectTag).FirstRow().Element("id").Value);
                }
                else
                {
                    this.Log.Error("CommercialDocumentExScript:ExecutePackage " + e.ToString());
                    return false;
                }
            }
            return true;
        }

        private void ForwardPackage(ICommunicationPackage communicationPackage, Guid targetBranchId)
        {
            XmlTransferObject forwardedPkgData = new XmlTransferObject
            {
                DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId,
                Id = Guid.NewGuid(),
                LocalTransactionId = Guid.NewGuid(),
                XmlType = "CommercialDocumentSnapshotEx",
                Content = this.CurrentPackage.Xml.ToString(System.Xml.Linq.SaveOptions.DisableFormatting)
            };
            ICommunicationPackage pkg = new CommunicationPackage(forwardedPkgData);
            pkg.DatabaseId = Makolab.Fractus.Kernel.Mappers.DictionaryMapper.Instance.GetBranch(targetBranchId).DatabaseId;
            CommunicationPackageRepository pkgRepo = new CommunicationPackageRepository(this.UnitOfWork);
            pkgRepo.PutToOutgoingQueue(pkg);
        }

        private bool MustForwardPackage()
        {
            string oppositeDocumentId = PackageExecutionHelper.GetDocumentAttrValue(this.CurrentPackage.Table("documentAttrValue").Xml,
                                                                              Makolab.Fractus.Kernel.Enums.DocumentFieldName.Attribute_OppositeDocumentId,
                                                                              "textValue");
            if (oppositeDocumentId == null) return true;

            DBXml oppositeSnapshot = this.repository.FindCommercialDocumentSnapshot(new Guid(oppositeDocumentId));
            if (oppositeSnapshot == null) return true;

            string orderStatus = PackageExecutionHelper.GetDocumentAttrValue(this.CurrentPackage.Table("documentAttrValue").Xml,
                                                                              Makolab.Fractus.Kernel.Enums.DocumentFieldName.Attribute_OrderStatus,
                                                                              "textValue");
            string oppositeOrderStatus = (oppositeSnapshot.Table("documentAttrValue") == null) ? null : 
                                                  PackageExecutionHelper.GetDocumentAttrValue(oppositeSnapshot.Table("documentAttrValue").Xml,
                                                                                              Makolab.Fractus.Kernel.Enums.DocumentFieldName.Attribute_OrderStatus,
                                                                                              "textValue");

            //should work like this (orderStatus is a number) if ((orderStatus == null && oppositeOrderStatus != null) || (orderStatus != null && orderStatus.Equals(oppositeOrderStatus, StringComparison.OrdinalIgnoreCase) == false)) return true;
            if (orderStatus != oppositeOrderStatus) return true;
            else return false;
        }

        public override DBXml GenerateChangeset(DBXml commSnapshot, DBXml dbSnapshot)
        {
            this.dbSnapshot = dbSnapshot;
            return base.GenerateChangeset(commSnapshot, dbSnapshot);
        }
    }
}
