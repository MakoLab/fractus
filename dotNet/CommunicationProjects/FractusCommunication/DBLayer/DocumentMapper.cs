using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication.DBLayer;
using Makolab.Commons.Communication;
using System.Data;
using System.Data.SqlClient;
using Makolab.Fractus.Commons;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication.DBLayer
{
    /// <summary>
    /// Mapps the documents data to and from database and persists documents related data.
    /// </summary>
    public class DocumentMapper : IMapper
    {
        /// <summary>
        /// Helper object.
        /// </summary>
        private MapperHelper helper;

        /// <summary>
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager Database { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentMapper"/> class.
        /// </summary>
        public DocumentMapper() { }
        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentMapper"/> class.
        /// </summary>
        /// <param name="databaseConnectorManager">The DatabaseConnector manager.</param>
        public DocumentMapper(IDatabaseConnectionManager databaseConnectorManager)
        {
            if (databaseConnectorManager == null) throw new ArgumentNullException("databaseConnectorManager");
              
            this.Database = databaseConnectorManager;

            this.helper = new MapperHelper(this.Database, this);
        }

        #region IMapper Members

        /// <summary>
        /// Gets or sets the database transaction.
        /// </summary>
        /// <value>The database transaction.</value>
        public IDbTransaction Transaction { get; set; }

        #endregion

        /// <summary>
        /// Gets the commercial document snapshot.
        /// </summary>
        /// <param name="id">The document id.</param>
        /// <returns>Commercial document snapshot in xml format.</returns>
        public virtual DBXml GetCommercialDocumentSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getCommercialDocumentPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument documentSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                documentSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(documentSnapshot);
        }

        /// <summary>
        /// Gets the warehouse document snapshot.
        /// </summary>
        /// <param name="id">The document id.</param>
        /// <returns>Warehouse document snapshot in xml format.</returns>
        public virtual DBXml GetWarehouseDocumentSnapshot(Guid id)
        { 
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getWarehouseDocumentPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument documentSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                documentSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(documentSnapshot);
        }

        /// <summary>
        /// Gets the commercial-warehouse valuations data for specified list of identifiers.
        /// </summary>
        /// <param name="valuationsId">The list of valuations identifiers.</param>
        /// <returns>Commercial-warehouse valuations in xml format.</returns>
        public virtual DBXml GetCommercialWarehouseValuations(List<Guid> valuationsId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getCommercialWarehouseValuationPackage.ToProcedureName());
            SqlParameter id = new SqlParameter("@id", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);

            XDocument valuations = XDocument.Parse("<root><commercialWarehouseValuation/></root>");
            using (this.Database.SynchronizeConnection())
            {
                foreach (Guid valuationId in valuationsId)
                {
                    id.Value = valuationId;
                    XDocument valuationXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                    if (valuationXml.Root.HasElements == true)
                    {
                        var valuation = valuationXml.Root.Element("commercialWarehouseValuation").Element("entry");
                        if (valuation != null) valuations.Root.Element("commercialWarehouseValuation").Add(valuation);
                    }
                }
            }
            return new DBXml(valuations);
        }

        /// <summary>
        /// Gets the commercial-warehouse relations data for specified list of identifiers.
        /// </summary>
        /// <param name="relationsId">The list of relations identifiers.</param>
        /// <returns>Commercial-warehouse relations in xml format.</returns>
        public virtual DBXml GetCommercialWarehouseRelations(List<Guid> relationsId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getCommercialWarehouseRelationPackage.ToProcedureName());
            SqlParameter id = new SqlParameter("@id", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);

            XDocument valuations = XDocument.Parse("<root><commercialWarehouseRelation/></root>");
            using (this.Database.SynchronizeConnection())
            {
                foreach (Guid relationId in relationsId)
                {
                    id.Value = relationId;
                    XDocument valuationXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                    if (valuationXml.Root.HasElements == true)
                    {
                        var valuation = valuationXml.Root.Element("commercialWarehouseRelation").Element("entry");
                        if (valuation != null) valuations.Root.Element("commercialWarehouseRelation").Add(valuation);
                    }
                }
            }
            return new DBXml(valuations);
        }

        /// <summary>
        /// Gets the income-outcome relations data for specified list of identifiers.
        /// </summary>
        /// <param name="relationsId">The list of relations identifiers.</param>
        /// <returns>Income-outcome relations in xml format.</returns>
        public virtual DBXml GetIncomeOutcomeRelation(List<Guid> relationsId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getIncomeOutcomeRelationPackage.ToProcedureName());
            SqlParameter id = new SqlParameter("@id", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);

            XDocument relations = XDocument.Parse("<root><incomeOutcomeRelation/></root>");
            using (this.Database.SynchronizeConnection())
            {
                foreach (Guid relationId in relationsId)
                {
                    id.Value = relationId;
                    XDocument relationXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                    if (relationXml.Root.HasElements == true)
                    {
                        var relation = relationXml.Root.Element("incomeOutcomeRelation").Element("entry");
                        if (relation != null) relations.Root.Element("incomeOutcomeRelation").Add(relation);
                    }
                }
            }
            return new DBXml(relations);
        }


        /// <summary>
        /// Gets the inventory document snapshot.
        /// </summary>
        /// <param name="id">The document id.</param>
        /// <returns>Inventory document snapshot in xml format.</returns>
        public DBXml GetInventoryDocumentSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getInventoryDocumentPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument documentSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                documentSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(documentSnapshot);
        }

        /// <summary>
        /// Gets the warehouse document valuations data for specified list of identifiers.
        /// </summary>
        /// <param name="valuationsId">The list of valuations identifiers.</param>
        /// <returns>Warehouse document valuations in xml format.</returns>
        public virtual DBXml GetWarehouseDocumentValuations(List<Guid> valuationsId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getWarehouseDocumentValuationPackage.ToProcedureName());
            SqlParameter id = new SqlParameter("@id", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);

            XDocument valuations = XDocument.Parse("<root><warehouseDocumentValuation/></root>");
            using (this.Database.SynchronizeConnection())
            {
                foreach (Guid valuationId in valuationsId)
                {
                    id.Value = valuationId;
                    XDocument valuationXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                    if (valuationXml.Root.HasElements == true)
                    {
                        var valuation = valuationXml.Root.Element("warehouseDocumentValuation").Element("entry");
                        if (valuation != null) valuations.Root.Element("warehouseDocumentValuation").Add(valuation);
                    }
                }
            }
            return new DBXml(valuations);
        }



        /// <summary>
        /// Gets the document commercial relations details for specified list of relations identifiers.
        /// </summary>
        /// <param name="valuationsId">The list of relations identifiers.</param>
        /// <returns>Document commercial-commercial relations in xml format.</returns>
        public virtual DBXml GetDocumentRelations(List<Guid> relationsId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getDocumentRelationPackage.ToProcedureName());
            SqlParameter id = new SqlParameter("@id", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);

            XDocument relations = XDocument.Parse("<root><documentRelation/></root>");
            using (this.Database.SynchronizeConnection())
            {
                foreach (Guid relationId in relationsId)
                {
                    id.Value = relationId;
                    XDocument relationXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                    if (relationXml.Root.HasElements == true)
                    {
                        var valuation = relationXml.Root.Element("documentRelation").Element("entry");
                        if (valuation != null) relations.Root.Element("documentRelation").Add(valuation);
                    }
                }
            }
            return new DBXml(relations);
        }

        /// <summary>
        /// Gets the payment snapshot.
        /// </summary>
        /// <param name="paymentsId">The id of payments.</param>
        /// <returns>
        /// Payment snapshot in xml format.
        /// </returns>
        public virtual DBXml GetPaymentSnapshot(List<Guid> paymentsId)
        {
            XDocument payments = XDocument.Parse("<root />");
            foreach (Guid payment in paymentsId) payments.Root.Add(new XElement("id", payment.ToUpperString()));

            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getPaymentPackage.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                       this.helper.CreateSqlXml(payments));

            XDocument paymentSnapshotSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                paymentSnapshotSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(paymentSnapshotSnapshot);
        }

        /// <summary>
        /// Gets the payment settlement snapshot.
        /// </summary>
        /// <param name="paymentSettlementId">The payment settlement id.</param>
        /// <returns>Payment settlement snapshot in xml format.</returns>
        public virtual DBXml GetPaymentSettlementSnapshot(Guid paymentSettlementId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getPaymentSettlementPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       paymentSettlementId);

            XDocument paymentSettlementSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                paymentSettlementSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(paymentSettlementSnapshot);
        }

        public virtual DBXml GetFinancialDocumentSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getFinancialDocumentPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument documentSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                documentSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(documentSnapshot);
        }

        public virtual DBXml GetFinancialReport(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getFinancialReportPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument reportSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                reportSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(reportSnapshot);
        }


        public DBXml GetComplaintDocumentSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getComplaintDocumentPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument documentSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                documentSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(documentSnapshot);
        }

        public virtual DBXml GetFileDescriptor(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getFileDescriptorPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument fileDescriptor = null;
            using (this.Database.SynchronizeConnection())
            {
                fileDescriptor = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(fileDescriptor);
        }

        /// <summary>
        /// Deletes relations of specified commercial document.
        /// </summary>
        /// <param name="commercialDocumentId">The commercial document id.</param>
        public virtual void DeleteCommercialDocumentRelations(Guid commercialDocumentId, Guid localTransactionId, Guid deferredTransactionId, Guid databaseId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.document_p_unrelateCommercialDocumentFromWarehouseDocuments.ToProcedureName());
            SqlParameter id = new SqlParameter("@commercialDocumentHeaderId", SqlDbType.UniqueIdentifier);
            SqlParameter localTransactionIdParam = new SqlParameter("@localTransactionId", SqlDbType.UniqueIdentifier);
            SqlParameter deferredTransactionIdParam = new SqlParameter("@deferredTransactionId", SqlDbType.UniqueIdentifier);
            SqlParameter databaseIdParam = new SqlParameter("@databaseId", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);
            cmd.Parameters.Add(localTransactionIdParam);
            cmd.Parameters.Add(deferredTransactionIdParam);
            cmd.Parameters.Add(databaseIdParam);
            id.Value = commercialDocumentId;
            localTransactionIdParam.Value = localTransactionId;
            deferredTransactionIdParam.Value = deferredTransactionId;
            databaseIdParam.Value = databaseId;
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Deletes relations of specified outcome warehouse document.
        /// </summary>
        /// <param name="warehouseDocumentId">The warehouse document id.</param>
        public virtual void DeleteWarehouseDocumentForOutcome(Guid warehouseDocumentId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.document_p_deleteWarehouseDocumentRelationsForOutcome.ToProcedureName());
            SqlParameter id = new SqlParameter("@warehouseDocumentHeaderId", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);
            id.Value = warehouseDocumentId;
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Deletes relations of specified income warehouse document.
        /// </summary>
        /// <param name="warehouseDocumentId">The warehouse document id.</param>
        public virtual void DeleteWarehouseDocumentForIncome(Guid warehouseDocumentId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.document_p_deleteWarehouseDocumentRelationsForIncome.ToProcedureName());
            SqlParameter id = new SqlParameter("@warehouseDocumentHeaderId", SqlDbType.UniqueIdentifier);
            cmd.Parameters.Add(id);
            id.Value = warehouseDocumentId;
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Creates the warehouse stock package.
        /// </summary>
        /// <param name="procedureInput">The procedure input.</param>
        public virtual void CreateWarehouseStockPackage(XDocument procedureInput)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_createWarehouseStockPackage.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                       this.helper.CreateSqlXml(procedureInput));

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Updates the stock.
        /// </summary>
        /// <param name="warehouseStockData">The warehouse stock data.</param>
        public virtual void UpdateStock(XDocument warehouseStockData)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.document_p_updateWarehouseStock.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                       this.helper.CreateSqlXml(warehouseStockData));

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Determines which of specified warehouses are local.
        /// </summary>
        /// <param name="warehouseList">The warehouses.</param>
        /// <returns>Specified warehouses with marked local warehouses.</returns>
        public virtual XDocument MarkLocalWarehouses(XDocument warehouseList)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.dictionary_p_isLocalWarehouse.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                       this.helper.CreateSqlXml(warehouseList));

            using (this.Database.SynchronizeConnection())
            {
                return this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }
        }

        /// <summary>
        /// Gets the series.
        /// </summary>
        /// <param name="seriesId">The series id.</param>
        /// <returns>Series data in xml format.</returns>
        public virtual DBXml GetSeries(Guid seriesId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getSeriesPackage.ToProcedureName(),
                                                       new SqlParameter("@seriesId", SqlDbType.UniqueIdentifier),
                                                       seriesId);

            XDocument documentSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                documentSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(documentSnapshot);
        }

        /// <summary>
        /// Updates specified document index.
        /// </summary>
        /// <param name="documentInfo">The document data.</param>
        /// <param name="isNew">if set to <c>true</c> the document is new.</param>
        public void UpdateDocumentIndex(XDocument documentInfo, bool isNew)
        {
            StoredProcedure? procedure = null;
            if (isNew == true) procedure = StoredProcedure.document_p_insertCommercialDocumentDictionary;
            //else update
            if (procedure == null || procedure.HasValue == false) return;
            SqlCommand cmd = this.helper.CreateCommand(procedure.Value.ToProcedureName(),
                                                        new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                        this.helper.CreateSqlXml(documentInfo));
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Sets the transaction savepoint.
        /// </summary>
        /// <param name="savepointName">Name of the savepoint.</param>
        public void SetTransactionSavepoint(string savepointName)
        {
            SqlCommand cmd = this.helper.CreateCommand("SAVE TRANSACTION @savepointName");
            cmd.CommandType = CommandType.Text;

            SqlParameter savepoint = new SqlParameter("@savepointName", savepointName);
            cmd.Parameters.Add(savepoint);

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }        
        }

        /// <summary>
        /// Rollbacks the transaction to savepoint.
        /// </summary>
        /// <param name="savepointName">Name of the savepoint.</param>
        public void RollbackTransactionToSavepoint(string savepointName)
        {
            SqlCommand cmd = this.helper.CreateCommand("ROLLBACK TRANSACTION @savepointName");
            cmd.CommandType = CommandType.Text;

            SqlParameter savepoint = new SqlParameter("@savepointName", savepointName);
            cmd.Parameters.Add(savepoint);

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }
    }
}
