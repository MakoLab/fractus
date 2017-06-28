using System.Collections.Generic;

namespace Makolab.Fractus.Messenger.Providers
{
    public class EsemeserProvider : SmsProvider
    {
        public EsemeserProvider()
        {
            UrlTemplate = "http://www.esemeser.pl/0api/wyslij.php?konto={account}&login={login}&haslo={password}&rodzaj={smsType}&nazwa={recipient}&telefon={recipient}&tresc={message}";
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="result"></param>
        /// <param name="message"></param>
        /// <remarks>
        /// Zwraca rezulatat zapytania do konta w systemie esemeser.pl         
        ///   – -1  - nie istnieje konto o podanej nazwie
        ///   – -2 - konto istnieje ale login i/lub has³o s¹ b³êdne
        ///   – -3 - podany numer nie jest numerem na telefon komórkowy
        ///   – OK -  wiadomoœæ zosta³a przyjêta do wysy³ki.
        ///   – NIE - wiadomoœæ nie zosta³a wys³ana
        /// </remarks>
        protected override void SetMessageState(string result, Message message)
        {
            switch (result)
            {
                case "-1":
                    message.State = MessageState.Retry;
                    message.Error = "Nie istnieje konto o podanej nazwie";
                    break;
                case "-2":
                    message.State = MessageState.Retry;
                    message.Error = "Konto istnieje ale login i/lub has³o s¹ b³êdne";
                    break;
                case "-3":
                    message.State = MessageState.Failed;
                    message.Error = "Podany numer nie jest numerem na telefon komórkowy";
                    break;
                case "OK":
                    message.State = MessageState.Send;
                    break;
                case "NIE":
                    message.State = MessageState.Failed;
                    message.Error = "Wiadomoœæ nie zosta³a wys³ana.";
                    break;
                default:
                    message.State = MessageState.Failed;
                    message.Error = "Nieznany B³¹d.";
                    break;
            }            
        }
    }

}