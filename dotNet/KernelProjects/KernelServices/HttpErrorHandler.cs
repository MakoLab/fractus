using System;
using System.Net;
using System.ServiceModel.Channels;
using System.ServiceModel.Dispatcher;

namespace Makolab.Fractus.Kernel.Services
{
    class HttpErrorHandler : IErrorHandler
    {
        public bool HandleError(Exception error)
        {             
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("HttpErrorHandler:HandleError(Exception error)");
            return false;
        }

        public void ProvideFault(Exception error, MessageVersion version, ref Message fault)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Debug("HttpErrorHandler:ProvideFault(Exception error, MessageVersion version, ref Message fault)");
            if (fault != null)
            {
                HttpResponseMessageProperty properties = new HttpResponseMessageProperty();
                properties.StatusCode = HttpStatusCode.OK;
                fault.Properties.Add(HttpResponseMessageProperty.Name, properties);
            }
        }
    }
}
