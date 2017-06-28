using System;
using Makolab.SecurityProvider.Interfaces;

namespace Makolab.SecurityProvider
{
    /// <summary>
    /// Class that stores session id in a one static field.
    /// </summary>
    public class StaticSessionIdProvider : ISessionIdProvider
    {
        /// <summary>
        /// Session id.
        /// </summary>
        private static Guid? sessionId;

        #region ISessionIdProvider Members

        /// <summary>
        /// Gets or sets SessionId for current client's request.
        /// </summary>
        /// <value></value>
        public Guid? SessionId
        {
            get { return StaticSessionIdProvider.sessionId; }
            set { StaticSessionIdProvider.sessionId = value; }
        }

        #endregion
    }
}
