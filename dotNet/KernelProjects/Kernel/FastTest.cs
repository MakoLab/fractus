namespace KernelHelpers
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Web;
    using System.Configuration;
    using KernelHelpers;

    internal static class FastTest
    {
        private static readonly string ServerName = ConfigurationManager.AppSettings["ServerIdentification"];

        public static void Fail(string m)
        {
            if (ServerName == null)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Error("Server identity cannot be null - please set unique name in webconfig with key <appSettings><add key=\"ServerIdentification\" value=\"Something unique for fast diagnose distributed problem :))\" />" + m);
                throw new InvalidOperationException(SendRemoteFail("Server identity cannot be null - please set unique name in webconfig with key <appSettings><add key=\"ServerIdentification\" value=\"Something unique for fast diagnose distributed problem :))\" />" + m));
            }

            RoboFramework.Tools.RandomLogHelper.GetLog().Error("(" + ServerName + ")" + m);
            new System.Threading.Thread(new System.Threading.ThreadStart(delegate()
            {
                SendRemoteFail("(" + ServerName + ")" + m);
            })).Start();
        }

        private static string SendRemoteFail(string m)
        {
            m += "(" + RoboFramework.Tools.RandomLogHelper.LOG_NAME + ") ";

            //try
            //{
            //    
            //    WebPostRequest ipcPost = new WebPostRequest("http://demo.fractus.pl/fractus/f2test/ipc.ashx");
            //    ipcPost.Add("obj", @"command=put*code=notify*key=" + Guid.NewGuid() + @"*value={""notify"": [{""global"":[{""m"":""" +
            //        HttpUtility.UrlEncode(m.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\b", "\\b").Replace("\f", "\\f").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t").Replace("*", "#star#").Replace("=", "#equal#"))
            //        + @""",""t"":""e"",""b"":""s"",""p"":""t""}]}]}");
            //    ipcPost.Add("rct", "jsonp");
            //    ipcPost.Add("pnm", "MessageStore");
            //    ipcPost.Add("sht", ".");
            //    string result = ipcPost.GetResponse();
            //    if (result != "({})")
            //    {
            //        RoboFramework.Tools.RandomLogHelper.GetLog().Error("SendRemoteFail:: notify send error result != ({})");
            //    }
            //}
            //catch (Exception ex)
            //{
            //    RoboFramework.Tools.RandomLogHelper.GetLog().Error("SendRemoteFail:: notify send error" + ex.Message + ex.StackTrace);
            //}

            try
            {
                KernelHelpers.SendMailHelper.PerformSingleSendMailRequest(
                @"<mail><recipent>Arkadiusz.Schwarz@makolab.net</recipent><topic>Fractus Bug logger - there is new bug !</topic><data> 
                        <content_plain> " + "<![CDATA[" + "UTF8_BYTES_BASE64_ENCODED:" + System.Convert.ToBase64String(Encoding.UTF8.GetBytes(m)) + @"]]> </content_plain>" +
                    "<content_html>" + "<html><body><![CDATA[" + "UTF8_BYTES_BASE64_ENCODED:" + System.Convert.ToBase64String(Encoding.UTF8.GetBytes(m)) + @"]]> </body></html></content_html>
                            </data></mail>", "https://forigami.pl/system/sendmail.ashx");
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Error("SendFailMail:: notify send error (No unique server name) " + ex.Message + ex.StackTrace);
            }
            return m;
        }

        //internal static void SendOKAlert(string m)
        //{
        //    new System.Threading.Thread(new System.Threading.ThreadStart(delegate()
        //    {
        //        try
        //        {
        //            m += " (eid=" + new Random().Next(0, 1000000000) + ")(" + RoboFramework.Tools.RandomLogHelper.LOG_NAME + ") ";
        //            WebPostRequest ipcPost = new WebPostRequest("http://demo.fractus.pl/fractus/f2test/ipc.ashx");
        //            ipcPost.Add("obj", @"command=put*code=notify*key=" + Guid.NewGuid() + @"*value={""notify"": [{""global"":[{""m"":""" + "(" + ServerName + ")" + " " +
        //                HttpUtility.UrlEncode(m.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\b", "\\b").Replace("\f", "\\f").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t").Replace("*", "#star#").Replace("=", "#equal#"))
        //                + @""",""t"":""m"",""b"":""s"",""p"":""t""}]}]}");
        //            ipcPost.Add("rct", "jsonp");
        //            ipcPost.Add("pnm", "MessageStore");
        //            ipcPost.Add("sht", ".");
        //            string result = ipcPost.GetResponse();
        //        }
        //        catch (Exception ex)
        //        {
        //            RoboFramework.Tools.RandomLogHelper.GetLog().Error("SendOKAlert:: notify send error ");
        //        }
        //    })).Start();
        //}

        //internal static void SendWarningAlert(string m)
        //{
        //    new System.Threading.Thread(new System.Threading.ThreadStart(delegate()
        //    {
        //        try
        //        {
        //            m += " (eid=" + new Random().Next(0, 1000000000) + ")(" + RoboFramework.Tools.RandomLogHelper.LOG_NAME + ") ";
        //            WebPostRequest ipcPost = new WebPostRequest("http://demo.fractus.pl/fractus/f2test/ipc.ashx");
        //            ipcPost.Add("obj", @"command=put*code=notify*key=" + Guid.NewGuid() + @"*value={""notify"": [{""global"":[{""m"":""" + "(" + ServerName + ")" + " " +
        //                HttpUtility.UrlEncode(m.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\b", "\\b").Replace("\f", "\\f").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t").Replace("*", "#star#").Replace("=", "#equal#"))
        //                + @""",""t"":""w"",""b"":""s"",""p"":""t""}]}]}");
        //            ipcPost.Add("rct", "jsonp");
        //            ipcPost.Add("pnm", "MessageStore");
        //            ipcPost.Add("sht", ".");
        //            string result = ipcPost.GetResponse();
        //        }
        //        catch (Exception ex)
        //        {
        //            RoboFramework.Tools.RandomLogHelper.GetLog().Error("SendWarningAlert:: notify send error ");
        //        }
        //    })).Start();
        //}
    }
}
