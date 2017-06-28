using System;
using System.Collections.Generic;
using System.Configuration;
using System.Threading;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.HelperObjects;
using Makolab.SecurityProvider.Interfaces;
using Makolab.SecurityProvider;
using Makolab.SecurityProvider.Exceptions;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Managers
{
    /// <summary>
    /// Wrapper class for ISession classes exposing a session ready for use.
    /// </summary>
    public static class SessionManager
    {
        /// <summary>
        /// Specifies how much time should elapse before an unused session entry will be considered as expired.
        /// </summary>
        private static int sessionTimeoutInMinutes;
        
        /// <summary>
        /// Session provider.
        /// </summary>
        private static ISession<Guid> session;

        /// <summary>
        /// A place to store SessionID for each client.
        /// </summary>
        private static ISessionIdProvider sessionIdProvider;

        /// <summary>
        /// Gets or sets SessionId for current client request.
        /// </summary>
        public static Guid? SessionId
        {
            get { return SessionManager.sessionIdProvider.SessionId; }
            set { SessionManager.sessionIdProvider.SessionId = value; }
        }

        #region User's session objects
        /// <summary>
        /// Gets or sets User object in session.
        /// </summary>
        public static User User
        {
            get { return (User)SessionManager.GetData("User"); }
            set { SessionManager.SetData("User", value); }
        }

        public static string PaymentForDocumentLabel
        {
            get { return (string)SessionManager.GetData("PaymentForDocumentLabel"); }
            set { SessionManager.SetData("PaymentForDocumentLabel", value); }
        }

		public static string Profile
		{
			get { return (string)SessionManager.GetData("Profile"); }
			set { SessionManager.SetData("Profile", value); }
		}

		public static string ProfileId
		{
			get { return (string)SessionManager.GetData("ProfileId"); }
			set { SessionManager.SetData("ProfileId", value); }
		}

        /// <summary>
        /// Gets or sets user's language version.
        /// </summary>
        public static string Language
        {
            get { return (string)SessionManager.GetData("Language"); }
            set { SessionManager.SetData("Language", value); }
        }

        /// <summary>
        /// Gets or sets the volatile elements that are restored to its default values on each client request.
        /// </summary>
        /// <value>The volatile elements.</value>
        public static VolatileContainer VolatileElements
        {
            get
            {
                object obj = Thread.GetData(Thread.GetNamedDataSlot("VolatileElements"));

                if (obj == null)
                {
                    VolatileContainer c = new VolatileContainer();
                    Thread.SetData(Thread.GetNamedDataSlot("VolatileElements"), c);
                    return c;
                }
                else
                    return (VolatileContainer)obj;
            }
            set { Thread.SetData(Thread.GetNamedDataSlot("VolatileElements"), value); }
        }

        /// <summary>
        /// Gets or sets the value indicating whether this session is one time session and therefore it should be removed at the end of client's request.
        /// </summary>
        public static bool OneTimeSession
        {
            get
            {
                object obj = SessionManager.GetData("OneTimeSession");

                return obj == null ? false : (bool)obj; //default value is false
            }
            set { SessionManager.SetData("OneTimeSession", value); }
        }
        #endregion

        /// <summary>
        /// Initializes the <see cref="SessionManager"/> class.
        /// </summary>
        static SessionManager()
        {
            FractusKernelSectionHandler handler = (FractusKernelSectionHandler)ConfigurationManager.GetSection("fractusKernel");
            SessionManager.sessionTimeoutInMinutes = handler.SessionTimeout;
            bool desktopMode = handler.DesktopMode;

            SessionManager.sessionIdProvider = CreateSessionIdProvider(desktopMode);

            SessionManager.session = CreateSession(desktopMode);
            SessionManager.session.SessionExpired += new SessionExpiredDelegate<Guid>(OnSessionExpired);
        }

        private static ISessionIdProvider CreateSessionIdProvider(bool desktopMode)
        {
            var kernelCfg = ConfigurationManager.GetSection("fractusKernel") as FractusKernelSectionHandler;

            if (kernelCfg.SessionIdProviderType != null) return Activator.CreateInstance(kernelCfg.SessionIdProviderAssembly, kernelCfg.SessionIdProviderType).Unwrap() as ISessionIdProvider;
            else if (desktopMode) return new StaticSessionIdProvider();
            else return new ThreadSlotSessionIdProvider();
        }

        private static ISession<Guid> CreateSession(bool desktopMode)
        {
            var kernelCfg = ConfigurationManager.GetSection("fractusKernel") as FractusKernelSectionHandler;

            if (kernelCfg.SessionType != null) return Activator.CreateInstance(kernelCfg.SessionAssembly, kernelCfg.SessionType).Unwrap() as ISession<Guid>;
            else return new MemorySession<Guid>(SessionManager.sessionTimeoutInMinutes, desktopMode);

        }

        /// <summary>
        /// On session expired event handler.
        /// </summary>
        /// <param name="sessionIdentifiers">Collection of expired session identifiers.</param>
        private static void OnSessionExpired(ICollection<Guid> sessionIdentifiers)
        {
            //zakomentowalem bo i tak z journala sie nie korzysta a tutaj wystepuje problem ze w pozniejszym odwolaniu LogToJournal jest pobieranie z sesji
            //userId i sie wywala bo tej sesji nei ma wiec trzebaby to przerobic, no ale nie ma czasu, wiadomo, sa inne rzeczy do zrobienia
            /*SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                foreach (Guid id in sessionIdentifiers)
                {
                    XDocument xml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                        "<root><sessionId>{0}</sessionId></root>", id.ToUpperString()));

                    //log the operation
                    JournalManager.Instance.LogToJournal(JournalAction.User_LogOff, null, null, null, xml);
                }
            }
            finally
            {
                SqlConnectionManager.Instance.ReleaseConnection();
            }*/
        }

        /// <summary>
        /// Resets the volatile container to its initial state.
        /// </summary>
        public static void ResetVolatileContainer()
        {
            Thread.SetData(Thread.GetNamedDataSlot("VolatileElements"), new VolatileContainer());
        }

        /// <summary>
        /// Gets an object from current user's session.
        /// </summary>
        /// <param name="key">The key whose value to get.</param>
        /// <returns>The value for specified key. Returns <c>null</c> if the specified key doesn't exist.</returns>
        /// <exception cref="ClientException">Session expired.</exception>
        private static object GetData(string key)
        {
			try
			{
				return SessionManager.session.GetData(SessionManager.SessionId.Value, key);
			}
			catch (SessionExpiredException sessExp)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:104");
				throw new ClientException(ClientExceptionId.SessionExpired, sessExp, null);
			}
        }

        /// <summary>
        /// Stores an object in current user's session.
        /// </summary>
        /// <param name="key">The key of the element to add or modify.</param>
        /// <param name="val">The value of the element to add or modify.</param>
        /// <exception cref="ClientException">Session expired.</exception>
        private static void SetData(string key, object val)
        {
			try
			{
				SessionManager.session.SetData(SessionManager.SessionId.Value, key, val);
			}
			catch (SessionExpiredException sessEx)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:105");
				throw new ClientException(ClientExceptionId.SessionExpired, sessEx, null);
			}
        }

        /// <summary>
        /// Updates user's LastAccessTime.
        /// </summary>
        /// <returns>
        /// <c>true</c> if the session exists and LastAccessTime was updated successfully; otherwise, <c>false</c>.
        /// </returns>
        public static bool UpdateLastAccessTime()
        {
            return SessionManager.session.UpdateLastAccessTime(SessionManager.SessionId.Value);
        }

        /// <summary>
        /// Removes current user's session.
        /// </summary>
        internal static void RemoveSession()
        {
            SessionManager.session.RemoveSession(SessionManager.SessionId.Value);
        }

        /// <summary>
        /// Creates a new session for current user.
        /// </summary>
        internal static void CreateSession()
        {
            SessionManager.session.CreateSession(SessionManager.SessionId.Value);
        }
    }

}
