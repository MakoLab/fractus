using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.Web;
using System.Web.Hosting;
using System.Xml.Linq;
using Makolab.Barcodes;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Printing;
using Makolab.RestUpload;
using System.Collections.Specialized;
using System.Xml;
using System.Xml.XPath;
using Makolab.Fractus.Kernel.Mappers;
using XlsToXmlTools;
using Makolab.Fractus.Kernel.Services.Barcodes;
using System.Xml.Schema;
using System.Dynamic;
using System.Collections.Concurrent;
using System.Threading;
using System.Data.SqlClient;
using System.Data;
//using ECRUtilATLLib;


namespace Makolab.Fractus.Kernel.Services
{
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    public class PrintService : IPrintService
    {
        public const string PDF_CONTENT_TYPE = "application/pdf";
        public const string CSV_CONTENT_TYPE = "application/octet-stream";
        public const string EXCEL_CONTENT_TYPE = "application/vnd.ms-excel";
        public const string XML_CONTENT_TYPE = "text/xml";
        public const string VCARD_CONTENT_TYPE = "text/x-vcard";
        public const string HTML_CONTENT_TYPE = "text/html";
        public const string TEXT_CONTENT_TYPE = "text/plain";
        private static string ResourcesDir = PrintService.GetResourcesDir();
        public static bool singleCleanerForMultipartResources = false;

        public PrintService()
        {
            if (!singleCleanerForMultipartResources)
            {
                singleCleanerForMultipartResources = true;
                Thread resourceCleaner = new System.Threading.Thread(new System.Threading.ThreadStart(delegate
                {
                    try
                    {
                        while (true)
                        {
                            Thread.Sleep(60000 * 60);
                            lock (synchroForCleaningMultiPartResources)
                            {
                                while (synchroForPacketBufferCleaner_workingBuffers != 0)
                                {
                                    Thread.Sleep(1000);
        }

                                List<string> packetsToDelete = new List<string>();
                                foreach (KeyValuePair<string, List<object>> li in packetBuffer)
                                {
                                    TimeSpan elapsed = DateTime.Now - (DateTime)(li.Value[0]);
                                    double l = 2;
                                    if (elapsed.TotalHours > l)
                                    {
                                        packetsToDelete.Add(li.Key);
                                    }
                                }

                                foreach (string k in packetsToDelete)
                                {
                                    List<object> n = new List<object>();
                                    int timeoutForTryRemove = 3000;
                                    while (timeoutForTryRemove > 0)
                                    {
                                        if (packetBuffer.TryRemove(k, out n) == true)
                                        {
                                            break;
                                        }
                                        Thread.Sleep(10);
                                        timeoutForTryRemove--;
                                    }
                                }

                                packetsToDelete = new List<string>();
                                foreach (KeyValuePair<string, List<object>> li in binaryResourcesBuffer)
                                {
                                    TimeSpan elapsed = DateTime.Now - (DateTime)(li.Value[0]);
                                    double l = 2;
                                    if (elapsed.TotalHours > l)
                                    {
                                        packetsToDelete.Add(li.Key);
                                    }
                                }

                                foreach (string k in packetsToDelete)
                                {
                                    List<object> n = new List<object>();
                                    int timeoutForTryRemove = 3000;
                                    while (timeoutForTryRemove > 0)
                                    {
                                        if (binaryResourcesBuffer.TryRemove(k, out n) == true)
                                        {
                                            break;
                                        }
                                        Thread.Sleep(10);
                                        timeoutForTryRemove--;
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        //KernelHelpers.FastTest.Fail("Thread for cleaning MultipartResources error: " + ex.Message);
                    }
                }));

                resourceCleaner.IsBackground = true;
                resourceCleaner.Start();
            }
        }

        private static string GetResourcesDir()
        {
            try
            {
                string fractusDir = HostingEnvironment.MapPath("~");

                if (fractusDir == null) //desktop mode
                    fractusDir = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location);

                return Path.Combine(fractusDir, "Resources");
            }
            catch (NullReferenceException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:600");
                return null;
            }
        }
//        public void CVSImport(Stream input)
//        {
//            bool is2007format = false;
//            string config =
//                @"<?xml version='1.0'?> 
//                    <ConverterPattern>
//                      <RemoveAllEmptyClosedElements value='True' />
//                      <AddRowTags value='True' />
//                      <RemoveDataBeforeHeaders value='True' />
//                      <Spreadsheet name='Legenda'>
//                      </Spreadsheet>
//                      <Spreadsheet>
//                        <Column name='SAP' />
//                        <Column name='CAI' />
//                        <Column name='SAPKOD' />
//                        <StaticField >
//                          <Field name='Title' />
//                        </StaticField>
//	                    <RenameField name='Column2' changeTo='Srednica' />
//                        </Spreadsheet>
//                    </ConverterPattern>";

//            /*
//             * W razie potrzeby można filtrować odpowiedź tylko do wybranych
//             * elementów. Zmieniając config na np.
//                <Spreadsheet>
//                        <Column name='SAP' />
//                        <Column name='CAI' />
//                        <Column name='SAPKOD' />
//                        <StaticField >
//                          <Field name='Title' />
//                        </StaticField>
//                        <RenameField name='Column2' changeTo='Srednica' />
//                       <ReturnOnly name='SAP' />
//                        <ReturnOnly name='INDEKS' />
//                        <ReturnOnly name='BIEZNIK' />
//                </Spreadsheet>
//             * 
//             */
//            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
//            SqlConnectionManager.Instance.InitializeConnection();
//            XElement configEntry = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "import.itemPrices").First().Value;
//            config = configEntry.ToString();

//            ICollection<UploadedFile> files = UploadHelper.ExtractFiles(input);
//            UploadedFile file = files.First();

//            XlsToXmlTools.XlsConvert convert = new XlsToXmlTools.XlsConvert(config);    // -- Tworzenie konwertera na podstawie konfiguracji

//            MemoryStream ms = new MemoryStream();
//            XmlWriterSettings xws = new XmlWriterSettings();
//            xws.OmitXmlDeclaration = false;                         // -- Czy dodac <?...?>
//            xws.Indent = true;                                      // -- Czy formatowac
//            Encoding Utf8 = new UTF8Encoding(false);                // -- Wyłączenie BOM
//            xws.Encoding = Utf8;

//            WebOperationContext.Current.OutgoingResponse.ContentType = "text/xml";
//            WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

//            XmlWriter xw = XmlWriter.Create(ms, xws);
//            XDocument ans = convert.ToXml(is2007format, new MemoryStream(file.Data));
//            ans = convert.CorrectFile(ans);
//            ans.WriteTo(xw);
//            xw.Flush();

//            ms.Position = 0; // --! uhh

//            return ms;

//        }


        public Stream XlsToXmlGeneric(Stream input)
        {
 
            ICollection<UploadedFile> files = UploadHelper.ExtractFiles(input);
            UploadedFile file = files.First();

            XlsToXmlTools.XlsConvert convert = new XlsToXmlTools.XlsConvert();

            MemoryStream ms = new MemoryStream();
            XmlWriterSettings xws = new XmlWriterSettings();
            xws.OmitXmlDeclaration = false;                         // -- Czy dodac <?...?>
            xws.Indent = false;                                      // -- Czy formatowac
            Encoding Utf8 = new UTF8Encoding(false);                // -- Wyłączenie BOM
            xws.Encoding = Utf8;

            WebOperationContext.Current.OutgoingResponse.ContentType = "text/xml";
            WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

            XmlWriter xw = XmlWriter.Create(ms, xws);

            DataSet dtx = convert.ToDataSet(false, new MemoryStream(file.Data), true);
            XDocument resultXml = XDocument.Parse(dtx.GetXml());
 
            resultXml.WriteTo(xw);
            xw.Flush();

            ms.Position = 0; // --! uhh

            return ms;

        }



        public Stream XlsToXml(Stream input)
        {


            bool is2007format = false;
            string config =
                @"<?xml version='1.0'?> 
                    <ConverterPattern>
                      <RemoveAllEmptyClosedElements value='True' />
                      <AddRowTags value='True' />
                      <RemoveDataBeforeHeaders value='True' />
                      <Spreadsheet name='Legenda'>
                      </Spreadsheet>
                      <Spreadsheet>
                        <Column name='SAP' />
                        <Column name='CAI' />
                        <Column name='SAPKOD' />
                        <StaticField >
                          <Field name='Title' />
                        </StaticField>
	                    <RenameField name='Column2' changeTo='Srednica' />
                        </Spreadsheet>
                    </ConverterPattern>";


            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SqlConnectionManager.Instance.InitializeConnection();
            XElement configEntry = ConfigurationMapper.Instance.GetConfiguration(SessionManager.User, "import.itemPrices").First().Value;
            config = configEntry.ToString();

            ICollection<UploadedFile> files = UploadHelper.ExtractFiles(input);
            UploadedFile file = files.First();

            XlsToXmlTools.XlsConvert convert = new XlsToXmlTools.XlsConvert(config);    // -- Tworzenie konwertera na podstawie konfiguracji

            MemoryStream ms = new MemoryStream();
            XmlWriterSettings xws = new XmlWriterSettings();
            xws.OmitXmlDeclaration = false;                         // -- Czy dodac <?...?>
            xws.Indent = true;                                      // -- Czy formatowac
            Encoding Utf8 = new UTF8Encoding(false);                // -- Wyłączenie BOM
            xws.Encoding = Utf8;

            WebOperationContext.Current.OutgoingResponse.ContentType = "text/xml";
            WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

            XmlWriter xw = XmlWriter.Create(ms, xws);
            XDocument ans = convert.ToXml(is2007format, new MemoryStream(file.Data));
            ans = convert.CorrectFile(ans);
            ans.WriteTo(xw);
            xw.Flush();

            ms.Position = 0; // --! uhh

            return ms;

        }

        public Stream DownloadResource(Stream input)
        {
            StreamReader reader = new StreamReader(input);
            string body = reader.ReadToEnd();
            string[] parts = body.Split(new char[] { '&' }, StringSplitOptions.None);
            //string profileName = null;
            string packedId = "";
            foreach (string part in parts)
            {
                string[] keyValue = part.Split(new char[] { '=' }, StringSplitOptions.None);

                if (keyValue[0] == "packedId")
                {
                    packedId = HttpUtility.UrlDecode(keyValue[1]);
                    break;
                }

                //switch (keyValue[0])
                //{
                    //case "packedId":
                        //packedId = HttpUtility.UrlDecode(keyValue[1]);
                        //break;
                    //case "profileName":
                    //    profileName = String.IsNullOrEmpty(keyValue[1]) ? null : HttpUtility.UrlDecode(keyValue[1]);
                    //    break;
                //}
            }

            List<object> currentDictionaryValue = new List<object>();
            int timeoutForTry = 3000;
            while (timeoutForTry > 0)
            {
                if (binaryResourcesBuffer.TryRemove(packedId, out currentDictionaryValue) == true)
                {
                    break;
                }
                Thread.Sleep(10);
                timeoutForTry--;
            }

            WebOperationContext.Current.OutgoingResponse.Headers.Add("Content-disposition",
                "attachment; filename=" + HttpUtility.UrlEncode("export" + packedId + "." + (currentDictionaryValue[2] as String)));
            WebOperationContext.Current.OutgoingResponse.Headers.Add("Access-Control-Allow-Origin", "*");
            WebOperationContext.Current.OutgoingResponse.ContentType = "application/octet-stream";
            WebOperationContext.Current.OutgoingResponse.ContentLength = (currentDictionaryValue[1] as Stream).Length;
            return (currentDictionaryValue[1] as Stream);
        }

        public Stream PrintXml(Stream input)
        {
            StreamReader reader = new StreamReader(input);
            string body = reader.ReadToEnd();
            string[] parts = body.Split(new char[] { '&' }, StringSplitOptions.None);

            string xml = null;
            string profileName = null;
            string outputContentType = null;
            string packedId = "";
            string partsNumber = "";
            string partSend = "";

            foreach (string part in parts)
            {
                string[] keyValue = part.Split(new char[] { '=' }, StringSplitOptions.None);

                switch (keyValue[0])
                {
                    case "packedId":
                        packedId = HttpUtility.UrlDecode(keyValue[1]);
                        break;
                    case "partsNumber":
                        partsNumber = HttpUtility.UrlDecode(keyValue[1]);
                        break;
                    case "partSend":
                        partSend = HttpUtility.UrlDecode(keyValue[1]);
                        break;
                    case "xml":
                        xml = String.IsNullOrEmpty(keyValue[1]) ? null : HttpUtility.UrlDecode(keyValue[1]);
                        break;
                    case "profileName":
                        profileName = String.IsNullOrEmpty(keyValue[1]) ? null : HttpUtility.UrlDecode(keyValue[1]);
                        break;
                    case "outputContentType":
                        outputContentType = String.IsNullOrEmpty(keyValue[1]) ? null : HttpUtility.UrlDecode(keyValue[1].Replace('_', '-'));
                        break;
                }
            }

            lock (synchroForCleaningMultiPartResources)
            {
                Interlocked.Increment(ref synchroForPacketBufferCleaner_workingBuffers);
            }

            try
            {
                if (Convert.ToInt32(partsNumber) < Convert.ToInt32(partSend))
                {
                    throw new InvalidOperationException("bad part number");
                }
                else if ((Convert.ToInt32(partsNumber) == Convert.ToInt32(partSend)) && (Convert.ToInt32(partsNumber) != 1))
                {
                    List<object> currentDictionaryValue = new List<object>();
                    int timeoutForTryRemove = 3000;
                    while (timeoutForTryRemove > 0)
                    {
                        if (packetBuffer.TryRemove(packedId, out currentDictionaryValue) == true)
                        {
                            break;
                        }
                        Thread.Sleep(10);
                        timeoutForTryRemove--;
                    }

                    OutgoingWebResponseContext context = WebOperationContext.Current.OutgoingResponse;
                    context.ContentType = "text/xml";
                    string outputContentTypeHelper = "";
                    Stream buffStream = this.PrintXml((currentDictionaryValue[1] as string) + xml, profileName, outputContentType, ref outputContentTypeHelper);

                    int timeoutForTry = 3000;
                    while (timeoutForTry > 0)
                    {
                        if (binaryResourcesBuffer.TryAdd(packedId, new List<object>() { DateTime.Now, buffStream, outputContentTypeHelper}) == true)
                        {
                            break;
                        }
                        Thread.Sleep(10);
                        timeoutForTry--;
                    }

                    return new MemoryStream(Encoding.UTF8.GetBytes("<root><success>1</success></root>"));
                }
                else
                {
                    if (Convert.ToInt32(partsNumber) == 1)
                    {
                        OutgoingWebResponseContext context = WebOperationContext.Current.OutgoingResponse;
                        context.ContentType = "text/xml";
                        string outputContentTypeHelper = "";
                        Stream buffStream = this.PrintXml(xml, profileName, outputContentType, ref outputContentTypeHelper);

                        int timeoutForTry = 3000;
                        while (timeoutForTry > 0)
                        {
                            if (binaryResourcesBuffer.TryAdd(packedId, new List<object>() { DateTime.Now, buffStream, outputContentTypeHelper }) == true)
                            {
                                break;
                            }
                            Thread.Sleep(10);
                            timeoutForTry--;
                        }

                        return new MemoryStream(Encoding.UTF8.GetBytes("<root><success>1</success></root>"));
                    }

                    bool concurrentDictionaryContainsKey = false;

                    if (packetBuffer.ContainsKey(packedId))
                    {
                        concurrentDictionaryContainsKey = true;
                    }


                    if (concurrentDictionaryContainsKey)
                    {
                        List<object> currentDictionaryValue = new List<object>();
                        int timeoutForTryRemove = 3000;
                        while (timeoutForTryRemove > 0)
                        {
                            if (packetBuffer.TryGetValue(packedId, out currentDictionaryValue) == true)
                            {
                                break;
                            }
                            Thread.Sleep(10);
                            timeoutForTryRemove--;
            }

                        timeoutForTryRemove = 3000;
                        while (timeoutForTryRemove > 0)
                        {
                            if (packetBuffer.TryUpdate(packedId, new List<object>() { DateTime.Now, (currentDictionaryValue[1] as string) + xml }, currentDictionaryValue) == true)
                            {
                                break;
                            }
                            Thread.Sleep(10);
                            timeoutForTryRemove--;
                        }
                    }
                    else
                    {
                        int timeoutForTryRemove = 3000;
                        while (timeoutForTryRemove > 0)
                        {
                            if (packetBuffer.TryAdd(packedId, new List<object>() { DateTime.Now, xml }) == true)
                            {
                                break;
                            }
                            Thread.Sleep(10);
                            timeoutForTryRemove--;
                        }
                    }

                    OutgoingWebResponseContext context2 = WebOperationContext.Current.OutgoingResponse;
                    context2.ContentType = "text/xml";
                    return new MemoryStream(Encoding.UTF8.GetBytes("<root><success>1</success></root>"));
                }
            }
            finally
            {
                Interlocked.Decrement(ref synchroForPacketBufferCleaner_workingBuffers);
            }
        }

        private static volatile object synchroForCleaningMultiPartResources = new object();
        private static int synchroForPacketBufferCleaner_workingBuffers = 0;
        private static ConcurrentDictionary<string, List<object>> packetBuffer = new ConcurrentDictionary<string, List<object>>();
        private static ConcurrentDictionary<string, List<object>> binaryResourcesBuffer = new ConcurrentDictionary<string, List<object>>();

        private string AppendParamsToDataXml(string xml, string wordValueLanguage, XElement profileXml)
        {
            XElement queryResultsElement = profileXml.XPathSelectElement(@"configuration/queryResultsContainers");
            if (queryResultsElement != null)
            {
                try
                {
                    SqlConnectionManager.Instance.InitializeConnection();
                    ListMapper mapper = DependencyContainerManager.Container.Get<ListMapper>();

                    XElement qrResultElement = new XElement(queryResultsElement.Name);
                    foreach (XElement containerElement in queryResultsElement.Elements())
                    {
                        XElement contResultElement = new XElement(containerElement.Name);
                        qrResultElement.Add(contResultElement);
                        foreach (XElement queryResult in containerElement.Elements())
                        {
                            XElement resultElement = new XElement(queryResult.Name);
                            //copy attributes
                            if (queryResult.HasAttributes)
                            {
                                resultElement.Add(queryResult.Attributes());
                            }

                            XElement storedProcedureElement = queryResult.Element("storedProcedure");
                            string storedProcedureName = storedProcedureElement != null ? storedProcedureElement.Value : null;
                            XDocument storedProcedureParam = XDocument.Parse(xml);

                            XElement paramsElement = queryResult.Element("params");
                            if (paramsElement != null)
                            {
                                storedProcedureParam.Root.Add(paramsElement);
                            }

                            XElement result = mapper.ExecuteCustomProcedure(storedProcedureName, true, storedProcedureParam, true);
                            resultElement.Add(result.Nodes());
                            contResultElement.Add(resultElement);
                        }
                    }
                    XDocument xdoc = XDocument.Parse(xml);
                    xdoc.Root.Add(qrResultElement);
                    xml = xdoc.ToString(SaveOptions.DisableFormatting);
                }
                finally
                {
                    SqlConnectionManager.Instance.ReleaseConnection();
                }
            }
            return this.AppendParamsToDataXml(xml, wordValueLanguage);
        }

        //private XDocument AppendBarcodesToXml(XDocument doc)
        //{
        //    //var s = doc.Element("Atributes").Elements("Attribute").Single(x => (string)x.Attribute("itemFieldId") == "Attribute_Barcode").Element("Value");


        //    //var s = from node in doc.Root.Elements()
        //    //        where node.Attribute("name").Value == "Attribute_Barcode"
        //    //        select node;

        //    try
        //    {
        //        var att = from node in doc.Descendants("attribute")
        //                  where node.Element("itemFieldId").Attribute("name").Value == "Attribute_Barcode"
        //                  select node;

        //        string[] barcodes = null;

        //        if (att == null)
        //            return doc;

        //        foreach (XElement el in att)
        //        {
        //            barcodes = el.Element("value").Value.ToString().Split(',');
        //            break;
        //        }


        //        XDocument newDoc = XDocument.Parse("<root/>");


        //        if (barcodes == null || barcodes.Length < 2)
        //            return doc;

        //        for (int i = 0; i < barcodes.Length; i++)
        //        {

        //            var attq = from node in doc.Descendants("attribute")
        //                       where node.Element("itemFieldId").Attribute("name").Value == "Attribute_Barcode"
        //                       select node;



        //            foreach (XElement el in attq)
        //            {
        //                el.Element("value").Value = barcodes[i];
        //                break;
        //            }

        //            var items = from node in doc.Descendants("item")
        //                        select node;

        //            XElement item = null;
        //            foreach (XElement t in items)
        //            {
        //                item = t;
        //                break;
        //            }

        //            //XElement el = XElement.Parse(String.Format("<DDBarcode>{0}</DDBarcode>", barcodes[i]));
        //            //item.Add(el);
        //            newDoc.Root.Add(item);
        //        }

        //        return newDoc;
        //    }
        //    catch (Exception ex)
        //    {
        //        RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:601" + ex.Message + ex.StackTrace);
        //        return doc;
        //    }
        //}

        private string AppendParamsToDataXml(string xml, string wordValueLanguage)
        {
            XDocument xmlDoc = XDocument.Parse(xml);

            //xmlDoc = AppendBarcodesToXml(xmlDoc);

            if (xmlDoc.Root.Attribute("currentDateTime") == null)
            {
                xmlDoc.Root.Add(new XAttribute("currentDateTime", SessionManager.VolatileElements.CurrentDateTime.ToIsoString()));
            }

            if (!String.IsNullOrEmpty(wordValueLanguage))
            {
                XElement wordValueConfig = this.LoadConfigurationEntry("printing.transformations.wordValueLanguage." + wordValueLanguage);

                if (wordValueConfig == null)
                    throw new FileNotFoundException("WordValueLanguage " + wordValueLanguage + " not found in the database.", wordValueLanguage);

                xmlDoc.Root.Add(wordValueConfig);
            }

            //opcjonalnie queryString
            NameValueCollection queryStringCollection = WebOperationContext.Current.IncomingRequest.UriTemplateMatch.QueryParameters;
            if (queryStringCollection != null && queryStringCollection.Count > 0)
            {
                XElement queryStringElement = XElement.Parse("<queryString/>");
                foreach (string key in queryStringCollection.AllKeys)
                {
                    queryStringElement.Add(new XAttribute(key, queryStringCollection[key]));
                }
                xmlDoc.Root.Add(queryStringElement);
            }

            return xmlDoc.ToString(SaveOptions.DisableFormatting);
        }

        public MemoryStream PrintBusinessObjectOffline(string id, string profileName, ref string resultContentType)
        {
            XElement validationProfileHelper = null;

            //TODO: do poprawnienia to tymczasowe logowanie
            //this.OnEntry();
            //ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            //SessionManager.OneTimeSession = true;
            MemoryStream outputStream = null;

            try
            {
                XElement profileXml = null;
                string transformationXml = null;
                string outputFormat = null;
                string driverConfigXml = null;
                string supportedBusinessObjectType = null;
                string wordValueLanguage = null;

                this.LoadPrintingObjectsFromDatabase(profileName, ref profileXml, ref transformationXml, ref driverConfigXml, ref outputFormat, ref supportedBusinessObjectType, ref wordValueLanguage, ref validationProfileHelper);

                resultContentType = this.GetContentTypeForOutputFormat(outputFormat);

                this.EvaluateVariables(profileXml);

                string storedProcedure = null;

                if (profileXml.Element("storedProcedure") != null)
                    storedProcedure = profileXml.Element("storedProcedure").Value;

                bool isFiscalPrint = false;

                if (profileXml.Element("fiscalPrint") != null && profileXml.Element("fiscalPrint").Value.ToUpperInvariant() == "TRUE")
                    isFiscalPrint = true;

                string dataXml = this.GetBusinessObjectXml(id, supportedBusinessObjectType, storedProcedure, isFiscalPrint, null);

                outputStream = this.GetPrintStream(this.AppendParamsToDataXml(dataXml, wordValueLanguage), transformationXml, profileXml.ToString(SaveOptions.DisableFormatting), driverConfigXml, outputFormat);
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:602");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                //ServiceHelper.Instance.OnExit();
            }

            return outputStream;
        }

        public MemoryStream PrintXmlOffline(string xml, string profileName, ref string resultContentType)
        {
            XElement validationProfileHelper = null;

            //this.OnEntry();
            //ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            //SessionManager.OneTimeSession = true;
            MemoryStream outputStream = null;

            try
            {
                XElement profileXml = null;
                string transformationXml = null;
                string outputFormat = null;
                string driverConfigXml = null;
                string supportedBusinessObjectType = null;
                string wordValueLanguage = null;

                this.LoadPrintingObjectsFromDatabase(profileName, ref profileXml, ref transformationXml, ref driverConfigXml, ref outputFormat, ref supportedBusinessObjectType, ref wordValueLanguage, ref validationProfileHelper);

                resultContentType = this.GetContentTypeForOutputFormat(outputFormat);

                this.EvaluateVariables(profileXml);

                outputStream = this.GetPrintStream(this.AppendParamsToDataXml(xml, wordValueLanguage), transformationXml, profileXml.ToString(SaveOptions.DisableFormatting), driverConfigXml, outputFormat);
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:603");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                //ServiceHelper.Instance.OnExit();
            }

            return outputStream;
        }

        private Stream PrintXml(string xml, string profileName, string outputContentType, ref string outputContentTypeHelper)
        {
            XElement validationProfileHelper = null;

            //this.OnEntry();
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            SessionManager.OneTimeSession = true;
            Stream outputStream = null;

            //try
            //{
                XElement profileXml = null;
                string transformationXml = null;
                string outputFormat = null;
                string driverConfigXml = null;
                string supportedBusinessObjectType = null;
                string wordValueLanguage = null;

                this.LoadPrintingObjectsFromDatabase(profileName, ref profileXml, ref transformationXml, ref driverConfigXml, ref outputFormat, ref supportedBusinessObjectType, ref wordValueLanguage, ref validationProfileHelper);

                //string contentType = null;

                if (outputContentType == "content")
                {
                    //contentType = this.GetContentTypeForOutputFormat(outputFormat);
                    outputContentTypeHelper = outputFormat.ToLowerInvariant();
                }
                else
                {
                    //contentType = "application/octet-stream";
                    outputContentTypeHelper = outputFormat.ToLowerInvariant();
                }

                this.EvaluateVariables(profileXml);

                outputStream = this.GetPrintStream(this.AppendParamsToDataXml(xml, wordValueLanguage), transformationXml, profileXml.ToString(SaveOptions.DisableFormatting), driverConfigXml, outputFormat);

                //WebOperationContext.Current.OutgoingResponse.ContentLength = outputStream.Length;
                //WebOperationContext.Current.OutgoingResponse.ContentType = contentType;
                //WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

                //if (contentType != PrintService.PDF_CONTENT_TYPE && outputContentType == "content")
                //    WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate");

                //if (outputContentType != "content")
                //{
                //    WebOperationContext.Current.OutgoingResponse.Headers.Add("Content-Disposition",
                //        String.Format(CultureInfo.InvariantCulture, "attachment; filename={0}.{1}", outputContentType, outputFormat.ToLowerInvariant()));
                //}
            //}
            //catch (Exception ex)
            //{
            //    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:604");
            //    ServiceHelper.Instance.OnException(ex);
            //}
            //finally
            //{
                ServiceHelper.Instance.OnExit();
            //}

            //using (Stream file = File.OpenWrite("d:\\test.xls"))
            //{
            //    CopyStream(outputStream, file);
            //}

            return outputStream;
        }

        /* Used only for compatibility issues
        private Stream PrintXmlOldVersion(string xml, string profileName, string outputContentType)
        {
            XElement validationProfileHelper = null;

            //this.OnEntry();
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            SessionManager.OneTimeSession = true;
            Stream outputStream = null;

            try
            {
                XElement profileXml = null;
                string transformationXml = null;
                string outputFormat = null;
                string driverConfigXml = null;
                string supportedBusinessObjectType = null;
                string wordValueLanguage = null;

                this.LoadPrintingObjectsFromDatabase(profileName, ref profileXml, ref transformationXml, ref driverConfigXml, ref outputFormat, ref supportedBusinessObjectType, ref wordValueLanguage, ref validationProfileHelper);

                string contentType = null;

                if (outputContentType == "content")
                    contentType = this.GetContentTypeForOutputFormat(outputFormat);
                else
                    contentType = "application/octet-stream";

                this.EvaluateVariables(profileXml);

                outputStream = this.GetPrintStream(this.AppendParamsToDataXml(xml, wordValueLanguage), transformationXml, profileXml.ToString(SaveOptions.DisableFormatting), driverConfigXml, outputFormat);

                WebOperationContext.Current.OutgoingResponse.ContentLength = outputStream.Length;
                WebOperationContext.Current.OutgoingResponse.ContentType = contentType;
                WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

                if (contentType != PrintService.PDF_CONTENT_TYPE && outputContentType == "content")
                    WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate");

                if (outputContentType != "content")
                {
                    WebOperationContext.Current.OutgoingResponse.Headers.Add("Content-Disposition",
                        String.Format(CultureInfo.InvariantCulture, "attachment; filename={0}.{1}", outputContentType, outputFormat.ToLowerInvariant()));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:604");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            //using (Stream file = File.OpenWrite("d:\\test.xls"))
            //{
            //    CopyStream(outputStream, file);
            //}

            return outputStream;
        }*/

        /// <summary>
        /// Copies the contents of input to output. Doesn't close either stream.
        /// </summary>
        /// 
        public Stream GetXml(string function, string parameter)
        {

            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            SessionManager.OneTimeSession = false;
            Stream retXml = null;
            String procedureName = function;
            String parameterXml = parameter;

            switch (function)
	        {
                case "CommercialDocumentXML":
                    {
                        procedureName = "custom.p_getCommercialDocumentXML";
                        parameterXml = "<root>" + parameter + "</root>";
                    }
                    break;
                case "Item":
                    {
                        procedureName = "custom.p_getItemDataXML";
                        parameterXml = "<root>" + parameter + "</root>";
                    }
                break;
                case "ChangedItems":
                {
                    procedureName = "custom.p_getChangedItemsDataXML";
                    parameterXml = "<root>" + parameter + "</root>";
                }
                break;
	        }
            

            try
            {

                string outputFormat = "xml";

                using (ListCoordinator c = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = String.Concat("ExecuteCustomProcedure_", procedureName);
                    retXml = new MemoryStream(Encoding.UTF8.GetBytes(c.ExecuteCustomProcedure(procedureName, parameterXml, outputFormat)));
                }
                

            }
            catch (Exception ex)
            {
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                //ServiceHelper.Instance.OnExit();
            }


            return retXml;
        }

        public static void CopyStream(Stream input, Stream output)
        {
            byte[] buffer = new byte[8 * 1024];
            int len;
            while ((len = input.Read(buffer, 0, buffer.Length)) > 0)
            {
                output.Write(buffer, 0, len);
        }
        }

        public Stream GetAllDocumentsReport()
        {
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = true;

            Stream stream = new MemoryStream();
            StreamWriter writer = new StreamWriter(stream);
            string contentType = this.GetContentTypeForOutputFormat("TEXT");

            ListCoordinator c = new ListCoordinator();
            try
            {
                string result = c.ExecuteCustomProcedure("custom.p_getAllDocumentsReport", "<root/>");//, "csv");
                writer.Write(result);
                stream.Position = 0;
                WebOperationContext.Current.OutgoingResponse.ContentLength = stream.Length;
                WebOperationContext.Current.OutgoingResponse.ContentType = contentType;
                WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
                WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate");
            }
            catch (Exception e)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:605");
                ServiceHelper.Instance.OnException(e);
            }
            finally
            {
                c.Dispose();
                ServiceHelper.Instance.OnExit();
            }

            return stream;

        }

        public string GetPivotReport(string id)
        {
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = true;

            string result = "";

            ConfigurationCoordinator configurationCoordinator = new ConfigurationCoordinator();
            XDocument configuration = configurationCoordinator.GetConfiguration(id, SessionManager.ProfileId);
            configurationCoordinator.Dispose();
            result = configuration.ToString();

            return result;
        }

        public void SavePivotReport(string type, string name, Stream input)
        {
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = true;

            StreamReader reader = new StreamReader(input);
            string content = reader.ReadToEnd();
            string content2 = content;
        }

        private XElement LoadPrintProfile(string name)
        {
            if (String.IsNullOrEmpty(name))
                throw new ArgumentNullException("name", "name cannot be null or empty.");

            using (ConfigurationCoordinator c = new ConfigurationCoordinator())
            {
                XDocument xml = c.GetConfiguration(String.Format(CultureInfo.InvariantCulture,
                    "printing.profiles.{0}", name));

                XElement profile = (XElement)(((XElement)xml.Root.FirstNode).FirstNode);

                //load necessary configValues if needed

                if (profile.Element("configuration") != null &&
                    profile.Element("configuration").Element("configValues") != null)
                {
                    foreach (XElement configValue in profile.Element("configuration").Element("configValues").Elements())
                    {
                        xml = c.GetConfiguration(configValue.Attribute("key").Value);

                        configValue.Add(((XElement)xml.Root.FirstNode).FirstNode);
                    }
                }

                return profile;
            }
        }

        private XElement LoadConfigurationEntry(string name)
        {
            if (String.IsNullOrEmpty(name))
                throw new ArgumentNullException("name", "name cannot be null or empty.");

            string profile = this.ParseUserProfile(OperationContext.Current.RequestContext.RequestMessage.Headers.To.AbsoluteUri);

            using (ConfigurationCoordinator c = new ConfigurationCoordinator())
            {
                XDocument xml = c.GetConfiguration(name, profile);

                if (xml.Root.HasElements)
                    return (XElement)(((XElement)xml.Root.FirstNode).FirstNode);
                else
                    return null;
            }
        }

        private void MergeIncludes(XElement xslt)
        {
            List<XElement> includes = new List<XElement>();

            foreach (XElement include in xslt.Elements(XName.Get("import", "http://www.w3.org/1999/XSL/Transform")))
                includes.Add(include);

            foreach (XElement include in xslt.Elements(XName.Get("include", "http://www.w3.org/1999/XSL/Transform")))
                includes.Add(include);

            foreach (XElement include in includes)
            {
                string filename = include.Attribute("href").Value;
                XElement fileToInclude = this.LoadConfigurationEntry("printing.transformations.templates." + filename);

                if (fileToInclude == null)
                    throw new FileNotFoundException("File " + filename + " not found in the database.", filename);

                include.Parent.Add(fileToInclude.Nodes());
                include.Remove();
            }
        }

        private void LoadPrintingObjectsFromDatabase(string profileName, ref XElement profileXml, ref string transformationXml, ref string driverConfigXml, ref string outputFormat, ref string supportedBusinessObjectType, ref string wordValueLanguage,
            ref XElement validationHelperPrintingProfile)
        {
            XElement printProfile = this.LoadPrintProfile(profileName);
            validationHelperPrintingProfile = printProfile;

            if (printProfile == null)
                throw new FileNotFoundException("Profile " + profileName + " not found in the database.", profileName);

            string transformationName = printProfile.Element("transformation").Value;

            XElement xslt = this.LoadConfigurationEntry(transformationName);

            if (xslt == null)
                throw new FileNotFoundException("Transformation " + transformationName + " not found in the database.", transformationName);

            this.MergeIncludes(xslt);

            if (printProfile.Element("driverConfig") != null)
            {
                string driverConfigName = printProfile.Element("driverConfig").Value;
                driverConfigXml = this.LoadConfigurationEntry(driverConfigName).ToString(SaveOptions.DisableFormatting);

                if (driverConfigXml == null)
                    throw new FileNotFoundException("Driver config " + driverConfigName + " not found in the database.", driverConfigName);
            }

            outputFormat = printProfile.Element("outputFormat").Value;
            profileXml = printProfile;
            transformationXml = xslt.ToString(SaveOptions.DisableFormatting);
            supportedBusinessObjectType = printProfile.Element("supportedBusinessObjectType").Value;

            if (printProfile.Element("wordValueLanguage") != null)
                wordValueLanguage = printProfile.Element("wordValueLanguage").Value;
            else
                wordValueLanguage = null;
        }

        private string ParseUserProfile(string url)
        {
            if (url != null && url.Contains('?'))
            {
                string[] par = url.Substring(url.IndexOf('?') + 1).Split(new char[] { '&' }, StringSplitOptions.RemoveEmptyEntries);

                foreach (var p in par)
                {
                    string[] keyVal = p.Split(new char[] { '=' }, StringSplitOptions.RemoveEmptyEntries);
                    if (keyVal[0] == "userProfileId")
                        return keyVal[1];
                }

                return null;
            }
            else
                return null;
        }

        public Stream PrintParcelOrder(string id, string outputContentType)
        {
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = false;
            Stream result = null;
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["Main"].ConnectionString;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand("communication.p_getParcelPrint", connection))
                {


                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Clear();
                    command.Parameters.Add("@commercialDocumentHeaderId", SqlDbType.UniqueIdentifier).Value = new Guid(id);
                    using (SqlDataReader reader = command.ExecuteReader(CommandBehavior.SingleRow))
                    {
                        if (reader.Read())
                        {
                            int dataID = reader.GetOrdinal("Data");
                            if (reader[dataID] != DBNull.Value)
                            {
                                result = new MemoryStream(reader.GetSqlBinary(dataID).Value);
                            }
                        }
                    }
                }
            }


            WebOperationContext.Current.OutgoingResponse.ContentType = PrintService.PDF_CONTENT_TYPE;
            WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

         
            return result;

        }

        public string setAmount(string number, string amount)
        {
            string status = null;
            string ipAddress = null;
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = false;

            //XElement printConfig = this.LoadConfigurationEntry("system.terminalConfiguration");
            //if (printConfig == null)
            //    throw new ArgumentNullException("terminalConfiguration", "terminalConfiguration cannot be null or empty.");
            //if (printConfig != null)
            //    ipAddress = printConfig.Element("terminalAddres").Value;

            //TerminalIPAddress PedIP = new TerminalIPAddress();
            //SSLCertificate PedSSL = new SSLCertificate();
            //Status PedState = new Status();
            //PedIP.IPAddressIn = ipAddress;

            //PedIP.SetIPAddress();
            //PedSSL.PathIn = "TerminalRoot.pem";
            //PedSSL.SetPath();
            //PedState.GetTerminalState();

            //Transaction PedTRN = new Transaction();

            //PedTRN.MessageNumberIn = "11";
            //PedTRN.Amount1In = amount;
            //PedTRN.Amount1LabelIn = number;
            //PedTRN.TransactionTypeIn = "00";
            //PedTRN.DoTransaction();

            //status = PedTRN.DiagRequestOut.ToString();
            return status;
        }
        public Stream PrintBusinessObject(string id, string profileName, string outputContentType)
        {
            XElement validationProfileHelper = null;
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = false;
            Stream outputStream = null;

            try
            {
                //KernelHelpers.FastTest.Fail("Start PRINTSERVICEREQUEST: id=(" + id + "),profileName(" + profileName + "),outputContentType(" + outputContentType + ")");
                XElement profileXml = null;
                string transformationXml = null;
                string outputFormat = null;
                string driverConfigXml = null;
                string supportedBusinessObjectType = null;
                string wordValueLanguage = null;
                string customLabelsLanguage = null;

                this.LoadPrintingObjectsFromDatabase(profileName, ref profileXml, ref transformationXml, ref driverConfigXml, ref outputFormat, ref supportedBusinessObjectType, ref wordValueLanguage, ref validationProfileHelper);

                //Disable attachment
                NameValueCollection queryStringCollection = WebOperationContext.Current.IncomingRequest.UriTemplateMatch.QueryParameters;
                bool enableAttachment = queryStringCollection["attachment"] != null && queryStringCollection["attachment"].ToUpper() == "TRUE";

                string contentType = enableAttachment ? "application/octet-stream" : this.GetContentTypeForOutputFormat(outputFormat);

                string storedProcedure = null;

                this.EvaluateVariables(profileXml);

                if (profileXml.Element("storedProcedure") != null)
                    storedProcedure = profileXml.Element("storedProcedure").Value;

                bool isFiscalPrint = false;

                if (profileXml.Element("fiscalPrint") != null && profileXml.Element("fiscalPrint").Value.ToUpperInvariant() == "TRUE")
                    isFiscalPrint = true;

                if (profileXml.Element("labelsLanguage") != null)
                    customLabelsLanguage = profileXml.Element("labelsLanguage").Value;

                string dataXml = this.GetBusinessObjectXml(id, supportedBusinessObjectType, storedProcedure, isFiscalPrint, customLabelsLanguage);

                dynamic mediator = new ExpandoObject();
                mediator.id = id;
                if (!isFiscalPrint)
                {
                    ValidatePrint(ref dataXml, ref validationProfileHelper, ref mediator);
                }
                 outputStream = this.GetPrintStream(this.AppendParamsToDataXml(dataXml, wordValueLanguage, profileXml), transformationXml, profileXml.ToString(SaveOptions.DisableFormatting), driverConfigXml, outputFormat);

                WebOperationContext.Current.OutgoingResponse.ContentLength = outputStream.Length;
                WebOperationContext.Current.OutgoingResponse.ContentType = contentType;
                WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

                if (contentType != PrintService.PDF_CONTENT_TYPE && !enableAttachment)
                    WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate");

                if (enableAttachment)
                {
                    WebOperationContext.Current.OutgoingResponse.Headers.Add("Content-Disposition",
                        String.Format(CultureInfo.InvariantCulture, "attachment; filename={0}.{1}", outputContentType, outputFormat.ToLowerInvariant()));
                }
            }
            catch (Exception ex)
            {
                KernelHelpers.FastTest.Fail("Błąd logiki wydruku!" + ex.Message + ex.StackTrace);
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return outputStream;
        }

        private void ValidatePrint(ref string dataXml, ref XElement validationProfileHelper, ref dynamic mediator)
        {
            string transformationForValidation = "";
            XDocument xml = XDocument.Parse(dataXml);

            if (validationProfileHelper.Element("transformation") == null)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Error("ValidatePrint - validationProfileHelper.Element(\"transformation\") == null");
                throw new InvalidOperationException("ValidatePrint - validationProfileHelper.Element(\"transformation\") == null");
            }
            else
            {
                transformationForValidation = validationProfileHelper.Element("transformation").Value;
                if (validationProfileHelper.Element("outputFormat") == null)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Error("validationProfileHelper.Element(\"outputFormat\") == null");
                    throw new InvalidOperationException("validationProfileHelper.Element(\"outputFormat\") == null");
                }
                else
                {
                    switch (transformationForValidation)
                    {
                        case "printing.transformations.pl.pdf.commercialDocument":
                        case "printing.transformations.pl.text.commercialDocument":
                            // Required

                            string errorStep = "begin test";
                            string contractorNip = null;
                            string issuerNip = null;

                            try
                            {
                                if (xml.Root.Element("commercialDocument") == null)
                                {
                                    errorStep = @" xml.Root.Element(""commercialDocument"") == null ";
                                }

                                if (xml.Root.Element("commercialDocument").Element("xmlConstantData") == null)
                                {
                                    errorStep = @" xml.Root.Element(""commercialDocument"").Element(""xmlConstantData"") == null ";
                                }
                                else
                                {
                                    // Uwaga porzucenie logiki walidacji dla poprzednich dokumentów!

                                    if (xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant") == null)
                                    {
                                        errorStep = @" xml.Root.Element(""commercialDocument"").Element(""xmlConstantData"").Element(""constant"") == null ";
                                    }

                                    if (xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("contractor") == null)
                                    {
                                        errorStep = @" xml.Root.Element(""commercialDocument"").Element(""xmlConstantData"").Element(""constant"").Element(""contractor"") == null ";
                                    }

                                    //xpath /root/commercialDocument/xmlConstantData/constant/contractor/nip/node()[1]
                                    if (xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("contractor") != null)
                                    {
                                        if (xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("contractor").Element("nip") != null)
                                        {
                                            contractorNip = xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("contractor").Element("nip").Value;
                                            if (xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("contractor").Element("nipPrefixCountrySymbol") != null)
                                            {
                                                xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("contractor").Element("nip").Value =
                                                    xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("contractor").Element("nipPrefixCountrySymbol").Value + " " + contractorNip;
                                            }
                                        }
                                    }

                                    errorStep = "2";

                                    //xpath /root/commercialDocument/xmlConstantData/constant/issuer/addresses/address/countryId/@symbol
                                    issuerNip = xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("issuer").Element("nip").Value;
                                    if (xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("issuer").Element("nipPrefixCountrySymbol") != null)
                                    {
                                        xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("issuer").Element("nip").Value =
                                            xml.Root.Element("commercialDocument").Element("xmlConstantData").Element("constant").Element("issuer").Element("nipPrefixCountrySymbol").Value + " " + issuerNip;
                                    }

                                    dataXml = xml.ToString();
                                }
                            }
                            catch
                            {
                                KernelHelpers.FastTest.Fail("(TEST FAILED) Wydruk printing.transformations.pl.pdf.commercialDocument (walidacja wymaganych pól) (step=" + errorStep + ")");
                                throw new InvalidOperationException("(TEST FAILED) Wydruk printing.transformations.pl.pdf.commercialDocument (walidacja wymaganych pól)(step=" + errorStep + ")");
                            }
                            return;

                        case "printing.transformations.pl.pdf.InventoryDocument":
                            // Test czy niezatwierdzony - jesli tak to przeprowadza dalsze testy
                            Makolab.Fractus.Kernel.BusinessObjects.Documents.Document document = null;
                            using (DocumentCoordinator coordinator = new DocumentCoordinator())
                            {
                                document = (Makolab.Fractus.Kernel.BusinessObjects.Documents.Document)coordinator.LoadBusinessObject(BusinessObjectType.InventoryDocument, new Guid(mediator.id));
                            }
                            if (document.DocumentStatus == Makolab.Fractus.Kernel.Enums.DocumentStatus.Committed)
                            {
                                //FastTest.SendOKAlert("(TEST) Wydruk inwentaryzacji (dokument zatwierdzony)");
                                    }
                            else if (document.DocumentStatus == Makolab.Fractus.Kernel.Enums.DocumentStatus.Saved)
                            {
                                //FastTest.SendOKAlert("(TEST) Wydruk inwentaryzacji (dokument niezatwierdzony)");
                                foreach (XElement line in xml.Root.Element("warehouse").Elements("line"))
                                {
                                    string lineId = line.Element("id").Value;
                                    // Stan zliczony: Ilosc (szi) = <userQuantity>
                                    int szi = KernelService.ConvertNumberFromProcedureResponseToInteger(line.Element("userQuantity").Value);
                                    // Stan przed zliczeniem (spz) = <systemQuantity>
                                    int spz = KernelService.ConvertNumberFromProcedureResponseToInteger(line.Element("systemQuantity").Value);
                                    // Test (non = nadwyzka czy niedobor) = mozna wyliczyc sprawdzajac ilosci :) wykorzystujac <systemQuantity>
                                    int ncn = spz - szi;
                                    if (spz - szi > 0)
                                    {
                                        //Niedobor

                                        XDocument inventoryDocumentSheetLines = XDocument.Parse(KernelService.ExecuteCustomProcedureStatic("document.p_getInventoryDocumentSheetLines",
                                        @"<param><inventoryDocumentHeaderId>" + mediator.id + "</inventoryDocumentHeaderId></param>",
                                        "xml"));

                                        // Stan zliczony: wartosc (szw) = z line <itemValue>
                                        decimal szw = decimal.Parse(line.Element("itemValue").Value.Replace(".", ",")); // TODO i18n
                                        // Niedobor : wartosc = wyliczenie z dostaw
                                        string itemID = line.Element("itemId").Value;
                                        string warehouseID = inventoryDocumentSheetLines.Root.Element("line").Element("warehouseId").Value;
                                        XDocument deliveries = XDocument.Parse(KernelService.ExecuteCustomProcedureStatic("item.p_getDeliveriesWithNoLock",
                                        @"<root><item id=""" + itemID + @""" warehouseId=""" + warehouseID + @"""/></root>",
                                        "xml"));

                                        //Test (szw) = (w = Aktualna wartosc towaru) (v = corrected <value> wartosc niedoboru)
                                        decimal w = 0;
                                        decimal v = 0;
                                        foreach (XElement delivery in deliveries.Root.Elements("delivery"))
                                        {
                                            decimal q = KernelService.ConvertNumberFromProcedureResponseToInteger(delivery.Attribute("quantity").Value);
                                            decimal price = decimal.Parse(delivery.Attribute("price").Value.Replace(".", ",")); // TODO i18n
                                            w += q * price;

                                            if ((ncn != 0) && (ncn <= q))
                                            {
                                                v += ncn * price;
                                                ncn = 0;
                                            }
                                            else if (ncn != 0)
                                            {
                                                v += q * price;
                                                ncn = ncn - Convert.ToInt32(q);
                                            }
                                        }

                                        if (szw != (w - v))
                                        {
                                            //FastTest.SendFailAlertWithMail("(TEST FAILED) Wydruk inwentaryzacji (dokument niezatwierdzony) (test zgodności (Stan zliczony wartość(" + szw + ") != wartość towaru w magazynie(" + w + ") - wartość niedonoru(" + v + ")))" +
                                            //    "procedura EXEC [print].[p_getInventoryDocumentSheetLines] @documentHeaderId = '" + mediator.id + "'" + "lineID=" + lineId + " <itemValue> should be = (" + (w - v).ToString() + ") and <value> = (" + v.ToString() + ")");
                                            // throw new InvalidOperationException("(TEST FAILED) Wydruk inwentaryzacji (dokument niezatwierdzony) (test zgodności (Stan zliczony wartość("+szw+") != wartość towaru w magazynie("+w+") - wartość niedonoru("+v+")))" +
                                            //     "procedura EXEC [print].[p_getInventoryDocumentSheetLines] @documentHeaderId = '" + mediator.id + "'" + "lineID=" + lineId + " <itemValue> should be = (" + (w - v).ToString() + ") and <value> = (" + v.ToString() + ")");

                                            // Korekta wartosci
                                            line.Element("itemValue").Value = (w - v).ToString().Replace(",", ".");
                                            line.Element("value").Value = v.ToString().Replace(",", ".");
                                        }
                                        else
                                        {
                                            // szw ok korekta v :)
                                            line.Element("value").Value = v.ToString().Replace(",", ".");
                                        }
                                    }
                                }
                            }
                            else
                            {
                                KernelHelpers.FastTest.Fail("Nieprawidłowa wartość DocumentStatus dla obiektu Document - printing.transformations.pl.pdf.InventoryDocument");
                                throw new InvalidOperationException("Nieprawidłowa wartość DocumentStatus dla obiektu Document - printing.transformations.pl.pdf.InventoryDocument");
                            }

                            dataXml = xml.ToString();

                            return;
                    }

                    RoboFramework.Tools.RandomLogHelper.GetLog().Fatal("ValidationNotReady for (" + transformationForValidation + ")");
                    return;
                }
            }
        }

        private void EvaluateVariables(XElement profile)
        {
            if (profile.Element("configuration") != null &&
                profile.Element("configuration").Element("header") != null)
            {
                XElement header = profile.Element("configuration").Element("header");

                foreach (XElement element in header.Descendants())
                {
                    foreach (XAttribute attr in element.Attributes())
                    {
                        if (attr.Value.Contains("$[resourcesDir]"))
                        {
                            attr.Value = attr.Value.Replace("$[resourcesDir]", PrintService.ResourcesDir);
                        }
                    }
                }
            }
        }

        private string GetBusinessObjectXml(string id, string type, string storedProcedure, bool isFiscalPrint, string customLabelsLanguage)
        {
            string retXml = null;
            BusinessObjectType boType;

            try
            {
                boType = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), type, true);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:607");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + type);
            }

            XDocument xml = this.CreateRequestXml(boType, id, storedProcedure, isFiscalPrint);

            Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(boType);

            try
            {
                retXml = c.LoadBusinessObjectForPrinting(xml, customLabelsLanguage).ToString();
            }
            finally
            {
                c.Dispose();
            }

            return retXml;
        }

        private MemoryStream GetPrintStream(string dataXml, string xslt, string printProfile, string driverConfig, string outputFormat)
        {
            MemoryStream stream = new MemoryStream();
            MakoPrint.Generate(dataXml, xslt, printProfile, driverConfig, outputFormat, stream);
            stream.Position = 0;
            return stream;
        }

        private XDocument CreateRequestXml(BusinessObjectType type, string id, string storedProcedure, bool isFiscalPrint)
        {
            XDocument xdoc = XDocument.Parse("<root></root>");
            xdoc.Root.Add(new XElement("type", type.ToString()));
            xdoc.Root.Add(new XElement("id", id));
            xdoc.Root.Add(new XElement("isFiscalPrint", isFiscalPrint.ToString(CultureInfo.InvariantCulture)));

            if (!String.IsNullOrEmpty(storedProcedure))
                xdoc.Root.Add(new XElement("storedProcedure", storedProcedure));

            return xdoc;
        }

        private string GetContentTypeForOutputFormat(string format)
        {
            string contentType = null;

            switch (format.ToUpperInvariant())
            {
                case "PDF":
                    contentType = PDF_CONTENT_TYPE;
                    break;
                case "CSV":
                    contentType = CSV_CONTENT_TYPE;
                    break;
                case "XLS":
                    contentType = EXCEL_CONTENT_TYPE;
                    break;
                case "XML":
                    contentType = XML_CONTENT_TYPE;
                    break;
                case "VCF":
                    contentType = VCARD_CONTENT_TYPE;
                    break;
                case "HTML":
                    contentType = HTML_CONTENT_TYPE;
                    break;
                case "TEXT":
                    contentType = TEXT_CONTENT_TYPE;
                    break;
                default:
                    throw new InvalidOperationException("Unknown output format: " + format);
            }

            return contentType;
        }

        public Stream GenerateGuidBarcode(string guid)
        {
            Guid g = new Guid(guid.Substring(1));
            string encoded = Convert.ToBase64String(g.ToByteArray());

            encoded = guid[0].ToString() + encoded;

            return this.GenerateBarcode(encoded);
        }

        public Stream GenerateBarcode(string code)
        {
            Image img = null;
            if (code.Length == 18)			// EAN 13 + addon 5
                img = CodeEAN13Rendering.MakeBarcodeImage(code);
            else
                img = Code128Rendering.MakeBarcodeImage(code, 1, false);

            MemoryStream stream = new MemoryStream();
            img.Save(stream, ImageFormat.Gif);

            stream.Flush();
            stream.Position = 0;

            WebOperationContext.Current.OutgoingResponse.ContentLength = stream.Length;
            WebOperationContext.Current.OutgoingResponse.ContentType = "image/gif";

            return stream;
        }

        public Stream GetFile(string fileName)
        {
            string destinationPath = ConfigurationManager.AppSettings["TempFolder"];
            string filePath = null;

            if (!Path.IsPathRooted(destinationPath))
                destinationPath = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, destinationPath);

            filePath = Path.Combine(destinationPath, fileName);

            return new FileStream(filePath, FileMode.Open, FileAccess.Read);
        }

        public Stream GetFileUtf(string fileName)
        {
            string destinationPath = ConfigurationManager.AppSettings["TempFolder"];
            string filePath = null;

            if (!Path.IsPathRooted(destinationPath))
                destinationPath = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, destinationPath);

            filePath = Path.Combine(destinationPath, fileName);
            StreamReader r = new StreamReader(filePath, Encoding.UTF8);
            return r.BaseStream;

        }

        public Stream PutFile(Stream input)
        {
            string destinationPath = ConfigurationManager.AppSettings["TempFolder"];
            string fileName = Guid.NewGuid().ToUpperString();
            string filePath = null;

            if (!Path.IsPathRooted(destinationPath))
                destinationPath = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, destinationPath);

            filePath = Path.Combine(destinationPath, fileName);

            ICollection<UploadedFile> files = UploadHelper.ExtractFiles(input);
            UploadedFile file = files.First();

            using (FileStream w = File.Open(filePath, FileMode.Create, FileAccess.Write))
            {
                w.Write(file.Data, 0, file.Data.Length);

                w.Flush();
                w.Close();
            }

            WebOperationContext.Current.OutgoingResponse.ContentType = "text/plain";

            return new MemoryStream(Encoding.UTF8.GetBytes(fileName));
        }



        public Stream Test(Stream input)
        {

            string destinationPath = ConfigurationManager.AppSettings["TempFolder"];
            string fileName = Guid.NewGuid().ToUpperString();
            string filePath = null;
 
            if (!Path.IsPathRooted(destinationPath))
                destinationPath = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, destinationPath);
             
            filePath = Path.Combine(destinationPath, fileName);
            byte[] buffer ;
            buffer = input.ToByteArray();
            bool t = false;
            foreach (byte item in buffer)
            {
                if (item == 197)
                {
                    t = true;
                    break;
                }
            }

            if (t)
                buffer = Encoding.Convert(Encoding.UTF8, Encoding.GetEncoding("windows-1252"), buffer); //Encoding.GetEncoding("windows-1252")
              
            
            return new MemoryStream(buffer);
            
        }


        public Stream PutFileAnsi(Stream input)
        {
            string destinationPath = ConfigurationManager.AppSettings["TempFolder"];
            string fileName = Guid.NewGuid().ToUpperString();
            string filePath = null;
            Stream tmp = new System.IO.MemoryStream();
            if (!Path.IsPathRooted(destinationPath))
                destinationPath = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, destinationPath);
             
            filePath = Path.Combine(destinationPath, fileName);
            byte[] buffer ;

            buffer = input.ToByteArray();

            if (buffer[0] == 0xef && buffer[1] == 0xbb && buffer[2] == 0xbf)
            {
                using (StreamReader sr = new StreamReader(input, Encoding.Default))
                {
                    buffer = Encoding.Convert(sr.CurrentEncoding, Encoding.UTF8, buffer);
                }
                return null;
            }

            ICollection<UploadedFile> files;
            files = UploadHelper.ExtractFiles(buffer); 

            UploadedFile file = files.First();
            

            using (FileStream w = File.Open(filePath, FileMode.Create, FileAccess.Write))
            {
                w.Write(file.Data, 0, file.Data.Length);

                w.Flush();
                w.Close();
            }

            WebOperationContext.Current.OutgoingResponse.ContentType = "text/plain";

            return new MemoryStream(Encoding.UTF8.GetBytes(fileName));
        }
 
        

        public Stream GetExportToAccountingFile(string procedureName, string fileName)
        {
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = true;

            Stream outputStream = null;
            StreamWriter sw = null;

            string contentType = "application/octet-stream";

            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                var configEntry = ConfigurationMapper.Instance.GetSingleConfigurationEntry("system.taskManagerSqlCommandTimeout");
                int? sqlCommandTimeout = configEntry != null ? (int?)Convert.ToInt32(configEntry.Value.Value, CultureInfo.InvariantCulture) : null;

                XDocument xmlParam = this.CreateXmlParamFromQueryString();

                XElement result = DependencyContainerManager.Container.Get<ListMapper>().ExecuteCustomProcedure(procedureName, true, xmlParam, true, sqlCommandTimeout);

                //convert to a file
                outputStream = new MemoryStream();
                sw = new StreamWriter(outputStream);

                foreach (var row in result.Elements())
                {
                    XAttribute lineAttr = row.Attribute(XmlName.Line);
                    if (lineAttr != null)
                    {
                        sw.WriteLine(lineAttr.Value);
                    }
                }
                sw.Flush();
                outputStream.Position = 0;

                //write file to response
                WebOperationContext.Current.OutgoingResponse.ContentLength = outputStream.Length;
                WebOperationContext.Current.OutgoingResponse.ContentType = contentType;
                WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

                WebOperationContext.Current.OutgoingResponse.Headers.Add("Content-Disposition",
                    String.Format(CultureInfo.InvariantCulture, "attachment; filename={0}", fileName));
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:608");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                SqlConnectionManager.Instance.ReleaseConnection();
                ServiceHelper.Instance.OnExit();
            }

            return outputStream;
        }

        private XDocument CreateXmlParamFromQueryString()
        {
            XDocument xmlDoc = XDocument.Parse(XmlName.EmptyRoot);
            NameValueCollection queryStringCollection = WebOperationContext.Current.IncomingRequest.UriTemplateMatch.QueryParameters;
            if (queryStringCollection != null && queryStringCollection.Count > 0)
            {
                foreach (string key in queryStringCollection.AllKeys)
                {
                    xmlDoc.Root.Add(new XElement(key, queryStringCollection[key]));
                }
            }
            return xmlDoc;
        }
    }
}
