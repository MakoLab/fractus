using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.Xml.Linq;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process WarehouseDocumentSnapshot communication package.
    /// </summary>
    public class WarehouseDocumentSnapshot : SnapshotScript
    {
        private ICommunicationPackage package;

        /// <summary>
        /// Document repository
        /// </summary>
        protected DocumentRepository Repository { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this branch is headquarter.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this branch is headquarter; otherwise, <c>false</c>.
        /// </value>
        protected bool IsHeadquarter { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="WarehouseDocumentSnapshot"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        /// <param name="isHeadquarter">if set to <c>true</c> currnet branch is headquarter.</param>
        public WarehouseDocumentSnapshot(IUnitOfWork unitOfWork, ExecutionController controller, bool isHeadquarter)
            : base(unitOfWork)
        {
            this.Repository = new DocumentRepository(unitOfWork, controller);
            this.ExecutionController = controller;
            this.IsHeadquarter = isHeadquarter;
        }

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "warehouseDocumentHeader"; }
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(Makolab.Fractus.Communication.DBLayer.DBXml changeset)
        {
            //remove valuations that link to lines marked as deleted
            if (changeset.Table("warehouseDocumentValuation") != null && changeset.Table("warehouseDocumentLine") != null)
            {
                List<DBRow> deletedValuations = new List<DBRow>();
                foreach (var line in changeset.Table("warehouseDocumentLine").Rows.Where(l => l.Action == DBRowState.Delete))
                {
                    foreach (var valuation in changeset.Table("warehouseDocumentValuation").Rows)
                    {
                        if (valuation.Element("incomeWarehouseDocumentLineId").Value.Equals(line.Element("id").Value, StringComparison.OrdinalIgnoreCase)
                            || valuation.Element("outcomeWarehouseDocumentLineId").Value.Equals(line.Element("id").Value, StringComparison.OrdinalIgnoreCase))
                        {
                            deletedValuations.Add(valuation);
                        }
                    }
                }
                deletedValuations.ForEach(v => v.Remove());
            }


            //TODO kod dodany by wykorzystywac mechanizm savepointow, ale dziwia warunki na korekte pz/wz
            //TODO nalezy sprawdzi czy zmiana wycen rusza wersje obiektu glownego bo wyglda na to ze nie
            var docType = Makolab.Fractus.Kernel.Mappers.DictionaryMapper.Instance.GetDocumentType(
                new Guid(this.CurrentPackage.Table(this.MainObjectTag).FirstRow().Element("documentTypeId").Value));
            if ((docType.DocumentCategory == Makolab.Fractus.Kernel.Enums.DocumentCategory.IncomeWarehouseCorrection
                    || docType.DocumentCategory == Makolab.Fractus.Kernel.Enums.DocumentCategory.OutcomeWarehouseCorrection)
                && changeset.Table("warehouseDocumentValuation") != null )
            {
                var warehouseValuationTable = changeset.Table("warehouseDocumentValuation");
                warehouseValuationTable.Remove();
                DBXml valuationXml = new DBXml();
                valuationXml.AddTable(warehouseValuationTable);

                this.Repository.ExecuteOperations(changeset);

                WarehouseDocumentValuation valuationProcessor = new WarehouseDocumentValuation(this.UnitOfWork, this.ExecutionController, this.IsHeadquarter);
                valuationProcessor.Log = this.Log;
                valuationProcessor.LocalTransactionId = this.LocalTransactionId;
                CommunicationPackage valuationPackage = new CommunicationPackage(new XmlTransferObject() { Content = valuationXml.Xml.ToString(SaveOptions.DisableFormatting) });
                valuationPackage.DatabaseId = this.package.DatabaseId;
                valuationPackage.XmlData.LocalTransactionId = this.package.XmlData.LocalTransactionId;
                valuationPackage.XmlData.DeferredTransactionId = this.package.XmlData.DeferredTransactionId;
                valuationProcessor.ExecutePackage(valuationPackage, 0);
            }
            else this.Repository.ExecuteOperations(changeset);
        }

        /// <summary>
        /// Process communication package persisting it's data to database.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            this.package = communicationPackage;
            return base.ExecutePackage(communicationPackage);
        }

        /// <summary>
        /// Gets xml representation of bussiness object with related objects.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns>
        /// 	<see cref="DBXml"/> from database with specified id.
        /// </returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.Repository.FindWarehouseDocumentSnapshot(objectId);
            return GetSnapshotOrNull(snapshot);
        }
    }
}