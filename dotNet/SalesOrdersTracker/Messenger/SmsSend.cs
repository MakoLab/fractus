using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;
using System.Xml.Linq;
using System.Xml;
using System.Net;
using System.IO;


namespace Makolab.Fractus.Messenger
{
    class SmsSend
    {
        //Logger log = new Logger();
        //private static readonly ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private string fromMessage = "Makolab"; // do konfiguracji
        private string smsTypeSmsApi = "1"; //do konfiguracji sprawdzic w dokumentacji jakie sa opcje
        private string passSmsApi = "";
        private string loginSmsApi = "bemek";
        private string smsTypeEsemeser = "eco"; //do konfiguracji sprawdzic w dokumentacji jakie sa opcje
        private string passEsemeser = "";
        private string loginEsemeser = "bemek";
        private string smsTypeGsmService = "eco"; //do konfiguracji sprawdzic w dokumentacji jakie sa opcje
        private string passGsmService = "";
        private string loginGsmService = "bemek";
        /*
         * 
         * 
         * 
         * 
         * smsApi.pl
         * 
         * 
         * 
         * 
         */
        /*  Wysyłanie sms-ow za pomoca smsapi.pl funkcja zwraca OK w przypadku powodzenia wysłania bądz w przypadku niepowaodzenia komunikat błędu:
         *  11 Zbyt długa lub brak wiadomości lub ustawiono parametr nounicode i
            pojawiły się znaki specjalne w wiadomości
            12 Wiadomość zawiera ponad 160 znaków (gdy użyty parametr &single=1)
            13 Nieprawidłowy numer odbiorcy
            14 Nieprawidłowe pole nadawcy
            17 Nie można wysłać FLASH ze znakami specjalnymi
            18 Nieprawidłowa liczba parametrów
            19 Za dużo wiadomości w jednym odwołaniu (maksymalnie 100)
            20 Nieprawidłowa liczba parametrów IDX
            21 Wiadomość MMS ma za duży rozmiar (maksymalnie 100kB)
            22 Błędny format SMIL
            101 Niepoprawne lub brak danych autoryzacji
            102 Nieprawidłowy login lub hasło
            103 Brak punków dla tego użytkownika
            104 Brak szablonu
            105 Błędny adres IP (włączony filtr IP dla interfejsu API)
            200 Nieudana próba wysłania wiadomości
            300 Nieprawidłowa wartość pola points (przy użyciu pola points jest
            wymagana wartość 1)
            301 ID wiadomości nie istnieje
            400 Nieprawidłowy ID statusu wiadomości
            999 Wewnętrzny błąd systemu (prosimy zgłosić)
         */

        //wysyla sms-y za pomoca serwisu sms-api zwraca kod bledu lub OK jesli zostalo wyslane, wewnatrz wywolywana jest funkcja ktora zwraca zapytanie zwrocone przez serwer
        public string sendBySMSApi(string recipient, string sender, string message)
        {
            string s = resultSendBySMSApi(recipient, sender, message);
            
            string[] statement = s.Split(':');
            foreach (string word in statement)
            {
                Console.WriteLine(word);
            }
            switch (statement[0])
            {
                case "OK":
                    Console.WriteLine("Wyslano");
                    //log.infoLog("SMS na numer " + recipient + " został poprawnie wysłany poprzez smsapi");
                    return statement[0];
                case "ERROR":
                    switch (statement[1])
                    {
                        case "11":
                            return "Zbyt długa lub brak wiadomości lub ustawiono parametr nounicode i pojawiły się znaki specjalne w wiadomości";
                        case "12":
                            return "Wiadomość zawiera ponad 160 znaków (gdy użyty parametr &single=1)";
                        case "13":
                            return "Nieprawidłowy numer odbiorcy";
                        case "14":
                            return "Nieprawidłowe pole nadawcy";
                        case "17":
                            return "Nie można wysłać FLASH ze znakami specjalnymi";
                        case "18":
                            return "Nieprawidłowa liczba parametrów";
                        case "19":
                            return "Za dużo wiadomości w jednym odwołaniu (maksymalnie 100)";
                        case "20":
                            return "Nieprawidłowa liczba parametrów IDX";
                        case "21":
                            return "Wiadomość MMS ma za duży rozmiar (maksymalnie 100kB)";
                        case "22":
                            return "Błędny format SMIL";
                        case "101":
                            return "Niepoprawne lub brak danych autoryzacji";
                        case "102":
                            return "Nieprawidłowy login lub hasło";
                        case "103":
                            return "Brak punków dla tego użytkownika";
                        case "104":
                            return "Brak szablonu";
                        case "105":
                            return "Błędny adres IP (włączony filtr IP dla interfejsu API)";
                        case "200":
                            return "Nieudana próba wysłania wiadomości";
                        case "300":
                            return "Nieprawidłowa wartość pola points (przy użyciu pola points jest wymagana wartość 1)";
                        case "301":
                            return "ID wiadomości nie istnieje";
                        case "400":
                            return "Nieprawidłowy ID statusu wiadomości";
                        case "999":
                            return "Wewnętrzny błąd systemu (prosimy zgłosić) na www.smsapi.pl";

                    }
                    break;
            }
            return "Bład w funkcji sendBySMSApi";
        }
        //zwraca zapytanie zwrocone przez serwer
        private string resultSendBySMSApi(string recipient, string sender, string message)
        {
                
            HttpWebRequest req = (HttpWebRequest)
                WebRequest.Create("http://api.smsapi.pl/send.do?username="+loginSmsApi+"&password=" + getMd5Hash(passSmsApi) + "&to=" + recipient + "&eco="+smsTypeSmsApi+"&message=" + message ); //w wersji ostatecznej usunac z adresu koncowke &test=1
           


            HttpWebResponse response = (HttpWebResponse)req.GetResponse();
            StreamReader reader = new StreamReader(response.GetResponseStream());
            string str = reader.ReadLine();

            return str;
        }



        /*
         * 
         * 
         * 
         * 
         * ESEMESER
         * 
         * 
         * 
         * 
         */
        //wysyla sms-y za pomoca serwisu esmemser zwraca kod bledu lub OK jesli zostalo wyslane, wewnatrz wywolywana jest funkcja ktora zwraca zapytanie zwrocone przez serwer
        public string sendByEsemeser(string recipient, string sender, string message)
        {
            string eMessage = "";
            //MessengerWindowsService.service = new MessengerWindowsService();
            string result = resultSendMessageToPhoneByEsemeser(recipient, sender, message);
            switch (result)
            {
                case "-1":
                    eMessage = "Nie istnieje konto o podanej nazwie";
                    break;
                case "-2":
                    eMessage = "Konto istnieje ale login i/lub hasło są błędne";
                    break;
                case "-3":
                    eMessage = "Podany numer nie jest numerem na telefon komórkowy";
                    break;
                case "OK":
                    eMessage = "OK";
                    break;
                case "NIE":
                    eMessage = "Wiadomość nie została wysłana.";
                    break;
                default:
                    eMessage = "Nieznany Błąd.";
                    break;
            }
            return eMessage;
        }
        /**
         * Zwraca rezulatat zapytania do konta w systemie esemeser.pl         
            – -1  - nie istnieje konto o podanej nazwie
            – -2 - konto istnieje ale login i/lub hasło są błędne
            – -3 - podany numer nie jest numerem na telefon komórkowy
            – OK -  wiadomość została przyjęta do wysyłki.
            – NIE - wiadomość nie została wysłana*/

        private string resultSendMessageToPhoneByEsemeser(string recipient, string sender, string message)
        {
            HttpWebRequest req = (HttpWebRequest)
                WebRequest.Create("http://www.esemeser.pl/0api/wyslij.php?konto="+ loginEsemeser+ "&login="+loginEsemeser+"&haslo="+passEsemeser+"&rodzaj="+ smsTypeEsemeser +"&nazwa=" + recipient + "&telefon=" + recipient + "&tresc=" + message);


            HttpWebResponse response = (HttpWebResponse)req.GetResponse();
            StreamReader reader = new StreamReader(response.GetResponseStream());
            string str = reader.ReadLine();


            return str;



        }
        /*
         * 
         * 
         * bramka.gsmservice.pl
         * 
         * 
         * 
         * */
        //wysyla sms-y za pomoca serwisu gsmservice zwraca kod bledu lub OK jesli zostalo wyslane, wewnatrz wywolywana jest funkcja ktora zwraca zapytanie zwrocone przez serwer
        public string sendByGSMService(string recipient, string sender, string message)
        {

            //MessengerWindowsService.service = new MessengerWindowsService();
            string result = resultSendByGSMService(recipient, sender, message);
            switch (result)
            {
                case "000":
                    return "Brak wystarczających środków na koncie w Bramce SMS";
                case "001":
                    return "Błąd techniczny w składni SMSa";
                case "002":
                    return "SMS nie został wysłany";
                case "003":
                    return "OK";
                case "004":
                    return "Sieć, do której próbowano wysłać SMSa jest obecnie niedostępna lub wpisano nieprawidlowy numer bez kierunku kraju";
                case "005":
                    return "Numer odbiorcy jest nieprawidłowy";
                case "006":
                    return "Brak treści SMSa";
                case "007":
                    return "Problem z doręczeniem SMSa (abonent ma wyłączony telefon, jest poza zasięgiem sieci, jego numer został przeniesiony lub jego skrzynka odbiorcza jest przepełniona itp.)";
                case "008":
                    return "Nieprawidłowy Login lub/i hasło do subkonta API";
                case "009":
                    return "Nieprawidłowy rodzaj SMSa";
                case "010":
                    return "SMS oczekuje w kolejce na wysłanie";
                case "011":
                    return "Trwa oczekiwanie na zwrócenie statusu SMSa przez sieć GSM ";
                case "012":
                    return "Wiadomość anulowana przez użytkownika";
                case "013":
                    return "OK";
                case "200":
                    return "FAX został przekazany do operatora.";
                case "201":
                    return "FAX został wysłany do odbiorcy.";
                case "202":
                    return "Linia odbiorcy była zajęta. FAX nie został wysłany.";
                case "203":
                    return "Brak sygnału faksu. Prawdopodobnie pod podanym numerem nie pracuje fax.";
                case "204":
                    return "Nie udało się odebrać informacji o rezultacie wysyłania faksu.";
                case "205":
                    return "Połączenie nie zostało odebrane.";
                case "206":
                    return "Zbyt niska jakość połączenia ze strony odbiorcy nie pozwala na wysyłkę faksu pod ten numer. Faks wysyłający nie rozpoczął transmisji obrazu.";
                case "207":
                    return "Faks został częściowo wysłany. Przetransmitowano tylko cześć stron gdyż połączenie zostało przerwane.";
                case "208":
                    return "Błąd protokołu. FAX nie został wysłany.";
                case "209":
                    return "Faks wysyłający i odbierający nie uzgodniły opcji transmisji.";
                case "210":
                    return "Wiadomość jest w trakcie wysłania.";
                case "211":
                    return "Wystąpił nieoczekiwany błąd. Wiadomość nie została wysłana.";
                case "212":
                    return "Wiadomość jest w trakcie wysłania.";
                case "213":
                    return "Nieprawidłowy plik PDF";
                case "300":
                    return "Żądanie wykonane poprawnie";
                case "301":
                    return "Błąd w żądaniu";
                default:
                    return "nieznany błąd";
            }

        }
        private string resultSendByGSMService(string recipient, string sender, string message)
        {
            
            HttpWebRequest req = (HttpWebRequest)
                WebRequest.Create("https://api.gsmservice.pl/send.php?login="+loginGsmService+"&pass=" + passGsmService + "&recipient=" + recipient + "&text=" + message + "&type="+smsTypeGsmService+"&sender=" + fromMessage);




            HttpWebResponse response = (HttpWebResponse)req.GetResponse();
            StreamReader reader = new StreamReader(response.GetResponseStream());
            string str = reader.ReadLine();

            return str;
        }

        //do dokonczenia. Wysyla smsm-y(ale nie sprawdza ich statutu) wiadomo tylko zaraz po wyslaniu ze sms na pewno nie dotarł. 
        //Trzeba stworzyc oddzielne zapytanie do serwera w ktorym musi byc umieszczone id wiadomosci i w postaci xml zostanie zwrocny komunikat
        public string sendSmsBySmsSerwer(string recipient, string sender, string message)
        {
            string result = resultSendBySmsSerwer(recipient, sender, message);
            //Console.WriteLine(result);
            XmlDocument XmlDoc = new XmlDocument();
            XmlDocument XmlStatus = new XmlDocument();
            try
            {
                XmlDoc.LoadXml(result);
            }
            catch (Exception e)
            {

                return "Błąd ładowania xml " + e.Message;
            }


            XmlNodeList blad = XmlDoc.GetElementsByTagName("Blad");

            foreach (XmlNode val in blad)
            {

                return val.InnerText;

            }

           

            return "Błąd w funkcji sendSmsBySmsSerwer";
        }

        //sprawdza statut wiadomosci,funkcja do sprawdzenia czy dziala na koncie ktore zostanie oplacone poniewaz w wersji testowej nie da sie sprawdzic statusu
        private string chceckStstusBySmsSerwer(string recipient, string messageId)
        {
            string pass = "webapitest";//haslo testtowe
            string url = "http://www.api1.serwersms.pl/zdalnie/index.php?login=webapi&haslo=" + pass + "&akcja=sprawdz_sms&numer=" + recipient + "&smsid=" + messageId;
            HttpWebRequest req = (HttpWebRequest)
            WebRequest.Create(url);



            HttpWebResponse response = (HttpWebResponse)req.GetResponse();
            StreamReader reader = new StreamReader(response.GetResponseStream());
            //string str = "";

            StreamReader sr = new StreamReader(response.GetResponseStream());
            string result = sr.ReadToEnd();
            sr.Close();
            //Console.Out(sr);

            return result;
        }






        private string resultSendBySmsSerwer(string recipient, string sender, string message)
        {
            string pass = "webapitest";

            HttpWebRequest req = (HttpWebRequest)
                WebRequest.Create("http://www.api1.serwersms.pl/zdalnie/index.php?login=webapi&haslo=" + pass + "&akcja=wyslij_sms&numer=" + recipient + "&wiadomosc=" + message + "&test=1");



            HttpWebResponse response = (HttpWebResponse)req.GetResponse();
            StreamReader reader = new StreamReader(response.GetResponseStream());
            //string str = "";

            StreamReader sr = new StreamReader(response.GetResponseStream());
            string result = sr.ReadToEnd();
            sr.Close();
            //Console.Out(sr);

            return result;
        }

        /*
         * 
         * 
         * 
            <?xml version="1.0" encoding="UTF-8"?>
            <request  protocol=”SmesX” version="2.2"
            user="user_name" password="password_string">
            <send_sms>
            <msisdn>Numer_MSISDN</msisdn>
            <body>Tutaj treść SMS-a</body>
            <expire_at>yyyy-mm-dd hh:mi:ss</expire_at>
            <sender>Nadawca</sender>
            <sms_type>Kod typu smsa</sms_type>
            <send_after>yyyy-mm-dd hh:mi:ss</send_after>
            </send_sms>
            </request
         * 
         * 
         */
        //do sprawdzenie i poprawienia, pradwdopodobnie wogole nie wysyla poprawnie xml-a, ale zakladajac ze uda sie wyslac xml-a wiadomosc powinna sie wyslac.
        //UWAGAŁ login i haslo nie jest to samo co podczas zakladania konta w serwisie. Prawdilowe dostepne jest dopiero po zalogowaniu w dziale interfejsy
        public string sendSMSbySmeskom(string recipient, string sender, string message)
        {

            XmlDocument doc = new XmlDocument();
            XmlNode docNode = doc.CreateXmlDeclaration("1.0", "UTF-8", null);
            doc.AppendChild(docNode);

            XmlNode requestNode = doc.CreateElement("request");
            XmlAttribute requestAttributePr = doc.CreateAttribute("protocol");
            requestAttributePr.Value = "SmesX";
            requestNode.Attributes.Append(requestAttributePr);
            XmlAttribute requestAttributeVer = doc.CreateAttribute("version");
            requestAttributeVer.Value = "2.2";
            requestNode.Attributes.Append(requestAttributeVer);
            XmlAttribute requestAttributeUser = doc.CreateAttribute("user");
            requestAttributeUser.Value = "htguser3113";
            requestNode.Attributes.Append(requestAttributeUser);
            XmlAttribute requestAttributePassword = doc.CreateAttribute("password");
            requestAttributePassword.Value = "qmWuU3pP";
            requestNode.Attributes.Append(requestAttributePassword);
            doc.AppendChild(requestNode);

            XmlNode sendSmsNode = doc.CreateElement("send_sms");
            requestNode.AppendChild(sendSmsNode);

            XmlNode msisdnNode = doc.CreateElement("msisdn");
            msisdnNode.AppendChild(doc.CreateTextNode("604 212 480"));
            sendSmsNode.AppendChild(msisdnNode);
            XmlNode bodyNode = doc.CreateElement("body");
            bodyNode.AppendChild(doc.CreateTextNode("Tekst"));
            sendSmsNode.AppendChild(bodyNode);


            StringWriter sw = new StringWriter();
            XmlTextWriter xw = new XmlTextWriter(sw);
            doc.WriteTo(xw);
            string xml = sw.ToString();
            Console.WriteLine(xml);
            byte[] bytes = Encoding.UTF8.GetBytes(xml);


            WebRequest request =
WebRequest.Create("https://smesx1.smeskom.pl:2200/smesx");

            request.Method = "POST";
            request.ContentLength = bytes.Length;
            request.Timeout = 300;
            request.ContentType = "text/xml; encoding='UTF-8'";
            request.Method = "_POST";
            //request.Credentials = new
            NetworkCredential("htguser3112", "qmWuU3pP");
            Stream requestStream = request.GetRequestStream();
            requestStream.Write(bytes, 0, bytes.Length);
            WebResponse response = request.GetResponse();
            StreamReader reader = new
StreamReader(response.GetResponseStream());
            string str = reader.ReadLine();
            while (str != null)
            {
                Console.WriteLine(str);
                str = reader.ReadLine();
            }






            return "test";
        }

        private void NetworkCredential(string p, string p_2)
        {
            throw new NotImplementedException();
        }



        static string getMd5Hash(string input)
        {
            // Create a new instance of the MD5CryptoServiceProvider object.
            MD5 md5Hasher = MD5.Create();

            // Convert the input string to a byte array and compute the hash.
            byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(input));

            // Create a new Stringbuilder to collect the bytes
            // and create a string.
            StringBuilder sBuilder = new StringBuilder();

            // Loop through each byte of the hashed data 
            // and format each one as a hexadecimal string.
            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }

            // Return the hexadecimal string.
            return sBuilder.ToString();
        }
    }
}
