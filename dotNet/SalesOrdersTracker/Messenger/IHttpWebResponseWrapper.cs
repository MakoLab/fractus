using System;
namespace Makolab.Fractus.Messenger
{
    public interface IHttpWebResponseWrapper
    {
        string CharacterSet { get; }
        void Close();
        string ContentEncoding { get; }
        long ContentLength { get; }
        string ContentType { get; }
        System.Net.CookieCollection Cookies { get; set; }
        string GetResponseHeader(string headerName);
        System.IO.Stream GetResponseStream();
        System.Net.WebHeaderCollection Headers { get; }
        bool IsMutuallyAuthenticated { get; }
        DateTime LastModified { get; }
        string Method { get; }
        Version ProtocolVersion { get; }
        Uri ResponseUri { get; }
        string Server { get; }
        System.Net.HttpStatusCode StatusCode { get; }
        string StatusDescription { get; }
    }
}
