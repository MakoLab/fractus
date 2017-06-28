using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;

namespace Makolab.Fractus.Messenger
{
    public class MessengerSectionHandler : IConfigurationSectionHandler
    {
        #region IConfigurationSectionHandler Members

        public object Create(object parent, object configContext, System.Xml.XmlNode section)
        {
            MessengerConfiguration cfg = new MessengerConfiguration();
            
            cfg.RetrieveMessageInterval = Convert.ToInt32(GetAttribute("retrieveMessageInterval", section, "60000"));
            cfg.RetryInterval = Convert.ToInt32(GetAttribute("retryInterval", section, "3000"));
            cfg.SendInterval = Convert.ToInt32(GetAttribute("sendInterval", section, "3000"));
            cfg.RetryLimit = Convert.ToInt32(GetAttribute("retryLimit", section, "3"));
            cfg.ReloadMessageLimit = Convert.ToInt32(GetAttribute("reloadMessageLimit", section, "20"));
            cfg.BeginSmsTransmissionPeriod = TimeSpan.Parse(GetAttribute("beginSmsTransmisionPeriod", section, "08:00"));
            cfg.EndSmsTransmissionPeriod = TimeSpan.Parse(GetAttribute("endSmsTransmisionPeriod", section, "22:00"));
            cfg.SmsServiceProvider = GetAttribute("smsServiceProvider", section, null);
            cfg.SmsServiceParameters = GetProviderConfiguration(section.SelectSingleNode("smsProvider"));
            cfg.MailServer = GetMailServerConfiguration(section.SelectSingleNode("mailServer"));

            //REQUIRED
            cfg.GetMessageStoredProcedure = GetAttribute("getMessageSP", section);
			cfg.GetMessageAttachmentsStoredProcedure = GetAttribute("getMessageAttachmentsSP", section);
            cfg.SetMessageTransmissionSuccessStoredProcedure = GetAttribute("setSuccessSP", section);
            cfg.SetMessageTransmissionErrorStoredProcedure = GetAttribute("setErrorSP", section);
            cfg.ServiceName = GetAttribute("name", section);

            if (ConfigurationManager.ConnectionStrings["messengerDB"] == null) throw new ConfigurationErrorsException("Nie zdefiniowano połączenia do bazy o nazwie messengerDB");
            else cfg.MessageDBConnectionString = ConfigurationManager.ConnectionStrings["messengerDB"].ConnectionString;

            return cfg;
        }

        #endregion

        private MailServerConfiguration GetMailServerConfiguration(System.Xml.XmlNode xmlNode)
        {
            if (xmlNode == null) return null;

            var mailCfg = new MailServerConfiguration();
            mailCfg.Account = GetAttribute("account", xmlNode);
            mailCfg.Password = GetAttribute("password", xmlNode);
            mailCfg.SMTP = GetAttribute("smtp", xmlNode);
            mailCfg.Port = Convert.ToInt32(GetAttribute("port", xmlNode, "25"));
            mailCfg.UseSSL = Convert.ToBoolean(GetAttribute("useSSL", xmlNode, "false"));

            return mailCfg;
        }

        private Dictionary<string, string> GetProviderConfiguration(System.Xml.XmlNode xmlNode)
        {
            var providerParams = new Dictionary<string, string>();
            if (xmlNode == null) return providerParams;
            foreach (System.Xml.XmlNode property in xmlNode.SelectNodes("property"))
            {
                providerParams.Add(GetAttribute("name", property), GetAttribute("value", property));
            }
            return providerParams;
        }

        private string GetAttribute(string attributeName, System.Xml.XmlNode section)
        {
            var attrib = section.Attributes[attributeName];
            if (attrib == null) throw new ConfigurationErrorsException(String.Format("Brak parametru konfiguracji {0}", attributeName));
            else return attrib.Value;
        }

        private string GetAttribute(string attributeName, System.Xml.XmlNode section, string defaultValue)
        {
            var attrib = section.Attributes[attributeName];
            if (attrib == null) return defaultValue;
            else return attrib.Value;
        }
    }
}
