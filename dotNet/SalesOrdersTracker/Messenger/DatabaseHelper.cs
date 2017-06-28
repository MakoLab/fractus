using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Xml.Linq;
using System.Xml;
using System.Data.SqlTypes;

namespace Makolab.Fractus.Messenger
{
    public class DatabaseHelper
    {
        string connectionString;

        public DatabaseHelper(string connectionString)
        {
            this.connectionString = connectionString;
        }

        public SqlParameter CreateSqlParameter(string name, SqlDbType paramType, object value)
        {
            SqlParameter p = new SqlParameter(name, paramType);
            p.Value = value;
            return p;
        }

        public SqlDataReader ExecuteStoreProcedure(string procedure, params SqlParameter[] sqlParameters)
        {
            SqlConnection conn = GetOpenedConnection();
            try
            {
                using (SqlCommand cmd = new SqlCommand(procedure, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddRange(sqlParameters);
                    return cmd.ExecuteReader(System.Data.CommandBehavior.CloseConnection);
                }
            }
            catch
            {
                if (conn != null) conn.Close();
                throw;
            }
        }

        public XDocument ExecuteXmlStoreProcedure(string procedure, params SqlParameter[] sqlParameters)
        {
            using(SqlConnection conn = GetOpenedConnection())
            using (SqlCommand cmd = new SqlCommand(procedure, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddRange(sqlParameters);
                return GetXmlDocument(cmd.ExecuteXmlReader());
            }
        }

        public void ExecuteNonQueryStoreProcedure(string procedure, params SqlParameter[] sqlParameters)
        {
            using (SqlConnection conn = GetOpenedConnection())
            using (SqlCommand cmd = new SqlCommand(procedure, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddRange(sqlParameters);
                cmd.ExecuteNonQuery();
            }
        }

        public SqlDataReader ExecuteStoreProcedure(string procedure, TransactionManager transaction, params SqlParameter[] sqlParameters)
        {
            using (SqlCommand cmd = new SqlCommand(procedure, transaction.Connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = transaction.Transaction;
                cmd.Parameters.AddRange(sqlParameters);
                return cmd.ExecuteReader(System.Data.CommandBehavior.Default);
            }
        }

        public XDocument ExecuteXmlStoreProcedure(string procedure, TransactionManager transaction, params SqlParameter[] sqlParameters)
        {
            using (SqlCommand cmd = new SqlCommand(procedure, transaction.Connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = transaction.Transaction;
                cmd.Parameters.AddRange(sqlParameters);
                return GetXmlDocument(cmd.ExecuteXmlReader());
            }
        }

        public void ExecuteNonQueryStoreProcedure(string procedure, TransactionManager transaction, params SqlParameter[] sqlParameters)
        {
            using (SqlCommand cmd = new SqlCommand(procedure, transaction.Connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = transaction.Transaction;
                cmd.Parameters.AddRange(sqlParameters);
                cmd.ExecuteNonQuery();
            }
        }

        public TransactionManager Transaction(IsolationLevel level)
        { 
            var conn =  GetOpenedConnection();
            var t = new TransactionManager(conn.BeginTransaction(level));
            return t;
        }

        public XDocument GetXmlDocument(XmlReader reader)
        {
            if (reader == null) throw new ArgumentNullException("reader");

            try
            {
                XDocument xdoc = XDocument.Load(reader);
                return xdoc;
            }
            finally { reader.Close(); }
        }

        /// <summary>
        /// Creates the <see cref="SqlXml"/> object from <see cref="XNode"/>.
        /// </summary>
        /// <param name="xml">A <see cref="XNode"/>.</param>
        /// <returns>Created <see cref="SqlXml"/> object.</returns>
        public SqlXml CreateSqlXml(XNode xml)
        {
            if (xml == null) throw new ArgumentNullException("xml");

            XmlReader reader = xml.CreateReader();
            try
                { return new SqlXml(reader); }
            finally
                { reader.Close(); }
        }

        public SqlConnection GetOpenedConnection()
        {
            var conn = new SqlConnection(this.connectionString);
            conn.Open();
            return conn;
        }
    }
}
