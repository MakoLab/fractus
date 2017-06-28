using System.Net.Mail;
using System.Net;
using log4net;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;

namespace Makolab.Fractus.Messenger.Providers
{
    public class EmailProvider : IMessageProvider
    {
        private SmtpClient smtp;
        private MailServerConfiguration cfg;

        public ILog Log { get; set; }

        public void Initialize(MailServerConfiguration configuration)
        {
            this.cfg = configuration;

            this.smtp = new SmtpClient()
            {
                Host = configuration.SMTP,
                Port = configuration.Port,
                Credentials = new NetworkCredential(configuration.Account, configuration.Password),
                EnableSsl = configuration.UseSSL
            };
        }

        public void SendMessage(Message message)
        {
			Debugger.Launch();
			List<MemoryStream> attachmentsStreams = new List<MemoryStream>(2);
			try
			{
				MailMessage msg = new MailMessage()
				{
					From = new MailAddress((message.Sender != null) ? message.Sender : cfg.Account),
					Body = message.Body,
					Subject = message.Subject,
					IsBodyHtml = (message.Type == MessageType.HtmlEmail)
             
				};
                if (message.CC != null)
                {
                    MailAddress copy = new MailAddress(message.CC);
                    msg.CC.Add(copy);
                }
                
				msg.To.Add(new MailAddress(message.Recipient));
				if (message.Attachments != null)
				{
					foreach (MessageAttachment msgAtt in message.Attachments)
					{
						MemoryStream ms = new MemoryStream(msgAtt.Content);
						Attachment attachment = new Attachment(ms, msgAtt.Name ?? "x", msgAtt.ContentType ?? "application/octet-stream");
						msg.Attachments.Add(attachment);
                        //Czarekw - obs³uga inline attachments
                        msg.Body.Replace("cid:" + msgAtt.Name, "cid:"+attachment.ContentId);
					}
				}

				this.smtp.Send(msg);

				message.State = MessageState.Send;
			}
			finally
			{
				foreach (MemoryStream ms in attachmentsStreams)
				{
					ms.Dispose();
				}
			}
        }

    }

}