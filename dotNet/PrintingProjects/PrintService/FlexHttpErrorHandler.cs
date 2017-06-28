using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel.Channels;

namespace Makolab.Fractus.Printing
{
    class FlexHttpErrorHandler : System.ServiceModel.Dispatcher.IErrorHandler
    {
        public bool HandleError(Exception error)
        {
            return false;
        }

        public void ProvideFault(Exception error, MessageVersion version, ref Message fault)
        {
            if (fault != null)
            {
                HttpResponseMessageProperty properties = new HttpResponseMessageProperty();
                properties.StatusCode = System.Net.HttpStatusCode.OK;
                fault.Properties.Add(HttpResponseMessageProperty.Name, properties);
            }
        }
    }
}
