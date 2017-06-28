using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using Makolab.SecurityProvider.Interfaces;
using Makolab.SecurityProvider.Exceptions;

namespace Makolab.SecurityProvider
{
    /// <summary>
    /// Creates a session whose backing store is memory.
    /// </summary>
    /// <typeparam name="T">Type of session's key</typeparam>
    public class MemorySession<T> : ISession<T>, IDisposable
    {
        /// <summary>
        /// An entry for session. Contains user's last access time and his objects. One instance of this class is stored for every session.
        /// </summary>
        private class MemorySessionEntry
        {
            /// <summary>
            /// User's last access time.
            /// </summary>
            public DateTime LastAccessTime
            { get; set; }

            /// <summary>
            /// Collection of user's objects.
            /// </summary>
            public Dictionary<string, object> SessionObjects
            { get; set; }

            /// <summary>
            /// Initializes a new instance of the <see cref="MemorySession&lt;T&gt;"/> class and automatically sets <see cref="LastAccessTime"/> to present time.
            /// </summary>
            public MemorySessionEntry()
            {
                this.LastAccessTime = DateTime.Now;
                this.SessionObjects = new Dictionary<string, object>();
            }
        }

        /// <summary>
        /// List used by the <see cref="cleanerThread"/> for temporary storing session to remove.
        /// </summary>
        private List<T> expiredEntries = new List<T>();

        /// <summary>
        /// Occurs when session expired.
        /// </summary>
        public event SessionExpiredDelegate<T> SessionExpired;

        /// <summary>
        /// All active session entries.
        /// </summary>
        private Dictionary<T, MemorySessionEntry> activeEntries = new Dictionary<T, MemorySessionEntry>();
        
        /// <summary>
        /// Thread that periodically checks for expired sessions and removes them.
        /// </summary>
        private Thread cleanerThread;

        /// <summary>
        /// Shared lock used to synchronize all threads using the current <see cref="MemorySession&lt;T&gt;"/> object.
        /// </summary>
        private ReaderWriterLockSlim slimLock;

        /// <summary>
        /// Gets the value that indicates whether <see cref="Dispose(bool)"/> has been called.
        /// </summary>
        private bool isDisposed = false;

        /// <summary>
        /// Specifies how much time should elapse before an unused session entry will be considered as expired.
        /// </summary>
        private int sessionTimeoutInMinutes;

        /// <summary>
        /// Initializes a new instance of the <see cref="MemorySession&lt;T&gt;"/> class specyfing how much time should elapse before an unused session entry will be considered as expired.
        /// </summary>
        /// <param name="sessionTimeoutInMinutes">Specifies how much time should elapse before an unused session entry will be considered as expired.</param>
        /// <param name="desktopMode">if set to <c>true</c> desktop mode will be on so sessions will never expire.</param>
        public MemorySession(int sessionTimeoutInMinutes, bool desktopMode)
        {
            this.sessionTimeoutInMinutes = sessionTimeoutInMinutes;
            this.slimLock = new ReaderWriterLockSlim();

            if (!desktopMode && this.sessionTimeoutInMinutes > 0)
            {
                this.cleanerThread = new Thread(new ThreadStart(this.ClearExpired));
                this.cleanerThread.IsBackground = true;
                this.cleanerThread.Start();
            }
        }

        /// <summary>
        /// Updates user's LastAccessTime.
        /// </summary>
        /// <param name="sessionId">User's SessionId.</param>
        /// <returns>
        /// <c>true</c> if the session exists and LastAccessTime was updated successfully; otherwise, <c>false</c>.
        /// </returns>
        public bool UpdateLastAccessTime(T sessionId)
        {
            this.slimLock.EnterReadLock();

            try
            {
                //search for entry
                foreach (T key in this.activeEntries.Keys)
                {
                    if (key.Equals(sessionId))
                    {
                        this.activeEntries[key].LastAccessTime = DateTime.Now;
                        return true;
                    }
                }

                return false;
            }
            finally
            {
                this.slimLock.ExitReadLock();
            }
        }

        /// <summary>
        /// Stores an object in session.
        /// </summary>
        /// <param name="sessionId">User's SessionId indicating whose session to store in.</param>
        /// <param name="key">The key of the element to add or modify.</param>
        /// <param name="value">The value of the element to add or modify.</param>
        /// <exception cref="ClientException">Session expired.</exception>
        public void SetData(T sessionId, string key, object value)
        {
            this.slimLock.EnterReadLock();

            try
            {
                //MemorySessionEntry exists
                if (this.activeEntries.ContainsKey(sessionId))
                {
                    MemorySessionEntry entry = this.activeEntries[sessionId];
                    //Overwrite if object already exist
                    if (entry.SessionObjects.ContainsKey(key))
                        entry.SessionObjects[key] = value;
                    else //add new object to the SessionObjects collection
                        entry.SessionObjects.Add(key, value);
                }
                else
                    throw new SessionExpiredException();
            }
            finally
            {
                this.slimLock.ExitReadLock();
            }
        }

        /// <summary>
        /// Gets an object from session.
        /// </summary>
        /// <param name="sessionId">User's SessionId indicating whose session to store in.</param>
        /// <param name="key">The key whose value to get.</param>
        /// <returns>The value for specified key. Returns <c>null</c> if the specified key doesn't exist.</returns>
        /// <exception cref="ClientException">Session expired.</exception>
        public object GetData(T sessionId, string key)
        {
            this.slimLock.EnterReadLock();

            try
            {
				if (this.activeEntries.ContainsKey(sessionId))
				{
					MemorySessionEntry entry = this.activeEntries[sessionId];
					entry.LastAccessTime = DateTime.Now;

					if (entry.SessionObjects.ContainsKey(key))
						return entry.SessionObjects[key];
					else
						return null;
				}
				else
					throw new SessionExpiredException();
            }
            finally
            {
                this.slimLock.ExitReadLock();
            }
        }

        /// <summary>
        /// Method used by the <see cref="cleanerThread"/> that periodically looks for expired sessions and removes them.
        /// </summary>
        private void ClearExpired()
        {
            while (true)
            {
                this.slimLock.EnterUpgradeableReadLock();
                
                try
                {
                    int sessionTimeout = this.sessionTimeoutInMinutes;

                    Debug.WriteLine("SessionCleaner: Searching for expired sessions...");
                    //process all active entries
                    foreach(T key in this.activeEntries.Keys)
                    {
                        TimeSpan span = DateTime.Now - this.activeEntries[key].LastAccessTime;

                        if (span.TotalMinutes >= sessionTimeout)
                        {
                            this.expiredEntries.Add(key);
                        }
                    }

                    //remove timeout entries
                    if (this.expiredEntries.Count > 0)
                    {
                        this.slimLock.EnterWriteLock();

                        try
                        {
                            List<T> expiredKeys = new List<T>();

                            foreach (T key in this.expiredEntries)
                            {
                                Debug.WriteLine("SessionCleaner: Removing expired session: "+key.ToString());

                                //the entry could be removed after the search process, but before now
                                if (this.activeEntries.ContainsKey(key))
                                {
                                    this.activeEntries.Remove(key);
                                    expiredKeys.Add(key);
                                }
                            }

                            //fire event asynchronously
                            foreach (Delegate del in this.SessionExpired.GetInvocationList())
                            {
                                SessionExpiredDelegate<T> listener = (SessionExpiredDelegate<T>)del;
                                listener.BeginInvoke(expiredKeys, null, null);
                            }

                            this.expiredEntries.Clear();
                        }
                        finally
                        {
                            this.slimLock.ExitWriteLock();
                        }
                    }
                }
                finally
                {
                    this.slimLock.ExitUpgradeableReadLock();
                }

                Debug.WriteLine("SessionCleaner: Sleeping...");
                //sleep for 1 minute(larger values will speed up the session)
                Thread.Sleep((int)TimeSpan.FromMinutes(1).TotalMilliseconds);
            }

        }

        /// <summary>
        /// Removes a specified session.
        /// </summary>
        /// <param name="sessionId">SessionId indicating which session to remove.</param>
        public void RemoveSession(T sessionId)
        {
            this.slimLock.EnterWriteLock();

            try
            {
                if (this.activeEntries.ContainsKey(sessionId))
                    this.activeEntries.Remove(sessionId);
            }
            finally
            {
                this.slimLock.ExitWriteLock();
            }
        }

        /// <summary>
        /// Creates a new session.
        /// </summary>
        /// <param name="sessionId">SessionId for the new session.</param>
        public void CreateSession(T sessionId)
        {
            this.slimLock.EnterWriteLock();

            try
            {
                //register new session
                this.activeEntries.Add(sessionId, new MemorySessionEntry());
            }
            finally
            {
                this.slimLock.ExitWriteLock();
            }
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="MemorySession&lt;T&gt;"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (!this.isDisposed)
            {
                if (disposing)
                {
                    //Dispose only managed resources here

                    //terminate cleanerThread if it's sleeping
                    if (this.cleanerThread != null)
                    {
                        this.cleanerThread.Abort();
                        this.cleanerThread.Join();
                    }

                    this.activeEntries.Clear();
                    this.activeEntries = null;

                    this.expiredEntries.Clear();
                    this.expiredEntries = null;
                }
            }
            // Code to dispose the unmanaged resources 
            // held by the class
            this.isDisposed = true;
        }

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion
    }

}
