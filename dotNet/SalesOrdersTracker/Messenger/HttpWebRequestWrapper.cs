using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;

namespace Makolab.Fractus.Messenger
{
    public class HttpWebRequestWrapper : IHttpWebRequestWrapper
    {
        private HttpWebRequest httpWebRequest;

        public HttpWebRequestWrapper(string url)
        {
            this.httpWebRequest = (HttpWebRequest)HttpWebRequest.Create(url);
        }

        public HttpWebRequestWrapper(Uri url)
        {
            this.httpWebRequest = (HttpWebRequest)HttpWebRequest.Create(url);
        }

        public Stream GetRequestStream()
        {
            return this.httpWebRequest.GetRequestStream();
        }

        public IHttpWebResponseWrapper GetResponse()
        {
            return new HttpWebResponseWrapper((HttpWebResponse)this.httpWebRequest.GetResponse());
        }

        public Int64 ContentLength
        {
            get { return this.httpWebRequest.ContentLength; }
            set { this.httpWebRequest.ContentLength = value; }
        }

        public string Method
        {
            get { return this.httpWebRequest.Method; }
            set { this.httpWebRequest.Method = value; }
        }

        public string ContentType
        {
            get { return this.httpWebRequest.ContentType; }
            set { this.httpWebRequest.ContentType = value; }
        }

        public Uri RequestUri
        { 
            get
            {
                return this.httpWebRequest.RequestUri;
            }
        }
    }

}
