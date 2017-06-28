using System;
using System.Windows.Forms;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.KernelTester
{
    public partial class XmlTextBox : TextBox
    {
        public XmlTextBox()
        {
            InitializeComponent();
            this.MaxLength = 0;
            this.Multiline = true;
            this.ScrollBars = ScrollBars.Vertical;
        }

        public override string Text
        {
            get
            {
                if (String.IsNullOrEmpty(base.Text))
                    return base.Text;

                try
                {
                    XDocument xdoc = XDocument.Parse(base.Text);

                    if (xdoc.Declaration != null)
                        return xdoc.Declaration.ToString() + xdoc.ToString(SaveOptions.DisableFormatting);
                    else
                        return xdoc.ToString(SaveOptions.DisableFormatting);
                }
                catch (Exception)
                {
                    return base.Text;
                }
            }
            set
            {
                try
                {
                    XDocument xdoc = XDocument.Parse(value);

                    if (xdoc.Declaration != null)
                        base.Text = xdoc.Declaration.ToString() + Environment.NewLine + xdoc.ToString();
                    else
                        base.Text = xdoc.ToString();
                }
                catch (Exception)
                {
                    base.Text = value;
                }
            }
        }
    }
}
