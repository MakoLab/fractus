using System.IO;
using System.ServiceModel;
using System.ServiceModel.Web;

namespace Makolab.Fractus.Kernel.Services
{
    [ServiceContract]
    public interface IPrintService
    {
        [OperationContract]
        [WebInvoke(UriTemplate = "DownloadResource", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream DownloadResource(Stream packedId);

        [OperationContract]
        [WebGet(UriTemplate = "PrintBusinessObject/{id}/{profileName}/{outputContentType}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PrintBusinessObject(string id, string profileName, string outputContentType);

        [OperationContract]
        [WebGet(UriTemplate = "setAmount/{number}/{amount}", BodyStyle = WebMessageBodyStyle.Bare)]
        string setAmount(string number, string amount);


        [OperationContract]
        [WebGet(UriTemplate = "PrintParcelOrder/{id}/{outputContentType}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PrintParcelOrder(string id, string outputContentType);

        [OperationContract]
        [WebInvoke(UriTemplate = "PrintXml", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PrintXml(Stream input);

        [OperationContract]
        [WebGet(UriTemplate = "GetXml/{function}/{parameter}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GetXml(string function, string parameter);

        [OperationContract]
        [WebInvoke(UriTemplate = "XlsToXml", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream XlsToXml(Stream input);

        [OperationContract]
        [WebInvoke(UriTemplate = "XlsToXmlGeneric", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream XlsToXmlGeneric(Stream input);

        [OperationContract]
        [WebGet(UriTemplate = "GenerateBarcode/{code}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GenerateBarcode(string code);

        [OperationContract]
        [WebGet(UriTemplate = "GenerateGuidBarcode/{guid}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GenerateGuidBarcode(string guid);

        [OperationContract]
        [WebInvoke(UriTemplate = "PutFile", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PutFile(Stream input);

        [OperationContract]
        [WebGet(UriTemplate = "GetFile/{fileName}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GetFile(string fileName);

        [OperationContract]
        [WebGet(UriTemplate = "GetFileUtf/{fileName}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GetFileUtf(string fileName);

        [OperationContract]
        [WebInvoke(UriTemplate = "PutFileAnsi", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PutFileAnsi(Stream input);

        [OperationContract]
        [WebInvoke(UriTemplate = "Test", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream Test(Stream input);

		[OperationContract]
		[WebGet(UriTemplate = "GetExportToAccountingFile/{procedureName}/{fileName}", BodyStyle = WebMessageBodyStyle.Bare)]
		Stream GetExportToAccountingFile(string procedureName, string fileName);

        [OperationContract]
        [WebGet(UriTemplate = "GetAllDocumentsReport", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GetAllDocumentsReport();

        [OperationContract]
        [WebInvoke(UriTemplate = "SavePivotReport/?type={type}&name={name}", BodyStyle = WebMessageBodyStyle.WrappedRequest)]
        void SavePivotReport(string type, string name, Stream input);
	}
}
