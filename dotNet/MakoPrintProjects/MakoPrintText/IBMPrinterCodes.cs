using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Printing.Text
{
    public class IBMPrinterCodes : PrinterCodes
    {

        public IBMPrinterCodes()
        {
            Console.WriteLine();
        }
        
        public static Dictionary<string, string> codes = new Dictionary<string, string>
        {
            {"%PRINTER-FONT-WEIGHT%bold_on", ((char)27).ToString() + ((char)71).ToString()},
            {"%PRINTER-FONT-WEIGHT%bold_off", ((char)27).ToString() + ((char)72).ToString()},

            {"%PRINTER-FONT-SIZE%10.0cpi_on", ((char)18).ToString()},
            {"%PRINTER-FONT-SIZE%10.0cpi_off", ""},
            
            {"%PRINTER-FONT-SIZE%12.0cpi_on", ((char)27).ToString() + ((char)58).ToString()},
            {"%PRINTER-FONT-SIZE%12.0cpi_off", ((char)18).ToString()},

            {"%PRINTER-FONT-SIZE%17.0cpi_on", ((char)18).ToString() + ((char)15).ToString()},
            {"%PRINTER-FONT-SIZE%17.0cpi_off", ((char)18).ToString()},            

            {"%PRINTER-INTERLINIA%6", ((char)27).ToString() + ((char)65).ToString() + ((char)10).ToString() + ((char)27).ToString() + ((char)50).ToString()},
            {"%PRINTER-INTERLINIA%8", ((char)27).ToString() + ((char)65).ToString() + ((char)7).ToString() + ((char)27).ToString() + ((char)50).ToString()},
            {"%PRINTER-INTERLINIA%10", ((char)27).ToString() + ((char)65).ToString() + ((char)6).ToString() + ((char)27).ToString() + ((char)50).ToString()},
            {"%PRINTER-INTERLINIA%12", ((char)27).ToString() + ((char)65).ToString() + ((char)5).ToString() + ((char)27).ToString() + ((char)50).ToString()},
            {"%PRINTER-KONIEC-STRONY%", ((char)12).ToString()},
            {"%PRINTER-FONT%nlq_on", ((char)27).ToString() + ((char)73).ToString() + ((char)2).ToString()},
            {"%PRINTER-FONT%nlq_off",((char)27).ToString() + ((char)73).ToString() + ((char)0).ToString()},         
        
        };

        public override string ReplaceChars(string tekst)
        {

            StringBuilder b = new StringBuilder(tekst);
            b.Replace("%FONT-WEIGHT%bold_on", codes["%PRINTER-FONT-WEIGHT%bold_on"])
             .Replace("%FONT-WEIGHT%bold_off", codes["%PRINTER-FONT-WEIGHT%bold_off"])
             .Replace("%FONT-STYLE%italic_on", "")
             .Replace("%FONT-STYLE%italic_off", "")

             .Replace("%FONT-SIZE%6.0pt_on", codes["%PRINTER-FONT-SIZE%17.0cpi_on"])
             .Replace("%FONT-SIZE%6.0pt_off", codes["%PRINTER-FONT-SIZE%17.0cpi_off"])

             .Replace("%FONT-SIZE%8.0pt_on", codes["%PRINTER-FONT-SIZE%17.0cpi_on"])
             .Replace("%FONT-SIZE%8.0pt_off", codes["%PRINTER-FONT-SIZE%17.0cpi_off"])

             .Replace("%FONT-SIZE%10.0pt_on", codes["%PRINTER-FONT-SIZE%17.0cpi_on"])
             .Replace("%FONT-SIZE%10.0pt_off", codes["%PRINTER-FONT-SIZE%17.0cpi_off"])

             .Replace("%FONT-SIZE%12.0pt_on", codes["%PRINTER-FONT-SIZE%12.0cpi_on"])
             .Replace("%FONT-SIZE%12.0pt_off", codes["%PRINTER-FONT-SIZE%12.0cpi_off"])

             .Replace("%FONT-SIZE%14.0pt_on", codes["%PRINTER-FONT-SIZE%12.0cpi_on"])
             .Replace("%FONT-SIZE%14.0pt_off", codes["%PRINTER-FONT-SIZE%12.0cpi_off"])

             .Replace("%FONT-SIZE%17.0pt_on", codes["%PRINTER-FONT-SIZE%10.0cpi_on"])
             .Replace("%FONT-SIZE%17.0pt_off", codes["%PRINTER-FONT-SIZE%10.0cpi_off"])

             .Replace("%FONT-SIZE%20.0pt_on", codes["%PRINTER-FONT-SIZE%10.0cpi_on"])
             .Replace("%FONT-SIZE%20.0pt_off", codes["%PRINTER-FONT-SIZE%10.0cpi_off"])

             .Replace("%INTERLINIA%6", codes["%PRINTER-INTERLINIA%6"])
             .Replace("%INTERLINIA%8", codes["%PRINTER-INTERLINIA%8"])
             .Replace("%INTERLINIA%10", codes["%PRINTER-INTERLINIA%10"])
             .Replace("%INTERLINIA%12", codes["%PRINTER-INTERLINIA%12"])

             .Replace("%KONIEC-STRONY%", codes["%PRINTER-KONIEC-STRONY%"])

             .Replace("%FONT%nlq_on", codes["%PRINTER-FONT%nlq_on"])
             .Replace("%FONT%nlq_off", codes["%PRINTER-FONT%nlq_off"])

            //twarda spacja na mientką
             .Replace((char)160, (char)32);

            return b.ToString();
        }


    }
}
