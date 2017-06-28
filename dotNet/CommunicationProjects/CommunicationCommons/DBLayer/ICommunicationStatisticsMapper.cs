using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

namespace Makolab.Commons.Communication.DBLayer
{
    public interface ICommunicationStatisticsMapper
    {
        IDatabaseConnectionManager Database { get; }
        IDbTransaction Transaction { get; set; }

        void UpdateStatistics(CommunicationStatistics statistics, Guid departmentId);
        System.Xml.Linq.XDocument GetAdditionalData(string procedureName);
    }
}
