using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Makolab.Printing.Text;
using System.IO;
using System.Xml.Xsl;
using System.Drawing.Printing;

namespace TestIglowka
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void viewTextPrint_Click(object sender, EventArgs e)
        {
            string inputxml = this.inputWindow.Text;
           
            /*FileStream fs = new FileStream("aabbcc.txt",
                FileMode.Create, FileAccess.Write, FileShare.None);

           
            MakoPrintText.Generate(inputxml, ms);

            fs.Close();

            StreamReader tr = new StreamReader("aabbcc.txt");
            
            this.outputWindow.Text = tr.ReadToEnd();*/



            MemoryStream s = new MemoryStream();

			string driverConfigXml = @"
<driverConfig>
  <!-- ustawic forceSize w printerModel zeby wymusic znaczniki 8pt na kazdej linii -->
  <printerModel>IBM</printerModel>
  <portName>LPT1</portName>
  <wsdl>http://printsrv:3322/Printing/?wsdl</wsdl>
  <printMethod>WebService</printMethod>
  <!--textEncoding>cp852</textEncoding-->
  <textEncoding>mazovia</textEncoding>
  <forceSize>8.0pt</forceSize>
  <paging enabled=""true"" default-font-size=""8.0"" ratio=""550.0"" />
</driverConfig>";

            // MakoPrintText.Generate(File.OpenText("result.html").ReadToEnd(), s);
            MakoPrintText.Generate(inputxml, s, this.checkBoxPaging.Checked ? driverConfigXml : null);
            s.Position = 0;
            byte[] b = new byte[s.Length];
            s.Read(b, 0, b.Length);
            string xml = Encoding.UTF8.GetString(b).Substring(1);

			//Console.WriteLine();
			//String temp = xml.Replace("%FONT-STYLE%italic_on", "");
			//temp = temp.Replace("%FONT-STYLE%italic_off", "");
			//temp = temp.Replace("%FONT-WEIGHT%bold_on", "");
			//temp = temp.Replace("%FONT-WEIGHT%bold_off", "");
			//temp = temp.Replace("%FONT-SIZE%8.0pt_on", "");
			//temp = temp.Replace("%FONT-SIZE%8.0pt_off", "");
			//temp = temp.Replace("%FONT-SIZE%20.0pt_on", "");
			//temp = temp.Replace("%FONT-SIZE%20.0pt_off", "");

            this.outputWindow.Text = xml;
			if (!this.chBoxRawView.Checked)
				this.ReplaceCharsRich(this.outputWindow);

		}

        private void wytnij_Click(object sender, EventArgs e)
        {
            string temp = this.outputWindow.Text;
            this.outputWindow.Text = ReplaceChars(temp);
        }

        public string ReplaceChars(string tekst)
        {

            StringBuilder b = new StringBuilder(tekst);
            b.Replace("%FONT-WEIGHT%bold_on", "")
             .Replace("%FONT-WEIGHT%bold_off", "")
             .Replace("%FONT-STYLE%italic_on", "")
             .Replace("%FONT-STYLE%italic_off", "")

             .Replace("%FONT-SIZE%6.0pt_on", "")
             .Replace("%FONT-SIZE%6.0pt_off", "")

             .Replace("%FONT-SIZE%8.0pt_on", "")
             .Replace("%FONT-SIZE%8.0pt_off", "")

             .Replace("%FONT-SIZE%10.0pt_on", "")
             .Replace("%FONT-SIZE%10.0pt_off", "")

             .Replace("%FONT-SIZE%12.0pt_on", "")
             .Replace("%FONT-SIZE%12.0pt_off", "")

             .Replace("%FONT-SIZE%14.0pt_on", "")
             .Replace("%FONT-SIZE%14.0pt_off", "")

             .Replace("%FONT-SIZE%17.0pt_on", "")
             .Replace("%FONT-SIZE%17.0pt_off", "")

             .Replace("%FONT-SIZE%20.0pt_on", "")
             .Replace("%FONT-SIZE%20.0pt_off", "")

             .Replace("%INTERLINIA%6", "")
             .Replace("%INTERLINIA%8", "")
             .Replace("%INTERLINIA%10", "")
             .Replace("%INTERLINIA%12", "")

             .Replace("%KONIEC-STRONY%", "")

             .Replace("%FONT%nlq_on", "")
             .Replace("%FONT%nlq_off", "")

            //twarda spacja na mientką
             .Replace((char)160, (char)32);

            return b.ToString();
        }

		private void ReplaceCharsRich(RichTextBox richTextBox)
		{
			foreach(TextStyle style in TextStyle.AllStyles)
			{
				int index = 0;
				while (index >= 0 && index < richTextBox.Text.Length)
				{
					index = this.ApplyStyle(richTextBox, style, index);
				}
			}
		}

		private int ApplyStyle(RichTextBox richTextBox, TextStyle style, int start)
		{
			start = richTextBox.Find(style.StartTag, start, RichTextBoxFinds.MatchCase);

			if (start == -1)
				return start;

			//remove startTag
			richTextBox.Select(start, style.StartTag.Length);
			richTextBox.Cut();

			//check if we have multiple same starting tags
			int anotherStart = richTextBox.Find(style.StartTag, start, RichTextBoxFinds.MatchCase);

			int end = richTextBox.Find(style.EndTag, start, RichTextBoxFinds.MatchCase);

			bool multipleTags = anotherStart != -1 && anotherStart < end;

			//remove end tag
			richTextBox.Select(end, style.EndTag.Length);
			richTextBox.Cut();

			//apply style to selected text
			richTextBox.Select(start, end - start);
			style.ApplyStyle(richTextBox);

			return multipleTags ? anotherStart : end;
		}

        private void button1_Click(object sender, EventArgs e)
        {
            string a = @"<root printerModel=""Seikosha"" portName=""LPT1"" wsdl=""http://printsrv:3322/Printing/?wsdl"" printMethod=""WebService"" textEncoding=""mazovia"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:msxsl=""urn:schemas-microsoft-com:xslt"">
	<table dotyczy=""tabela główna"">
		<table dotyczy=""miejsce wystawienia"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""70%"" />
				<td ALIGN=""left"" WIDTH=""20%"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Miejsce rejestracji:</td>
				<td ALIGN=""right"" WIDTH=""10%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Łódź</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""70%"" />
				<td ALIGN=""left"" WIDTH=""20%"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Data rejestracji:</td>
				<td ALIGN=""right"" WIDTH=""10%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">2011-04-01</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""70%"" />
				<td ALIGN=""left"" WIDTH=""20%"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Data wpływu:</td>
				<td ALIGN=""right"" WIDTH=""10%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">2011-04-01</td>
			</tr>
		</table>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr RAW-WIDTH=""80"" FONT-SIZE=""20.0pt"">
			<td ALIGN=""center"" WIDTH=""100%"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Faktura zakupu 144/O1/2011</td>
		</tr>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<table dotyczy=""sprzedawca nabywca"">
			<tr FONT-SIZE=""8.0pt"">
				<td ALIGN=""left"" WIDTH=""15%"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Nabywca:</td>
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Twoja firma</td>
				<td ALIGN=""left"" WIDTH=""15%"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Sprzedawca:</td>
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">""JAWA"" SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""15%"" />
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Domyślna 1</td>
				<td BLANK=""true"" WIDTH=""15%"" />
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">3-GO MAJA 128</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""15%"" />
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">12-345 Miasto</td>
				<td BLANK=""true"" WIDTH=""15%"" />
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">42-360 PORAJ</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""15%"" />
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">NIP: 111-111-11-11</td>
				<td BLANK=""true"" WIDTH=""15%"" />
				<td ALIGN=""left"" WIDTH=""35%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">NIP: 5771842337</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""15%"" />
				<td BLANK=""true"" WIDTH=""35%"" />
				<td BLANK=""true"" WIDTH=""15%"" />
				<td BLANK=""true"" WIDTH=""35%"" />
			</tr>
		</table>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<table dotyczy=""tabela towarów"">
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""5pt"" />
				<td ALIGN=""center"" WIDTH=""16pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Lp</td>
				<td ALIGN=""center"" WIDTH=""60pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Kod</td>
				<td ALIGN=""center"" WIDTH=""168pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Nazwa</td>
				<td ALIGN=""center"" WIDTH=""28pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Ilość</td>
				<td ALIGN=""center"" WIDTH=""24pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">J.m.</td>
				<td ALIGN=""center"" WIDTH=""80pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Cena jedn.netto</td>
				<td ALIGN=""center"" WIDTH=""60pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość netto</td>
				<td ALIGN=""center"" WIDTH=""32pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT [%]</td>
				<td ALIGN=""center"" WIDTH=""48pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
				<td ALIGN=""center"" WIDTH=""60pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość brutto</td>
			</th>
			<tr TEXT-WRAP=""true"" ALLOW-N=""true"" FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" BOTTOMBORDER=""-"" CROSSBORDER=""+"">
				<td BLANK=""true"" WIDTH=""5pt"" />
				<td ALIGN=""center"" WIDTH=""16pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">1</td>
				<td ALIGN=""left"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">SPFRCO0L07ND2SAB2KA100</td>
				<td ALIGN=""left"" WIDTH=""168pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">skr.pn.for.COR.ok.L70.N/dąb2.szc.msr.blalala.2z.ram.sChin.</td>
				<td ALIGN=""center"" WIDTH=""28pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">1</td>
				<td ALIGN=""center"" WIDTH=""24pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">szt.</td>
				<td ALIGN=""right"" WIDTH=""80pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">550,07</td>
				<td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">550,07</td>
				<td ALIGN=""right"" WIDTH=""32pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">23</td>
				<td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">126,52</td>
				<td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" ALLOW-N=""true"" FORCE-BORDER=""true"">676,59</td>
			</tr>
		</table>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<table dotyczy=""tabela vat"">
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""280pt"" />
				<td ALIGN=""center"" WIDTH=""50pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Stawka VAT</td>
				<td ALIGN=""center"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Wartość netto</td>
				<td ALIGN=""center"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Kwota VAT</td>
				<td ALIGN=""center"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Wartość brutto</td>
			</th>
			<tr FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" BOTTOMBORDER=""-"" CROSSBORDER=""+"">
				<td BLANK=""true"" WIDTH=""280pt"" />
				<td ALIGN=""right"" WIDTH=""50pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">23</td>
				<td ALIGN=""right"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">550,07</td>
				<td ALIGN=""right"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">126,52</td>
				<td ALIGN=""right"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">676,59</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td BLANK=""true"" WIDTH=""280pt"" />
				<td ALIGN=""right"" WIDTH=""50pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">RAZEM:</td>
				<td ALIGN=""right"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">550,07</td>
				<td ALIGN=""right"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">126,52</td>
				<td ALIGN=""right"" WIDTH=""84pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">676,59</td>
			</tr>
		</table>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<table dotyczy=""razem do zapłaty"">
			<tr RAW-WIDTH=""80"" FONT-SIZE=""20.0pt"">
				<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Wartość netto:</td>
				<td ALIGN=""left"" WIDTH=""50"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">550,07 PLN</td>
			</tr>
			<tr RAW-WIDTH=""80"" FONT-SIZE=""20.0pt"">
				<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Wartość brutto:</td>
				<td ALIGN=""left"" WIDTH=""50"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">676,59 PLN</td>
			</tr>
			<tr FONT-SIZE=""8.0pt"">
				<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Słownie:</td>
				<td ALIGN=""left"" WIDTH=""110"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">sześćset siedemdziesiąt sześć PLN pięćdziesiąt dziewięć PLN/100 </td>
			</tr>
		</table>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<table dotyczy=""płatności"">
			<tr FONT-SIZE=""8.0pt"">
				<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Forma płatności:</td>
				<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Przelew 14</td>
				<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Termin płatności:</td>
				<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">2011-04-15</td>
			</tr>
		</table>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr FONT-SIZE=""8.0pt"">
			<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Zapłacono:</td>
			<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">0,00 PLN</td>
			<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Do zapłaty:</td>
			<td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">676,59 PLN</td>
		</tr>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<table dotyczy=""osoba wystawiająca i podpisy"">
			<tr FONT-SIZE=""8.0pt"">
				<td ALIGN=""left"" WIDTH=""25%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Osoba rejestrująca:</td>
				<td ALIGN=""left"" WIDTH=""25%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Konto Systemowe(op)</td>
				<td ALIGN=""left"" WIDTH=""25%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Odebrał:</td>
				<td ALIGN=""left"" WIDTH=""25%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal""></td>
			</tr>
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<tr FONT-SIZE=""6.0pt"">
				<td ALIGN=""left"" WIDTH=""50%"" FONT-WEIGHT=""normal"" FONT-STYLE=""italic"">Podpis osoby rejestrującej:</td>
				<td ALIGN=""left"" WIDTH=""50%"" FONT-WEIGHT=""normal"" FONT-STYLE=""italic""></td>
			</tr>
		</table>
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
		<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
	</table>
</root>";


            this.inputWindow.Text = a;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            string a = @"<root printerModel=""Seikosha"" portName=""LPT1"" wsdl=""http://printsrv:3322/Printing/?wsdl"" printMethod=""WebService"" textEncoding=""mazovia"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:msxsl=""urn:schemas-microsoft-com:xslt"">
  <table dotyczy=""tabela główna"">
    <table dotyczy=""miejsce wystawienia"">
      <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
      <tr FONT-SIZE=""8.0pt"">
        <td BLANK=""true"" WIDTH=""70%"" />
        <td WIDTH=""20%"" ALIGN=""right"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Miejsce wystawienia:</td>
        <td ALIGN=""right"" WIDTH=""10%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Łódź</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"">
        <td BLANK=""true"" WIDTH=""70%"" />
        <td WIDTH=""20%"" ALIGN=""right"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Data wystawienia:</td>
        <td ALIGN=""right"" WIDTH=""10%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">2011-04-20</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"">
        <td BLANK=""true"" WIDTH=""70%"" />
        <td WIDTH=""20%"" ALIGN=""right"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Data sprzedaży:</td>
        <td ALIGN=""right"" WIDTH=""10%"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">2011-04-20</td>
      </tr>
    </table>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr RAW-WIDTH=""80"" FONT-SIZE=""20.0pt"">
      <td ALIGN=""center"" WIDTH=""100%"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Faktura korygująca zakupu 37/O1/2011</td>
    </tr>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <table dotyczy=""dokument korygowany"">
      <tr FONT-SIZE=""8.0pt"">
        <td WIDTH=""49"" BLANK=""true"" />
        <td WIDTH=""22"" ALIGN=""left"">Dokument korygowany:</td>
        <td WIDTH=""13"" ALIGN=""left"">155/O1/2011</td>
        <td WIDTH=""8"" ALIGN=""left"">z dnia</td>
        <td WIDTH=""12"" ALIGN=""left"">2011-04-20</td>
      </tr>
    </table>
    <table dotyczy=""sprzedawca nabywca"">
      <tr FONT-SIZE=""8.0pt"">
        <td ALIGN=""left"" WIDTH=""15%"">Nabywca:</td>
        <td ALIGN=""left"" WIDTH=""35%"">Twoja firma</td>
        <td ALIGN=""left"" WIDTH=""15%"">Sprzedawca:</td>
        <td ALIGN=""left"" WIDTH=""35%"">""ALI-BOATS""</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"">
        <td BLANK=""true"" WIDTH=""15%"" />
        <td ALIGN=""left"" WIDTH=""35%"">Domyślna 1</td>
        <td BLANK=""true"" WIDTH=""15%"" />
        <td ALIGN=""left"" WIDTH=""35%""></td>
      </tr>
      <tr FONT-SIZE=""8.0pt"">
        <td BLANK=""true"" WIDTH=""15%"" />
        <td ALIGN=""left"" WIDTH=""35%"">12-345 Miasto</td>
        <td BLANK=""true"" WIDTH=""15%"" />
        <td ALIGN=""left"" WIDTH=""35%"">89-430 KAMIEŃ KRAJEŃSKI</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"">
        <td BLANK=""true"" WIDTH=""15%"" />
        <td ALIGN=""left"" WIDTH=""35%"">NIP:  111-111-11-11</td>
        <td BLANK=""true"" WIDTH=""15%"" />
        <td ALIGN=""left"" WIDTH=""35%"">NIP:  7411192223</td>
      </tr>
    </table>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <table dotyczy=""tabela towarów"">
      <th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" VERTICALBORDER=""|"">
        <td BLANK=""true"" WIDTH=""5pt"" />
        <td ALIGN=""center"" WIDTH=""16pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Lp</td>
        <td ALIGN=""center"" WIDTH=""184pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Nazwa</td>
        <td ALIGN=""center"" WIDTH=""28pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Ilość</td>
        <td ALIGN=""center"" WIDTH=""24pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">J.m.</td>
        <td ALIGN=""center"" WIDTH=""88pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Cena netto bez rabatu</td>
        <td ALIGN=""center"" WIDTH=""36pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Rabat</td>
        <td ALIGN=""center"" WIDTH=""32pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">VAT [%]</td>
        <td ALIGN=""center"" WIDTH=""60pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Wartość netto</td>
        <td ALIGN=""center"" WIDTH=""48pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Wartość VAT</td>
        <td ALIGN=""center"" WIDTH=""72pt"" FONT-SIZE=""8.0pt"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Wartość brutto</td>
      </th>
      <tr FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" TOPBORDER=""-"" BOTTOMBORDER=""-"" CROSSBORDER=""+"">
        <td BLANK=""true"" WIDTH=""5pt"" />
        <td ALIGN=""center"" WIDTH=""16pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">1</td>
        <td ALIGN=""left"" WIDTH=""184pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Massachusetts</td>
        <td ALIGN=""center"" WIDTH=""28pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">9</td>
        <td ALIGN=""center"" WIDTH=""24pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">szt.</td>
        <td ALIGN=""right"" WIDTH=""88pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">200,00</td>
        <td ALIGN=""center"" WIDTH=""36pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">40%</td>
        <td ALIGN=""center"" WIDTH=""32pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">23</td>
        <td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">1080,00</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">248,40</td>
        <td ALIGN=""right"" WIDTH=""72pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">1328,40</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" CROSSBORDER=""+"">
        <td BLANK=""true"" WIDTH=""20pt"" />
        <td ALIGN=""left"" WIDTH=""184pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Korekta</td>
        <td FORCE-BORDER=""true"" ALIGN=""center"" WIDTH=""28pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">0</td>
        <td FORCE-BORDER=""true"" ALIGN=""center"" WIDTH=""24pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal""></td>
        <td FORCE-BORDER=""true"" ALIGN=""right"" WIDTH=""88pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">0,00</td>
        <td FORCE-BORDER=""true"" ALIGN=""center"" WIDTH=""36pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">+5%</td>
        <td FORCE-BORDER=""true"" ALIGN=""center"" WIDTH=""32pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal""></td>
        <td FORCE-BORDER=""true"" ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">-90,00</td>
        <td FORCE-BORDER=""true"" ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">-20,70</td>
        <td FORCE-BORDER=""true"" ALIGN=""right"" WIDTH=""72pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">-110,70</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" TOPBORDER=""-"" BOTTOMBORDER=""-"" CROSSBORDER=""+"">
        <td BLANK=""true"" WIDTH=""20pt"" />
        <td ALIGN=""left"" WIDTH=""184pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Po korekcie</td>
        <td ALIGN=""center"" WIDTH=""28pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">9</td>
        <td ALIGN=""center"" WIDTH=""24pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">szt.</td>
        <td ALIGN=""right"" WIDTH=""88pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">200,00</td>
        <td ALIGN=""center"" WIDTH=""36pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">45%</td>
        <td ALIGN=""center"" WIDTH=""32pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">23</td>
        <td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">990,00</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">227,70</td>
        <td ALIGN=""right"" WIDTH=""72pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">1217,70</td>
      </tr>
    </table>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <table dotyczy=""tabela vat"">
      <th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" VERTICALBORDER=""|"">
        <td BLANK=""true"" WIDTH=""364pt"" />
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Stawka VAT</td>
        <td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Wartość netto</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Kwota VAT</td>
        <td ALIGN=""right"" WIDTH=""72pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Wartość brutto</td>
      </th>
      <tr FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" TOPBORDER=""-"" BOTTOMBORDER=""-"" CROSSBORDER=""+"">
        <td BLANK=""true"" WIDTH=""304pt"" />
        <td WIDTH=""60pt"" ALIGN=""left"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Przed korektą</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">23</td>
        <td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">2340,00</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">538,20</td>
        <td ALIGN=""right"" WIDTH=""72pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">2878,20</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" BOTTOMBORDER=""-"" CROSSBORDER=""+"">
        <td BLANK=""true"" WIDTH=""304pt"" />
        <td WIDTH=""60pt"" ALIGN=""left"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Korekta</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">23</td>
        <td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">-90,00</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">-20,70</td>
        <td ALIGN=""right"" WIDTH=""72pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">-110,70</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"" VERTICALBORDER=""|"" BOTTOMBORDER=""-"" CROSSBORDER=""+"">
        <td BLANK=""true"" WIDTH=""304pt"" />
        <td WIDTH=""60pt"" ALIGN=""left"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Po korekcie</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">23</td>
        <td ALIGN=""right"" WIDTH=""60pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">2250,00</td>
        <td ALIGN=""right"" WIDTH=""48pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">517,50</td>
        <td ALIGN=""right"" WIDTH=""72pt"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">2767,50</td>
      </tr>
    </table>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <table dotyczy=""razem do zapłaty"">
      <tr FONT-SIZE=""8.0pt"">
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Razem do zwrotu:</td>
        <td ALIGN=""left"" WIDTH=""110"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">110,70 PLN</td>
      </tr>
      <tr FONT-SIZE=""8.0pt"">
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""normal"" FONT-STYLE=""normal"">Słownie:</td>
        <td ALIGN=""left"" WIDTH=""110"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">sto dziesięć PLN siedemdziesiąt PLN/100 </td>
      </tr>
    </table>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <table dotyczy=""płatności"">
      <tr FONT-SIZE=""8.0pt"">
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Forma płatności:</td>
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Przelew 14</td>
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Termin płatności:</td>
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">2011-05-04</td>
      </tr>
    </table>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr FONT-SIZE=""8.0pt"">
      <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Zapłacono:</td>
      <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">0,00 PLN</td>
      <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Pozostało:</td>
      <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">110,70 PLN</td>
    </tr>
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    <table dotyczy=""osoba wystawiająca i podpisy"">
      <tr FONT-SIZE=""8.0pt"">
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Osoba wystawiająca:</td>
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Konto Systemowe(op)</td>
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"">Odebrał:</td>
        <td ALIGN=""left"" WIDTH=""30"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal""></td>
      </tr>
      <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
      <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
      <tr FONT-SIZE=""6.0pt"">
        <td ALIGN=""left"" WIDTH=""60"" FONT-WEIGHT=""normal"" FONT-STYLE=""italic"">Podpis osoby upoważnionej do wystawienia faktury VAT:</td>
        <td ALIGN=""left"" WIDTH=""60"" FONT-WEIGHT=""normal"" FONT-STYLE=""italic"">Podpis osoby upoważnionej do odbioru faktury VAT:</td>
      </tr>
      <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
      <tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
    </table>
  </table>
</root>";


            this.inputWindow.Text = a;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            string a = @"<root printerModel=""Seikosha"" portName=""LPT1"" wsdl=""http://printsrv:3322/Printing/?wsdl"" printMethod=""WebService"" textEncoding=""mazovia"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:msxsl=""urn:schemas-microsoft-com:xslt"">
	<table dotyczy=""tabela główna"">
	
		<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""4pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""5pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""6pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""7pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""8pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""9pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""10pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""10pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""11pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""12pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""13pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""14pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""15pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""16pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""17pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""18pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""19pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""20pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""21pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""22pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""23pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""24pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""25pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""26pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""27pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""28pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""29pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""30pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""31pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""32pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""33pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""34pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""35pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>					
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""36pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""37pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""38pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""39pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""40pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""41pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""42pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""43pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""44pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""45pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""46pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""47pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""48pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""49pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""50pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""51pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""52pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""53pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""54pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""55pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""56pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""57pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""58pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""59pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""60pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""61pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""62pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""63pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""64pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""65pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
	
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""66pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""67pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""68pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""69pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""70pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""71pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""72pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""73pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""74pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""75pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""76pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""77pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""78pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""79pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""80pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""81pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""82pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""83pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""84pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""85pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""86pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""87pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""88pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""89pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""90pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""91pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""92pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""93pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""94pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""95pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""96pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""97pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""98pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""99pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""100pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""101pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""102pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""103pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""104pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""105pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""106pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""107pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""108pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""109pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""110pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""110pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""111pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""112pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""113pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""114pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""115pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""116pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""117pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""118pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""119pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""120pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""121pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""122pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""123pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""124pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""125pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""126pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""127pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""128pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""129pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""130pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""131pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""132pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""133pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""134pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""135pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>					
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""136pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""137pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""138pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""139pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""140pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""141pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""142pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""143pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""144pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""145pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""146pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""147pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""148pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""149pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0pt"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""150pt"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>				
	</table>	
</root>";
            this.inputWindow.Text = a;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            string a = @"<root printerModel=""Seikosha"" portName=""LPT1"" wsdl=""http://printsrv:3322/Printing/?wsdl"" printMethod=""WebService"" textEncoding=""mazovia"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:msxsl=""urn:schemas-microsoft-com:xslt"">
	<table dotyczy=""tabela główna"">
	
		<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""4"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""5"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""6"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""7"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""8"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""9"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""10"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""10"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""11"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""12"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""13"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""14"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""15"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""16"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""17"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""18"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""19"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""20"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""21"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""22"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""23"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""24"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""25"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""26"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""27"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""28"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""29"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""30"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""31"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""32"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""33"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""34"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""35"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>					
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""36"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""37"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""38"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""39"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""40"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""41"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""42"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""43"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""44"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""45"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""46"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""47"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""48"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""49"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""50"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""51"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""52"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""53"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""54"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""55"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""56"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""57"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""58"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""59"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""60"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""61"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""62"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""63"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""64"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""65"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
	
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""66"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""67"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""68"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""69"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""70"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""71"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""72"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""73"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""74"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""75"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""76"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""77"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""78"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""79"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""80"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""81"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""82"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""83"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""84"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""85"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""86"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""87"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""88"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""89"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""90"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""91"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""92"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""93"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""94"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""95"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""96"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""97"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""98"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""99"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""100"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""101"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""102"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""103"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""104"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""105"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""106"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""107"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""108"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""109"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""110"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""110"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""111"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""112"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""113"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""114"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>

<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""115"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""116"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""117"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""118"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""119"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""120"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""121"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""122"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""123"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""124"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""125"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""126"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""127"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""128"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""129"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""130"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""131"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""132"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""133"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""134"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""135"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>					
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""136"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""137"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""138"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""139"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""140"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""141"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>		
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""142"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>	
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""143"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
<table dotyczy=""tabela towarów"">
			<tr WIDTH=""100%"" BLANK=""true"" FONT-SIZE=""8.0"" />
			<th FONT-SIZE=""8.0pt"" TOPBORDER=""-"" CROSSBORDER=""+"" BOTTOMBORDER=""-"" VERTICALBORDER=""|"">
				<td BLANK=""true"" WIDTH=""144"" />
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">VAT     [%]</td>
				<td ALIGN=""center"" WIDTH=""AUTO"" FONT-WEIGHT=""bold"" FONT-STYLE=""normal"" FORCE-BORDER=""true"">Wartość VAT</td>
			</th>			
		</table>			
		
	</table>	
</root>";


            this.inputWindow.Text = a;
        }

		private void GetXsltButton_Click(object sender, EventArgs e)
		{
			using (OpenFileDialog ofd = new OpenFileDialog { AddExtension = true, CheckFileExists = true, Filter = "XSLT files (*.xsl, *.xslt)|*.xsl;*.xslt", Multiselect = false })
			{
				if (ofd.ShowDialog() == DialogResult.OK)
				{
					xsltFilenameTextBox.Text = ofd.FileName;
				}
			}
		}

		private void getObjectXmlButton_Click(object sender, EventArgs e)
		{
			using (OpenFileDialog ofd = new OpenFileDialog { AddExtension = true, CheckFileExists = true, Filter = "XML files (*.xml)|*.xml", Multiselect = false })
			{
				if (ofd.ShowDialog() == DialogResult.OK)
				{
					objectXmlFileNameTextBox.Text = ofd.FileName;
				}
			}
		}


		private static void XslTransform(string xslFilename, string xmlDataFilename, MemoryStream memoryStream)
		{
			XslCompiledTransform xslt = new XslCompiledTransform();
			xslt.Load(xslFilename);
			xslt.Transform(xmlDataFilename, null, memoryStream);
		}

		private void transformButton_Click(object sender, EventArgs e)
		{
			if (!String.IsNullOrEmpty(this.xsltFilenameTextBox.Text) && !String.IsNullOrEmpty(this.objectXmlFileNameTextBox.Text))
			{
				using (MemoryStream memoryStream = new MemoryStream())
				{
					XslTransform(this.xsltFilenameTextBox.Text, this.objectXmlFileNameTextBox.Text, memoryStream);
					memoryStream.Position = 0;
					using (StreamReader strReader = new StreamReader(memoryStream))
					{
						inputWindow.Text = strReader.ReadToEnd();
					}
				}
			}
        }

        private void getPrinterNamesButton_Click(object sender, EventArgs e)
        {
            List<String> printers = new List<string>();
            foreach (String printer in PrinterSettings.InstalledPrinters)
            {
                printers.Add(printer);                

            }
            this.outputWindow.Text = String.Join(Environment.NewLine, printers.ToArray());

            File.WriteAllText("installedPrinters.txt", String.Join(Environment.NewLine, printers.ToArray()));
        }

      
    }
}
