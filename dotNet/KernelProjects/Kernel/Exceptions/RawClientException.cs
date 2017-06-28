using System;
using System.Runtime.Serialization;

namespace Makolab.Fractus.Kernel.Exceptions
{
    [Serializable]
    public class RawClientException : Exception
    {
        public RawClientException()
        { }

        public RawClientException(string message)
            : base(message)
        { }

        protected RawClientException(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
        }

        public override string ToString()
        {
            string label = "RawClientException: " + this.Message.ToString();

            return label;
        }
    }
}
