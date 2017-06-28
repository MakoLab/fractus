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
    internal class ExportToAccountingTask : Task
    {
        private Guid requestId = Guid.NewGuid();
        private Guid contractorId;
        private Guid warehouseDocumentId;
        private Guid commercialDocumentId;
        private Guid financialReportId;
        private string exportServiceUrl;
        private string externalSystemName;
        private string xmlWrapperTemplate;
        private Guid? accountingRuleId;
        private bool disableExport;
        private Guid applicationUserId;
        private int? requestTimeout;
		private int? sqlCommandTimeout;

        public ExportToAccountingTask(XElement param)
        {
            if (param.Element("contractorId") != null)
                this.contractorId = new Guid(param.Element("contractorId").Value);
            else if (param.Element("warehouseDocumentId") != null)
                this.warehouseDocumentId = new Guid(param.Element("warehouseDocumentId").Value);
            else if (param.Element("commercialDocumentId") != null)
                this.commercialDocumentId = new Guid(param.Element("commercialDocumentId").Value);
            else if (param.Element("financialReportId") != null)
                this.financialReportId = new Guid(param.Element("financialReportId").Value);

            if (param.Element("createAccountingEntries") != null)
                this.accountingRuleId = new Guid(param.Element("createAccountingEntries").Attribute("accountingRuleId").Value);

            if (param.Element("disableExport") != null)
                this.disableExport = true;

            this.applicationUserId = SessionManager.User.UserId;
        }

        private void LoadUrl()
        {
            if (this.disableExport) return;

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

        private XElement LoadRequestXml()
        {
            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                StoredProcedure? sp = null;
                string paramName = null;
                Guid paramValue = Guid.Empty;

                if (this.contractorId != Guid.Empty)
                {
                    sp = StoredProcedure.accounting_p_getContractorData;
                    paramName = "contractorId";
                    paramValue = this.contractorId;
                }
                else if (this.warehouseDocumentId != Guid.Empty)
                {
                    sp = StoredProcedure.accounting_p_getWarehouseDocument;
                    paramName = "warehouseDocumentHeaderId";
                    paramValue = this.warehouseDocumentId;
                }
                else if (this.commercialDocumentId != Guid.Empty)
                {
                    sp = StoredProcedure.accounting_p_getCommercialDocument;
                    paramName = "commercialDocumentHeaderId";
                    paramValue = this.commercialDocumentId;
                }
                else if (this.financialReportId != Guid.Empty)
                {
                    sp = StoredProcedure.accounting_p_getFinancialReport;
                    paramName = "financialReportId";
                    paramValue = this.financialReportId;
                }

                ListMapper mapper = new ListMapper();
                XDocument xml = mapper.ExecuteStoredProcedure(sp.Value, true, paramName, paramValue, this.sqlCommandTimeout);
                return xml.Root;
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:701");
                XElement exceptionXml = Utils.CreateInnerExceptionXml(ex, null, false);
                exceptionXml.Name = "exception";
                exceptionXml.Add(new XAttribute("phase", "load object from fractus db"));
                this.result = exceptionXml.ToString(SaveOptions.DisableFormatting);
                throw;
            }
            finally
            {
                SqlConnectionManager.Instance.ReleaseConnection();
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
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:702");
                XElement exceptionXml = Utils.CreateInnerExceptionXml(ex, null, false);
                exceptionXml.Name = "exception";
                exceptionXml.Add(new XAttribute("phase", "http request to external system"));
                exceptionXml.Add(request);
                this.result = exceptionXml.ToString(SaveOptions.DisableFormatting);
                throw;
            }
        }

        private void ProcessStatus(XElement response)
        {
            XElement status = response.Descendants().Where(n => n.Name.LocalName == "status").FirstOrDefault();

            if (status == null || status.Element("code").Value != "1")
            {
                response.Add(new XAttribute("phase", "response status processing"));
                this.result = response.ToString(SaveOptions.DisableFormatting);
                throw new InvalidOperationException();
            }
        }

        private void SetObjectMapping(XElement response)
        {
            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                ListMapper mapper = new ListMapper();
                mapper.ExecuteStoredProcedure(null, StoredProcedure.accounting_p_setObjectMapping, false, new XDocument(response), this.sqlCommandTimeout);
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:703");
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

        private void CreateAccountingEntries()
        {
            if (this.accountingRuleId == null) return;

            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                XDocument xml = XDocument.Parse("<params/>");
                xml.Root.Add(new XElement("accountingRuleId", this.accountingRuleId.ToUpperString()));
                xml.Root.Add(new XElement("applicationUserId", this.applicationUserId.ToUpperString()));

                if (this.commercialDocumentId != Guid.Empty)
                {
                    xml.Root.Add(new XElement("documentId", this.commercialDocumentId.ToUpperString()));
                    xml.Root.Add(new XElement("documentCategory", "CommercialDocument"));
                }
                else if (this.warehouseDocumentId != Guid.Empty)
                {
                    xml.Root.Add(new XElement("documentId", this.warehouseDocumentId.ToUpperString()));
                    xml.Root.Add(new XElement("documentCategory", "WarehouseDocument"));
                }
                else if (this.financialReportId != Guid.Empty)
                {
                    xml.Root.Add(new XElement("documentId", this.financialReportId.ToUpperString()));
                    xml.Root.Add(new XElement("documentCategory", "FinancialReport"));
                }

                ListMapper mapper = new ListMapper();
                xml = mapper.ExecuteStoredProcedure(null, StoredProcedure.accounting_p_createAccountingEntries, true, xml, this.sqlCommandTimeout);

                if (xml.Root.Value.Length != 0)
                    throw new InvalidOperationException(xml.Root.Value);
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:704");
                XElement exceptionXml = Utils.CreateInnerExceptionXml(ex, null, false);
                exceptionXml.Name = "exception";
                exceptionXml.Add(new XAttribute("phase", "execute procedure createAccountingEntries"));
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

            this.Progress = 10;

            this.CreateAccountingEntries();

            if (this.disableExport)
            {
                this.Progress = 100;
                return;
            }

            this.Progress = 20;

            XElement requestXml = this.LoadRequestXml();

            this.Progress = 40;

            XElement response = this.GetResponse(requestXml);

            this.Progress = 60;

            this.ProcessStatus(response);
            
            this.Progress = 80;

            this.SetObjectMapping(response);

            this.Progress = 90;
            
            this.result = response.ToString(SaveOptions.DisableFormatting);
            
            this.Progress = 100;
        }
    }
}
