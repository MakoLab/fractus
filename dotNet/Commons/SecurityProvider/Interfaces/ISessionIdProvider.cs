using System;

namespace Makolab.SecurityProvider.Interfaces
{
    /// <summary>
    /// Provides the capabilities for storing SessionId from every client.
    /// </summary>
    public interface ISessionIdProvider
    {
        /// <summary>
        /// Gets or sets SessionId for current client's request.
        /// </summary>
        Guid? SessionId
        { get; set; }
    }
}
