using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Defines interfaces that every HostingService module must implement.
    /// Hosting service module is a independant application that is hosted by HostingService in separate <see cref="AppDomain"/>.
    /// </summary>
    public interface IModule
    {
        /// <summary>
        /// Called when module is started.
        /// </summary>
        void OnStartModule();

        /// <summary>
        /// Called when module is stopped.
        /// </summary>
        void OnStopModule();

        /// <summary>
        /// Called when diagnose is performed on module.
        /// </summary>
        /// <param name="request">The diagnostic request.</param>
        /// <returns></returns>
        string OnDiagnose(string request);
    }
}
