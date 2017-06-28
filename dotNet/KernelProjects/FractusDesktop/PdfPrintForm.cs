using System;
using System.IO;
using System.Windows.Forms;

namespace FractusDesktop
{
    public partial class PdfPrintForm : Form
    {
        private MemoryStream printStream;
        private string outputFilename;
        private string contentType;
        private MainForm mainForm;

        public PdfPrintForm(MemoryStream printStream, string contentType, MainForm mainForm)
        {
            this.mainForm = mainForm;
            this.mainForm.RegisterForm(this);
            this.printStream = printStream;
            this.contentType = contentType;
            
            InitializeComponent();

            this.ProcessPdfPrint();
        }

        private void ProcessPdfPrint()
        {
            this.outputFilename = Path.GetTempFileName();

            using (FileStream fs = new FileStream(this.outputFilename, FileMode.Create, FileAccess.Write))
            {
                fs.Write(this.printStream.GetBuffer(), 0, (int)this.printStream.Length);
            }
            this.axAcroPDFCtrl.LoadFile(this.outputFilename);
        }

        private void PdfForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            try
            {
                this.axAcroPDFCtrl.Dispose();
                File.Delete(this.outputFilename);
                this.mainForm.UnregisterForm(this);
            }
            catch (Exception)
            { }
        }
    }
}
