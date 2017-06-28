using System;
using System.Diagnostics;
using System.Windows.Forms;

namespace FractusDesktop
{
    public partial class AcrobatInstallForm : Form
    {
        private string url = "http://get.adobe.com/reader/";

        public AcrobatInstallForm()
        {
            InitializeComponent();
            this.label1.Text = String.Format(MainForm.ResourceManager.GetString("NoAcrobatInstalled"), this.url);
            this.btnClose.Text = MainForm.ResourceManager.GetString("Close");
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void LaunchBrowser()
        {
            Process.Start(new ProcessStartInfo(this.url));
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {
            this.LaunchBrowser();
        }

        private void linkLabel1_Click(object sender, EventArgs e)
        {
            this.LaunchBrowser();
        }
    }
}
