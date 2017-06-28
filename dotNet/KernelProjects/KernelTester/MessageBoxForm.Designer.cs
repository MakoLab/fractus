namespace Makolab.Fractus.Kernel.KernelTester
{
    partial class MessageBoxForm
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
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.tabControlMain = new System.Windows.Forms.TabControl();
            this.tabPageRawXml = new System.Windows.Forms.TabPage();
            this.tabPageXmlTreeView = new System.Windows.Forms.TabPage();
            this.btnOk = new System.Windows.Forms.Button();
            this.tabPageHighlighted = new System.Windows.Forms.TabPage();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.tabControlMain.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.tabControlMain);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.btnOk);
            this.splitContainer1.Size = new System.Drawing.Size(826, 528);
            this.splitContainer1.SplitterDistance = 491;
            this.splitContainer1.TabIndex = 2;
            // 
            // tabControlMain
            // 
            this.tabControlMain.Controls.Add(this.tabPageRawXml);
            this.tabControlMain.Controls.Add(this.tabPageXmlTreeView);
            this.tabControlMain.Controls.Add(this.tabPageHighlighted);
            this.tabControlMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControlMain.Location = new System.Drawing.Point(0, 0);
            this.tabControlMain.Name = "tabControlMain";
            this.tabControlMain.SelectedIndex = 0;
            this.tabControlMain.Size = new System.Drawing.Size(826, 491);
            this.tabControlMain.TabIndex = 2;
            this.tabControlMain.SelectedIndexChanged += new System.EventHandler(this.tabControlMain_SelectedIndexChanged);
            // 
            // tabPageRawXml
            // 
            this.tabPageRawXml.Location = new System.Drawing.Point(4, 22);
            this.tabPageRawXml.Name = "tabPageRawXml";
            this.tabPageRawXml.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageRawXml.Size = new System.Drawing.Size(818, 465);
            this.tabPageRawXml.TabIndex = 0;
            this.tabPageRawXml.Text = "RAW XML";
            this.tabPageRawXml.UseVisualStyleBackColor = true;
            // 
            // tabPageXmlTreeView
            // 
            this.tabPageXmlTreeView.Location = new System.Drawing.Point(4, 22);
            this.tabPageXmlTreeView.Name = "tabPageXmlTreeView";
            this.tabPageXmlTreeView.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageXmlTreeView.Size = new System.Drawing.Size(818, 465);
            this.tabPageXmlTreeView.TabIndex = 1;
            this.tabPageXmlTreeView.Text = "XML TreeView";
            this.tabPageXmlTreeView.UseVisualStyleBackColor = true;
            // 
            // btnOk
            // 
            this.btnOk.Location = new System.Drawing.Point(376, 5);
            this.btnOk.Name = "btnOk";
            this.btnOk.Size = new System.Drawing.Size(75, 23);
            this.btnOk.TabIndex = 1;
            this.btnOk.Text = "Ok";
            this.btnOk.UseVisualStyleBackColor = true;
            this.btnOk.Click += new System.EventHandler(this.btnOk_Click);
            // 
            // tabPageHighlighted
            // 
            this.tabPageHighlighted.Location = new System.Drawing.Point(4, 22);
            this.tabPageHighlighted.Name = "tabPageHighlighted";
            this.tabPageHighlighted.Size = new System.Drawing.Size(818, 465);
            this.tabPageHighlighted.TabIndex = 2;
            this.tabPageHighlighted.Text = "Highlighted xml";
            this.tabPageHighlighted.UseVisualStyleBackColor = true;
            // 
            // MessageBoxForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(826, 528);
            this.Controls.Add(this.splitContainer1);
            this.Name = "MessageBoxForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "MessageBoxForm";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.ResumeLayout(false);
            this.tabControlMain.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.TabControl tabControlMain;
        private System.Windows.Forms.TabPage tabPageRawXml;
        private System.Windows.Forms.TabPage tabPageXmlTreeView;
        private System.Windows.Forms.Button btnOk;
        private System.Windows.Forms.TabPage tabPageHighlighted;

    }
}