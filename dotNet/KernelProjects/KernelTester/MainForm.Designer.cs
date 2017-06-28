namespace Makolab.Fractus.Kernel.KernelTester
{
    partial class MainForm
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
            this.tabControlMain = new System.Windows.Forms.TabControl();
            this.tabPageRawXml = new System.Windows.Forms.TabPage();
            this.tabPageXmlTreeView = new System.Windows.Forms.TabPage();
            this.tabPageHighlighted = new System.Windows.Forms.TabPage();
            this.btnLogin = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label10 = new System.Windows.Forms.Label();
            this.txtBoxProfile = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.txtBoxLanguage = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.txtBoxPassword = new System.Windows.Forms.TextBox();
            this.txtBoxUser = new System.Windows.Forms.TextBox();
            this.btnCustomExecute = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.btnPrintReport = new System.Windows.Forms.Button();
            this.btnClearSource = new System.Windows.Forms.Button();
            this.label8 = new System.Windows.Forms.Label();
            this.txtBoxSource = new System.Windows.Forms.TextBox();
            this.txtBoxTemplate = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.btnDelete = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.btnLoad = new System.Windows.Forms.Button();
            this.txtBoxId = new System.Windows.Forms.TextBox();
            this.btnSave = new System.Windows.Forms.Button();
            this.btnCreateNewBO = new System.Windows.Forms.Button();
            this.cboxType = new System.Windows.Forms.ComboBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.rbtnNormalSession = new System.Windows.Forms.RadioButton();
            this.rbtnOneTimeSession = new System.Windows.Forms.RadioButton();
            this.cboxMethodName = new System.Windows.Forms.ComboBox();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.label7 = new System.Windows.Forms.Label();
            this.btnHtmlDecode = new System.Windows.Forms.Button();
            this.btnUrlDecode = new System.Windows.Forms.Button();
            this.groupBox5 = new System.Windows.Forms.GroupBox();
            this.btnExecuteCustomProc = new System.Windows.Forms.Button();
            this.txtBoxCustomProcName = new System.Windows.Forms.TextBox();
            this.label9 = new System.Windows.Forms.Label();
            this.groupBoxTransformScript = new System.Windows.Forms.GroupBox();
            this.buttonGenerateTransformScript = new System.Windows.Forms.Button();
            this.buttonBrowse = new System.Windows.Forms.Button();
            this.labelScriptName = new System.Windows.Forms.Label();
            this.labelInputFolder = new System.Windows.Forms.Label();
            this.textBoxScriptName = new System.Windows.Forms.TextBox();
            this.textBoxInputFolder = new System.Windows.Forms.TextBox();
            this.button1 = new System.Windows.Forms.Button();
            this.GuidBarcodeResultInput = new System.Windows.Forms.TextBox();
            this.tabControlMain.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox4.SuspendLayout();
            this.groupBox5.SuspendLayout();
            this.groupBoxTransformScript.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabControlMain
            // 
            this.tabControlMain.Controls.Add(this.tabPageRawXml);
            this.tabControlMain.Controls.Add(this.tabPageXmlTreeView);
            this.tabControlMain.Controls.Add(this.tabPageHighlighted);
            this.tabControlMain.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.tabControlMain.Location = new System.Drawing.Point(0, 231);
            this.tabControlMain.Name = "tabControlMain";
            this.tabControlMain.SelectedIndex = 0;
            this.tabControlMain.Size = new System.Drawing.Size(973, 475);
            this.tabControlMain.TabIndex = 0;
            this.tabControlMain.SelectedIndexChanged += new System.EventHandler(this.tabControlMain_SelectedIndexChanged);
            // 
            // tabPageRawXml
            // 
            this.tabPageRawXml.Location = new System.Drawing.Point(4, 22);
            this.tabPageRawXml.Name = "tabPageRawXml";
            this.tabPageRawXml.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageRawXml.Size = new System.Drawing.Size(965, 449);
            this.tabPageRawXml.TabIndex = 0;
            this.tabPageRawXml.Text = "RAW XML";
            this.tabPageRawXml.UseVisualStyleBackColor = true;
            // 
            // tabPageXmlTreeView
            // 
            this.tabPageXmlTreeView.Location = new System.Drawing.Point(4, 22);
            this.tabPageXmlTreeView.Name = "tabPageXmlTreeView";
            this.tabPageXmlTreeView.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageXmlTreeView.Size = new System.Drawing.Size(965, 449);
            this.tabPageXmlTreeView.TabIndex = 1;
            this.tabPageXmlTreeView.Text = "XML TreeView";
            this.tabPageXmlTreeView.UseVisualStyleBackColor = true;
            // 
            // tabPageHighlighted
            // 
            this.tabPageHighlighted.Location = new System.Drawing.Point(4, 22);
            this.tabPageHighlighted.Name = "tabPageHighlighted";
            this.tabPageHighlighted.Size = new System.Drawing.Size(965, 449);
            this.tabPageHighlighted.TabIndex = 2;
            this.tabPageHighlighted.Text = "Highlighted xml";
            this.tabPageHighlighted.UseVisualStyleBackColor = true;
            // 
            // btnLogin
            // 
            this.btnLogin.Location = new System.Drawing.Point(119, 91);
            this.btnLogin.Name = "btnLogin";
            this.btnLogin.Size = new System.Drawing.Size(75, 23);
            this.btnLogin.TabIndex = 1;
            this.btnLogin.Text = "Login";
            this.btnLogin.UseVisualStyleBackColor = true;
            this.btnLogin.Click += new System.EventHandler(this.btnLogin_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label10);
            this.groupBox1.Controls.Add(this.txtBoxProfile);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.txtBoxLanguage);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.btnLogin);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.txtBoxPassword);
            this.groupBox1.Controls.Add(this.txtBoxUser);
            this.groupBox1.Location = new System.Drawing.Point(767, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(200, 117);
            this.groupBox1.TabIndex = 2;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Login";
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(7, 75);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(36, 13);
            this.label10.TabIndex = 7;
            this.label10.Text = "Profile";
            // 
            // txtBoxProfile
            // 
            this.txtBoxProfile.Location = new System.Drawing.Point(64, 68);
            this.txtBoxProfile.Name = "txtBoxProfile";
            this.txtBoxProfile.Size = new System.Drawing.Size(130, 20);
            this.txtBoxProfile.TabIndex = 6;
            this.txtBoxProfile.Text = "Profil 1";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(7, 94);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(31, 13);
            this.label5.TabIndex = 5;
            this.label5.Text = "Lang";
            // 
            // txtBoxLanguage
            // 
            this.txtBoxLanguage.Location = new System.Drawing.Point(64, 91);
            this.txtBoxLanguage.Name = "txtBoxLanguage";
            this.txtBoxLanguage.Size = new System.Drawing.Size(29, 20);
            this.txtBoxLanguage.TabIndex = 4;
            this.txtBoxLanguage.Text = "pl";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(7, 50);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(53, 13);
            this.label2.TabIndex = 3;
            this.label2.Text = "Password";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(7, 26);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(29, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "User";
            // 
            // txtBoxPassword
            // 
            this.txtBoxPassword.Location = new System.Drawing.Point(64, 43);
            this.txtBoxPassword.Name = "txtBoxPassword";
            this.txtBoxPassword.Size = new System.Drawing.Size(130, 20);
            this.txtBoxPassword.TabIndex = 1;
            this.txtBoxPassword.Text = "fbc0869948bf8c8805dcf8ed246c68068bf55953ff68b5d87aad44cabd2ac09f";
            this.txtBoxPassword.DoubleClick += new System.EventHandler(this.txtBox_DoubleClick);
            // 
            // txtBoxUser
            // 
            this.txtBoxUser.Location = new System.Drawing.Point(64, 19);
            this.txtBoxUser.Name = "txtBoxUser";
            this.txtBoxUser.Size = new System.Drawing.Size(130, 20);
            this.txtBoxUser.TabIndex = 0;
            this.txtBoxUser.Text = "makoadmin";
            this.txtBoxUser.DoubleClick += new System.EventHandler(this.txtBox_DoubleClick);
            // 
            // btnCustomExecute
            // 
            this.btnCustomExecute.Location = new System.Drawing.Point(106, 61);
            this.btnCustomExecute.Name = "btnCustomExecute";
            this.btnCustomExecute.Size = new System.Drawing.Size(75, 23);
            this.btnCustomExecute.TabIndex = 3;
            this.btnCustomExecute.Text = "Execute";
            this.btnCustomExecute.UseVisualStyleBackColor = true;
            this.btnCustomExecute.Click += new System.EventHandler(this.btnCustom_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.btnPrintReport);
            this.groupBox2.Controls.Add(this.btnClearSource);
            this.groupBox2.Controls.Add(this.label8);
            this.groupBox2.Controls.Add(this.txtBoxSource);
            this.groupBox2.Controls.Add(this.txtBoxTemplate);
            this.groupBox2.Controls.Add(this.label6);
            this.groupBox2.Controls.Add(this.btnDelete);
            this.groupBox2.Controls.Add(this.label4);
            this.groupBox2.Controls.Add(this.label3);
            this.groupBox2.Controls.Add(this.btnLoad);
            this.groupBox2.Controls.Add(this.txtBoxId);
            this.groupBox2.Controls.Add(this.btnSave);
            this.groupBox2.Controls.Add(this.btnCreateNewBO);
            this.groupBox2.Controls.Add(this.cboxType);
            this.groupBox2.Location = new System.Drawing.Point(12, 12);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(356, 213);
            this.groupBox2.TabIndex = 4;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "BusinessObject";
            // 
            // btnPrintReport
            // 
            this.btnPrintReport.Location = new System.Drawing.Point(6, 184);
            this.btnPrintReport.Name = "btnPrintReport";
            this.btnPrintReport.Size = new System.Drawing.Size(75, 23);
            this.btnPrintReport.TabIndex = 13;
            this.btnPrintReport.Text = "PrintReport";
            this.btnPrintReport.UseVisualStyleBackColor = true;
            this.btnPrintReport.Click += new System.EventHandler(this.btnPrintReport_Click);
            // 
            // btnClearSource
            // 
            this.btnClearSource.Location = new System.Drawing.Point(237, 157);
            this.btnClearSource.Name = "btnClearSource";
            this.btnClearSource.Size = new System.Drawing.Size(79, 23);
            this.btnClearSource.TabIndex = 12;
            this.btnClearSource.Text = "ClearSource";
            this.btnClearSource.UseVisualStyleBackColor = true;
            this.btnClearSource.Click += new System.EventHandler(this.btnCreateTask_Click);
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(6, 79);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(41, 13);
            this.label8.TabIndex = 11;
            this.label8.Text = "Source";
            // 
            // txtBoxSource
            // 
            this.txtBoxSource.Location = new System.Drawing.Point(6, 97);
            this.txtBoxSource.MaxLength = 100000;
            this.txtBoxSource.Multiline = true;
            this.txtBoxSource.Name = "txtBoxSource";
            this.txtBoxSource.Size = new System.Drawing.Size(344, 54);
            this.txtBoxSource.TabIndex = 10;
            this.txtBoxSource.DoubleClick += new System.EventHandler(this.txtBox_DoubleClick);
            // 
            // txtBoxTemplate
            // 
            this.txtBoxTemplate.Location = new System.Drawing.Point(60, 60);
            this.txtBoxTemplate.Name = "txtBoxTemplate";
            this.txtBoxTemplate.Size = new System.Drawing.Size(290, 20);
            this.txtBoxTemplate.TabIndex = 9;
            this.txtBoxTemplate.DoubleClick += new System.EventHandler(this.txtBox_DoubleClick);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(3, 61);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(51, 13);
            this.label6.TabIndex = 8;
            this.label6.Text = "Template";
            // 
            // btnDelete
            // 
            this.btnDelete.Location = new System.Drawing.Point(177, 157);
            this.btnDelete.Name = "btnDelete";
            this.btnDelete.Size = new System.Drawing.Size(54, 23);
            this.btnDelete.TabIndex = 7;
            this.btnDelete.Text = "Delete";
            this.btnDelete.UseVisualStyleBackColor = true;
            this.btnDelete.Click += new System.EventHandler(this.btnDelete_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(237, 22);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(16, 13);
            this.label4.TabIndex = 6;
            this.label4.Text = "Id";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(6, 18);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(31, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Type";
            // 
            // btnLoad
            // 
            this.btnLoad.Location = new System.Drawing.Point(123, 157);
            this.btnLoad.Name = "btnLoad";
            this.btnLoad.Size = new System.Drawing.Size(49, 23);
            this.btnLoad.TabIndex = 4;
            this.btnLoad.Text = "Load";
            this.btnLoad.UseVisualStyleBackColor = true;
            this.btnLoad.Click += new System.EventHandler(this.btnLoad_Click);
            // 
            // txtBoxId
            // 
            this.txtBoxId.Location = new System.Drawing.Point(240, 35);
            this.txtBoxId.Name = "txtBoxId";
            this.txtBoxId.Size = new System.Drawing.Size(110, 20);
            this.txtBoxId.TabIndex = 3;
            this.txtBoxId.DoubleClick += new System.EventHandler(this.txtBox_DoubleClick);
            // 
            // btnSave
            // 
            this.btnSave.Location = new System.Drawing.Point(66, 157);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(50, 23);
            this.btnSave.TabIndex = 2;
            this.btnSave.Text = "Save";
            this.btnSave.UseVisualStyleBackColor = true;
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // btnCreateNewBO
            // 
            this.btnCreateNewBO.Location = new System.Drawing.Point(6, 157);
            this.btnCreateNewBO.Name = "btnCreateNewBO";
            this.btnCreateNewBO.Size = new System.Drawing.Size(53, 23);
            this.btnCreateNewBO.TabIndex = 1;
            this.btnCreateNewBO.Text = "Create";
            this.btnCreateNewBO.UseVisualStyleBackColor = true;
            this.btnCreateNewBO.Click += new System.EventHandler(this.btnCreateNewBO_Click);
            // 
            // cboxType
            // 
            this.cboxType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboxType.FormattingEnabled = true;
            this.cboxType.Location = new System.Drawing.Point(6, 34);
            this.cboxType.Name = "cboxType";
            this.cboxType.Size = new System.Drawing.Size(225, 21);
            this.cboxType.TabIndex = 0;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.rbtnNormalSession);
            this.groupBox3.Controls.Add(this.rbtnOneTimeSession);
            this.groupBox3.Location = new System.Drawing.Point(667, 12);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(94, 63);
            this.groupBox3.TabIndex = 5;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "SessionMode";
            // 
            // rbtnNormalSession
            // 
            this.rbtnNormalSession.AutoSize = true;
            this.rbtnNormalSession.Location = new System.Drawing.Point(7, 40);
            this.rbtnNormalSession.Name = "rbtnNormalSession";
            this.rbtnNormalSession.Size = new System.Drawing.Size(58, 17);
            this.rbtnNormalSession.TabIndex = 1;
            this.rbtnNormalSession.TabStop = true;
            this.rbtnNormalSession.Text = "Normal";
            this.rbtnNormalSession.UseVisualStyleBackColor = true;
            // 
            // rbtnOneTimeSession
            // 
            this.rbtnOneTimeSession.AutoSize = true;
            this.rbtnOneTimeSession.Checked = true;
            this.rbtnOneTimeSession.Location = new System.Drawing.Point(7, 20);
            this.rbtnOneTimeSession.Name = "rbtnOneTimeSession";
            this.rbtnOneTimeSession.Size = new System.Drawing.Size(71, 17);
            this.rbtnOneTimeSession.TabIndex = 0;
            this.rbtnOneTimeSession.TabStop = true;
            this.rbtnOneTimeSession.Text = "One Time";
            this.rbtnOneTimeSession.UseVisualStyleBackColor = true;
            // 
            // cboxMethodName
            // 
            this.cboxMethodName.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboxMethodName.FormattingEnabled = true;
            this.cboxMethodName.Location = new System.Drawing.Point(6, 34);
            this.cboxMethodName.Name = "cboxMethodName";
            this.cboxMethodName.Size = new System.Drawing.Size(275, 21);
            this.cboxMethodName.TabIndex = 6;
            this.cboxMethodName.SelectedIndexChanged += new System.EventHandler(this.cboxMethodName_SelectedIndexChanged);
            // 
            // groupBox4
            // 
            this.groupBox4.Controls.Add(this.label7);
            this.groupBox4.Controls.Add(this.btnCustomExecute);
            this.groupBox4.Controls.Add(this.cboxMethodName);
            this.groupBox4.Location = new System.Drawing.Point(374, 12);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(287, 98);
            this.groupBox4.TabIndex = 7;
            this.groupBox4.TabStop = false;
            this.groupBox4.Text = "Custom method execution";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(6, 18);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(72, 13);
            this.label7.TabIndex = 10;
            this.label7.Text = "Method name";
            // 
            // btnHtmlDecode
            // 
            this.btnHtmlDecode.Location = new System.Drawing.Point(667, 77);
            this.btnHtmlDecode.Name = "btnHtmlDecode";
            this.btnHtmlDecode.Size = new System.Drawing.Size(94, 23);
            this.btnHtmlDecode.TabIndex = 8;
            this.btnHtmlDecode.Text = "HTML Decode";
            this.btnHtmlDecode.UseVisualStyleBackColor = true;
            this.btnHtmlDecode.Click += new System.EventHandler(this.btnHtmlDecode_Click);
            // 
            // btnUrlDecode
            // 
            this.btnUrlDecode.Location = new System.Drawing.Point(667, 106);
            this.btnUrlDecode.Name = "btnUrlDecode";
            this.btnUrlDecode.Size = new System.Drawing.Size(94, 23);
            this.btnUrlDecode.TabIndex = 9;
            this.btnUrlDecode.Text = "URL Decode";
            this.btnUrlDecode.UseVisualStyleBackColor = true;
            this.btnUrlDecode.Click += new System.EventHandler(this.btnUrlDecode_Click);
            // 
            // groupBox5
            // 
            this.groupBox5.Controls.Add(this.btnExecuteCustomProc);
            this.groupBox5.Controls.Add(this.txtBoxCustomProcName);
            this.groupBox5.Controls.Add(this.label9);
            this.groupBox5.Location = new System.Drawing.Point(375, 117);
            this.groupBox5.Name = "groupBox5";
            this.groupBox5.Size = new System.Drawing.Size(286, 85);
            this.groupBox5.TabIndex = 10;
            this.groupBox5.TabStop = false;
            this.groupBox5.Text = "ExecuteCustomProcedure";
            // 
            // btnExecuteCustomProc
            // 
            this.btnExecuteCustomProc.Location = new System.Drawing.Point(105, 52);
            this.btnExecuteCustomProc.Name = "btnExecuteCustomProc";
            this.btnExecuteCustomProc.Size = new System.Drawing.Size(75, 23);
            this.btnExecuteCustomProc.TabIndex = 12;
            this.btnExecuteCustomProc.Text = "Execute";
            this.btnExecuteCustomProc.UseVisualStyleBackColor = true;
            this.btnExecuteCustomProc.Click += new System.EventHandler(this.btnExecuteCustomProc_Click);
            // 
            // txtBoxCustomProcName
            // 
            this.txtBoxCustomProcName.Location = new System.Drawing.Point(47, 26);
            this.txtBoxCustomProcName.Name = "txtBoxCustomProcName";
            this.txtBoxCustomProcName.Size = new System.Drawing.Size(233, 20);
            this.txtBoxCustomProcName.TabIndex = 11;
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(6, 27);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(35, 13);
            this.label9.TabIndex = 10;
            this.label9.Text = "Name";
            // 
            // groupBoxTransformScript
            // 
            this.groupBoxTransformScript.Controls.Add(this.buttonGenerateTransformScript);
            this.groupBoxTransformScript.Controls.Add(this.buttonBrowse);
            this.groupBoxTransformScript.Controls.Add(this.labelScriptName);
            this.groupBoxTransformScript.Controls.Add(this.labelInputFolder);
            this.groupBoxTransformScript.Controls.Add(this.textBoxScriptName);
            this.groupBoxTransformScript.Controls.Add(this.textBoxInputFolder);
            this.groupBoxTransformScript.Location = new System.Drawing.Point(668, 138);
            this.groupBoxTransformScript.Name = "groupBoxTransformScript";
            this.groupBoxTransformScript.Size = new System.Drawing.Size(298, 81);
            this.groupBoxTransformScript.TabIndex = 11;
            this.groupBoxTransformScript.TabStop = false;
            this.groupBoxTransformScript.Text = "Transformations update script";
            // 
            // buttonGenerateTransformScript
            // 
            this.buttonGenerateTransformScript.Location = new System.Drawing.Point(218, 44);
            this.buttonGenerateTransformScript.Name = "buttonGenerateTransformScript";
            this.buttonGenerateTransformScript.Size = new System.Drawing.Size(71, 23);
            this.buttonGenerateTransformScript.TabIndex = 11;
            this.buttonGenerateTransformScript.Text = "Generate";
            this.buttonGenerateTransformScript.UseVisualStyleBackColor = true;
            this.buttonGenerateTransformScript.Click += new System.EventHandler(this.buttonGenerateTransformScript_Click);
            // 
            // buttonBrowse
            // 
            this.buttonBrowse.Location = new System.Drawing.Point(234, 19);
            this.buttonBrowse.Name = "buttonBrowse";
            this.buttonBrowse.Size = new System.Drawing.Size(55, 23);
            this.buttonBrowse.TabIndex = 10;
            this.buttonBrowse.Text = "Browse";
            this.buttonBrowse.UseVisualStyleBackColor = true;
            this.buttonBrowse.Click += new System.EventHandler(this.buttonBrowse_Click);
            // 
            // labelScriptName
            // 
            this.labelScriptName.AutoSize = true;
            this.labelScriptName.Location = new System.Drawing.Point(6, 50);
            this.labelScriptName.Name = "labelScriptName";
            this.labelScriptName.Size = new System.Drawing.Size(65, 13);
            this.labelScriptName.TabIndex = 9;
            this.labelScriptName.Text = "Script Name";
            // 
            // labelInputFolder
            // 
            this.labelInputFolder.AutoSize = true;
            this.labelInputFolder.Location = new System.Drawing.Point(6, 20);
            this.labelInputFolder.Name = "labelInputFolder";
            this.labelInputFolder.Size = new System.Drawing.Size(63, 13);
            this.labelInputFolder.TabIndex = 8;
            this.labelInputFolder.Text = "Input Folder";
            // 
            // textBoxScriptName
            // 
            this.textBoxScriptName.Location = new System.Drawing.Point(70, 47);
            this.textBoxScriptName.Name = "textBoxScriptName";
            this.textBoxScriptName.Size = new System.Drawing.Size(142, 20);
            this.textBoxScriptName.TabIndex = 1;
            // 
            // textBoxInputFolder
            // 
            this.textBoxInputFolder.Location = new System.Drawing.Point(70, 20);
            this.textBoxInputFolder.Name = "textBoxInputFolder";
            this.textBoxInputFolder.Size = new System.Drawing.Size(158, 20);
            this.textBoxInputFolder.TabIndex = 0;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(377, 208);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(109, 23);
            this.button1.TabIndex = 12;
            this.button1.Text = "GuidBarcodeResult";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // GuidBarcodeResultInput
            // 
            this.GuidBarcodeResultInput.Location = new System.Drawing.Point(493, 210);
            this.GuidBarcodeResultInput.Name = "GuidBarcodeResultInput";
            this.GuidBarcodeResultInput.Size = new System.Drawing.Size(168, 20);
            this.GuidBarcodeResultInput.TabIndex = 13;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(973, 706);
            this.Controls.Add(this.GuidBarcodeResultInput);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.groupBoxTransformScript);
            this.Controls.Add(this.groupBox5);
            this.Controls.Add(this.btnUrlDecode);
            this.Controls.Add(this.btnHtmlDecode);
            this.Controls.Add(this.groupBox4);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.tabControlMain);
            this.MaximizeBox = false;
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Fractus Tester";
            this.tabControlMain.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.groupBox4.ResumeLayout(false);
            this.groupBox4.PerformLayout();
            this.groupBox5.ResumeLayout(false);
            this.groupBox5.PerformLayout();
            this.groupBoxTransformScript.ResumeLayout(false);
            this.groupBoxTransformScript.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TabControl tabControlMain;
        private System.Windows.Forms.TabPage tabPageRawXml;
        private System.Windows.Forms.TabPage tabPageXmlTreeView;
        private System.Windows.Forms.Button btnLogin;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtBoxPassword;
        private System.Windows.Forms.TextBox txtBoxUser;
        private System.Windows.Forms.Button btnCustomExecute;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button btnCreateNewBO;
        private System.Windows.Forms.ComboBox cboxType;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.RadioButton rbtnNormalSession;
        private System.Windows.Forms.RadioButton rbtnOneTimeSession;
        private System.Windows.Forms.Button btnSave;
        private System.Windows.Forms.TextBox txtBoxId;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button btnLoad;
        private System.Windows.Forms.TextBox txtBoxLanguage;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TabPage tabPageHighlighted;
        private System.Windows.Forms.Button btnDelete;
        private System.Windows.Forms.TextBox txtBoxTemplate;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.ComboBox cboxMethodName;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Button btnHtmlDecode;
        private System.Windows.Forms.Button btnUrlDecode;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.TextBox txtBoxSource;
        private System.Windows.Forms.GroupBox groupBox5;
        private System.Windows.Forms.TextBox txtBoxCustomProcName;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Button btnExecuteCustomProc;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.TextBox txtBoxProfile;
		private System.Windows.Forms.Button btnClearSource;
		private System.Windows.Forms.Button btnPrintReport;
		private System.Windows.Forms.GroupBox groupBoxTransformScript;
		private System.Windows.Forms.Label labelScriptName;
		private System.Windows.Forms.Label labelInputFolder;
		private System.Windows.Forms.TextBox textBoxScriptName;
		private System.Windows.Forms.TextBox textBoxInputFolder;
		private System.Windows.Forms.Button buttonBrowse;
		private System.Windows.Forms.Button buttonGenerateTransformScript;
		private System.Windows.Forms.Button button1;
		private System.Windows.Forms.TextBox GuidBarcodeResultInput;
    }
}

