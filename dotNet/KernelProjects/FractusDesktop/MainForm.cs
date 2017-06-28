using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Resources;
using System.Threading;
using System.Windows.Forms;

namespace FractusDesktop
{
    public partial class MainForm : Form
    {
        KernelServiceWrapper kernelService;

        public static ResourceManager ResourceManager = new ResourceManager("FractusDesktop.Labels", Assembly.GetExecutingAssembly());
        private static CultureInfo polishCulture = new CultureInfo("pl-PL");
        private static CultureInfo englishCulture = new CultureInfo("en-US");
        private List<Form> childForms = new List<Form>();

        public MainForm()
        {
            Thread.CurrentThread.CurrentUICulture = MainForm.polishCulture;
            InitializeComponent();

            string mainLocation = System.Configuration.ConfigurationManager.AppSettings["MainFileLocation"];
            this.browserControl.Url = new System.Uri("file://" + MakeAbsolutePath(mainLocation), System.UriKind.Absolute);

            this.kernelService = new KernelServiceWrapper(this.browserControl, this);
            this.browserControl.ObjectForScripting = kernelService;
        }

        public void SetLanguage(string language)
        {
            if(language == "en")
                Thread.CurrentThread.CurrentUICulture = MainForm.englishCulture;
            else
                Thread.CurrentThread.CurrentUICulture = MainForm.polishCulture;
        }

        private string MakeAbsolutePath(string mainLocation)
        {
            if (Path.IsPathRooted(mainLocation)) return mainLocation;
            else
            {
                string currLoc = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location);
                return Path.Combine(currLoc, mainLocation);
            }
        }

        public void RegisterForm(Form childForm)
        {
            this.childForms.Add(childForm);
        }

        public void UnregisterForm(Form childForm)
        {
            this.childForms.Remove(childForm);
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            while (this.childForms.Count > 0)
                this.childForms[0].Close();
        }
    }
}
