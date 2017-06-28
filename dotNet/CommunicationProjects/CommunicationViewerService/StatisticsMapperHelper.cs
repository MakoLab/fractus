namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using System.Xml.Linq;
    using System.Data.SqlClient;
    using System.Data.SqlTypes;
    using System.IO;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.DBLayer;

    /// <summary>
    /// Helper class for mapper objects.
    /// </summary>
    public class StatisticsMapperHelper
    {

        /// <summary>
        /// Initializes a new instance of the <see cref="MapperHelper"/> class.
        /// </summary>
        /// <param name="database">The DatabaseConnector manager with database connection.</param>
        /// <param name="mapper">The mapper using helper.</param>
        public StatisticsMapperHelper(SqlConnection database)
        {
            this.Database = database;
        }

        /// <summary>
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public SqlConnection Database { get; set; }

        /// <summary>
        /// Creates <see cref="XDocument"/> from <see cref="XmlReader"/> returned by query.
        /// </summary>
        /// <param name="reader">The reader with xml.</param>
        /// <returns>Created <see cref="XDocument"/></returns>
        public XDocument GetXmlDocument(XmlReader reader)
        {
            if (reader == null) throw new ArgumentNullException("reader");

            try
            {
                XDocument xdoc = XDocument.Load(reader);
                return xdoc;
            }
            finally
                { reader.Close(); }
        }

        /// <summary>
        /// Creates the SQL command for specified stored procedure.
        /// </summary>
        /// <param name="procedure">The stored procedure.</param>
        /// <returns>Created SQL command.</returns>
        public SqlCommand CreateCommand(string procedure)
        {
            SqlCommand cmd = this.Database.CreateCommand();
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.CommandText = procedure;
            return cmd;
        }

        /// <summary>
        /// Creates the SQL command for specified stored procedure with specified parameter.
        /// </summary>
        /// <param name="procedure">The stored procedure.</param>
        /// <param name="parameterInfo">The parameter object.</param>
        /// <param name="parameterValue">The parameter value.</param>
        /// <returns>Created <see cref="SqlCommand"/> with specified parameters.</returns>
        public SqlCommand CreateCommand(string procedure, SqlParameter parameterInfo, object parameterValue)
        {
            if (parameterInfo == null) throw new ArgumentNullException("parameterInfo");

            if (parameterValue != null && parameterValue.GetType().FullName.StartsWith("System.Data.SqlTypes", StringComparison.Ordinal) == true)
            {
                parameterInfo.SqlValue = parameterValue;
            }
            else parameterInfo.Value = parameterValue;

            SqlCommand cmd = CreateCommand(procedure);
            cmd.Parameters.Add(parameterInfo);
            return cmd;
        }

        /// <summary>
        /// Creates the <see cref="SqlXml"/> object from <see cref="string"/>.
        /// </summary>
        /// <param name="xml">The <see cref="string"/> with xml.</param>
        /// <returns>Created <see cref="SqlXml"/> object.</returns>
        public SqlXml CreateSqlXml(string xml)
        {
            if (xml == null) throw new ArgumentNullException("xml");

            XmlReader reader = XmlTextReader.Create(new StringReader(xml));
            try
                { return new SqlXml(reader); }
            finally
                { reader.Close(); }
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
    }
}
