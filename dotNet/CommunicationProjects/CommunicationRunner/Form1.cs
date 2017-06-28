using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;
using System.Configuration;

namespace CommunicationRunner
{
    public partial class Form1 : Form
    {
        private Process centralCommunication;
        private Process branch1Communication;
        private Process branch2Communication;
        private Process wcfHostProcess;

        private string centralCommunicationPath;
        private string branch1CommunicationPath;
        private string branch2CommunicationPath;
        private string wcfHostProcessPath;
        private string updateBatPath;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.stopBranch1Btn.Enabled = false;
            this.stopBranch2Btn.Enabled = false;
            this.stopCentralBtn.Enabled = false;
            this.stopWCFBtn.Enabled = false;

            this.centralCommunicationPath = ConfigurationManager.AppSettings["centralPath"];
            this.branch1CommunicationPath = ConfigurationManager.AppSettings["branch1Path"];
            this.branch2CommunicationPath = ConfigurationManager.AppSettings["branch2Path"];
            this.wcfHostProcessPath = ConfigurationManager.AppSettings["wcfPath"];
            this.updateBatPath = ConfigurationManager.AppSettings["updateBatPath"];
        }


        public Process StartProcess(string file)
        {
            ProcessStartInfo info = new ProcessStartInfo(file, " x");
            info.CreateNoWindow = true;
            return Process.Start(info);
        }

        public void StopProcess(Process p)
        {
            if (p.HasExited == false)  p.Kill();
        }

        private void startWCFBtn_Click(object sender, EventArgs e)
        {
            this.stopWCFBtn.Enabled = true;
            this.startWCFBtn.Enabled = false;
            this.wcfHostProcess = this.StartProcess(this.wcfHostProcessPath);
            this.wcfProcessIdLbl.Text = this.wcfHostProcess.Id.ToString();
        }

        private void startCentralBtn_Click(object sender, EventArgs e)
        {
            this.stopCentralBtn.Enabled = true;
            this.startCentralBtn.Enabled = false;
            this.centralCommunication = this.StartProcess(this.centralCommunicationPath);
            this.centralProcessIdLbl.Text = this.centralCommunication.Id.ToString();
        }

        private void startBranch1Btn_Click(object sender, EventArgs e)
        {
            this.stopBranch1Btn.Enabled = true;
            this.startBranch1Btn.Enabled = false;
            this.branch1Communication = this.StartProcess(this.branch1CommunicationPath);
            this.branch1ProcessIdLbl.Text = this.branch1Communication.Id.ToString();
        }

        private void startBranch2Btn_Click(object sender, EventArgs e)
        {
            this.stopBranch2Btn.Enabled = true;
            this.startBranch2Btn.Enabled = false;
            this.branch2Communication = this.StartProcess(this.branch2CommunicationPath);
            this.branch2ProcessIdLbl.Text = this.branch2Communication.Id.ToString();
        }

        private void stopWCFBtn_Click(object sender, EventArgs e)
        {
            this.stopWCFBtn.Enabled = false;
            this.startWCFBtn.Enabled = true;
            this.StopProcess(this.wcfHostProcess);
            this.wcfProcessIdLbl.Text = String.Empty;
        }

        private void stopCentralBtn_Click(object sender, EventArgs e)
        {
            this.stopCentralBtn.Enabled = false;
            this.startCentralBtn.Enabled = true;
            this.StopProcess(this.centralCommunication);
            this.centralProcessIdLbl.Text = String.Empty;
        }

        private void stopBranch1Btn_Click(object sender, EventArgs e)
        {
            this.stopBranch1Btn.Enabled = false;
            this.startBranch1Btn.Enabled = true;
            this.StopProcess(this.branch1Communication);
            this.branch1ProcessIdLbl.Text = String.Empty;
        }

        private void stopBranch2Btn_Click(object sender, EventArgs e)
        {
            this.stopBranch2Btn.Enabled = false;
            this.startBranch2Btn.Enabled = true;
            this.StopProcess(this.branch2Communication);
            this.branch2ProcessIdLbl.Text = String.Empty;
        }

        private void updateBtn_Click(object sender, EventArgs e)
        {
            ProcessStartInfo info = new ProcessStartInfo(this.updateBatPath);
            Process.Start(info);
        }

    }
}
