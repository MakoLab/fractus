using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Messenger.Providers
{
    public class NullMessageProvider : IMessageProvider
    {
        #region IMessageProvider Members

        public void SendMessage(Message message)
        {
            throw new System.Configuration.ConfigurationErrorsException(String.Format("Nie skonfigurowano dostawcy wiadomości typu {0}", message.Type));
        }

        #endregion
    }
}
