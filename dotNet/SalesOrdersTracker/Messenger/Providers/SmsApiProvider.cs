using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using System;
using System.IO;

namespace Makolab.Fractus.Messenger.Providers
{
    public class SmsApiProvider : SmsProvider
    {

        public SmsApiProvider() : this(false)
        {

        }

        public SmsApiProvider(bool isDebugMode)
        {
            var debugElements = "&test=1&details=1";
            this.UrlTemplate = "https://ssl.smsapi.pl/sms.do?username={login}&password={password}&to={recipient}&eco={smsType}&from={sender}&message={message}";

            if (isDebugMode == true) this.UrlTemplate += debugElements;
        }

        public override void Initialize(Dictionary<string, string> configuration, TimeSpan beginSmsTransmissionPeriod, TimeSpan endSmsTransmissionPeriod)
        {
            configuration["password"] = CreateMd5Hash(configuration["password"]);
            base.Initialize(configuration, beginSmsTransmissionPeriod, endSmsTransmissionPeriod);
        }

        /// <summary>
        /// Sets the state of the message.
        /// </summary>
        /// <param name="result">The result.</param>
        /// <param name="message">The message.</param>
        /// <remarks>
        /// Wysy�anie sms-ow za pomoca smsapi.pl funkcja zwraca OK w przypadku powodzenia wys�ania b�dz w przypadku niepowaodzenia komunikat b��du:
        /// 11 Zbyt d�uga lub brak wiadomo�ci lub ustawiono parametr nounicode i pojawi�y si� znaki specjalne w wiadomo�ci
        /// 12 Wiadomo�� zawiera ponad 160 znak�w (gdy u�yty parametr &single=1)
        /// 13 Nieprawid�owy numer odbiorcy
        /// 14 Nieprawid�owe pole nadawcy
        /// 17 Nie mo�na wys�a� FLASH ze znakami specjalnymi
        /// 18 Nieprawid�owa liczba parametr�w
        /// 19 Za du�o wiadomo�ci w jednym odwo�aniu (maksymalnie 100)
        /// 20 Nieprawid�owa liczba parametr�w IDX
        /// 21 Wiadomo�� MMS ma za du�y rozmiar (maksymalnie 100kB)
        /// 22 B��dny format SMIL
        /// 101 Niepoprawne lub brak danych autoryzacji
        /// 102 Nieprawid�owy login lub has�o
        /// 103 Brak punk�w dla tego u�ytkownika
        /// 104 Brak szablonu
        /// 105 B��dny adres IP (w��czony filtr IP dla interfejsu API)
        /// 200 Nieudana pr�ba wys�ania wiadomo�ci
        /// 300 Nieprawid�owa warto�� pola points (przy u�yciu pola points jest wymagana warto�� 1)
        /// 301 ID wiadomo�ci nie istnieje
        /// 400 Nieprawid�owy ID statusu wiadomo�ci
        /// 999 Wewn�trzny b��d systemu (prosimy zg�osi�)
        /// </remarks>
        protected override void SetMessageState(string result, Message message)
        {
            StringReader reader = new StringReader(result);
            string line = null;
            bool? isMessageSend = null;
            string errorCode = null;
            do
            {
                line = reader.ReadLine();
                if (line.StartsWith("OK")) isMessageSend = true;
                else if (line.StartsWith("ERROR"))
                {
                    isMessageSend = false;
                    errorCode = line.Split(new string[] {":"}, StringSplitOptions.RemoveEmptyEntries)[1];
                }

            } while (line != null && isMessageSend.HasValue == false);

            if (isMessageSend == true) message.State = MessageState.Send;
            else if (isMessageSend == false)
            {
                message.State = MessageState.Failed;
                switch (errorCode)
                {
                    case "11":
                        message.Error = "Zbyt d�uga lub brak wiadomo�ci lub ustawiono parametr nounicode i pojawi�y si� znaki specjalne w wiadomo�ci";
                        break;
                    case "12":
                        message.Error = "Wiadomo�� zawiera ponad 160 znak�w (gdy u�yty parametr &single=1)";
                        break;
                    case "13":
                        message.Error = "Nieprawid�owy numer odbiorcy";
                        break;
                    case "14":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid�owe pole nadawcy";
                        break;
                    case "17":
                        message.Error = "Nie mo�na wys�a� FLASH ze znakami specjalnymi";
                        break;
                    case "18":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid�owa liczba parametr�w";
                        break;
                    case "19":
                        message.State = MessageState.Retry;
                        message.Error = "Za du�o wiadomo�ci w jednym odwo�aniu (maksymalnie 100)";
                        break;
                    case "20":
                        message.Error = "Nieprawid�owa liczba parametr�w IDX";
                        break;
                    case "21":
                        message.Error = "Wiadomo�� MMS ma za du�y rozmiar (maksymalnie 100kB)";
                        break;
                    case "22":
                        message.Error = "B��dny format SMIL";
                        break;
                    case "101":
                        message.State = MessageState.Retry;
                        message.Error = "Niepoprawne lub brak danych autoryzacji";
                        break;
                    case "102":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid�owy login lub has�o";
                        break;
                    case "103":
                        message.State = MessageState.Retry;
                        message.Error = "Brak punk�w dla tego u�ytkownika";
                        break;
                    case "104":
                        message.State = MessageState.Retry;
                        message.Error = "Brak szablonu";
                        break;
                    case "105":
                        message.State = MessageState.Retry;
                        message.Error = "B��dny adres IP (w��czony filtr IP dla interfejsu API)";
                        break;
                    case "200":
                        message.Error = "Nieudana pr�ba wys�ania wiadomo�ci";
                        break;
                    case "300":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid�owa warto�� pola points (przy u�yciu pola points jest wymagana warto�� 1)";
                        break;
                    case "301":
                        message.Error = "ID wiadomo�ci nie istnieje";
                        break;
                    case "400":
                        message.Error = "Nieprawid�owy ID statusu wiadomo�ci";
                        break;
                    case "999":
                        message.State = MessageState.Retry;
                        message.Error = "Wewn�trzny b��d systemu (prosimy zg�osi�) na www.smsapi.pl";
                        break;
                    default:
                        message.Error = String.Format("Nieznany kod b��du: {0}", errorCode);
                        break;
                }
            }
            else
            {
                message.State = MessageState.Failed;
                message.Error = String.Format("Nieznany format odpowiedzi od serwisu SmsApi: {0}", result);         
            }
        }

        private string CreateMd5Hash(string input)
        {
            // Create a new instance of the MD5CryptoServiceProvider object.
            MD5 md5Hasher = MD5.Create();

            // Convert the input string to a byte array and compute the hash.
            byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(input));
            return data.ToHexString();
        }
    }

}