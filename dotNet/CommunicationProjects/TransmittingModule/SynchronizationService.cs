using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.ServiceModel.Channels;
using System.Configuration;
using System.Xml;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Web service that is responsible for data transmission between branches.
    /// </summary>
    public class SynchronizationService : ISynchronizationService
    {
        readonly IMessageHandler requestHandler;

        /// <summary>
        /// Initializes a new instance of the <see cref="SynchronizationService"/> class.
        /// </summary>
        public SynchronizationService()
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SynchronizationService:SynchronizationService()");
            HandlerInfo handler = ConfigurationManager.GetSection("messageHandler") as HandlerInfo;
            requestHandler = (IMessageHandler) Activator.CreateInstance(handler.AssemblyName, handler.TypeName).Unwrap();
        }

        #region ISynchronizationService Members

        /// <summary>
        /// Web method that is called when synchronization data is requested from <b>ISynchronizationService</b>.
        /// </summary>
        /// <param name="data">The method params.</param>
        /// <returns>Generic response.</returns>
        public Message GetData(Message data)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SynchronizationService:GetData(Message data)");
            DataContractSerializer serializer = new DataContractSerializer(requestHandler.GetDataRequestedParameterType());
            using (XmlDictionaryReader reader = data.GetReaderAtBodyContents())
            using (data)
            {
                object objData = serializer.ReadObject(reader);
                object result = requestHandler.DataRequested(objData);
                return Message.CreateMessage(data.Version, "http://tempuri.org/ISynchronizationService/GetDataResponse", result);
            }
        }

        /// <summary>
        /// Web method that is called when synchronization data is send to <b>ISynchronizationService</b>.
        /// </summary>
        /// <param name="data">The method params.</param>
        /// <returns>Generic response.</returns>
        public Message SendData(Message data)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SynchronizationService:SendData(Message data)");
            DataContractSerializer serializer = new DataContractSerializer(requestHandler.GetDataReceivedParameterType());
            using (XmlDictionaryReader reader = data.GetReaderAtBodyContents())
            using (data)
            {
                object objData = serializer.ReadObject(reader);
                object result = requestHandler.DataReceived(objData);
                return Message.CreateMessage(data.Version, "http://tempuri.org/ISynchronizationService/SendDataResponse", result);
            }
        }

        #endregion
    }
}
