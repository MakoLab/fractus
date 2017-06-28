using System;
using log4net;
namespace Makolab.Fractus.Messenger.Providers
{
    public class MessageProviderFactory : IMessageProviderFactory
    {
        IMessageProvider email;
        IMessageProvider sms;

        public ILog Log { get; set; }

        public MessageProviderFactory(MessengerConfiguration configuration, ILog logger)
        {
            this.Log = logger;

            if (configuration.MailServer != null)
            {
                var emailProvider = new EmailProvider();
                emailProvider.Initialize(configuration.MailServer);
                emailProvider.Log = logger;
                this.email = emailProvider;
            }
            else this.email = new NullMessageProvider();

            if (configuration.SmsServiceProvider != null)
            {
                var smsProvider = GetSmsProvider(configuration.SmsServiceProvider);
                smsProvider.Initialize(configuration.SmsServiceParameters, configuration.BeginSmsTransmissionPeriod, configuration.EndSmsTransmissionPeriod);
                smsProvider.Log = logger;
                this.sms = smsProvider;
            }
            else this.sms = new NullMessageProvider();
        }

        public IMessageProvider CreateProvider(MessageType messageType)
        {
            switch (messageType)
            {
                case MessageType.Unknown:
                    throw new ArgumentException("Nieobs³ugiwany typ wiadomoœci");
                case MessageType.Email:
                case MessageType.HtmlEmail:
                    return this.email;
                case MessageType.Sms:
                    return this.sms;
                default:
                    throw new ArgumentException("Nieobs³ugiwany typ wiadomoœci");
            }
        }

        private SmsProvider GetSmsProvider(string providerName)
        {
            var className = "Makolab.Fractus.Messenger.Providers." + providerName.Substring(0, 1).ToUpperInvariant() + providerName.Substring(1) + "Provider";
            var classType = Type.GetType(className);
            return Activator.CreateInstance(classType) as SmsProvider;
        }
    }

}