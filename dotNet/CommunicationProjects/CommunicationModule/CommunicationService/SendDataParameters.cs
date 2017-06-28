using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using Makolab.Commons.Communication;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Class that encapsulates parameters of SendData web service method.
    /// </summary>
    [DataContract]
    public class SendDataParameters
    {
        /// <summary>
        /// Gets or sets the object representing XML.
        /// </summary>
        /// <value>The XML.</value>
        [DataMember(IsRequired = true)]
        public XmlTransferObject Xml { get; set; }

        /// <summary>
        /// Gets or sets department identifier.
        /// </summary>
        [DataMember(IsRequired = true)]
        public Guid DepartmentIdentifier { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Xml is last in transaction.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if Xml is last in transaction; otherwise, <c>false</c>.
        /// </value>
        [DataMember(IsRequired = true)]
        public bool IsLastInTransaction { get; set; }

        /// <summary>
        /// Gets or sets the communication statistics.
        /// </summary>
        /// <value>The communication statistics.</value>
        [DataMember(IsRequired = false)]
        public CommunicationStatistics Statistics { get; set; }
    }
}
