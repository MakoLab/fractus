using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Configuration;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.TaskManager.Tasks
{
    internal class SettlementTask : Task
    {
        private string exportServiceUrl;
        private string externalSystemName;
        private string xmlWrapperTemplate;
        private int? requestTimeout;
        private XElement parameters = new XElement("request");

        public SettlementTask(XElement param)
        {
            List<XElement> xList = new List<XElement>(param.Elements());
            foreach (XElement element in xList)
                this.parameters.Add(element);
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
                    //else if (conf.Key == "system.taskManagerSqlCommandTimeout")
                    //    this.sqlCommandTimeout = Convert.ToInt32(conf.Value.Value, CultureInfo.InvariantCulture);
                }
            }
        }

        protected override void StartProcedure()
        {
            this.LoadUrl();

            this.Progress = 30;

            XElement response = this.GetResponse(parameters);

            this.Progress = 60;

            this.result = response.ToString(SaveOptions.DisableFormatting);

            this.Progress = 100;
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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:707");
                XElement exceptionXml = Utils.CreateInnerExceptionXml(ex, null, false);
                exceptionXml.Name = "exception";
                exceptionXml.Add(new XAttribute("phase", "http request to external system"));
                exceptionXml.Add(request);
                this.result = exceptionXml.ToString(SaveOptions.DisableFormatting);
                throw;
            }
        }
    }
}
