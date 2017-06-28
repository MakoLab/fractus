using Makolab.Fractus.Messenger;
using System.Collections.Generic;
using System.Net;
using System.IO;
using System.Text.RegularExpressions;
using System;
using System.Web;
using log4net;
using Microsoft.Practices.ServiceLocation;
using Ninject;
using Ninject.Parameters;


namespace Makolab.Fractus.Messenger.Providers
{
    public abstract class SmsProvider : IMessageProvider
    {
        public SmsProvider()
        {

        }

        public ILog Log { get; set; }

        public virtual void SendMessage(Message message)
        {
            var currentTime = new TimeSpan(DateTime.Now.Hour, DateTime.Now.Minute, 0);
            if (currentTime < this.BeginSmsTranssmisionPeriod || currentTime > EndSmsTranssmisionPeriod)
            {
                message.State = MessageState.Postponed;
                return;
            }

            IHttpWebRequestWrapper req = ServiceLocator.Current.ToNinject().Kernel.Get<IHttpWebRequestWrapper>(new ConstructorArgument("url", BuildMessageUrl(message)));
            PrepareRequest(req);
            this.Log.DebugFormat("Wysy³anie requestu do providera wiadomoœci na adres: {0}", req.RequestUri.AbsoluteUri);
            IHttpWebResponseWrapper response = req.GetResponse();
            HandleResponse(response, message);
        }

        public virtual void Initialize(Dictionary<string, string> configuration, TimeSpan beginSmsTransmissionPeriod, TimeSpan endSmsTransmissionPeriod)
        {
            this.Configuration = configuration;

            if (this.Configuration.ContainsKey("urlTemplate")) this.UrlTemplate = this.Configuration["urlTemplate"];

            this.UrlTemplate = BuildProviderUrl();
            this.BeginSmsTranssmisionPeriod = beginSmsTransmissionPeriod;
            this.EndSmsTranssmisionPeriod = endSmsTransmissionPeriod;
        }

        protected string UrlTemplate { get; set; }

        protected Dictionary<string, string> Configuration { get; set; }

        protected TimeSpan BeginSmsTranssmisionPeriod { get; set; }

        protected TimeSpan EndSmsTranssmisionPeriod { get; set; }

        protected virtual string BuildProviderUrl()
        {
            return FillTemplate(this.UrlTemplate, this.Configuration);
        }

        protected string FillTemplate(string template, Dictionary<string, string> values)
        {
            return Regex.Replace(template,
                                    @"\{.+?\}",
                                    m =>
                                    {
                                        var key = m.Groups[0].Value.Substring(1, m.Groups[0].Value.Length - 2);
                                        return values.ContainsKey(key) ? values[key] : m.Groups[0].Value;
                                    });
        }

        #region SendMessage template method extension points

        protected virtual void PrepareRequest(IHttpWebRequestWrapper request)
        {
        }

        protected virtual void HandleResponse(IHttpWebResponseWrapper response, Message message)
        {
            using (StreamReader reader = new StreamReader(response.GetResponseStream()))
            {
                SetMessageState(GetStringFromReader(reader), message);
            }
        }

        protected string GetStringFromReader(StreamReader reader)
        {
            return reader.ReadToEnd();
        }

        protected virtual void SetMessageState(string result, Message message)
        {
            // must be overriden if default HandleResponse implementation is used
        }

        protected virtual string BuildMessageUrl(Message message)
        {
            return this.UrlTemplate.Replace("{recipient}", message.Recipient).Replace("{sender}", message.Sender).Replace("{message}", message.Body);
        }
        #endregion
    }
}