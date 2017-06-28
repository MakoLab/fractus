using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;

namespace Makolab.Fractus.Messenger
{
    public class HttpWebResponseWrapper : Makolab.Fractus.Messenger.IHttpWebResponseWrapper
    {
        private HttpWebResponse response;

        public HttpWebResponseWrapper(HttpWebResponse webResponse)
        {
            this.response = webResponse;
        }

        public bool IsMutuallyAuthenticated
        {
            get
            {
                return this.response.IsMutuallyAuthenticated;
            }
        }

        public CookieCollection Cookies
        {
            get
            {
                return this.response.Cookies;
            }
            set
            {
                this.response.Cookies = value;
            }
        }

        public WebHeaderCollection Headers
        {
            get
            {
                return this.response.Headers;
            }
        }

        public long ContentLength
        {
            get
            {
                return this.response.ContentLength;
            }
        }

        public string ContentEncoding
        {
            get
            {
                return this.response.ContentEncoding;
            }
        }

        public string ContentType
        {
            get
            {
                return this.response.ContentType;
            }
        }

        public string CharacterSet
        {
            get
            {
                return this.response.CharacterSet;
            }
        }

        public string Server
        {
            get
            {
                return this.response.Server;
            }
        }

        public DateTime LastModified
        {
            get
            {
                return this.response.LastModified;
            }
        }

        public HttpStatusCode StatusCode
        {
            get
            {
                return this.response.StatusCode;
            }
        }

        public string StatusDescription
        {
            get
            {
                return this.response.StatusDescription;
            }
        }

        public Version ProtocolVersion
        {
            get
            {
                return this.response.ProtocolVersion;
            }
        }

        public Uri ResponseUri
        {
            get
            {
                return this.response.ResponseUri;
            }
        }

        public string Method
        {
            get
            {
                return this.response.Method;
            }
        }

        public Stream GetResponseStream()
        {
            return this.response.GetResponseStream();
        }

        public void Close()
        {
            this.response.Close();
        }

        public string GetResponseHeader(string headerName)
        {
            return this.response.GetResponseHeader(headerName);
        }
    }
}
