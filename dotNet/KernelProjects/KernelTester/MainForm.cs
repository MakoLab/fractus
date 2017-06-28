using System;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.Web;
using System.Windows.Forms;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.KernelTester.WcfKernelService;
using UrielGuy.SyntaxHighlightingTextBox;
using System.Net;
using System.Threading;
using System.Net.Mime;
using System.Text;
using System.IO;
using Makolab.Fractus.Kernel.Coordinators;

namespace Makolab.Fractus.Kernel.KernelTester
{
    public partial class MainForm : Form
    {
        private SyntaxHighlightingTextBox shtb;
        private TextBox txtBoxXmlRaw;
        private XmlTextBox txtBoxXml;
        private string sessionId;
        private TabPage lastTabPage;

        private string xml
        {
            get
            {
                if (this.tabControlMain.SelectedTab == this.tabPageRawXml)
                    return this.txtBoxXmlRaw.Text;
                else if (this.tabControlMain.SelectedTab == this.tabPageXmlTreeView)
                    return this.txtBoxXml.Text;
                else
                    return this.shtb.Text;
            }
            set
            {
                this.txtBoxXmlRaw.Text = value;
                this.txtBoxXml.Text = value;
                this.shtb.Text = value;
            }
        }

        public MainForm()
        {
            InitializeComponent();
            this.LoadBusinessObjectTypes();
            this.LoadAllWebMethods();
            this.txtBoxXmlRaw = new TextBox();
            this.txtBoxXmlRaw.MaxLength = 0;
            this.txtBoxXmlRaw.Dock = DockStyle.Fill;
            this.txtBoxXmlRaw.Multiline = true;
            this.txtBoxXmlRaw.ScrollBars = ScrollBars.Vertical;
            this.txtBoxXmlRaw.KeyPress += new KeyPressEventHandler(txtBox_SelectAll);
            this.tabPageRawXml.Controls.Add(this.txtBoxXmlRaw);

            this.txtBoxXml = new XmlTextBox();
            this.txtBoxXml.Dock = DockStyle.Fill;
            this.txtBoxXml.KeyPress += new KeyPressEventHandler(txtBox_SelectAll);
            this.tabPageXmlTreeView.Controls.Add(this.txtBoxXml);

            this.shtb = new SyntaxHighlightingTextBox();
            this.shtb.Multiline = true;
            this.shtb.Dock = DockStyle.Fill;

            shtb.Seperators.Add(' ');
            shtb.Seperators.Add('\r');
            shtb.Seperators.Add('\n');
            shtb.Seperators.Add(',');
            shtb.Seperators.Add('.');
            shtb.Seperators.Add(')');
            shtb.Seperators.Add('(');
            shtb.Seperators.Add(']');
            shtb.Seperators.Add('[');
            shtb.Seperators.Add('}');
            shtb.Seperators.Add('{');
            shtb.Seperators.Add('+');
            shtb.Seperators.Add('=');
            shtb.Seperators.Add('\t');
            Font f = new Font("Courier New", 9);
            shtb.AddHighlightDescriptor(DescriptorRecognition.RegEx, "<.+?>", DescriptorType.Word, Color.Green, f, false);

            this.tabPageHighlighted.Controls.Add(this.shtb);

            this.cboxType.SelectedIndex = 5;
            this.txtBoxTemplate.Text = "";
            this.txtBoxSource.Text = @"";

            this.tabControlMain.SelectedIndex = 0;
            this.lastTabPage = this.tabControlMain.SelectedTab;
            this.cboxMethodName.SelectedIndex = 0;
        }

        private void LoadBusinessObjectTypes()
        {
            var fields = typeof(BusinessObjectType).GetFields().Where(f => f.FieldType.IsEnum).OrderBy(ff => ff.Name).Select(fff => fff.Name);

            foreach (var field in fields)
                this.cboxType.Items.Add(field);
        }

        private void LoadAllWebMethods()
        {
            var methods = typeof(IKernelService).GetMethods().OrderBy(m => m.Name).Select(mm => mm.Name);

            foreach (var method in methods)
                this.cboxMethodName.Items.Add(method);
        }

        private string FormatText(string text)
        {
            if (String.IsNullOrEmpty(text))
                return text;

            try
            {
                XDocument xdoc = XDocument.Parse(text);

                return xdoc.Declaration.ToString() + Environment.NewLine + xdoc.ToString();
            }
            catch (Exception)
            {
                return text;
            }
        }

        private void tabControlMain_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.tabControlMain.SelectedTab == this.tabPageRawXml)
            {
                if (this.lastTabPage == this.tabPageXmlTreeView)
                    this.txtBoxXmlRaw.Text = this.txtBoxXml.Text;
                else
                    this.txtBoxXmlRaw.Text = this.shtb.Text.Replace("\n", "\r\n");
            }
            else if (this.tabControlMain.SelectedTab == this.tabPageXmlTreeView)
            {
                if (this.lastTabPage == this.tabPageRawXml)
                    this.txtBoxXml.Text = this.txtBoxXmlRaw.Text;
                else
                    this.txtBoxXml.Text = this.shtb.Text.Replace("\n", "\r\n");
            }
            else if (this.tabControlMain.SelectedTab == this.tabPageHighlighted)
            {
                if (this.lastTabPage == this.tabPageRawXml)
                    this.shtb.Text = this.FormatText(this.txtBoxXmlRaw.Text);
                else
                    this.shtb.Text = this.FormatText(this.txtBoxXml.Text);
            }

            this.lastTabPage = this.tabControlMain.SelectedTab;
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

            try
            {
                XDocument xml = XDocument.Parse(String.Format(CultureInfo.InvariantCulture, 
                    "<root><username>{0}</username><password>{1}</password><language>{2}</language><profile>{3}</profile></root>",
                    this.txtBoxUser.Text, this.txtBoxPassword.Text, this.txtBoxLanguage.Text, this.txtBoxProfile.Text));

                string retXml = krnsrv.LogOn(xml.ToString(SaveOptions.DisableFormatting));

                xml = XDocument.Parse(retXml);
                this.sessionId = xml.Root.Element("sessionId").Value;
                MessageBoxForm.Show(xml.ToString());
            }
            catch (Exception ex)
            {
                MessageBoxForm.Show(ex.Message);
            }

            krnsrv.Close();
        }

        private void btnCustom_Click(object sender, EventArgs e)
        {
            WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

            using (new OperationContextScope(krnsrv.InnerChannel))
            {
                HttpRequestMessageProperty req = new HttpRequestMessageProperty();

                if (this.rbtnNormalSession.Checked)
                    req.Headers.Add("SessionID", this.sessionId);
                else
                    this.AddOneTimeSessionHeaders(req.Headers);

                OperationContext.Current.OutgoingMessageProperties[HttpRequestMessageProperty.Name] = req;

                string methodName = cboxMethodName.Text;
                
                MethodInfo mi = krnsrv.GetType().GetMethod(methodName);

                bool hasInput = mi.GetParameters().Length != 0;
                bool hasOutput = mi.ReturnType != typeof(void);

                if (hasOutput && hasInput)
                    MessageBoxForm.Show(mi.Invoke(krnsrv, new object[] { this.xml }).ToString());
                else if (hasOutput && !hasInput)
                    MessageBoxForm.Show(mi.Invoke(krnsrv, null).ToString());
                else if (!hasOutput && hasInput)
                    mi.Invoke(krnsrv, new object[] { this.xml });
                else
                    mi.Invoke(krnsrv, null);

                krnsrv.Close();
            }
        }

        private void btnCreateNewBO_Click(object sender, EventArgs e)
        {
            WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

            using (new OperationContextScope(krnsrv.InnerChannel))
            {
                HttpRequestMessageProperty req = new HttpRequestMessageProperty();

                if (this.rbtnNormalSession.Checked)
                    req.Headers.Add("SessionID", this.sessionId);
                else
                    this.AddOneTimeSessionHeaders(req.Headers);

                OperationContext.Current.OutgoingMessageProperties[HttpRequestMessageProperty.Name] = req;

                try
                {
                    XDocument param = XDocument.Parse("<root/>");
                    param.Root.Add(new XElement("type", this.cboxType.SelectedItem));

                    if (this.txtBoxTemplate.Text.Length != 0)
                        param.Root.Add(new XElement("template", this.txtBoxTemplate.Text));

                    if (this.txtBoxSource.Text.Length != 0)
                        param.Root.Add(XElement.Parse(this.txtBoxSource.Text));

                    this.xml = krnsrv.CreateNewBusinessObject(param.ToString(SaveOptions.DisableFormatting));
                }
                catch (Exception ex)
                {
                    krnsrv.Close();
                    MessageBoxForm.Show(ex.Message);
                }
            }
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

            using (new OperationContextScope(krnsrv.InnerChannel))
            {
                HttpRequestMessageProperty req = new HttpRequestMessageProperty();

                if (this.rbtnNormalSession.Checked)
                    req.Headers.Add("SessionID", this.sessionId);
                else
                    this.AddOneTimeSessionHeaders(req.Headers);

                OperationContext.Current.OutgoingMessageProperties[HttpRequestMessageProperty.Name] = req;

                try
                {
                    MessageBoxForm.Show(krnsrv.SaveBusinessObject(this.xml));
                }
                catch (Exception ex)
                {
                    krnsrv.Close();
                    MessageBoxForm.Show(ex.Message);
                }
            }
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

            using (new OperationContextScope(krnsrv.InnerChannel))
            {
                HttpRequestMessageProperty req = new HttpRequestMessageProperty();

                if (this.rbtnNormalSession.Checked)
                    req.Headers.Add("SessionID", this.sessionId);
                else
                    this.AddOneTimeSessionHeaders(req.Headers);

                OperationContext.Current.OutgoingMessageProperties[HttpRequestMessageProperty.Name] = req;

                try
                {
					string sourcePart = String.IsNullOrEmpty(this.txtBoxSource.Text.Trim()) 
						? String.Empty : this.txtBoxSource.Text;

                    this.xml = krnsrv.LoadBusinessObject(
                        @"<root>
                            <type>" + this.cboxType.SelectedItem.ToString() + @"</type>
                            <id>" + this.txtBoxId.Text + @"</id>"
							+ sourcePart +
                         "</root>");
                }
                catch (Exception ex)
                {
                    krnsrv.Close();
                    MessageBoxForm.Show(ex.Message);
                }
            }
        }

        private void txtBox_DoubleClick(object sender, EventArgs e)
        {
            TextBox txtBox = (TextBox)sender;
            txtBox.SelectionStart = 0;
            txtBox.SelectionLength = txtBox.Text.Length;
        }

        private void txtBox_SelectAll(object sender, KeyPressEventArgs e)
        {
            if ((Control.ModifierKeys == Keys.Control) && (e.KeyChar == (char)1))
            {
                ((TextBox)sender).SelectAll();
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

            using (new OperationContextScope(krnsrv.InnerChannel))
            {
                HttpRequestMessageProperty req = new HttpRequestMessageProperty();

                if (this.rbtnNormalSession.Checked)
                    req.Headers.Add("SessionID", this.sessionId);
                else
                    this.AddOneTimeSessionHeaders(req.Headers);

                OperationContext.Current.OutgoingMessageProperties[HttpRequestMessageProperty.Name] = req;

                try
                {
                    krnsrv.DeleteBusinessObject(
                        @"<root>
                            <type>" + this.cboxType.SelectedItem.ToString() + @"</type>
                            <id>" + this.txtBoxId.Text + @"</id>
                         </root>");
                }
                catch (Exception ex)
                {
                    krnsrv.Close();
                    MessageBoxForm.Show(ex.Message);
                }
            }
        }

        private void btnHtmlDecode_Click(object sender, EventArgs e)
        {
            this.xml = HttpUtility.HtmlDecode(this.xml);
        }

        private void btnUrlDecode_Click(object sender, EventArgs e)
        {
            this.xml = HttpUtility.UrlDecode(this.xml);
        }

        private void AddOneTimeSessionHeaders(WebHeaderCollection headers)
        {
            headers.Add("Username", this.txtBoxUser.Text);
            headers.Add("Password", this.txtBoxPassword.Text);
            headers.Add("Language", this.txtBoxLanguage.Text);
            headers.Add("Profile", this.txtBoxProfile.Text);
        }

        private void btnExecuteCustomProc_Click(object sender, EventArgs e)
        {
            WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

            using (new OperationContextScope(krnsrv.InnerChannel))
            {
                HttpRequestMessageProperty req = new HttpRequestMessageProperty();

                if (this.rbtnNormalSession.Checked)
                    req.Headers.Add("SessionID", this.sessionId);
                else
                    this.AddOneTimeSessionHeaders(req.Headers);

                OperationContext.Current.OutgoingMessageProperties[HttpRequestMessageProperty.Name] = req;

               // MessageBoxForm.Show(new StreamReader( krnsrv.ExecuteCustomProcedureStream(this.txtBoxCustomProcName.Text, "364EBB10-A744-4A76-AD6F-E764BC9827BD", "@commercialDocumentHeaderId") ).ReadToEnd());

                krnsrv.Close();
            }
        }

		/*
		 * private void btnCreateTask_Click(object sender, EventArgs e)
		{
			try
			{
				WcfKernelService.KernelServiceClient krnsrv = new WcfKernelService.KernelServiceClient();

				using (new OperationContextScope(krnsrv.InnerChannel))
				{
					HttpRequestMessageProperty req = new HttpRequestMessageProperty();

					if (this.rbtnNormalSession.Checked)
						req.Headers.Add("SessionID", this.sessionId);
					else
						this.AddOneTimeSessionHeaders(req.Headers);

					OperationContext.Current.OutgoingMessageProperties[HttpRequestMessageProperty.Name] = req;

					string idXml = krnsrv.CreateTask(this.xml);
					string qXml;

					while (true)
					{
						qXml = krnsrv.QueryTask(idXml);
						XDocument qDoc = XDocument.Parse(qXml);
						if (qDoc.Root.Element("status").Value != "inProgress")
						{
							break;
						}
						Thread.Sleep(20000);
					}

					MessageBoxForm.Show(krnsrv.GetTaskResult(idXml));

					krnsrv.Close();
				}
			}
			catch (Exception ex)
			{
				MessageBoxForm.Show(ex.Message);
			}
		}
		 */

		private void btnPrintReport_Click(object sender, EventArgs e)
		{
            txtBoxSource.Text = @"xml:<list>
  <details>
    <detail subHeader=""Należności ""/>
    <detail header=""MOTO CENTER Łukasz Piotrowski""/>
    <contractor>
      <shortName>MOTO CENTER Łukasz Piotrowski</shortName>
      <fullName>MOTO CENTER Łukasz Piotrowski</fullName>
      <address>Oś. Na Stoku 38/23</address>
      <city>Kielce</city>
      <postCode>25-437</postCode>
      <postOffice>Kielce</postOffice>
    </contractor>
  </details>
  <columns>
    <column label=""Lp."" field=""@lp""/>
    <column label=""Dokument"" field=""@fullNumber""/>
    <column label=""Data wystawienia"" field=""@issueDate""/>
    <column label=""Termin płatności"" field=""@dueDate""/>
    <column label=""Winien (waluta sys.)"" field=""@documentValue"" dataType=""currency""/>
    <column label=""Pozostało (waluta sys.)"" field=""@unsettled"" dataType=""currency""/>
    <column label=""%"" field=""@unsettledPercent""/>
    <column label=""Dokument dostawcy"" field=""@supplierDocumentNumber""/>
    <column label=""Forma płatności"" field=""@paymentMethod""/>
    <column label=""Winien (waluta dok.)"" field=""@documentAmount""/>
  </columns>
  <elements>
    <documents fullNumber=""FVS 4980/MC/2016"" documentType=""FVS"" documentValue=""41590.27"" documentAmount="""" unsettled=""41590.27"" dueDate=""2016-11-05"" dueDays=""60"" delay=""55"" issueDate=""2016-09-06"" paymentLeft=""0.00"" paymentMethod=""Przelew 60 dni (60)"" paymentMethodId=""55195181-9658-439F-9708-3FF95406E7C8"" commercialDocumentHeaderId=""825D6A94-06C5-4D28-85C8-FC2C2B3DE794"" documentInfo=""FVS;4980/MC/2016;2016-09-06;MC"" unsettledDocumentAmount=""41590.27"" currency=""PLN"" lp=""1"" enabled=""1"" color=""#ff0000"" unsettledPercent=""100%"" supplierDocumentNumber="""">
      <null/>
    </documents>
    <documents fullNumber=""FVS 5192/MC/2016"" documentType=""FVS"" documentValue=""8312.35"" documentAmount="""" unsettled=""8312.35"" dueDate=""2016-11-14"" dueDays=""60"" delay=""46"" issueDate=""2016-09-15"" paymentLeft=""0.00"" paymentMethod=""Przelew 60 dni (60)"" paymentMethodId=""55195181-9658-439F-9708-3FF95406E7C8"" commercialDocumentHeaderId=""BB655E78-B6B8-4286-8002-4F0C6B04449C"" documentInfo=""FVS;5192/MC/2016;2016-09-15;MC"" unsettledDocumentAmount=""8312.35"" currency=""PLN"" lp=""2"" enabled=""1"" color=""#ff0000"" unsettledPercent=""100%"" supplierDocumentNumber="""">
      <null/>
    </documents>
    <summary fullNumber=""Łącznie"" documentValue=""49902.62"" unsettled=""49902.62""/>
  </elements>
</list>
packedId:2ABAB83B-7421-2909-1E26-5018B504679E
partsNumber:1
partSend:1
outputContentType:content
profileName:batcarDunningLetterPdf";

			if (txtBoxSource.Text.Length != 0)
			{
				UTF8Encoding encoding = new UTF8Encoding();
				byte[] data = encoding.GetBytes(txtBoxSource.Text);
				HttpWebRequest printRequest = (HttpWebRequest)WebRequest.Create("http://127.0.0.1:3131/KernelServices/PrintService/PrintXml");
				printRequest.Method = WebRequestMethods.Http.Post;
				printRequest.ContentType = "application/x-www-form-urlencoded";
				printRequest.ContentLength = data.Length;
              
				Stream dataStream = printRequest.GetRequestStream();
				dataStream.Write(data, 0, data.Length);
				dataStream.Close();

				try
				{
					WebResponse response = printRequest.GetResponse();
					txtBoxXml.Text = response.ContentLength.ToString();
				}
				catch (WebException wex)
				{
					txtBoxXml.Text = wex.Message;
				}
			}
		}

		private void buttonBrowse_Click(object sender, EventArgs e)
		{
			using (FolderBrowserDialog fbd = new FolderBrowserDialog() { Description = "Select input folder" })
			{
				if (fbd.ShowDialog() == DialogResult.OK)
				{
					this.textBoxInputFolder.Text = fbd.SelectedPath;
					if (String.IsNullOrEmpty(this.textBoxScriptName.Text))
					{
						this.textBoxScriptName.Text = this.textBoxInputFolder.Text + "\\Untitled.sql";
					}
				}
			}
		}

		private void buttonGenerateTransformScript_Click(object sender, EventArgs e)
		{
			if (!String.IsNullOrEmpty(this.textBoxScriptName.Text))
			{
				string setConfigFormat = "EXECUTE [tools].[p_setConfigXmlValue] @key = '{0}',"+Environment.NewLine+"@value = '{1}'"+Environment.NewLine;
				StringBuilder scriptContent = new StringBuilder();
				if (!String.IsNullOrEmpty(this.textBoxInputFolder.Text))
				{
					string[] fileNames = Directory.GetFiles(this.textBoxInputFolder.Text);
					foreach (string fileName in fileNames)
					{
						FileInfo file = new FileInfo(fileName);
						using(StreamReader reader = new StreamReader(fileName)) {
							scriptContent.AppendFormat(setConfigFormat, file.Name, reader.ReadToEnd().Replace("'", "''"));
						}
					}
				}
				File.Delete(this.textBoxScriptName.Text);
				using (StreamWriter writer = new StreamWriter(this.textBoxScriptName.Text))
				{
					writer.Write(scriptContent);
				}
				MessageBox.Show(String.Format("Script was saved as {0}", this.textBoxScriptName.Text), "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
			}
		}

		private void button1_Click(object sender, EventArgs e)
		{
			string test = GuidBarcodeResultInput.Text;
			if (!String.IsNullOrEmpty(test))
			{
				Guid guid = new Guid(Convert.FromBase64CharArray(test.ToArray(), 1, test.Length-1));

				GuidBarcodeResultInput.Text = guid.ToString().ToUpperInvariant();
			}
		}

		private void btnCreateTask_Click(object sender, EventArgs e)
		{
			this.txtBoxSource.Text = String.Empty;
		}

        private void cboxMethodName_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}
