using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication.DBLayer;
using Makolab.Commons.Communication;
using System.Data;
using Makolab.Fractus.Commons;
using System.Data.SqlClient;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication.DBLayer
{
    /// <summary>
    /// Presists system configuration data. 
    /// </summary>
    public class ConfigurationMapper : IMapper
    {
        /// <summary>
        /// Helper object.
        /// </summary>
        private MapperHelper helper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorMapper"/> class.
        /// </summary>
        public ConfigurationMapper() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorMapper"/> class.
        /// </summary>
        /// <param name="databaseConnectorManager">The DatabaseConnector manager.</param>
        public ConfigurationMapper(IDatabaseConnectionManager databaseConnectorManager)
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
        /// Updates the system configuration.
        /// </summary>
        /// <param name="configuration">The changed configuration.</param>
        public void UpdateConfiguration(XNode configuration)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.configuration_p_updateConfiguration.ToProcedureName(),
                                                        new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                        this.helper.CreateSqlXml(configuration));
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }        
        }

        public void DeleteConfiguration(Guid configurationId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.configuration_p_deleteConfigurationById.ToProcedureName(),
                                                       new SqlParameter("@configurationId", SqlDbType.UniqueIdentifier),
                                                       configurationId);
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }         
        }

        public void InsertConfiguration(XNode configuration)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.configuration_p_insertConfiguration.ToProcedureName(),
                                                       new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                       this.helper.CreateSqlXml(configuration));
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }
    }
}
