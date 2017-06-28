using System;
namespace Makolab.Fractus.Messenger.Providers
{
    public interface IMessageProviderFactory
    {
        IMessageProvider CreateProvider(Makolab.Fractus.Messenger.MessageType messageType);
        log4net.ILog Log { get; set; }
    }
}
