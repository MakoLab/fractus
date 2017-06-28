using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel.Channels;
using System.Text;

namespace Makolab.Fractus.Kernel.Services
{
    public class FormContentTypeMapper : System.ServiceModel.Channels.WebContentTypeMapper
    {
            public override WebContentFormat GetMessageFormatForContentType(string contentType)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FormContentTypeMapper:GetMessageFormatForContentType(string contentType)");
                if (contentType.Contains("x-www-form-urlencoded"))
                {
                    return WebContentFormat.Raw;
                }
                else
                {
                    return WebContentFormat.Default;
                }
            }
    }
}
