using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.ServiceModel;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Services;
using Microsoft.Win32;

namespace FractusDesktop
{
    delegate void AsyncResponse(object[] result);

    [ComVisible(true)]
    public class KernelServiceWrapper 
    {
        [DllImport("kernel32.dll")]
        private static extern long GetVolumeInformation(string PathName, StringBuilder VolumeNameBuffer, UInt32 VolumeNameSize, ref UInt32 VolumeSerialNumber, ref UInt32 MaximumComponentLength, ref UInt32 FileSystemFlags, StringBuilder FileSystemNameBuffer, UInt32 FileSystemNameSize);

        private readonly MethodInfo[] serviceMethods;
        private KernelService kernel;
        private PrintService printService;
        private System.Windows.Forms.WebBrowser browserControl;
        private MainForm parentForm;

        private AsyncResponse asyncResponseDelegate;
        private AsyncResponse asyncErrorResponseDelegate;

        delegate void ProcessPrintDelegate(string requestId, MemoryStream printStream, string contentType);

        public KernelServiceWrapper(System.Windows.Forms.WebBrowser browserControl, MainForm parentForm)
        {
            this.parentForm = parentForm;
            this.browserControl = browserControl;
            this.kernel = new KernelService();
            this.printService = new PrintService();
            this.serviceMethods = typeof(KernelService).GetMethods(BindingFlags.Public | BindingFlags.Instance);
            this.asyncResponseDelegate = new AsyncResponse(SendResponse);
            this.asyncErrorResponseDelegate = new AsyncResponse(SendErrorResponse);
        }

        private void RefreshUserLanguage()
        {
            string lang = this.kernel.GetUserLanguageVersion();
            this.parentForm.SetLanguage(lang);
        }

        private void SendErrorResponse(object[] args)
        {
            if (browserControl.Document != null)
            {
                browserControl.Document.GetElementById("Main").InvokeMember("asyncErrorResponse", args);
            } 
        }

        private void SendResponse(object[] args)
        {
            if (browserControl.Document != null)
            {
                browserControl.Document.GetElementById("Main").InvokeMember("asyncResponse", args);
            }            
        }

        private void SendAsyncResponse(params object[] args)
        {
            object[] responseArgs = new object[1];
            responseArgs[0] = args;

            browserControl.BeginInvoke(this.asyncResponseDelegate, responseArgs);
        }

        private void SendAsyncErrorResponse(params object[] args)
        {
            object[] responseArgs = new object[1];
            responseArgs[0] = args;

            browserControl.BeginInvoke(this.asyncErrorResponseDelegate, responseArgs);
        }

        private string GetDriveSerialNumber()
        {
            uint serNum = 0;
            uint maxCompLen = 0;
            StringBuilder VolLabel = new StringBuilder(256); // Label
            UInt32 VolFlags = new UInt32();
            StringBuilder FSName = new StringBuilder(256); // File System Name
            long Ret = GetVolumeInformation("C:\\", VolLabel, (UInt32)VolLabel.Capacity, ref serNum, ref maxCompLen, ref VolFlags, FSName, (UInt32)FSName.Capacity);

            return Convert.ToString(serNum, CultureInfo.InvariantCulture);
        }

        public void CheckRegistration(string requestId)
        {
            //ZAKOMENTOWANA REJESTRACJA FRACTUSA
            /*RegistryKey key = this.GetFractusRegistryKey();

            object o = key.GetValue("Registered");

            if (o == null)
            {
                string responseXml = "Fractus2" + this.GetDriveSerialNumber();

                responseXml = "<root>" + CryptoUtils.Encrypt(CryptoUtils.PasswordFractus, responseXml) + "</root>";

                this.SendAsyncResponse(requestId, responseXml);
            }
            else*/
                this.SendAsyncResponse(requestId, "<root></root>");
        }

        public void RegisterFractus(string requestId, string licenseKey)
        {
            try
            {
                string plain = null;

                try
                {
                    plain = CryptoUtils.Decrypt(CryptoUtils.PasswordSite, licenseKey);
                }
                catch (Exception)
                { }

                if (plain == ("Fractus2" + this.GetDriveSerialNumber() + "Verified"))
                {
                    RegistryKey key = this.GetFractusRegistryKey();

                    key.SetValue("Registered", licenseKey);

                    this.SendAsyncResponse(requestId, "ok");
                }
                else
                    this.SendAsyncResponse(requestId, "error");
            }
            catch (Exception)
            {
                this.SendAsyncResponse(requestId, "exception");
            }
        }

        public void OpenExternalWebBrowser(string requestId, string url)
        {
            Process.Start(new ProcessStartInfo(url));
            this.SendAsyncResponse(requestId, true);
        }

        public void CloseApplication(string requestId)
        {
            Application.Exit();
        }

        private RegistryKey GetFractusRegistryKey()
        {
            RegistryKey key = Registry.CurrentUser.OpenSubKey("Software", true);

            if (key.OpenSubKey("Makolab") == null)
                key.CreateSubKey("Makolab");

            key = key.OpenSubKey("Makolab", true);

            if (key.OpenSubKey("Fractus2") == null)
                key.CreateSubKey("Fractus2");

            key = key.OpenSubKey("Fractus2", true);

            return key;
        }

        private void ExecuteOfflinePrint(string requestId, string arg)
        {
            XDocument inputXml = XDocument.Parse(arg);

            MemoryStream outputStream = null;
            string resultContentType = null;
            bool wasException = false;

            try
            {
                if (inputXml.Root.Element("id") != null)
                    outputStream = this.printService.PrintBusinessObjectOffline(inputXml.Root.Element("id").Value, inputXml.Root.Element("profileName").Value, ref resultContentType);
                else
                    outputStream = this.printService.PrintXmlOffline(inputXml.Root.Element("xml").FirstNode.ToString(), inputXml.Root.Element("profileName").Value, ref resultContentType);
            }
            catch (Exception ex)
            {
                wasException = true;
                this.SendAsyncErrorResponse(requestId, ex.Message);
            }

            if (!wasException)
            {
                AsyncCallArgs args = new AsyncCallArgs();

                args.IsSelfInvoke = true;

                //get requested method
                args.Method = this.GetType().GetMethod("ProcessPrint", BindingFlags.NonPublic | BindingFlags.Instance);

                args.MethodArgs = new object[] { requestId, outputStream, resultContentType };

                //call method in concurent thread
                System.Threading.ThreadPool.QueueUserWorkItem(DynamicCall, args);
            }
        }

        private string GetFilterStringForContentType(string contentType)
        {
            switch (contentType)
            {
                case PrintService.PDF_CONTENT_TYPE:
                    return "Pdf (*.pdf)|*.pdf";
                case PrintService.CSV_CONTENT_TYPE:
                    return "CSV (*.csv)|*.csv";
                case PrintService.HTML_CONTENT_TYPE:
                    return "HTML (*.html)|*.html";
                case PrintService.EXCEL_CONTENT_TYPE:
                    return "Excel (*.xls)|*.xls";
                case PrintService.VCARD_CONTENT_TYPE:
                    return "vCard (*.vcf)|*.vcf";
                case PrintService.XML_CONTENT_TYPE:
                    return "XML (*.xml)|*.xml";
                default:
                    throw new InvalidDataException("Unknown content type: " + contentType);
            }
        }

        private void ProcessPrint(string requestId, MemoryStream printStream, string contentType)
        {
            if (!this.parentForm.InvokeRequired)
            {
                if (contentType == PrintService.PDF_CONTENT_TYPE)
                {
                    try
                    {
                        PdfPrintForm frm = new PdfPrintForm(printStream, contentType, this.parentForm);
                        frm.Show();
                    }
                    catch(Exception)
                    {
                        AcrobatInstallForm frm = new AcrobatInstallForm();
                        frm.ShowDialog(this.parentForm);
                    }
                }
                else if (contentType == PrintService.XML_CONTENT_TYPE)
                {
                    StreamReader r = new StreamReader(printStream);
                    this.SendResponse(new object[] { requestId, r.ReadToEnd() });
                }
                else
                {
                    SaveFileDialog sfd = new SaveFileDialog();
                    sfd.AddExtension = true;
                    sfd.CheckPathExists = true;
                    sfd.OverwritePrompt = true;
                    sfd.Filter = this.GetFilterStringForContentType(contentType);
                    DialogResult res = sfd.ShowDialog();

                    if (res == DialogResult.OK)
                    {
                        using (FileStream fs = new FileStream(sfd.FileName, FileMode.Create, FileAccess.Write))
                        {
                            fs.Write(printStream.GetBuffer(), 0, (int)printStream.Length);
                        }
                    }
                }

                this.SendResponse(new object[] { requestId, "<root>ok</root>" });
            }
            else
            {
                ProcessPrintDelegate del = new ProcessPrintDelegate(this.ProcessPrint);
                this.parentForm.Invoke(del, new object[] { requestId, printStream, contentType });
            }
        }

        public bool ExecuteLocalMethod(string requestId, string methodName, string firstArg, string secondArg)
        {
            if (methodName != "CheckRegistration" 
                && methodName != "RegisterFractus" 
                && methodName != "OpenExternalWebBrowser"
                && methodName != "CloseApplication")
                return false;

            AsyncCallArgs args = new AsyncCallArgs();

            args.IsSelfInvoke = true;

            //get requested method
            args.Method = this.GetType().GetMethod(methodName, BindingFlags.Public | BindingFlags.Instance);

            if (args.Method == null) throw new Exception("Unknown method: " + methodName);

            args.RequestId = requestId;

            if (secondArg != null)
                args.MethodArgs = new object[] { requestId, firstArg, secondArg };
            else if (firstArg != null)
                args.MethodArgs = new object[] { requestId, firstArg };
            else
                args.MethodArgs = new object[] { requestId };

            //call method in concurent thread
            System.Threading.ThreadPool.QueueUserWorkItem(DynamicCall, args);

            return true;
        }

        public void CallMethod(string requestId, string methodName, string firstArg, string secondArg)
        {
            if (methodName == "OfflinePrint")
                this.ExecuteOfflinePrint(requestId, firstArg);
            else if (!this.ExecuteLocalMethod(requestId, methodName, firstArg, secondArg))
            {
                AsyncCallArgs args = new AsyncCallArgs();

                args.IsSelfInvoke = false;

                //get requested method
                args.Method = serviceMethods.SingleOrDefault(m => m.Name == methodName);

                if (args.Method == null) throw new Exception("Unknown method: " + methodName);

                args.RequestId = requestId;

                if (firstArg != null)
                    args.MethodArgs = (secondArg == null) ? new object[] { firstArg } : new object[] { firstArg, secondArg };

                //call method in concurent thread
                System.Threading.ThreadPool.QueueUserWorkItem(DynamicCall, args);
            }
        }

        private void DynamicCall(object callArgs)
        {
            AsyncCallArgs args = (AsyncCallArgs)callArgs;

            try
            {
                object target = args.IsSelfInvoke ? this : (object)this.kernel;

                object result = args.Method.Invoke(target, args.MethodArgs);

                object[] responseArgs = new object[1];
                responseArgs[0] = new object[] { args.RequestId, result };

                if (args.Method.Name == "LogOn")
                    this.RefreshUserLanguage();

                browserControl.BeginInvoke(this.asyncResponseDelegate, responseArgs);
            }
            catch (Exception e)
            {
                FaultException faultException = e.InnerException as FaultException;

                if (faultException != null)
                {
                    object[] responseArgs = new object[1];
                    responseArgs[0] = new object[] { args.RequestId, faultException.Message };

                    browserControl.BeginInvoke(this.asyncErrorResponseDelegate, responseArgs);
                }
                else
                    MessageBox.Show(e.ToString());
            }
        }
    }
}
