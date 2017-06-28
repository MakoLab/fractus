using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Kernel.Managers;
using System.Data.SqlClient;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication.DBLayer
{
    /// <summary>
    /// Gets informations related to documents from external source like database and persists documents informations.
    /// </summary>
    public class DocumentRepository : Repository<DBXml> //, IDisposable
    {
        /// <summary>
        /// Contractor mapper.
        /// </summary>
        private DocumentMapper mapper;

        /// <summary>
        /// Contractor mapper from Kernel assembly.
        /// </summary>
        private Kernel.Mappers.DocumentMapper kernelDocumentMapper;

        public ExecutionController ExecutionController { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentRepository"/> class.
        /// </summary>
        /// <param name="context">The active database context.</param>
        protected DocumentRepository(IUnitOfWork context) : base(context)
        {
            if (context == null) throw new ArgumentNullException("context");

            this.mapper = context.MapperFactory.CreateMapper<DocumentMapper>(context.ConnectionManager);
            if (this.mapper == null) this.mapper = new DocumentMapper(context.ConnectionManager);

            this.mapper.Transaction = context.Transaction;

            this.kernelDocumentMapper = context.MapperFactory.CreateMapper<Kernel.Mappers.DocumentMapper>(context.ConnectionManager);

            using (IConnectionWrapper conWrapper = context.ConnectionManager.SynchronizeConnection())
            {

                if (this.kernelDocumentMapper == null)
                {
                    SqlConnectionManager.Instance.SetConnection(conWrapper.Connection, context.Transaction as SqlTransaction);
                    this.kernelDocumentMapper = new Kernel.Mappers.DocumentMapper();
                }
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentRepository"/> class.
        /// </summary>
        /// <param name="context">The context.</param>
        /// <param name="executionController">The execution controller.</param>
        public DocumentRepository(IUnitOfWork context, ExecutionController executionController) : this(context)
        {
            this.ExecutionController = executionController;
        }

        /// <summary>
        /// Executes the operations based on constractor related xml.
        /// </summary>
        /// <param name="operations">The xml with operations.</param>
        public void ExecuteOperations(DBXml operations)
        {
            this.ExecutionController.ExecuteOperations(this.kernelDocumentMapper.ExecuteOperations, operations);
            //if (this.ChangesetBuffer != null) this.ChangesetBuffer.AddOrReplaceData(operations.Tables);
            //else
            //{
            //    using (var wrapper = Context.ConnectionManager.SynchronizeConnection())
            //    {
            //        this.kernelDocumentMapper.ExecuteOperations(operations.Xml);
            //    }
            //}
        }

        /// <summary>
        /// Finds the commercial document snapshot.
        /// </summary>
        /// <param name="documentId">The document id.</param>
        /// <returns>Commercial document data in xml format.</returns>
        public DBXml FindCommercialDocumentSnapshot(Guid documentId)
        {
            return this.mapper.GetCommercialDocumentSnapshot(documentId);
        }

        /// <summary>
        /// Finds the warehouse document snapshot.
        /// </summary>
        /// <param name="documentId">The document id.</param>
        /// <returns>Warehouse document data in xml format.</returns>
        public DBXml FindWarehouseDocumentSnapshot(Guid documentId)
        {
            return this.mapper.GetWarehouseDocumentSnapshot(documentId);
        }

        /// <summary>
        /// Finds the commercial-warehouse valuations data for specified list of identifiers.
        /// </summary>
        /// <param name="valuationsId">The list of valuations identifiers.</param>
        /// <returns>Commercial-warehouse valuations in xml format.</returns>
        public DBXml FindCommercialWarehouseValuations(List<Guid> valuationsId)
        {
            return this.mapper.GetCommercialWarehouseValuations(valuationsId);
        }

        /// <summary>
        /// Finds the commercial-warehouse relations data for specified list of identifiers.
        /// </summary>
        /// <param name="relationsId">The list of relations identifiers.</param>
        /// <returns>Commercial-warehouse relations in xml format.</returns>
        public DBXml FindCommercialWarehouseRelations(List<Guid> relationsId)
        {
            return this.mapper.GetCommercialWarehouseRelations(relationsId);
        }

        /// <summary>
        /// Finds the inventory document snapshot.
        /// </summary>
        /// <param name="documentId">The document id.</param>
        /// <returns>Inventory document data in xml format.</returns>
        public DBXml FindInventoryDocumentSnapshot(Guid documentId)
        {
            return this.mapper.GetInventoryDocumentSnapshot(documentId);
        }

        /// <summary>
        /// Finds the income-outcome relations data for specified list of identifiers.
        /// </summary>
        /// <param name="relationsId">The list of relations identifiers.</param>
        /// <returns>Income-outcome relations in xml format.</returns>
        public DBXml FindIncomeOutcomeRelation(List<Guid> relationsId)
        {
            return this.mapper.GetIncomeOutcomeRelation(relationsId);
        }

        /// <summary>
        /// Finds the warehouse document valuations data for specified list of identifiers.
        /// </summary>
        /// <param name="valuationsId">The list of valuations identifiers.</param>
        /// <returns>Warehouse document valuations in xml format.</returns>
        public DBXml FindWarehouseDocumentValuations(List<Guid> valuationsId)
        {
            return this.mapper.GetWarehouseDocumentValuations(valuationsId);
        }

        /// <summary>
        /// Finds the commercial-commercial relations data for specified list of identifiers.
        /// </summary>
        /// <param name="relationsId">The list of relations identifiers.</param>
        /// <returns>Commercial-commercial relations in xml format.</returns>
        public DBXml FindDocumentRelations(List<Guid> relationsId)
        {
            return this.mapper.GetDocumentRelations(relationsId);
        }

        /// <summary>
        /// Unrelates the specified commercial document from warehouse documents.
        /// </summary>
        /// <param name="commercialDocumentId">The commercial document id to unrelate.</param>
        public void UnrelateCommercialDocument(Guid commercialDocumentId, Guid localTransactionId, Guid defferedTransactionId, Guid databaseId)
        {
            this.mapper.DeleteCommercialDocumentRelations(commercialDocumentId, localTransactionId, defferedTransactionId, databaseId);
        }

        /// <summary>
        /// Unrelates the outcome warehouse document from warehouse and/or commercial documents.
        /// </summary>
        /// <param name="warehouseDocumentId">The warehouse document id.</param>
        public void UnrelateWarehouseDocumentForOutcome(Guid warehouseDocumentId)
        {
            this.mapper.DeleteWarehouseDocumentForOutcome(warehouseDocumentId);
        }

        /// <summary>
        /// Unrelates the income warehouse document from warehouse and/or commercial documents.
        /// </summary>
        /// <param name="warehouseDocumentId">The warehouse document id.</param>
        public void UnrelateWarehouseDocumentForIncome(Guid warehouseDocumentId)
        {
            this.mapper.DeleteWarehouseDocumentForIncome(warehouseDocumentId);
        }

        /// <summary>
        /// Updates the stock.
        /// </summary>
        /// <param name="warehouseStockData">The warehouse stock data.</param>
        public void UpdateStock(XDocument warehouseStockData)
        {
            this.ExecutionController.ExecuteCommand(() => this.mapper.UpdateStock(warehouseStockData));
        }

        /// <summary>
        /// Determines which of specified warehouses are local.
        /// </summary>
        /// <param name="warehouseList">The warehouses.</param>
        /// <returns>Specified warehouses with marked local warehouses.</returns>
        public XDocument FindLocalWarehouses(XDocument warehouseList)
        {
            return this.mapper.MarkLocalWarehouses(warehouseList);
        }

        /// <summary>
        /// Finds the series.
        /// </summary>
        /// <param name="seriesId">The series id.</param>
        /// <returns>Series data in xml format.</returns>
        public DBXml FindSeries(Guid seriesId)
        { 
            return this.mapper.GetSeries(seriesId);
        }

        /// <summary>
        /// Finds the payment snapshot.
        /// </summary>
        /// <param name="paymentId">The payment id.</param>
        /// <returns></returns>
        public DBXml FindPaymentSnapshot(List<Guid> paymentsId)
        {
            return this.mapper.GetPaymentSnapshot(paymentsId);
        }

        /// <summary>
        /// Finds the payment settlement snapshot.
        /// </summary>
        /// <param name="paymentSettlementId">The payment settlement id.</param>
        /// <returns></returns>
        public DBXml FindPaymentSettlementSnapshot(Guid paymentSettlementId)
        {
            return this.mapper.GetPaymentSettlementSnapshot(paymentSettlementId);
        }

        /// <summary>
        /// Indexes the document.
        /// </summary>
        /// <param name="documentInfo">The document info.</param>
        /// <param name="isNew">if set to <c>true</c> the document is new.</param>
        public void IndexDocument(XDocument documentInfo, bool isNew)
        {
            this.ExecutionController.ExecuteCommand(() => this.mapper.UpdateDocumentIndex(documentInfo, isNew));
        }

        public DBXml FindFinancialDocumentSnapshot(Guid documentId)
        {
            return this.mapper.GetFinancialDocumentSnapshot(documentId);
        }

        public DBXml FindFinancialReport(Guid reportId)
        {
            return this.mapper.GetFinancialReport(reportId);
        }

        public DBXml FindComplaintDocumentSnapshot(Guid complaintId)
        {
            return this.mapper.GetComplaintDocumentSnapshot(complaintId);
        }

        public DBXml FindFileDescriptor(Guid descriptorId)
        {
            return this.mapper.GetFileDescriptor(descriptorId);
        }

        public void CreateSavepoint(string savepointName)
        {
            this.mapper.SetTransactionSavepoint(savepointName);
        }

        public void RollbackToSavepoint(string savepointName)
        {
            this.mapper.RollbackTransactionToSavepoint(savepointName);
        }

        //#region IDisposable Members

        ///// <summary>
        ///// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        ///// </summary>
        //public void Dispose()
        //{
        //    Dispose(true);
        //    GC.SuppressFinalize(this);
        //}

        //#endregion

        ///// <summary>
        ///// Releases unmanaged and - optionally - managed resources
        ///// </summary>
        ///// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        //protected virtual void Dispose(bool disposing)
        //{
        //    if (disposing)
        //    {
                
        //    }
        //}
    }
}
