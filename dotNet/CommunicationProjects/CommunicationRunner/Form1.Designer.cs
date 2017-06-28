namespace CommunicationRunner
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.startCentralBtn = new System.Windows.Forms.Button();
            this.startBranch1Btn = new System.Windows.Forms.Button();
            this.startBranch2Btn = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.startWCFBtn = new System.Windows.Forms.Button();
            this.stopBranch2Btn = new System.Windows.Forms.Button();
            this.stopCentralBtn = new System.Windows.Forms.Button();
            this.stopBranch1Btn = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.stopWCFBtn = new System.Windows.Forms.Button();
            this.updateBtn = new System.Windows.Forms.Button();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.wcfProcessIdLbl = new System.Windows.Forms.Label();
            this.centralProcessIdLbl = new System.Windows.Forms.Label();
            this.branch1ProcessIdLbl = new System.Windows.Forms.Label();
            this.branch2ProcessIdLbl = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // startCentralBtn
            // 
            this.startCentralBtn.Location = new System.Drawing.Point(12, 99);
            this.startCentralBtn.Name = "startCentralBtn";
            this.startCentralBtn.Size = new System.Drawing.Size(75, 23);
            this.startCentralBtn.TabIndex = 0;
            this.startCentralBtn.Text = "Centrala";
            this.startCentralBtn.UseVisualStyleBackColor = true;
            this.startCentralBtn.Click += new System.EventHandler(this.startCentralBtn_Click);
            // 
            // startBranch1Btn
            // 
            this.startBranch1Btn.Location = new System.Drawing.Point(12, 128);
            this.startBranch1Btn.Name = "startBranch1Btn";
            this.startBranch1Btn.Size = new System.Drawing.Size(75, 23);
            this.startBranch1Btn.TabIndex = 1;
            this.startBranch1Btn.Text = "Oddzial 1";
            this.startBranch1Btn.UseVisualStyleBackColor = true;
            this.startBranch1Btn.Click += new System.EventHandler(this.startBranch1Btn_Click);
            // 
            // startBranch2Btn
            // 
            this.startBranch2Btn.Location = new System.Drawing.Point(12, 157);
            this.startBranch2Btn.Name = "startBranch2Btn";
            this.startBranch2Btn.Size = new System.Drawing.Size(75, 23);
            this.startBranch2Btn.TabIndex = 2;
            this.startBranch2Btn.Text = "Oddzial 2";
            this.startBranch2Btn.UseVisualStyleBackColor = true;
            this.startBranch2Btn.Click += new System.EventHandler(this.startBranch2Btn_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.startWCFBtn);
            this.groupBox1.Location = new System.Drawing.Point(11, 51);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(78, 143);
            this.groupBox1.TabIndex = 3;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Uruchom";
            // 
            // startWCFBtn
            // 
            this.startWCFBtn.Location = new System.Drawing.Point(1, 19);
            this.startWCFBtn.Name = "startWCFBtn";
            this.startWCFBtn.Size = new System.Drawing.Size(75, 23);
            this.startWCFBtn.TabIndex = 0;
            this.startWCFBtn.Text = "WCF";
            this.startWCFBtn.UseVisualStyleBackColor = true;
            this.startWCFBtn.Click += new System.EventHandler(this.startWCFBtn_Click);
            // 
            // stopBranch2Btn
            // 
            this.stopBranch2Btn.Location = new System.Drawing.Point(1, 106);
            this.stopBranch2Btn.Name = "stopBranch2Btn";
            this.stopBranch2Btn.Size = new System.Drawing.Size(75, 23);
            this.stopBranch2Btn.TabIndex = 6;
            this.stopBranch2Btn.Text = "Oddzial 2";
            this.stopBranch2Btn.UseVisualStyleBackColor = true;
            this.stopBranch2Btn.Click += new System.EventHandler(this.stopBranch2Btn_Click);
            // 
            // stopCentralBtn
            // 
            this.stopCentralBtn.Location = new System.Drawing.Point(1, 48);
            this.stopCentralBtn.Name = "stopCentralBtn";
            this.stopCentralBtn.Size = new System.Drawing.Size(75, 23);
            this.stopCentralBtn.TabIndex = 4;
            this.stopCentralBtn.Text = "Centrala";
            this.stopCentralBtn.UseVisualStyleBackColor = true;
            this.stopCentralBtn.Click += new System.EventHandler(this.stopCentralBtn_Click);
            // 
            // stopBranch1Btn
            // 
            this.stopBranch1Btn.Location = new System.Drawing.Point(1, 77);
            this.stopBranch1Btn.Name = "stopBranch1Btn";
            this.stopBranch1Btn.Size = new System.Drawing.Size(75, 23);
            this.stopBranch1Btn.TabIndex = 5;
            this.stopBranch1Btn.Text = "Oddzial 1";
            this.stopBranch1Btn.UseVisualStyleBackColor = true;
            this.stopBranch1Btn.Click += new System.EventHandler(this.stopBranch1Btn_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.stopWCFBtn);
            this.groupBox2.Controls.Add(this.stopBranch2Btn);
            this.groupBox2.Controls.Add(this.stopCentralBtn);
            this.groupBox2.Controls.Add(this.stopBranch1Btn);
            this.groupBox2.Location = new System.Drawing.Point(100, 51);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(78, 143);
            this.groupBox2.TabIndex = 7;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Zatrzymaj";
            // 
            // stopWCFBtn
            // 
            this.stopWCFBtn.Location = new System.Drawing.Point(1, 19);
            this.stopWCFBtn.Name = "stopWCFBtn";
            this.stopWCFBtn.Size = new System.Drawing.Size(75, 23);
            this.stopWCFBtn.TabIndex = 0;
            this.stopWCFBtn.Text = "WCF";
            this.stopWCFBtn.UseVisualStyleBackColor = true;
            this.stopWCFBtn.Click += new System.EventHandler(this.stopWCFBtn_Click);
            // 
            // updateBtn
            // 
            this.updateBtn.Location = new System.Drawing.Point(62, 12);
            this.updateBtn.Name = "updateBtn";
            this.updateBtn.Size = new System.Drawing.Size(71, 23);
            this.updateBtn.TabIndex = 8;
            this.updateBtn.Text = "Uaktualnij";
            this.updateBtn.UseVisualStyleBackColor = true;
            this.updateBtn.Click += new System.EventHandler(this.updateBtn_Click);
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.branch2ProcessIdLbl);
            this.groupBox3.Controls.Add(this.branch1ProcessIdLbl);
            this.groupBox3.Controls.Add(this.centralProcessIdLbl);
            this.groupBox3.Controls.Add(this.wcfProcessIdLbl);
            this.groupBox3.Location = new System.Drawing.Point(184, 51);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(78, 143);
            this.groupBox3.TabIndex = 9;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Id procesu";
            // 
            // wcfProcessIdLbl
            // 
            this.wcfProcessIdLbl.AutoSize = true;
            this.wcfProcessIdLbl.Location = new System.Drawing.Point(16, 24);
            this.wcfProcessIdLbl.Name = "wcfProcessIdLbl";
            this.wcfProcessIdLbl.Size = new System.Drawing.Size(0, 13);
            this.wcfProcessIdLbl.TabIndex = 0;
            // 
            // centralProcessIdLbl
            // 
            this.centralProcessIdLbl.AutoSize = true;
            this.centralProcessIdLbl.Location = new System.Drawing.Point(16, 53);
            this.centralProcessIdLbl.Name = "centralProcessIdLbl";
            this.centralProcessIdLbl.Size = new System.Drawing.Size(0, 13);
            this.centralProcessIdLbl.TabIndex = 1;
            // 
            // branch1ProcessIdLbl
            // 
            this.branch1ProcessIdLbl.AutoSize = true;
            this.branch1ProcessIdLbl.Location = new System.Drawing.Point(16, 82);
            this.branch1ProcessIdLbl.Name = "branch1ProcessIdLbl";
            this.branch1ProcessIdLbl.Size = new System.Drawing.Size(0, 13);
            this.branch1ProcessIdLbl.TabIndex = 2;
            // 
            // branch2ProcessIdLbl
            // 
            this.branch2ProcessIdLbl.AutoSize = true;
            this.branch2ProcessIdLbl.Location = new System.Drawing.Point(16, 111);
            this.branch2ProcessIdLbl.Name = "branch2ProcessIdLbl";
            this.branch2ProcessIdLbl.Size = new System.Drawing.Size(0, 13);
            this.branch2ProcessIdLbl.TabIndex = 3;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(290, 205);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.updateBtn);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.startBranch2Btn);
            this.Controls.Add(this.startCentralBtn);
            this.Controls.Add(this.startBranch1Btn);
            this.Controls.Add(this.groupBox1);
            this.Name = "Form1";
            this.Text = "Tester Komnikacji";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button startCentralBtn;
        private System.Windows.Forms.Button startBranch1Btn;
        private System.Windows.Forms.Button startBranch2Btn;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button stopBranch2Btn;
        private System.Windows.Forms.Button stopCentralBtn;
        private System.Windows.Forms.Button stopBranch1Btn;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button startWCFBtn;
        private System.Windows.Forms.Button stopWCFBtn;
        private System.Windows.Forms.Button updateBtn;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.Label branch2ProcessIdLbl;
        private System.Windows.Forms.Label branch1ProcessIdLbl;
        private System.Windows.Forms.Label centralProcessIdLbl;
        private System.Windows.Forms.Label wcfProcessIdLbl;
    }
}

