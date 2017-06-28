using System;
using System.Threading;
using Makolab.SecurityProvider.Interfaces;

namespace Makolab.SecurityProvider
{
    /// <summary>
    /// Class that stores SessionId from every client in current thread's DataSlot.
    /// </summary>
    public class ThreadSlotSessionIdProvider : ISessionIdProvider
    {
        #region ISessionIDProvider Members

        /// <summary>
        /// Gets or sets SessionId for current client's request.
        /// </summary>
        public Guid? SessionId
        {
            get { return (Guid?)Thread.GetData(Thread.GetNamedDataSlot("SessionId")); }
            set { Thread.SetData(Thread.GetNamedDataSlot("SessionId"), value); }
        }

        #endregion
    }
}
