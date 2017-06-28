using System.Collections.Specialized;
using System.IO;
using System.ServiceModel;
using System.ServiceModel.Web;

namespace Makolab.Fractus.Kernel.Services
{
    [ServiceContract]
    public interface IKernelService
    {
        [OperationContract]
        string LogOn(string requestXml);

        [OperationContract]
        void LogOff();

        [OperationContract]
        string GetVersion();

        [OperationContract]
        string Delay(int mills);

		[OperationContract]
		string GetConfiguration(string keys);

		[OperationContract]
		string GetConfigurationByBranch(string requestXml);

		[OperationContract]
		string GetConfigurationKeys();

		[OperationContract]
        string SaveConfiguration(string requestXml);

		[OperationContract]
		string SaveConfigurationByBranch(string requestXml);

        [OperationContract]
        string CreateNewBusinessObject(string requestXml);

        [OperationContract]
        string SaveBusinessObject(string requestXml);

        [OperationContract]
        string GetDocuments(string requestXml);

        [OperationContract]
        string GetContractors(string requestXml);

        [OperationContract]
        string GetFileDescriptors();

        [OperationContract]
        string GetOwnCompanies();

        [OperationContract]
        string GetItems(string requestXml);

        [OperationContract]
        string GetProductionItems(string requestXml);

        [OperationContract]
        string GetDictionaries();

        [OperationContract]
        string LoadBusinessObject(string requestXml);

        [OperationContract]
        string GetLogByDate(string date);

        [OperationContract]
        string DeleteBusinessObject(string requestXml);

        [OperationContract]
        string GetHttpResponse(string url);

        [OperationContract]
        string CreateItemEquivalentGroup(string requestXml);

        [OperationContract]
        string CreateItemEquivalent(string requestXml);

        [OperationContract]
        string RemoveItemFromEquivalentGroup(string requestXml);

        [OperationContract]
        string RemoveItemFromEquivalent(string requestXml);

		[OperationContract]
		string CreateItemsBarcodes(string requestXml);

        [OperationContract]
        string LoadDictionary(string dictionary);

        [OperationContract]
        string SaveDictionary(string requestXml);

        [OperationContract]
        [WebGet(UriTemplate = "dictionaries/", ResponseFormat = WebMessageFormat.Xml)]
        int GetDictionariesVersion();

        [OperationContract]
        string GetFreeDocumentNumber(string requestXml);

        [OperationContract]
        string GetTemplates();

        [OperationContract]
        bool CheckNumberExistence(string requestXml);

        [OperationContract]
        string GetRandomContractors(string amount);

        [OperationContract]
        string GetRandomCommercialDocumentLines(string amount);

        [OperationContract]
        string GetRandomWarehouseDocumentLines(string amount);

        [OperationContract]
        string GetRandomKeywords(string requestXml);

        //[OperationContract]
        //string ExecuteCustomProcedure(string procedureName, string parameterXml);

        [OperationContract]
        [WebGet(UriTemplate = "ExecuteCustomProcedure/?procedureName={procedureName}&parameterXml={parameterXml}&outputFormat={outputFormat}")]
        //[WebInvoke(UriTemplate = "ExecuteCustomProcedure/?procedureName={procedureName}&parameterXml={parameterXml}&outputFormat={outputFormat}", BodyStyle = WebMessageBodyStyle.Bare)]
        string ExecuteCustomProcedure(string procedureName, string parameterXml, string outputFormat);

        [OperationContract]
        string RelateCommercialDocumentToWarehouseDocuments(string requestXml);

        [OperationContract]
        string UnrelateCommercialDocumentFromWarehouseDocuments(string requestXml);

        [OperationContract]
        string ChangeDocumentStatus(string requestXml);

        [OperationContract]
        string FiscalizeCommercialDocument(string requestXml);

        [OperationContract]
        string GetUserLanguageVersion();

        [OperationContract]
        string TestProc(string xml);

        [OperationContract]
        string GetContractorDealing(string requestXml);

        [OperationContract]
        string GetPermissionProfiles();

        [OperationContract]
        string GetWarehouseDocumentLinesTree(string requestXml);

        [OperationContract]
        string GetOpenedFinancialReport(string requestXml);

        [OperationContract]
        string CreateTask(string requestXml);

        [OperationContract]
        string QueryTask(string requestXml);

        [OperationContract]
        string GetTaskResult(string requestXml);

        [OperationContract]
        string TerminateTask(string requestXml);

        [OperationContract]
        string SaveWarehouseMap(string requestXml);

        [OperationContract]
        string GetItemsDetails(string requestXml);

        [OperationContract]
        string LoadShiftTransactionByShiftId(string requestXml);

        [OperationContract]
        string GetDocumentOperations(string requestXml);

        [OperationContract]
        string ChangeProcessState(string requestXml);

        [OperationContract]
        string UpdateItemCataloguePrices(string requestXml);

        [OperationContract]
        [WebInvoke(UriTemplate="SavePivotReport")]
        string SavePivotReport(Stream formsData);

        [OperationContract]
        [WebInvoke(Method = "GET", UriTemplate = "GetPivotReport?id={id}")]
        Stream GetPivotReport(string id);

        [OperationContract]
        [WebInvoke(UriTemplate = "GetPivotReportsList")]
        string GetPivotReportsList();
    }
}
