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


namespace Makolab.Fractus.Communication.DBLayer
{
    public class CustomMapper : IMapper
    { 
        private MapperHelper helper;


        public CustomMapper() { }

        public CustomMapper(IDatabaseConnectionManager databaseConnectorManager)
        {
            if (databaseConnectorManager == null) throw new ArgumentNullException("databaseConnectorManager");
              
            this.Database = databaseConnectorManager;

            this.helper = new MapperHelper(this.Database, this);
        }

        public IDatabaseConnectionManager Database { get; private set; }

        public IDbTransaction Transaction { get; set; }

        public virtual bool ExecuteCustomPackage(DBXml package)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.custom_p_executeCustomPackage.ToProcedureName(),
                                                        new SqlParameter("@xmlVar", SqlDbType.Xml), package.Xml.ToString());

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }

            return true;
        }
    }
}
