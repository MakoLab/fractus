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
        /// Wysy³anie sms-ow za pomoca smsapi.pl funkcja zwraca OK w przypadku powodzenia wys³ania b¹dz w przypadku niepowaodzenia komunikat b³êdu:
        /// 11 Zbyt d³uga lub brak wiadomoœci lub ustawiono parametr nounicode i pojawi³y siê znaki specjalne w wiadomoœci
        /// 12 Wiadomoœæ zawiera ponad 160 znaków (gdy u¿yty parametr &single=1)
        /// 13 Nieprawid³owy numer odbiorcy
        /// 14 Nieprawid³owe pole nadawcy
        /// 17 Nie mo¿na wys³aæ FLASH ze znakami specjalnymi
        /// 18 Nieprawid³owa liczba parametrów
        /// 19 Za du¿o wiadomoœci w jednym odwo³aniu (maksymalnie 100)
        /// 20 Nieprawid³owa liczba parametrów IDX
        /// 21 Wiadomoœæ MMS ma za du¿y rozmiar (maksymalnie 100kB)
        /// 22 B³êdny format SMIL
        /// 101 Niepoprawne lub brak danych autoryzacji
        /// 102 Nieprawid³owy login lub has³o
        /// 103 Brak punków dla tego u¿ytkownika
        /// 104 Brak szablonu
        /// 105 B³êdny adres IP (w³¹czony filtr IP dla interfejsu API)
        /// 200 Nieudana próba wys³ania wiadomoœci
        /// 300 Nieprawid³owa wartoœæ pola points (przy u¿yciu pola points jest wymagana wartoœæ 1)
        /// 301 ID wiadomoœci nie istnieje
        /// 400 Nieprawid³owy ID statusu wiadomoœci
        /// 999 Wewnêtrzny b³¹d systemu (prosimy zg³osiæ)
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
                        message.Error = "Zbyt d³uga lub brak wiadomoœci lub ustawiono parametr nounicode i pojawi³y siê znaki specjalne w wiadomoœci";
                        break;
                    case "12":
                        message.Error = "Wiadomoœæ zawiera ponad 160 znaków (gdy u¿yty parametr &single=1)";
                        break;
                    case "13":
                        message.Error = "Nieprawid³owy numer odbiorcy";
                        break;
                    case "14":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid³owe pole nadawcy";
                        break;
                    case "17":
                        message.Error = "Nie mo¿na wys³aæ FLASH ze znakami specjalnymi";
                        break;
                    case "18":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid³owa liczba parametrów";
                        break;
                    case "19":
                        message.State = MessageState.Retry;
                        message.Error = "Za du¿o wiadomoœci w jednym odwo³aniu (maksymalnie 100)";
                        break;
                    case "20":
                        message.Error = "Nieprawid³owa liczba parametrów IDX";
                        break;
                    case "21":
                        message.Error = "Wiadomoœæ MMS ma za du¿y rozmiar (maksymalnie 100kB)";
                        break;
                    case "22":
                        message.Error = "B³êdny format SMIL";
                        break;
                    case "101":
                        message.State = MessageState.Retry;
                        message.Error = "Niepoprawne lub brak danych autoryzacji";
                        break;
                    case "102":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid³owy login lub has³o";
                        break;
                    case "103":
                        message.State = MessageState.Retry;
                        message.Error = "Brak punków dla tego u¿ytkownika";
                        break;
                    case "104":
                        message.State = MessageState.Retry;
                        message.Error = "Brak szablonu";
                        break;
                    case "105":
                        message.State = MessageState.Retry;
                        message.Error = "B³êdny adres IP (w³¹czony filtr IP dla interfejsu API)";
                        break;
                    case "200":
                        message.Error = "Nieudana próba wys³ania wiadomoœci";
                        break;
                    case "300":
                        message.State = MessageState.Retry;
                        message.Error = "Nieprawid³owa wartoœæ pola points (przy u¿yciu pola points jest wymagana wartoœæ 1)";
                        break;
                    case "301":
                        message.Error = "ID wiadomoœci nie istnieje";
                        break;
                    case "400":
                        message.Error = "Nieprawid³owy ID statusu wiadomoœci";
                        break;
                    case "999":
                        message.State = MessageState.Retry;
                        message.Error = "Wewnêtrzny b³¹d systemu (prosimy zg³osiæ) na www.smsapi.pl";
                        break;
                    default:
                        message.Error = String.Format("Nieznany kod b³êdu: {0}", errorCode);
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