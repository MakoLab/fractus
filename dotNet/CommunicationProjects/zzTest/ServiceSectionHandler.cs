using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;

namespace Makolab.Fractus.Communication
{
    public class ServiceSectionHandler : IConfigurationSectionHandler
    {
        public string ServiceName {get; set;}

        #region IConfigurationSectionHandler Members

        public object Create(object parent, object configContext, System.Xml.XmlNode section)
        {
            
            ServiceName = section.Attributes["Name"].InnerText;
            return this;
        }

        #endregion
    }
}
