using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Service used to diagnose the state of modules by quering objects state.
    /// </summary>
    [ServiceContract]
    public interface IDiagnosticService
    {
        /// <summary>
        /// Sends the diagnostic request that queries module specified in request.
        /// </summary>
        /// <param name="request">The request.</param>
        /// <returns>Diagnostic query response.</returns>
        [OperationContract]
        string Query(string request);
    }
}
