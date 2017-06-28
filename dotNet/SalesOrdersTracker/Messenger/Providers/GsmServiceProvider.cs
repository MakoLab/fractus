using System.Collections.Generic;
using System;
using System.Net;
using System.IO;
using System.Web;

namespace Makolab.Fractus.Messenger.Providers
{
    public class GsmServiceProvider : SmsProvider
    {
        private string getMessageStatusTemplate = "https://api.gsmservice.pl/getstatus.php?login={login}&pass={password}&msgid={msgid}";
        const string COUNTRY_CODE = "48";

        public GsmServiceProvider()
        {
            this.UrlTemplate = "https://api.gsmservice.pl/send.php?login={login}&pass={password}&recipient={recipient}&text={message}&type={smsType}&sender={sender}";
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="configuration"></param>
        public override void Initialize(Dictionary<string, string> configuration, TimeSpan beginSmsTransmissionPeriod, TimeSpan endSmsTransmissionPeriod)
        {
            // TODO czy to czasem nie powinno byc w klasie bazowej??
            foreach (var pair in configuration)
            {
                configuration[pair.Key] = HttpUtility.UrlEncode(pair.Value);
            }

            base.Initialize(configuration, beginSmsTransmissionPeriod, endSmsTransmissionPeriod);
            this.getMessageStatusTemplate = FillTemplate(this.getMessageStatusTemplate, configuration);
        }


        /// <summary>
        /// Sends the message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <remarks>
        /// Numer telefonu odbiorcy, pod kt�ry SMS ma zosta� wys�any. UWAGA! 
        /// Koniecznie w postaci mi�dzynarodowej z kodem kraju na pocz�tku (bez znaku +) np. 48601444555
        /// </remarks>
        public override void SendMessage(Message message)
        {
            message.Sender = COUNTRY_CODE + message.Sender;
            base.SendMessage(message);
        }

        protected override void SetMessageState(string result, Message message)
        {
            SetMessageState(result, message, 0);
        }

        private void SetMessageState(string result, Message message, int numberOfRequests)
        {
            var results = result.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
            var msgid = results.Length > 1 ? results[1] : null;

            message.State = MessageState.Failed;
            switch (results[0])
            {
                case "000":
                    message.Error = "Brak wystarczaj�cych �rodk�w na koncie w Bramce SMS";
                    break;
                case "001":
                    message.Error = "B��d techniczny w sk�adni SMSa";
                    break;
                case "002":
                    message.Error = "SMS nie zosta� wys�any";
                    break;
                case "003":
                    message.State = MessageState.Send;
                    break;
                case "004":
                    message.Error = "Sie�, do kt�rej pr�bowano wys�a� SMSa jest obecnie niedost�pna lub wpisano nieprawidlowy numer bez kierunku kraju";
                    break;
                case "005":
                    message.Error = "Numer odbiorcy jest nieprawid�owy";
                    break;
                case "006":
                    message.Error = "Brak tre�ci SMSa";
                    break;
                case "007":
                    message.Error = "Problem z dor�czeniem SMSa (abonent ma wy��czony telefon, jest poza zasi�giem sieci, jego numer zosta� przeniesiony lub jego skrzynka odbiorcza jest przepe�niona itp.)";
                    break;
                case "008":
                    message.Error = "Nieprawid�owy Login lub/i has�o do subkonta API";
                    break;
                case "009":
                    message.Error = "Nieprawid�owy rodzaj SMSa";
                    break;
                case "010":
                    CheckMessageState(message, msgid, numberOfRequests);
                    break;
                case "011":
                    CheckMessageState(message, msgid, numberOfRequests);
                    break;
                case "012":
                    message.Error = "Wiadomo�� anulowana przez u�ytkownika";
                    break;
                case "013":
                    message.State = MessageState.Send;
                    break;
                case "200":
                    message.State = MessageState.Send;
                    break;
                case "201":
                    message.State = MessageState.Send;
                    break;
                case "202":
                    message.Error = "Linia odbiorcy by�a zaj�ta. FAX nie zosta� wys�any.";
                    break;
                case "203":
                    message.Error = "Brak sygna�u faksu. Prawdopodobnie pod podanym numerem nie pracuje fax.";
                    break;
                case "204":
                    message.Error = "Nie uda�o si� odebra� informacji o rezultacie wysy�ania faksu.";
                    break;
                case "205":
                    message.Error = "Po��czenie nie zosta�o odebrane.";
                    break;
                case "206":
                    message.Error = "Zbyt niska jako�� po��czenia ze strony odbiorcy nie pozwala na wysy�k� faksu pod ten numer. Faks wysy�aj�cy nie rozpocz�� transmisji obrazu.";
                    break;
                case "207":
                    message.Error = "Faks zosta� cz�ciowo wys�any. Przetransmitowano tylko cze�� stron gdy� po��czenie zosta�o przerwane.";
                    break;
                case "208":
                    message.Error = "B��d protoko�u. FAX nie zosta� wys�any.";
                    break;
                case "209":
                    message.Error = "Faks wysy�aj�cy i odbieraj�cy nie uzgodni�y opcji transmisji.";
                    break;
                case "210":
                    CheckMessageState(message, msgid, numberOfRequests);
                    break;
                case "211":
                    message.Error = "Wyst�pi� nieoczekiwany b��d. Wiadomo�� nie zosta�a wys�ana.";
                    break;
                case "212":
                    CheckMessageState(message, msgid, numberOfRequests);
                    break;
                case "213":
                    message.Error = "Nieprawid�owy plik PDF";
                    break;
                case "300":
                    message.State = MessageState.Send;
                    break;
                case "301":
                    message.Error = "B��d w ��daniu";
                    break;
                default:
                    message.Error = "nieznany b��d";
                    break;
            }

        }

        private void CheckMessageState(Message message, string msgid, int numberOfRequests)
        {
            if (numberOfRequests > 3 || msgid == null)
            {
                message.State = MessageState.Failed;
                message.Error = "Nie uda�o si� pobra� statusu wiadomo�ci";
            }
            else
            {
                ++numberOfRequests;
                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(this.getMessageStatusTemplate.Replace("{msgid}", msgid));
                HttpWebResponse response = (HttpWebResponse)req.GetResponse();
                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    SetMessageState(GetStringFromReader(reader), message, numberOfRequests);
                }
            }
        }

    }

}