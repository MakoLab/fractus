using System;
using System.Globalization;
using System.Net;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.Services
{
    /// <summary>
    /// Helper class that contains common methods used by the services exposed as a desktop application.
    /// </summary>
    public class DesktopServiceHelper : ServiceHelper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="DesktopServiceHelper"/> class.
        /// </summary>
        public DesktopServiceHelper() : base()
        { }

        /// <summary>
        /// Gets the client address (ip address or host name).
        /// </summary>
        /// <returns>Client IP address or hostname.</returns>
        protected override string GetHostAddress()
        {
            return Dns.GetHostName();
        }

        /// <summary>
        /// Gets the client language version.
        /// </summary>
        /// <returns>Client language version.</returns>
        protected override string GetClientLanguageVersion()
        {
            return CultureInfo.CurrentCulture.TwoLetterISOLanguageName;
        }

        /// <summary>
        /// Method invoked on every wrapper method exit.
        /// </summary>
        public override void OnExit()
        {
            try
            {
                SessionManager.ResetVolatileContainer();
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:127");
                ServiceHelper.Instance.OnException(ex);
            }
        }

        /// <summary>
        /// Method invoked on every wrapper method entry.
        /// </summary>
        public override void OnEntry()
        { }

        /// <summary>
        /// Method invoked on every wrapper method entry.
        /// </summary>
        public override void OnEntryMock()
        { }
    }
}
