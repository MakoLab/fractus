using log4net;
namespace Makolab.Fractus.Messenger.Providers
{
    public interface IMessageProvider
    {
        void SendMessage(Message message);
    }
}