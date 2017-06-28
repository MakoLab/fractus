using System;
using System.IO;
using System.Data.SqlClient;

namespace Makolab.Printing.Mappers
{
    /// <summary>
    /// Mapper class that reads data from MS SQL database.
    /// </summary>
    internal class SqlMapper : IMapper
    {
        /// <summary>
        /// Connection string used to connect to the database.
        /// </summary>
        private string connectionString;

        /// <summary>
        /// Select query used to load data from the database.
        /// </summary>
        private string selectQuery;

        /// <summary>
        /// Initializes a new instance of the <see cref="SqlMapper"/> class using specified connection string and select query.
        /// </summary>
        /// <param name="connectionString">The connection string used to connect to the database.</param>
        /// <param name="selectQuery">The select query used to load data from the database.</param>
        public SqlMapper(string connectionString, string selectQuery)
        {
            this.connectionString = connectionString;
            this.selectQuery = selectQuery;
        }

        /// <summary>
        /// Gets the data from datasource.
        /// </summary>
        /// <param name="name">Name of the data to get.</param>
        /// <returns>Loaded data.</returns>
        public string GetData(string name)
        {
            SqlConnection conn = null;
            SqlCommand cmd = null;

            try
            {
                conn = new SqlConnection(this.connectionString);
                conn.Open();

                cmd = new SqlCommand(this.selectQuery, conn);
                cmd.Parameters.AddWithValue("@name", name);

                return (string)cmd.ExecuteScalar();
            }
            finally
            {
                if (cmd != null)
                    cmd.Dispose();

                if (conn != null)
                    conn.Dispose();
            }
        }
    }
}
