using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;

namespace Makolab.Fractus.Printing
{
    [Serializable]
    public class CrossDomainXmlProviderSectionHandler : IConfigurationSectionHandler
    {
        #region IConfigurationSectionHandler Members

        public object Create(object parent, object configContext, System.Xml.XmlNode section)
        {
            if (section.Attributes["port"] == null) throw new ConfigurationErrorsException("port attribute not specified in crossDomainXmlProvider configuration section.");
            else return Int32.Parse(section.Attributes["port"].Value);
        }

        #endregion
    }
}