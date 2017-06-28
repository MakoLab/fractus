using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using log4net;

namespace Makolab.Fractus.Printing
{
    public class CrossDomainWebServer
    {
        private int port;
        private HttpListener httpListener;
        private bool isRunning;
        private string crossDomainXml = @"<?xml version='1.0'?>
<!DOCTYPE cross-domain-policy SYSTEM 'http://www.adobe.com/xml/dtds/cross-domain-policy.dtd'>
<cross-domain-policy>
    <site-control permitted-cross-domain-policies='all'/>
    <allow-access-from domain='*'/>
    <allow-http-request-headers-from domain='*' headers='*' />
</cross-domain-policy>";

        public ILog Log { get; set; }

        public CrossDomainWebServer(int port)
        {
            this.port = port;

            if (!HttpListener.IsSupported)
            {
                Console.WriteLine ("Windows XP SP2 or Server 2003 is required to use the HttpListener class.");
                throw new Exception("Windows XP SP2 or Server 2003 is required to use the HttpListener class.");
            }

            this.httpListener = new HttpListener();
            this.httpListener.Prefixes.Add(String.Format("http://+:{0}/", this.port));
        }

        public void Start()
        {
            this.isRunning = true;
            this.httpListener.Start();
            this.httpListener.BeginGetContext(new AsyncCallback(ListenerCallback), this.httpListener);
        }

        public void Close()
        {
            this.isRunning = false;
            this.httpListener.Close();
        }

        public void ListenerCallback(IAsyncResult result)
        {
            try
            {
                if (this.isRunning)
                {
                    HttpListener listener = (HttpListener)result.AsyncState;
                    HttpListenerContext context = listener.EndGetContext(result);
                    listener.BeginGetContext(new AsyncCallback(ListenerCallback), listener);
                    // Call EndGetContext to complete the asynchronous operation.
                    HttpListenerRequest request = context.Request;
                    // Obtain a response object.
                    //Console.WriteLine(request.Url);
                    HttpListenerResponse response = context.Response;
                    response.ContentType = "text/x-cross-domain-policy";
                    response.ContentEncoding = Encoding.UTF8;
                    response.KeepAlive = false;
                    // Construct a response.
                    byte[] buffer = System.Text.Encoding.UTF8.GetBytes(this.crossDomainXml);
                    // Get a response stream and write the response to it.
                    response.ContentLength64 = buffer.Length;
                    System.IO.Stream output = response.OutputStream;
                    output.Write(buffer, 0, buffer.Length);
                    // You must close the output stream.
                    output.Close();
                }
            }
            catch (Exception e)
            {
                this.Log.Error("CrossDomainWebServer.ListenerCallback Error", e);
            }
        }
    }
}
