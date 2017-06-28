
namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Fractus.Commons;
    using System.Data.SqlClient;
    using System.Data;
    using System.Xml.Linq;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.DBLayer;

    /// <summary>
    /// Class that persists contractor xml representation.
    /// </summary>
    public class ContractorMapper : IMapper
    {
        /// <summary>
        /// Helper object.
        /// </summary>
        private MapperHelper helper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorMapper"/> class.
        /// </summary>
        public ContractorMapper() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorMapper"/> class.
        /// </summary>
        /// <param name="databaseConnectorManager">The DatabaseConnector manager.</param>
        public ContractorMapper(IDatabaseConnectionManager databaseConnectorManager)
        {
            if (databaseConnectorManager == null) throw new ArgumentNullException("databaseConnectorManager");
              
            this.Database = databaseConnectorManager;

            this.helper = new MapperHelper(this.Database, this);
        }

        /// <summary>
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager Database { get; private set; }

        /// <summary>
        /// Gets or sets the database transaction.
        /// </summary>
        /// <value>The database transaction.</value>
        public IDbTransaction Transaction { get; set; }

        /// <summary>
        /// Gets the contractor snapshot.
        /// </summary>
        /// <param name="id">The contractor id.</param>
        /// <returns>Contractor xml.</returns>
        public virtual DBXml GetContractorSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getContractorPackage.ToProcedureName(), 
                                                       new SqlParameter("@contractorId", SqlDbType.UniqueIdentifier), 
                                                       id);

            XDocument contractorSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                contractorSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(contractorSnapshot);
        }

        /// <summary>
        /// Gets the contractor relations snapshot.
        /// </summary>
        /// <param name="id">The contractor relations id.</param>
        /// <returns>Contractor relations xml.</returns>
        public virtual DBXml GetContractorRelationsSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getContractorRelationPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier), 
                                                       id);

            XDocument contractorRelationsSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                contractorRelationsSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(contractorRelationsSnapshot);
        }

        /// <summary>
        /// Gets contractor group membership data in xml format.
        /// </summary>
        /// <param name="id">The Contractor group membership id.</param>
        /// <returns>Contractor group membership snapshot.</returns>
        public virtual DBXml GetContractorGroupMembershipSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getContractorGroupMembershipPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument contractorGroupMembershipSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                contractorGroupMembershipSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(contractorGroupMembershipSnapshot);
        }

        /// <summary>
        /// Updates the index of the contractor.
        /// </summary>
        /// <param name="contractorInfo">The contractor data.</param>
        public void UpdateContractorIndex(XNode contractorInfo)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.contractor_p_updateContractorDictionary.ToProcedureName(),
                                                        new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                        this.helper.CreateSqlXml(contractorInfo));
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }
    }
}
