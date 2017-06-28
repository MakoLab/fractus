using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.TaskManager.Tasks
{
    internal class PaymentSynchronizationTask : Task
    {
        private Guid requestId = Guid.NewGuid();
        private string exportServiceUrl;
        private string externalSystemName;
        private string xmlWrapperTemplate;
        private Guid applicationUserId;
        private int? requestTimeout;
		private int? sqlCommandTimeout;

        public PaymentSynchronizationTask(XElement param)
        {
            this.applicationUserId = SessionManager.User.UserId;
        }

        private void LoadUrl()
        {
            using (ConfigurationCoordinator c = new ConfigurationCoordinator())
            {
                ICollection<Configuration> col = ConfigurationMapper.Instance.GetConfiguration(null,
					"accounting.exportService.address", "accounting.export.externalSystemName", "accounting.export.xmlWrapperTemplate", "system.taskManagerRequestTimeout", "system.taskManagerSqlCommandTimeout");

                foreach (Configuration conf in col)
                {
                    if (conf.Key == "accounting.exportService.address")
                        this.exportServiceUrl = conf.Value.Value;
                    else if (conf.Key == "accounting.export.externalSystemName")
                        this.externalSystemName = conf.Value.Value;
                    else if (conf.Key == "accounting.export.xmlWrapperTemplate")
                        this.xmlWrapperTemplate = conf.Value.Value;
                    else if (conf.Key == "system.taskManagerRequestTimeout")
                        this.requestTimeout = Convert.ToInt32(conf.Value.Value, CultureInfo.InvariantCulture);
					else if (conf.Key == "system.taskManagerSqlCommandTimeout")
						this.sqlCommandTimeout = Convert.ToInt32(conf.Value.Value, CultureInfo.InvariantCulture);
				}
            }
        }

        private XElement GetResponse(XElement request)
        {
            try
            {
                WebRequest webReq = WebRequest.Create(this.exportServiceUrl);
                
                if (this.requestTimeout != null)
                    webReq.Timeout = this.requestTimeout.Value;
                
                webReq.Method = "POST";
                webReq.ContentType = "text/xml";

                Stream s = webReq.GetRequestStream();
                StreamWriter wr = new StreamWriter(s);
                string wrappedRequest = this.xmlWrapperTemplate.Replace("[FRACTUS-XML-VALUE]", request.ToString(SaveOptions.DisableFormatting));
                wr.Write(wrappedRequest);
                wr.Close();

                Stream responseStream = webReq.GetResponse().GetResponseStream();

                using (StreamReader r = new StreamReader(responseStream))
                {
                    string strResponse = r.ReadToEnd();
                    return XElement.Parse(strResponse);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:705");
                XElement exceptionXml = Utils.CreateInnerExceptionXml(ex, null, false);
                exceptionXml.Name = "exception";
                exceptionXml.Add(new XAttribute("phase", "http request to external system"));
                exceptionXml.Add(request);
                this.result = exceptionXml.ToString(SaveOptions.DisableFormatting);
                throw;
            }
        }

        private XElement UpdatePayments(XElement response)
        {
            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                ListMapper mapper = new ListMapper();
                XDocument xml = mapper.ExecuteStoredProcedure(null, StoredProcedure.accounting_p_updatePayments, true, new XDocument(response), this.sqlCommandTimeout);
                return xml.Root;
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:706");
                XElement exceptionXml = Utils.CreateInnerExceptionXml(ex, null, false);
                exceptionXml.Name = "exception";
                exceptionXml.Add(new XAttribute("phase", "execute procedure setObjectMapping"));
                this.result = exceptionXml.ToString(SaveOptions.DisableFormatting);
                throw;
            }
            finally
            {
                SqlConnectionManager.Instance.ReleaseConnection();
            }
        }

        protected override void StartProcedure()
        {
            this.LoadUrl();

            this.Progress = 20;

            XElement request = new XElement("request",
                    new XElement("requestId", this.requestId.ToUpperString()),
                    new XElement("method", "paymentSettlements"),
                    new XElement("action"));

            XElement response = this.GetResponse(request);

            this.Progress = 40;

            response = this.UpdatePayments(response);

            this.Progress = 60;

            response = this.GetResponse(response);

            this.Progress = 90;

            this.result = response.ToString(SaveOptions.DisableFormatting);

            this.Progress = 100;
        }
    }
}
