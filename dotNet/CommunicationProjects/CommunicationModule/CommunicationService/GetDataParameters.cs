namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Runtime.Serialization;

    /// <summary>
    /// Class that represents 
    /// </summary>
    [DataContract]
    public class GetDataParameters
    {
        /// <summary>
        /// Gets or sets the last received XML id.
        /// </summary>
        /// <value>The last received XML id.</value>
        [DataMember(IsRequired = false)]
        public Guid? LastReceivedXmlId { get; set; }

        /// <summary>
        /// Gets or sets the database identifier
        /// </summary>
        /// <value>The database id.</value>
        [DataMember(IsRequired = false)]
        public Guid DatabaseId { get; set; }
    }
}
