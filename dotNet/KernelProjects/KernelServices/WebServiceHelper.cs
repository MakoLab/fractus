using System;
using System.Diagnostics;
using System.Globalization;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.Threading;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.Services
{
    /// <summary>
    /// Helper class that contains common methods used by the services exposed as a web service.
    /// </summary>
    public class WebServiceHelper : ServiceHelper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="WebServiceHelper"/> class.
        /// </summary>
        public WebServiceHelper()
            : base()
        {
        }

        /// <summary>
        /// Gets the client address (ip address or host name).
        /// </summary>
        /// <returns>Client IP address or hostname.</returns>
        protected override string GetHostAddress()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("WebServiceHelper:GetHostAddress()");
            if (OperationContext.Current == null)
                return "internal";

            MessageProperties messageProperties = OperationContext.Current.IncomingMessageProperties;
            RemoteEndpointMessageProperty endpointProperty = messageProperties[RemoteEndpointMessageProperty.Name] as RemoteEndpointMessageProperty;
            string ipAddress = endpointProperty.Address + ":" + endpointProperty.Port;

            return ipAddress;
        }

        /// <summary>
        /// Gets the client language version.
        /// </summary>
        /// <returns>Client language version.</returns>
        protected override string GetClientLanguageVersion()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("WebServiceHelper:GetClientLanguageVersion()");
			if (OperationContext.Current != null)
			{
				HttpRequestMessageProperty httpRequestProperty = (HttpRequestMessageProperty)OperationContext.Current.IncomingMessageProperties[HttpRequestMessageProperty.Name];
				string userLang = httpRequestProperty.Headers["Accept-Language"];

				if (userLang != null)
					userLang = userLang.Split('-')[0];

				return userLang;
			}
			else
				return "pl";
        }

        /// <summary>
        /// Method invoked on every wrapper method exit.
        /// </summary>
        public override void OnExit()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("WebServiceHelper:OnExit()");
            try
            {
                Debug.WriteLine("-=-=Thread " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture) + " has enter OnExit()");
				//Try log test data
                // REFACTORINDICATOR
				//TestRecorderManager.Instance.LogTestStep();

                //if OneTimeSession then perform logout
                if (SessionManager.OneTimeSession)
                    SecurityManager.Instance.LogOff();

				SessionManager.ResetVolatileContainer();
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:700");
                ServiceHelper.Instance.OnException(ex);
            }
        }

        /// <summary>
        /// Method invoked on every wrapper method entry.
        /// </summary>
        public override void OnEntry()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("WebServiceHelper:OnEntry()");
            try
            {
				SessionManager.ResetVolatileContainer();
				Debug.WriteLine("-=-=Thread " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture) + " has enter OnEntry()");
				HttpRequestMessageProperty httpRequestProperty = (HttpRequestMessageProperty)OperationContext.Current.IncomingMessageProperties[HttpRequestMessageProperty.Name];
                string sessionId = httpRequestProperty.Headers["SessionId"];

                if (sessionId == null)
                {
                    string username = httpRequestProperty.Headers["Username"];
                    string password = httpRequestProperty.Headers["Password"];
                    string language = httpRequestProperty.Headers["Language"];
                    string profile = httpRequestProperty.Headers["Profile"];

                    //if OneTimeSession then perform login
                    if (username != null && password != null && language != null)
                    {
                        ServiceHelper.Instance.LogOn(username, password, language, profile);

                        SessionManager.OneTimeSession = true;

                        Thread.CurrentPrincipal = SessionManager.User.Principal;
                    }
                    else
                        throw new ClientException(ClientExceptionId.NoSessionId);
                }
                else
                {
                    try
                    {
                        Guid sessionGuid = new Guid(sessionId);

                        //save sessionId in current thread's DataSlot
                        SessionManager.SessionId = sessionGuid;
                        Thread.CurrentPrincipal = SessionManager.User.Principal;
                    }
                    catch (FormatException)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:701");
                        throw new ClientException(ClientExceptionId.SessionExpired);
                    }
                    catch (OverflowException)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:702");
                        throw new ClientException(ClientExceptionId.SessionExpired);
                    }

                    //update LastAccessTime in current user's session
                    if (!SessionManager.UpdateLastAccessTime())
                    {
                        SessionManager.SessionId = null;
                        throw new ClientException(ClientExceptionId.SessionExpired);
                    }
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:709");
                ServiceHelper.Instance.OnException(ex);
            }
        }

        public override void OnEntryMock()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("WebServiceHelper:OnEntry()");
            try
            {
                SessionManager.ResetVolatileContainer();
                Debug.WriteLine("-=-=Thread " + Thread.CurrentThread.ManagedThreadId.ToString(CultureInfo.InvariantCulture) + " has enter OnEntry()");
                HttpRequestMessageProperty httpRequestProperty = (HttpRequestMessageProperty)OperationContext.Current.IncomingMessageProperties[HttpRequestMessageProperty.Name];
                string sessionId = httpRequestProperty.Headers["SessionId"];

                if (sessionId == null)
                {
                    string username = httpRequestProperty.Headers["Username"];
                    string password = httpRequestProperty.Headers["Password"];
                    string language = httpRequestProperty.Headers["Language"];
                    string profile = httpRequestProperty.Headers["Profile"];

                    //if OneTimeSession then perform login
                    if (username != null && password != null && language != null)
                    {
                        ServiceHelper.Instance.LogOn(username, password, language, profile);

                        SessionManager.OneTimeSession = true;

                        Thread.CurrentPrincipal = SessionManager.User.Principal;
                    }
                    else
                        throw new ClientException(ClientExceptionId.NoSessionId);
                }
                else
                {
                    try
                    {
                        Guid sessionGuid = new Guid(sessionId);

                        //save sessionId in current thread's DataSlot
                        SessionManager.SessionId = sessionGuid;
                        Thread.CurrentPrincipal = SessionManager.User.Principal;
                    }
                    catch (FormatException)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:701");
                        throw new ClientException(ClientExceptionId.SessionExpired);
                    }
                    catch (OverflowException)
                    {
                        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:702");
                        throw new ClientException(ClientExceptionId.SessionExpired);
                    }

                    //update LastAccessTime in current user's session
                    if (!SessionManager.UpdateLastAccessTime())
                    {
                        SessionManager.SessionId = null;
                        throw new ClientException(ClientExceptionId.SessionExpired);
                    }
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:709");
                ServiceHelper.Instance.OnException(ex);
            }
        }
    }
}
