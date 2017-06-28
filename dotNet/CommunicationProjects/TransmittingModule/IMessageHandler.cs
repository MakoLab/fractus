using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Interface that must be implemented by classes that handles <see cref="ISynchronizationService"/> requests.
    /// </summary>
    public interface IMessageHandler
    {
        /// <summary>
        /// DataReceived is called when <see cref="ISynchronizationService"/> recives synchronization data.
        /// </summary>
        /// <param name="data">Method params.</param>
        /// <returns>Response to web service client.</returns>
        object DataReceived(object data);

        /// <summary>
        /// DataRequested is called when synchronization data is requested from <see cref="ISynchronizationService"/>.
        /// </summary>
        /// <param name="data">Method params.</param>
        /// <returns>Response to web service client.</returns>
        object DataRequested(object data);

        /// <summary>
        /// Gets the type of the DataReceived parameter.
        /// </summary>
        /// <returns>DataReceived method parameter type</returns>
        Type GetDataReceivedParameterType();

        /// <summary>
        /// Gets the type of the DataRequested parameter.
        /// </summary>
        /// <returns>DataRequested method parameter type.</returns>
        Type GetDataRequestedParameterType();
    }
}
