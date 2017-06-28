using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Commons;
using System.Data.SqlClient;
using System.Xml.Linq;
using Makolab.Fractus.Communication.DBLayer;
using System.Configuration;
using System.Data;
using Makolab.Commons.Communication;

namespace Makolab.Fractus.Communication
{
    public class CommunicationStatisticsMapper
    {
        private SqlConnection database;
        private StatisticsMapperHelper helper;

        public CommunicationStatisticsMapper()
        {
            this.database = new SqlConnection(ConfigurationManager.ConnectionStrings["statistics"].ConnectionString);
            this.helper = new StatisticsMapperHelper(database);
        }

        public Dictionary<string, string> GetBranchList()
        {
            if(this.database.State != ConnectionState.Open) this.database.Open();

            using (SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.dictionary_p_getBranches.ToProcedureName()))
            {
                XDocument branchXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                DBXml branches = new DBXml(branchXml);
                Dictionary<string, string> branchList = new Dictionary<string, string>();
                foreach (var branch in branches.Table("branch").Rows)
                {
                    branchList.Add(branch.Element("id").Value, branch.Element("xmlLabels").Element("labels").Element("label").Value);
                }

                return branchList;
            }
        }

        public Dictionary<string, DepartmentStatistics> GetBasicStatisticsList()
        {
            if (this.database.State != ConnectionState.Open) this.database.Open();

            DBXml branches = null;
            using (SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.dictionary_p_getBranches.ToProcedureName()))
            {
                XDocument branchXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                branches = new DBXml(branchXml);
            }


            using (SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getStatisticsList.ToProcedureName()))
            {
                XDocument statisticsXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                DBXml statistics = new DBXml(statisticsXml);

                Dictionary<string, DepartmentStatistics> branchStatisticsList = new Dictionary<string, DepartmentStatistics>();
                foreach (var branchStats in statistics.Table("statistics").Rows)
                {
                    string branchId = branches.Table("branch").Rows.Where(row => row.Element("databaseId").Value.Equals(branchStats.Element("databaseId").Value, StringComparison.OrdinalIgnoreCase))
                                                                   .First().Element("id").Value;
                    DepartmentStatistics branchStat = new DepartmentStatistics();
                    if (branchStats.Element("lastUpdate") == null) continue;
                    else branchStat.StatisticsUpdateTime = DateTime.Parse(branchStats.Element("lastUpdate").Value).Round(DateTimeAccuracy.Second);

                    branchStat.CurrentTime = DateTime.Parse(branchStats.Element("currentTime").Value).Round(DateTimeAccuracy.Second);
                    branchStat.SystemTime = DateTime.Now.Round(DateTimeAccuracy.Second);
                    branchStat.LastExecutionTime = (branchStats.Element("lastExecutionTime") == null) ? (DateTime?)null : DateTime.Parse(branchStats.Element("lastExecutionTime").Value).Round(DateTimeAccuracy.Second);
                    branchStat.LastReceiveTime = (branchStats.Element("lastReceiveDate") == null) ? (DateTime?)null : DateTime.Parse(branchStats.Element("lastReceiveDate").Value).Round(DateTimeAccuracy.Second);
                    branchStat.LastSendTime = (branchStats.Element("lastSendDate") == null) ? (DateTime?)null : DateTime.Parse(branchStats.Element("lastSendDate").Value).Round(DateTimeAccuracy.Second);
                    branchStat.PackagesToExecute = (branchStats.Element("unprocessedPackagesQuantity") == null) ? -1 : Int32.Parse(branchStats.Element("unprocessedPackagesQuantity").Value);
                    branchStat.PackagesToReceive = (branchStats.Element("unsentPackage") == null) ? -1 : Int32.Parse(branchStats.Element("unsentPackage").Value);
                    branchStat.PackagesToSend = (branchStats.Element("undeliveredPackagesQuantity") == null) ? -1 : Int32.Parse(branchStats.Element("undeliveredPackagesQuantity").Value);
                    branchStat.LastExecutionMessage = (branchStats.Element("executionMessageTime") == null) ? null : new MessageData() { Time = DateTime.Parse(branchStats.Element("executionMessageTime").Value).Round(DateTimeAccuracy.Second) };
                    branchStat.LastReceiveMessage = (branchStats.Element("receiveMessageTime") == null) ? null : new MessageData() { Time = DateTime.Parse(branchStats.Element("receiveMessageTime").Value).Round(DateTimeAccuracy.Second) };
                    branchStat.LastSendMessage = (branchStats.Element("sentMessageTime") == null) ? null : new MessageData() { Time = DateTime.Parse(branchStats.Element("sentMessageTime").Value).Round(DateTimeAccuracy.Second) };

                    SynchronizeStatisticTime(branchStat);
                    branchStatisticsList.Add(branchId, branchStat);
                }
                return branchStatisticsList;
            }
        }

        public DepartmentStatistics GetDetailedStatistics(Guid branchId)
        {
            if (this.database.State != ConnectionState.Open) this.database.Open();

            using (SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getStatisticsDetails.ToProcedureName(),
                                           new SqlParameter("@branchId", SqlDbType.UniqueIdentifier),
                                           branchId))
            {

                XDocument statisticsXml = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
                DBRow statistics = new DBXml(statisticsXml).Table("statistics").FirstRow();

                DepartmentStatistics branchStats = new DepartmentStatistics();
                branchStats.CurrentTime = DateTime.Parse(statistics.Element("currentTime").Value).Round(DateTimeAccuracy.Second);
                branchStats.SystemTime = DateTime.Now.Round(DateTimeAccuracy.Second);
                if (statistics.Element("executionMessageTime") != null)
                {
                    branchStats.LastExecutionMessage = new MessageData(statistics.Element("lastExecutionMessage").Value, DateTime.Parse(statistics.Element("executionMessageTime").Value).Round(DateTimeAccuracy.Second));
                }
                if (statistics.Element("receiveMessageTime") != null)
                {
                    branchStats.LastReceiveMessage = new MessageData(statistics.Element("lastReceiveMessage").Value, DateTime.Parse(statistics.Element("receiveMessageTime").Value).Round(DateTimeAccuracy.Second));
                }
                if (statistics.Element("sentMessageTime") != null)
                {
                    branchStats.LastSendMessage = new MessageData(statistics.Element("lastSentMessage").Value, DateTime.Parse(statistics.Element("sentMessageTime").Value).Round(DateTimeAccuracy.Second));
                }

                SynchronizeStatisticTime(branchStats);

                return branchStats;
            }
        }

        private void SynchronizeStatisticTime(DepartmentStatistics stats)
        {
            TimeSpan timeDiff = (TimeSpan)(stats.CurrentTime - stats.SystemTime);
            if (Math.Abs(timeDiff.TotalSeconds) > 10)
            {
                stats.StatisticsUpdateTime = stats.StatisticsUpdateTime + timeDiff;
                if (stats.LastExecutionTime.HasValue) stats.LastExecutionTime = (stats.LastExecutionTime.Value + timeDiff);
                if (stats.LastReceiveTime.HasValue) stats.LastReceiveTime = (stats.LastReceiveTime.Value + timeDiff);
                if (stats.LastSendTime.HasValue) stats.LastSendTime = (stats.LastSendTime.Value + timeDiff);

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
