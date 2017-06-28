using System.Collections.Generic;

namespace Makolab.SecurityProvider.Interfaces
{
    public delegate void SessionExpiredDelegate<T>(ICollection<T> sessionIdentifiers);

    /// <summary>
    /// Provides the capabilities for basic session operations.
    /// </summary>
    /// <typeparam name="T">Type of session's key.</typeparam>
    public interface ISession<T>
    {
        /// <summary>
        /// Occurs when session expired.
        /// </summary>
        event SessionExpiredDelegate<T> SessionExpired;

        /// <summary>
        /// Gets an object from session.
        /// </summary>
        /// <param name="sessionId">User's SessionId indicating whose session to store in.</param>
        /// <param name="key">The key whose value to get.</param>
        /// <returns>The value for specified key. Returns <c>null</c> if the specified key doesn't exist.</returns>
        /// <exception cref="ClientException">Session expired.</exception>
        object GetData(T sessionId, string key);

        /// <summary>
        /// Stores an object in session.
        /// </summary>
        /// <param name="sessionId">User's SessionId indicating whose session to store in.</param>
        /// <param name="key">The key of the element to add or modify.</param>
        /// <param name="value">The value of the element to add or modify.</param>
        /// <exception cref="ClientException">Session expired.</exception>
        void SetData(T sessionId, string key, object value);

        /// <summary>
        /// Updates user's LastAccessTime.
        /// </summary>
        /// <param name="sessionId">User's SessionId.</param>
        /// <returns>
        /// <c>true</c> if the session exists and LastAccessTime was updated successfully; otherwise, <c>false</c>.
        /// </returns>
        bool UpdateLastAccessTime(T sessionId);

        /// <summary>
        /// Removes a specified session.
        /// </summary>
        /// <param name="sessionId">SessionId indicating which session to remove.</param>
        void RemoveSession(T sessionId);

        /// <summary>
        /// Creates a new session.
        /// </summary>
        /// <param name="sessionId">SessionId for the new session.</param>
        void CreateSession(T sessionId);
    }
}
