namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Runtime.Serialization;

    [DataContract]
    public class LogEntry
    {
        [DataMember(IsRequired = true)]
        public int Id { get; set; }

        [DataMember(IsRequired = true)]
        public DateTime? Date { get; set; }

        [DataMember(IsRequired = false)]
        public string Service { get; set; }

        [DataMember(IsRequired = false)]
        public Guid? RequestId { get; set; }

        [DataMember(IsRequired = true)]
        public string Level { get; set; }

        [DataMember(IsRequired = false)]
        public string Message { get; set; }

        [DataMember(IsRequired = true)]
        public string State { get; set; }

        [DataMember(IsRequired = false)]
        public string Source { get; set; }

        [DataMember(IsRequired = false)]
        public string SourceParameters { get; set; }

        [DataMember(IsRequired = false)]
        public string Exception { get; set; }
    }
}
