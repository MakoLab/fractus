using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

namespace Makolab.Fractus.Communication
{
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Single, Name="CommunicationService")]
    public class CommunicationStatisticsService : ICommunicationStatusService
    {
        private CommunicationStatisticsMapper mapper;

        public CommunicationStatisticsService()
        {
            this.mapper = new CommunicationStatisticsMapper();
        }

        #region ICommunicationStatusService Members

        public Dictionary<string, string> GetDepartmentsName()
        {
            return this.mapper.GetBranchList();
        }

        public Dictionary<string, DepartmentStatistics> GetBasicDepartmentsStatistics()
        {
            return this.mapper.GetBasicStatisticsList();
        }

        public DepartmentStatistics GetAdvancedDepartmentStatistics(Makolab.Commons.Communication.ServiceType service, string departmentIdentifier)
        {
            DepartmentStatistics stats = this.mapper.GetDetailedStatistics(new Guid(departmentIdentifier));
            if (service == Makolab.Commons.Communication.ServiceType.Executor)
            {
                stats.LastReceiveMessage = null;
                stats.LastSendMessage = null;
            }
            else if (service == Makolab.Commons.Communication.ServiceType.Receiver)
            {
                stats.LastExecutionMessage = null;
                stats.LastSendMessage = null;
            }
            else if (service == Makolab.Commons.Communication.ServiceType.Sender)
            {
                stats.LastExecutionMessage = null;
                stats.LastReceiveMessage = null;
            }

            return stats;
        }

        public DepartmentStatistics GetFDirectorStatistics(string executorName)
        {
            return new DepartmentStatistics();
        }

        public string GetFDirectorLastExecutionLog(string executorName)
        {
            return String.Empty;
        }

        public LogEntry[] GetLog()
        {
            return new LogEntry[0];
        }

        #endregion
    }
}
