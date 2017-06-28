using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.Net;


namespace Makolab.Fractus.Messenger
{
    class EmailSend
    {
        //Logger log = new Logger();
        public bool sendMessageToEmail(string emailAddress, string subject, string message)
        {
            //MessengerWindowsService service = new MessengerWindowsService();
            SmtpClient SClient = new SmtpClient();
            bool sendResult = true;
            System.Net.Mail.MailMessage msgMail = new System.Net.Mail.MailMessage();


            MailAddress strFrom = new MailAddress("testspam@mm.com.pl");

            string strTo = emailAddress;
            string strSubject = subject;
            string strEmailBody = message;
            try
            {

                msgMail.Body = strEmailBody;
                msgMail.Subject = strSubject;
                msgMail.To.Add(strTo);
                msgMail.From = strFrom;

                msgMail.IsBodyHtml = true;
            }
            catch
            {
                //log.errorLog("Nieprawdiłowe dane e-mail");
            }
            SmtpClient smtpCli;
            try
            {
                smtpCli = new SmtpClient();
                smtpCli.Host = "smtp.mm.com.pl";
                smtpCli.Credentials = new NetworkCredential("testspam@mm.com.pl", "gWeo8");
                smtpCli.Send(msgMail);
                sendResult = true;
            }
            catch (SmtpFailedRecipientException)
            {

                //log.errorLog("Wiadomość NIE została wysłana ! " + ex);
                sendResult = false;

            }
            /*
            try
            {
                SClient.Send(msgMail);
                
                Service1.service.writeEntryEmailLog("Wiadomość została wysłana na e-mail: " + emailAddress);
                sendResult = true;
            }
            catch (Exception e)
            {
                Service1.service.writeEntryEmailLog("Wiadomość NIE została wysłana ! " + e);
                sendResult = false;
            }*/
            return sendResult;

        }
    }
}
