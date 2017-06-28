using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Linq;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Service used to diagnose the state of modules by quering objects state.
    /// </summary>
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    public class DiagnosticService : IDiagnosticService
    {
        private ICollection<ExternalModule> modules;
        private HostingServiceController host;

        /// <summary>
        /// Initializes a new instance of the <see cref="DiagnosticService"/> class.
        /// </summary>
        /// <param name="modules">The of hosting service modules.</param>
        /// <param name="host">The hosting service controller.</param>
        public DiagnosticService(ICollection<ExternalModule> modules, HostingServiceController host)
        {
            this.modules = modules;
            this.host = host;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DiagnosticService"/> class.
        /// </summary>
        public DiagnosticService()
        {

        }

        /// <summary>
        /// Sends the diagnostic request that queries module specified in request.
        /// </summary>
        /// <param name="request">The request.</param>
        /// <returns>Queried object response.</returns>
        public string Query(string request)
        {
            try
            {
                string response = null;
                string[] queryParts = request.Split(new char[] { '.' }, 2);

                if (queryParts[0] == "host")
                {
                    return host.OnDiagnose(request);
                }
                else
                {
                    IModule module = this.GetModule(queryParts[0]);

                    if (module != null) response = module.OnDiagnose(queryParts[1]);
                    else throw new ModuleNotFoundException("Module '" + queryParts[0] + "' not found.", queryParts[0]);

                    return response; 
                }
            }
            catch (Exception e)
            {
                return "<error><![CDATA[" + e.ToString() + "]]></error>";
            }
        }

        /// <summary>
        /// Gets the specified module.
        /// </summary>
        /// <param name="moduleName">Name of the module.</param>
        /// <returns></returns>
        private IModule GetModule(string moduleName)
        {
            return (from module in this.modules where module.Info.Name == moduleName select module.Instance).FirstOrDefault();
        }
    }
}
