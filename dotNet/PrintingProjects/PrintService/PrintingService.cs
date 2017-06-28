using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Threading;
using Makolab.Printing.Fiscal;
using log4net;
using System.ServiceModel.Channels;
using Makolab.Printing.Text;

namespace Makolab.Fractus.Printing
{
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    [ErrorBehavior(typeof(FlexHttpErrorHandler))]
    public class PrintingService : IPrintingService
    {
        private object fiscalPrintLock;
        private object dotMatrixPrintLock;
        private ILog log = log4net.LogManager.GetLogger(typeof(PrintServiceController));

        public PrintingService()
        {
            this.fiscalPrintLock = new object();
            this.dotMatrixPrintLock = new object();
        }

        #region IPrintingService Members

        public void FiscalPrint(string printXml)
        {
            try
            {
                lock (this.fiscalPrintLock)
                {
                    MakoPrintFiscal.Generate(printXml, null);
                }
            }
            catch (Exception e)
            {
                this.log.Error(String.Format("PrintingService.FiscalPrint, param:printXml = {0}", printXml), e);
                throw Makolab.Fractus.Commons.FlexExceptionProvider.GetClientException(e, GetClientLanguageVersion());
            }
        }

        public void TextualPrint(string printXml)
        {
            try
            {
                lock (this.dotMatrixPrintLock)
                {
                    MakoPrintText.Generate(printXml);    
                }
            }
            catch (Exception e)
            {
                this.log.Error(String.Format("PrintingService.TextPrint, param:printXml = {0}", printXml), e);
                throw Makolab.Fractus.Commons.FlexExceptionProvider.GetClientException(e, GetClientLanguageVersion());
            }        
        }

        public string WSTest(string input)
        {
            return DateTime.Now + ": Usługa wydruku zdalnego działa.";
        }

        #endregion

        private static string GetClientLanguageVersion()
        {
            HttpRequestMessageProperty httpRequestProperty = (HttpRequestMessageProperty)OperationContext.Current.IncomingMessageProperties[HttpRequestMessageProperty.Name];
            string userLang = httpRequestProperty.Headers["Accept-Language"];

            if (userLang != null) userLang = userLang.Split('-')[0];
            else userLang = "pl";

            return userLang;
        }
    }
}
