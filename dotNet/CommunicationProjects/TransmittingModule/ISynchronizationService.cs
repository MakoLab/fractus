using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.ServiceModel.Channels;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Web service that is responsible for data transmission between callers.
    /// </summary>
    [ServiceContract]
    public interface ISynchronizationService
    {
        /// <summary>
        /// Web method that is called when synchronization data is requested from <b>ISynchronizationService</b>.
        /// </summary>
        /// <param name="data">The method params.</param>
        /// <returns>Generic response.</returns>
        [OperationContract]
        Message GetData(Message data);

        /// <summary>
        /// Web method that is called when synchronization data is send to <b>ISynchronizationService</b>.
        /// </summary>
        /// <param name="data">The method params.</param>
        /// <returns>Generic response.</returns>
        [OperationContract]
        Message SendData(Message data);
    }
}
