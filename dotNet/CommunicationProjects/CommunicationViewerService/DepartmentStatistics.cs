using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;
using Makolab.Commons.Communication;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Communication statistics of department.
    /// </summary>
    [DataContract]
    public class DepartmentStatistics : CommunicationStatistics
    {
        /// <summary>
        /// Gets or sets amount of waiting packages.
        /// </summary>
        /// <value>The packages to receive.</value>
        [DataMember(IsRequired = false)]
        public int PackagesToReceive { get; set; }

        /// <summary>
        /// Gets or sets the last receive time.
        /// </summary>
        /// <value>The last receive time.</value>
        [DataMember(IsRequired = false)]
        public DateTime? LastReceiveTime { get; set; }

        /// <summary>
        /// Gets or sets the statistics last update time.
        /// </summary>
        /// <value>The statistics last update time.</value>
        [DataMember(IsRequired = false)]
        public DateTime StatisticsUpdateTime { get; set; }

        /// <summary>
        /// Gets or sets the communication last send time.
        /// </summary>
        /// <value>The communication last send time.</value>
        [DataMember(IsRequired = false)]
        public DateTime? LastSendTime { get; set; }

        /// <summary>
        /// Returns the text/xml reprezentation of object.
        /// </summary>
        /// <returns>Data serialized to custom xml format.</returns>
        public override string ToString()
        {
            string packagesToReceiveType = typeof(int).Name;
            string lastReceiveTimeType = typeof(DateTime).Name;
            string statisticsUpdateTimeType = typeof(DateTime).Name;
            string lastSendTimeType = typeof(MessageData).Name;
            return base.ToString() + String.Format(CultureInfo.InvariantCulture, 
                    "<PackagesToReceive type='{0}'>{1}</PackagesToReceive><LastReceiveTime type='{2}'>{3}</LastReceiveTime><StatisticsUpdateTime type='{4}'>{5}</StatisticsUpdateTime><LastSendTime type='{6}'>{7}</LastSendTime>",
                    packagesToReceiveType, PackagesToReceive, lastReceiveTimeType, LastReceiveTime, statisticsUpdateTimeType, StatisticsUpdateTime, lastSendTimeType, LastSendTime);
        }
    }
}
