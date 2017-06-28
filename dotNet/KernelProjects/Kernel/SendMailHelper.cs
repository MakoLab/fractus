namespace KernelHelpers
{
    using System;
    using System.Net;
    using System.Text;
    using System.Web;
    using System.IO;

    /// <summary>
    /// Send Mail handler helper 
    /// </summary>
    internal static class SendMailHelper
    {
        /// <summary>
        /// Performs the single send mail request.
        /// </summary>
        /// <param name="postData">The post data.</param>
        /// <param name="sendMailHandlerUrl">Url to the send mail handler</param>
        internal static void PerformSingleSendMailRequest(string postData, string sendMailHandlerUrl)
        {
            if (sendMailHandlerUrl == null)
            {
                throw new InvalidOperationException("SendMailHelper::PerformSingleSendMailRequest::sendMailHandlerUrl is null");
            }

            if (postData == null)
            {
                throw new InvalidOperationException("SendMailHelper::PerformSingleSendMailRequest::postData is null");
            }

            WebRequest request = WebRequest.Create(sendMailHandlerUrl);
            request.Method = "POST";
            byte[] byteArray = Encoding.UTF8.GetBytes(postData);
            request.ContentType = "text/xml";
            request.ContentLength = byteArray.Length;
            string responseFromServer = null;
            using (Stream dataStream = request.GetRequestStream())
            {
                dataStream.Write(byteArray, 0, byteArray.Length);
            }

            using (WebResponse response = request.GetResponse())
            {
                if ("OK" != ((HttpWebResponse)response).StatusDescription)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Error("SendMailGeneralError: (\"OK\" != ((HttpWebResponse)response).StatusDescription)");
                    return;
                }

                using (Stream dataStream = response.GetResponseStream())
                {
                    using (StreamReader reader = new StreamReader(dataStream))
                    {
                        responseFromServer = reader.ReadToEnd();
                    }
                }
            }

            if (responseFromServer != "<root><mail>OK</mail></root>")
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Error("SendMailGeneralError: (responseFromServer != \"<root><mail>OK</mail></root>\")");
                return;
            }
        }
    }
}