using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Xml.Linq;

namespace XlsToXmlTools
{
    public partial class TestingWindow : Form
    {
        private XlsConvert config;


        public TestingWindow()
        {
            InitializeComponent();
        }

        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            toolStripButton3_Click(null, null);
            if (openFileDialog1.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                //System.IO.StreamReader sr = new
                  // System.IO.StreamReader(openFileDialog1.FileName);

                FileStream stream = File.Open(openFileDialog1.FileName, FileMode.Open,
                FileAccess.ReadWrite, FileShare.None);


                
                // -- wczytanie podstawowego
                XDocument file = config.ToXml(false, stream);
                source.Text = file.ToString();

                // -- wczytanie po konwersji
                XDocument correctFile = config.CorrectFile(file);
                target.Text = correctFile.ToString();

                stream.Close();
                //sr.Close();
            }
        }

        private void toolStripButton3_Click(object sender, EventArgs e)
        {
            if(toolStripTextBox1.Text=="")
             if (openFileDialog1.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                toolStripTextBox1.Text = openFileDialog1.FileName;
            }

            System.IO.StreamReader sr = new
                   System.IO.StreamReader(toolStripTextBox1.Text);
            
            config = new XlsConvert(sr.ReadToEnd());
            sr.Close();
            



        }
    }
}
