using System;
using System.Drawing;
using System.Windows.Forms;
using System.Xml.Linq;
using UrielGuy.SyntaxHighlightingTextBox;

namespace Makolab.Fractus.Kernel.KernelTester
{
    public partial class MessageBoxForm : Form
    {
        private SyntaxHighlightingTextBox shtb;
        private XmlTextBox txtBoxXml;
        private TextBox txtBoxXmlRaw;
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
                this.shtb.Text = value;
                this.txtBoxXml.Text = value;
            }
        }

        private MessageBoxForm(string msg)
        {
            InitializeComponent();

            this.txtBoxXmlRaw = new TextBox();
            this.txtBoxXmlRaw.Dock = DockStyle.Fill;
            this.txtBoxXmlRaw.Multiline = true;
            this.txtBoxXmlRaw.ScrollBars = ScrollBars.Vertical;
            this.txtBoxXmlRaw.KeyPress += new KeyPressEventHandler(txtBox_SelectAll);
            this.tabPageRawXml.Controls.Add(this.txtBoxXmlRaw);

            this.txtBoxXml = new XmlTextBox();
            this.txtBoxXml.Dock = DockStyle.Fill;
            this.txtBoxXml.Multiline = true;
            this.txtBoxXml.ScrollBars = ScrollBars.Vertical;
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

            this.tabControlMain.SelectedIndex = 0;
            this.lastTabPage = this.tabControlMain.SelectedTab;

            this.xml = msg;
        }

        private void txtBox_SelectAll(object sender, KeyPressEventArgs e)
        {
            if ((Control.ModifierKeys == Keys.Control) && (e.KeyChar == (char)1))
            {
                ((TextBox)sender).SelectAll();
            }
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

        public static void Show(string msg)
        {
            MessageBoxForm frm = new MessageBoxForm(msg);
            frm.ShowDialog();
        }

        private void btnOk_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
