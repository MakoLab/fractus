namespace FractusDesktop
{
    partial class PdfPrintForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(PdfPrintForm));
            this.axAcroPDFCtrl = new AxAcroPDFLib.AxAcroPDF();
            ((System.ComponentModel.ISupportInitialize)(this.axAcroPDFCtrl)).BeginInit();
            this.SuspendLayout();
            // 
            // axAcroPDFCtrl
            // 
            this.axAcroPDFCtrl.Dock = System.Windows.Forms.DockStyle.Fill;
            this.axAcroPDFCtrl.Enabled = true;
            this.axAcroPDFCtrl.Location = new System.Drawing.Point(0, 0);
            this.axAcroPDFCtrl.Name = "axAcroPDFCtrl";
            this.axAcroPDFCtrl.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axAcroPDFCtrl.OcxState")));
            this.axAcroPDFCtrl.Size = new System.Drawing.Size(984, 664);
            this.axAcroPDFCtrl.TabIndex = 0;
            // 
            // PdfForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(984, 664);
            this.Controls.Add(this.axAcroPDFCtrl);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "PdfForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Fractus 2.0";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.PdfForm_FormClosed);
            ((System.ComponentModel.ISupportInitialize)(this.axAcroPDFCtrl)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private AxAcroPDFLib.AxAcroPDF axAcroPDFCtrl;
    }
}