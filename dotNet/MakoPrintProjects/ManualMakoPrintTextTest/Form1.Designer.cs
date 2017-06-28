namespace TestIglowka
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
			this.viewTextPrint = new System.Windows.Forms.Button();
			this.inputWindow = new System.Windows.Forms.RichTextBox();
			this.wytnij = new System.Windows.Forms.Button();
			this.button1 = new System.Windows.Forms.Button();
			this.button2 = new System.Windows.Forms.Button();
			this.label1 = new System.Windows.Forms.Label();
			this.button3 = new System.Windows.Forms.Button();
			this.button4 = new System.Windows.Forms.Button();
			this.xsltFilenameTextBox = new System.Windows.Forms.TextBox();
			this.objectXmlFileNameTextBox = new System.Windows.Forms.TextBox();
			this.GetXsltButton = new System.Windows.Forms.Button();
			this.getObjectXmlButton = new System.Windows.Forms.Button();
			this.transformButton = new System.Windows.Forms.Button();
			this.outputWindow = new System.Windows.Forms.RichTextBox();
			this.chBoxRawView = new System.Windows.Forms.CheckBox();
			this.getPrinterNamesButton = new System.Windows.Forms.Button();
			this.checkBoxPaging = new System.Windows.Forms.CheckBox();
			this.SuspendLayout();
			// 
			// viewTextPrint
			// 
			this.viewTextPrint.Location = new System.Drawing.Point(12, 385);
			this.viewTextPrint.Name = "viewTextPrint";
			this.viewTextPrint.Size = new System.Drawing.Size(75, 23);
			this.viewTextPrint.TabIndex = 1;
			this.viewTextPrint.Text = "Podglad";
			this.viewTextPrint.UseVisualStyleBackColor = true;
			this.viewTextPrint.Click += new System.EventHandler(this.viewTextPrint_Click);
			// 
			// inputWindow
			// 
			this.inputWindow.Location = new System.Drawing.Point(116, 15);
			this.inputWindow.Name = "inputWindow";
			this.inputWindow.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical;
			this.inputWindow.Size = new System.Drawing.Size(1557, 278);
			this.inputWindow.TabIndex = 2;
			this.inputWindow.Text = "";
			// 
			// wytnij
			// 
			this.wytnij.Location = new System.Drawing.Point(12, 453);
			this.wytnij.Name = "wytnij";
			this.wytnij.Size = new System.Drawing.Size(75, 23);
			this.wytnij.TabIndex = 3;
			this.wytnij.Text = "wytnij";
			this.wytnij.UseVisualStyleBackColor = true;
			this.wytnij.Click += new System.EventHandler(this.wytnij_Click);
			// 
			// button1
			// 
			this.button1.Location = new System.Drawing.Point(10, 34);
			this.button1.Name = "button1";
			this.button1.Size = new System.Drawing.Size(97, 23);
			this.button1.TabIndex = 4;
			this.button1.Text = "FVS";
			this.button1.UseVisualStyleBackColor = true;
			this.button1.Click += new System.EventHandler(this.button1_Click);
			// 
			// button2
			// 
			this.button2.Location = new System.Drawing.Point(9, 96);
			this.button2.Name = "button2";
			this.button2.Size = new System.Drawing.Size(99, 23);
			this.button2.TabIndex = 5;
			this.button2.Text = "ramki z pt";
			this.button2.UseVisualStyleBackColor = true;
			this.button2.Click += new System.EventHandler(this.button2_Click);
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point(24, 18);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(63, 13);
			this.label1.TabIndex = 6;
			this.label1.Text = "wstaw tekst";
			// 
			// button3
			// 
			this.button3.Location = new System.Drawing.Point(9, 125);
			this.button3.Name = "button3";
			this.button3.Size = new System.Drawing.Size(99, 23);
			this.button3.TabIndex = 7;
			this.button3.Text = "ramki";
			this.button3.UseVisualStyleBackColor = true;
			this.button3.Click += new System.EventHandler(this.button3_Click);
			// 
			// button4
			// 
			this.button4.Location = new System.Drawing.Point(10, 63);
			this.button4.Name = "button4";
			this.button4.Size = new System.Drawing.Size(99, 23);
			this.button4.TabIndex = 8;
			this.button4.Text = "korekta";
			this.button4.UseVisualStyleBackColor = true;
			this.button4.Click += new System.EventHandler(this.button4_Click);
			// 
			// xsltFilenameTextBox
			// 
			this.xsltFilenameTextBox.Location = new System.Drawing.Point(7, 165);
			this.xsltFilenameTextBox.Name = "xsltFilenameTextBox";
			this.xsltFilenameTextBox.Size = new System.Drawing.Size(103, 20);
			this.xsltFilenameTextBox.TabIndex = 9;
			// 
			// objectXmlFileNameTextBox
			// 
			this.objectXmlFileNameTextBox.Location = new System.Drawing.Point(7, 214);
			this.objectXmlFileNameTextBox.Name = "objectXmlFileNameTextBox";
			this.objectXmlFileNameTextBox.Size = new System.Drawing.Size(101, 20);
			this.objectXmlFileNameTextBox.TabIndex = 12;
			// 
			// GetXsltButton
			// 
			this.GetXsltButton.Location = new System.Drawing.Point(7, 190);
			this.GetXsltButton.Name = "GetXsltButton";
			this.GetXsltButton.Size = new System.Drawing.Size(102, 23);
			this.GetXsltButton.TabIndex = 13;
			this.GetXsltButton.Text = "Wczytaj xslt";
			this.GetXsltButton.UseVisualStyleBackColor = true;
			this.GetXsltButton.Click += new System.EventHandler(this.GetXsltButton_Click);
			// 
			// getObjectXmlButton
			// 
			this.getObjectXmlButton.Location = new System.Drawing.Point(7, 237);
			this.getObjectXmlButton.Name = "getObjectXmlButton";
			this.getObjectXmlButton.Size = new System.Drawing.Size(101, 41);
			this.getObjectXmlButton.TabIndex = 14;
			this.getObjectXmlButton.Text = "Wczytaj xml obiektu";
			this.getObjectXmlButton.UseVisualStyleBackColor = true;
			this.getObjectXmlButton.Click += new System.EventHandler(this.getObjectXmlButton_Click);
			// 
			// transformButton
			// 
			this.transformButton.Location = new System.Drawing.Point(12, 310);
			this.transformButton.Name = "transformButton";
			this.transformButton.Size = new System.Drawing.Size(75, 23);
			this.transformButton.TabIndex = 15;
			this.transformButton.Text = "Transformuj";
			this.transformButton.UseVisualStyleBackColor = true;
			this.transformButton.Click += new System.EventHandler(this.transformButton_Click);
			// 
			// outputWindow
			// 
			this.outputWindow.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
			this.outputWindow.Location = new System.Drawing.Point(116, 299);
			this.outputWindow.Name = "outputWindow";
			this.outputWindow.Size = new System.Drawing.Size(1479, 563);
			this.outputWindow.TabIndex = 16;
			this.outputWindow.Text = "";
			this.outputWindow.ZoomFactor = 1.25F;
			// 
			// chBoxRawView
			// 
			this.chBoxRawView.AutoSize = true;
			this.chBoxRawView.Location = new System.Drawing.Point(13, 362);
			this.chBoxRawView.Name = "chBoxRawView";
			this.chBoxRawView.Size = new System.Drawing.Size(59, 17);
			this.chBoxRawView.TabIndex = 17;
			this.chBoxRawView.Text = "surowy";
			this.chBoxRawView.UseVisualStyleBackColor = true;
			// 
			// getPrinterNamesButton
			// 
			this.getPrinterNamesButton.Location = new System.Drawing.Point(10, 502);
			this.getPrinterNamesButton.Margin = new System.Windows.Forms.Padding(2);
			this.getPrinterNamesButton.Name = "getPrinterNamesButton";
			this.getPrinterNamesButton.Size = new System.Drawing.Size(75, 53);
			this.getPrinterNamesButton.TabIndex = 18;
			this.getPrinterNamesButton.Text = "Pobierz nazwy drukarek";
			this.getPrinterNamesButton.UseVisualStyleBackColor = true;
			this.getPrinterNamesButton.Click += new System.EventHandler(this.getPrinterNamesButton_Click);
			// 
			// checkBoxPaging
			// 
			this.checkBoxPaging.AutoSize = true;
			this.checkBoxPaging.Checked = true;
			this.checkBoxPaging.CheckState = System.Windows.Forms.CheckState.Checked;
			this.checkBoxPaging.Location = new System.Drawing.Point(14, 415);
			this.checkBoxPaging.Name = "checkBoxPaging";
			this.checkBoxPaging.Size = new System.Drawing.Size(91, 17);
			this.checkBoxPaging.TabIndex = 19;
			this.checkBoxPaging.Text = "stronicowanie";
			this.checkBoxPaging.UseVisualStyleBackColor = true;
			// 
			// Form1
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(1197, 710);
			this.Controls.Add(this.checkBoxPaging);
			this.Controls.Add(this.getPrinterNamesButton);
			this.Controls.Add(this.chBoxRawView);
			this.Controls.Add(this.outputWindow);
			this.Controls.Add(this.transformButton);
			this.Controls.Add(this.getObjectXmlButton);
			this.Controls.Add(this.GetXsltButton);
			this.Controls.Add(this.objectXmlFileNameTextBox);
			this.Controls.Add(this.xsltFilenameTextBox);
			this.Controls.Add(this.button4);
			this.Controls.Add(this.button3);
			this.Controls.Add(this.label1);
			this.Controls.Add(this.button2);
			this.Controls.Add(this.button1);
			this.Controls.Add(this.wytnij);
			this.Controls.Add(this.inputWindow);
			this.Controls.Add(this.viewTextPrint);
			this.Name = "Form1";
			this.Text = "Form1";
			this.ResumeLayout(false);
			this.PerformLayout();

        }

        #endregion

		private System.Windows.Forms.Button viewTextPrint;
        private System.Windows.Forms.RichTextBox inputWindow;
        private System.Windows.Forms.Button wytnij;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button button3;
        private System.Windows.Forms.Button button4;
		private System.Windows.Forms.TextBox xsltFilenameTextBox;
		private System.Windows.Forms.TextBox objectXmlFileNameTextBox;
		private System.Windows.Forms.Button GetXsltButton;
		private System.Windows.Forms.Button getObjectXmlButton;
		private System.Windows.Forms.Button transformButton;
		private System.Windows.Forms.RichTextBox outputWindow;
		private System.Windows.Forms.CheckBox chBoxRawView;
        private System.Windows.Forms.Button getPrinterNamesButton;
		private System.Windows.Forms.CheckBox checkBoxPaging;
    }
}

