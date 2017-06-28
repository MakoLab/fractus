using System;
namespace Makolab.Fractus.Messenger
{
    public interface IHttpWebRequestWrapper
    {
        long ContentLength { get; set; }
        string ContentType { get; set; }
        System.IO.Stream GetRequestStream();
        IHttpWebResponseWrapper GetResponse();
        string Method { get; set; }
        Uri RequestUri { get; }
    }
}
