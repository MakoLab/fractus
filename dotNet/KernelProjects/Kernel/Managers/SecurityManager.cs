using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.HelperObjects;
using Microsoft.IdentityModel.Web;
using Makolab.SecurityProvider;
using Microsoft.IdentityModel.Claims;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;

namespace Makolab.Fractus.Kernel.Managers
{
    /// <summary>
    /// Class authenticating users.
    /// </summary>
    public class SecurityManager
    {
        /// <summary>
        /// Collection of allowed user's language versions.
        /// </summary>
        private string[] allowedLanguages = new string[] { "pl", "en" };

        /// <summary>
        /// Instance of <see cref="SecurityManager"/>.
        /// </summary>
        private static SecurityManager instance = new SecurityManager();

        private AuthenticationHelper auth = new AuthenticationHelper();

        /// <summary>
        /// Gets the instance of <see cref="SecurityManager"/>.
        /// </summary>
        public static SecurityManager Instance
        {
            get { return SecurityManager.instance; }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="SecurityManager"/> class.
        /// </summary>
        private SecurityManager()
        {
            BusinessObject.CacheAllClasses();
        }

        //private static TextWriterTraceListener listener;

        /// <summary>
        /// Performs login operation using specified credentials and reads user's permission.
        /// </summary>
        /// <param name="username">Username.</param>
        /// <param name="password">Password (SHA 256 hash).</param>
        /// <param name="language">User's language version.</param>
        /// <param name="hostAddress">Client's ip address or host name.</param>
        /// <returns>
        /// Created sessionId if successful; otherwise, <see cref="ClientException"/> is thrown.
        /// </returns>
        /// <exception cref="ClientException">InvalidLanguageVersion if supplied language is not supported.</exception>
        /// <exception cref="ClientException">AuthenticationError if supplied username or password is incorrect.</exception>
        public Guid LogOn(string username, string password, string language, string hostAddress)
        {
            /*if (listener != null)
            {
                listener.Flush();
                listener.Close();
                listener = null;
            }
            listener = new TextWriterTraceListener("C:\\Inetpub\\wwwroot\\KernelServices\\Log\\Debug.xml");
            Debug.Listeners.Add(listener);*/
            if (!this.allowedLanguages.Contains(language))
                throw new ClientException(ClientExceptionId.InvalidLanguageVersion);

            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                SecurityMapper mapper = DependencyContainerManager.Container.Get<SecurityMapper>();

                XDocument doc = mapper.GetApplicationUserData(username);

                XElement userElement = doc.Root.Element("applicationUser").Element("entry");

                if (userElement == null || userElement.Element("password") == null || userElement.Element("password").Value.ToUpperInvariant() != password.ToUpperInvariant()) //incorrect username
                    throw new ClientException(ClientExceptionId.AuthenticationError);

                User user = new User(new Guid(userElement.Element("contractorId").Value));

                //generate SessionID
                Guid sessionId = Guid.NewGuid();

                //set sessionId
                SessionManager.SessionId = sessionId;

                //create a new session
                SessionManager.CreateSession();

                //store User object in session
                SessionManager.User = user;

                //set user's language
                SessionManager.Language = language;

                if (hostAddress == null)
                    hostAddress = String.Empty;

                this.LoadUserData(user, userElement);

                var permissions = auth.CreatePrincipal(user.UserId.ToUpperString(), username, AuthenticationMethods.Password);
                user.Principal = permissions;
                System.Threading.Thread.CurrentPrincipal = permissions;

                XDocument xml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<root><host>{0}</host><sessionId>{1}</sessionId></root>", hostAddress, sessionId.ToUpperString()));

                //log the operation
                JournalManager.Instance.LogToJournal(JournalAction.User_LogOn, null, null, null, xml);

                return sessionId;
            }
            finally
            {
                SqlConnectionManager.Instance.ReleaseConnection();
            }
        }

        private void LoadUserData(User user, XElement xml)
        {
            try
            {
                DictionaryMapper.Instance.DictionaryLock.EnterReadLock();
                Branch b = DictionaryMapper.Instance.GetFirstBranchByDatabaseId(ConfigurationMapper.Instance.DatabaseId);

                if (b == null)
                    throw new InvalidOperationException("No branch for the current database id");

				using (ContractorCoordinator cCoord = new ContractorCoordinator(false, false))
				{
					user.UserName = cCoord.LoadBusinessObject<Contractor>(user.UserId).FullName;
				}

                user.BranchId = b.Id.Value;
                user.CompanyId = b.CompanyId;
                user.PermissionProfile = xml.Element("permissionProfile").Value;

                SessionManager.PaymentForDocumentLabel = ConfigurationMapper.Instance.GetConfiguration(user, "document.labels.paymentForDocument").First().Value.Value;
            }
            finally
            {
                DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
            }
        }

        /// <summary>
        /// Performs log off operation for the current user.
        /// </summary>
        public void LogOff()
        {
            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                XDocument xml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<root><sessionId>{0}</sessionId></root>", SessionManager.SessionId.ToUpperString()));

                //log the operation
                JournalManager.Instance.LogToJournal(JournalAction.User_LogOff, null, null, null, xml);
            }
            finally
            {
                SqlConnectionManager.Instance.ReleaseConnection();
            }

            SessionManager.RemoveSession();
        }
    }
}
