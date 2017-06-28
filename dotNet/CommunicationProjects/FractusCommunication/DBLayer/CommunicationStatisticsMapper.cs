namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using Makolab.Fractus.Commons;
    using System.Data;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.DBLayer;

    /// <summary>
    /// Class that handles communication statistics persistance.
    /// </summary>
    public class CommunicationStatisticsMapper : IMapper, ICommunicationStatisticsMapper
    {
        /// <summary>
        /// Helper object.
        /// </summary>
        private MapperHelper helper;

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationStatisticsMapper"/> class.
        /// </summary>
        public CommunicationStatisticsMapper() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationStatisticsMapper"/> class.
        /// </summary>
        /// <param name="databaseConnectorManager">The DatabaseConnector manager.</param>
        public CommunicationStatisticsMapper(IDatabaseConnectionManager databaseConnectorManager)
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
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager Database { get; private set; }

        /// <summary>
        /// Updates the communication statistics by pesristing them.
        /// </summary>
        /// <param name="statistics">The statistics data.</param>
        /// <param name="departmentId">The statistics target department id.</param>
        public virtual void UpdateStatistics(CommunicationStatistics statistics, Guid departmentId)
        {
            if (statistics == null) throw new ArgumentNullException("statistics");

            if (departmentId == null) throw new ArgumentNullException("departmentId");

            SynchronizeStatisticTime(statistics);

            DBRow row = new DBXml().AddTable("statistics").AddRow();
            row.AddElement("databaseId", departmentId.ToUpperString());
            row.AddElement("lastUpdate", DateTime.Now.ToIsoString());
            row.AddElement("undeliveredPackagesQuantity", statistics.PackagesToSend);
            row.AddElement("unprocessedPackagesQuantity", statistics.PackagesToExecute);
            if (statistics.LastExecutionTime != null) row.AddElement("lastExecutionTime", statistics.LastExecutionTime.Value.ToIsoString());

            if (statistics.LastSendMessage != null)
            {
                row.AddElement("lastSentMessage", statistics.LastSendMessage.Message);
                row.AddElement("sentMessageTime", statistics.LastSendMessage.Time.Value.ToIsoString());
            }

            if (statistics.LastExecutionMessage != null)
            {
                row.AddElement("lastExecutionMessage", statistics.LastExecutionMessage.Message);
                row.AddElement("executionMessageTime", statistics.LastExecutionMessage.Time.Value.ToIsoString());
            }

            if (statistics.LastReceiveMessage != null)
            {
                row.AddElement("lastReceiveMessage", statistics.LastReceiveMessage.Message);
                row.AddElement("receiveMessageTime", statistics.LastReceiveMessage.Time.Value.ToIsoString());
            }

            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_updateStatistics.ToProcedureName(),
                                                    new SqlParameter("@xmlVar", SqlDbType.Xml), 
                                                    this.helper.CreateSqlXml(row.Table.Document.Xml));

            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }             
        }

        public System.Xml.Linq.XDocument GetAdditionalData(string procedureName)
        {
            SqlCommand cmd = this.helper.CreateCommand("[communication].[" + procedureName + "]");
            using (this.Database.SynchronizeConnection())
            {
                return this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }
        }

        private void SynchronizeStatisticTime(CommunicationStatistics stats)
        {
            if (stats.CurrentTime.Year < DateTime.Now.Year) return;

            TimeSpan timeDiff = (TimeSpan) (DateTime.Now - stats.CurrentTime);
            if (Math.Abs(timeDiff.TotalMinutes) > 1.0)
            {
                if (stats.LastExecutionTime.HasValue) stats.LastExecutionTime = (stats.LastExecutionTime.Value + timeDiff);

                if (stats.LastExecutionMessage != null) 
                {
                    stats.LastExecutionMessage.Time = stats.LastExecutionMessage.Time.HasValue ? new DateTime?(stats.LastExecutionMessage.Time.Value + timeDiff) : null;
                }

                if (stats.LastReceiveMessage != null)
                {
                    stats.LastReceiveMessage.Time = stats.LastReceiveMessage.Time.HasValue ? new DateTime?(stats.LastReceiveMessage.Time.Value + timeDiff) : null;
                }

                if (stats.LastSendMessage != null)
                {
                    stats.LastSendMessage.Time = stats.LastSendMessage.Time.HasValue ? new DateTime?(stats.LastSendMessage.Time.Value + timeDiff) : null;
                }
            }            
        }
    }
}