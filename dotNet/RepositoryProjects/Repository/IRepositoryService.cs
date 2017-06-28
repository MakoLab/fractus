using System.IO;
using System.ServiceModel;
using System.ServiceModel.Web;

namespace Makolab.Repository
{
    [ServiceContract]
    public interface IRepositoryService
    {
        [OperationContract]
        [WebInvoke(UriTemplate = "PutFile", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PutFile(Stream input);

        [OperationContract]
        [WebInvoke(UriTemplate = "PutSingleFile", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PutSingleFile(Stream input);

        [OperationContract]
        [WebGet(UriTemplate = "GetFile/{name}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GetFile(string name);
    }
}
