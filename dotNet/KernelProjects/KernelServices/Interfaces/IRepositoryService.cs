using System.IO;
using System.ServiceModel;
using System.ServiceModel.Web;

namespace Makolab.Fractus.Kernel.Services
{
    [ServiceContract]
    public interface IRepositoryService
    {
        [OperationContract]
        [WebGet(UriTemplate = "GetFile/{name}", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream GetFile(string name);

        [OperationContract]
        [WebInvoke(UriTemplate = "PutFile", BodyStyle = WebMessageBodyStyle.Bare)]
        Stream PutFile(Stream input);
    }
}
