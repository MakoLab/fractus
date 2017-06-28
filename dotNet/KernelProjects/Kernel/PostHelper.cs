namespace KernelHelpers
{
    using System;
    using System.Net;
    using System.IO;
    using System.Collections;
    using System.Web;

    class WebPostRequest
    {
        WebRequest theRequest;
        HttpWebResponse theResponse;
        ArrayList theQueryData;

        internal WebPostRequest(string url)
        {
            theRequest = WebRequest.Create(url);
            theRequest.Method = "POST";
            theQueryData = new ArrayList();
        }

        internal void Add(string key, string value)
        {
            theQueryData.Add(String.Format("{0}={1}", key, value));
        }

        internal string GetResponse()
        {
            theRequest.ContentType = "application/x-www-form-urlencoded";
            string Parameters = String.Join("&", (String[])theQueryData.ToArray(typeof(string)));
            theRequest.ContentLength = Parameters.Length;
            StreamWriter sw = new StreamWriter(theRequest.GetRequestStream());
            sw.Write(Parameters);
            sw.Close();
            theResponse = (HttpWebResponse)theRequest.GetResponse();
            StreamReader sr = new StreamReader(theResponse.GetResponseStream());
            string result = sr.ReadToEnd();
            sr.Close();
            theResponse.Close();
            return result;
        }
    }
}

