using System;
namespace Makolab.Fractus.Messenger
{
    public interface IMessageMapper
    {
        Message Get();
        void Update(Message message);
    }
}
