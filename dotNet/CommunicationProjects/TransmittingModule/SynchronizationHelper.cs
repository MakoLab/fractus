using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel.Channels;
using System.Reflection;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Helps to encapsulate data in <see cref="Message"/> object and retrives data from <see cref="Message"/> object.
    /// </summary>
    public class SynchronizationHelper
    {
        /// <summary>
        /// Creates the <see cref="Message"/> from specified parameters.
        /// </summary>
        /// <param name="data">The <see cref="Message"/> data.</param>
        /// <param name="method">The <see cref="Message"/> method.</param>
        /// <returns>Created <see cref="Message"/>.</returns>
        public static Message CreateMessage(object data, string method, MessageVersion messageVersion)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SynchronizationHelper::CreateMessage(object data, string method, MessageVersion messageVersion)");
            if (data == null) return null;

            return Message.CreateMessage(messageVersion, "http://tempuri.org/ISynchronizationService/" + method, data);        
        }

        /// <summary>
        /// Gets the data from specified <see cref="Message"/> object.
        /// </summary>
        /// <typeparam name="T">Type of returned object with data.</typeparam>
        /// <param name="data">The <see cref="Message"/> with data.</param>
        /// <returns>Object with data.</returns>
        public static T GetData<T>(Message data)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("SynchronizationHelper::T GetData<T>(Message data)");
            using (data)
            {
                if (data == null) return default(T);

                if (data.IsFault == true)
                {
                    MessageFault fault = MessageFault.CreateFault(data, 500000);
                    if (fault.HasDetail)
                    {
                        System.ServiceModel.ExceptionDetail excDet = fault.GetDetail<System.ServiceModel.ExceptionDetail>();
                        Type excType = String.IsNullOrEmpty(excDet.Type) ? null : Type.GetType(excDet.Type);
                        Exception e = (excType == null) ? new Exception() : (Exception)Activator.CreateInstance(excType);

                        FieldInfo innerExceptionField = typeof(Exception).GetField("_innerException", BindingFlags.NonPublic | BindingFlags.Instance);
                        FieldInfo messageField = typeof(Exception).GetField("_message", BindingFlags.NonPublic | BindingFlags.Instance);
                        FieldInfo stackTraceField = typeof(Exception).GetField("_remoteStackTraceString", BindingFlags.NonPublic | BindingFlags.Instance);
                        innerExceptionField.SetValue(e, excDet.InnerException);
                        messageField.SetValue(e, excDet.Message);
                        stackTraceField.SetValue(e, excDet.StackTrace);
                        throw e;
                    }
                }

                return data.GetBody<T>();            
            }
        }
    }
}
