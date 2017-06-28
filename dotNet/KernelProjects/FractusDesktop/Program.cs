using System;
using System.Windows.Forms;

namespace FractusDesktop
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            AppDomain.CurrentDomain.UnhandledException +=
                    new UnhandledExceptionEventHandler(
                      CurrentDomain_UnhandledException);

            Application.ThreadException += new System.Threading.ThreadExceptionEventHandler(Application_ThreadException);

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }


        static void CurrentDomain_UnhandledException (object sender, UnhandledExceptionEventArgs e)
        {
            try
            {
                Exception ex = (Exception)e.ExceptionObject;

                MessageBox.Show("Wystąpił nieobsłużony błąd krytyczny "
                      + ":\n\n"
                      + ex.Message + ex.StackTrace, "Błąd krytyczny",
                      MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            finally
            {
                Application.Exit();
            }
        }

        public static void Application_ThreadException(object sender, System.Threading.ThreadExceptionEventArgs e)
        {
            DialogResult result = DialogResult.Abort;
            try
            {
                result = MessageBox.Show("Wystąpił nieobsłużony błąd krytyczny "
                  + ":\n\n"
                  + e.Exception.Message + e.Exception.StackTrace,
                  "Błąd aplikacji", MessageBoxButtons.AbortRetryIgnore,
                  MessageBoxIcon.Stop);
            }
            finally
            {
                if (result == DialogResult.Abort)
                {
                    Application.Exit();
                }
            }
        }


    }
}
