using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Printing.Text
{
    public class EpsonPrinterCodes : PrinterCodes
    {

        public static Dictionary<string, string> codes = new Dictionary<string, string>
        {
            {"%PRINTER-FONT-WEIGHT%bold_on", ((char)27).ToString() + ((char)71).ToString()},
            {"%PRINTER-FONT-WEIGHT%bold_off", ((char)27).ToString() + ((char)72).ToString()},
            {"%PRINTER-FONT-STYLE%italic_on", ((char)27).ToString() + ((char)52).ToString()},
            {"%PRINTER-FONT-STYLE%italic_off", ((char)27).ToString() + ((char)53).ToString()},
            {"%PRINTER-FONT-SIZE%default_on", ""},
            {"%PRINTER-FONT-SIZE%default_off", ""},
            {"%PRINTER-FONT-SIZE%12.0cpi_on", ((char)27).ToString() + ((char)77).ToString()},
            {"%PRINTER-FONT-SIZE%12.0cpi_off", ((char)27).ToString() + ((char)80).ToString()},
            {"%PRINTER-FONT-SIZE%15.0cpi_on", ((char)27).ToString() + ((char)103).ToString()},
            {"%PRINTER-FONT-SIZE%15.0cpi_off", ((char)27).ToString() + ((char)80).ToString()},
            {"%PRINTER-FONT-SIZE%17.0cpi_on", ((char)27).ToString() + ((char)80).ToString() + ((char)27).ToString() + ((char)15).ToString()},
            {"%PRINTER-FONT-SIZE%17.0cpi_off", ((char)27).ToString() + ((char)80).ToString()},
            {"%PRINTER-FONT-SIZE%20.0cpi_on", ((char)27).ToString() + ((char)77).ToString() + ((char)27).ToString() + ((char)15).ToString()},
            {"%PRINTER-FONT-SIZE%20.0cpi_off", ((char)27).ToString() + ((char)80).ToString()},
            {"%PRINTER-INTERLINIA%6", ((char)27).ToString() + ((char)65).ToString() + ((char)10).ToString()},
            {"%PRINTER-INTERLINIA%8", ((char)27).ToString() + ((char)65).ToString() + ((char)8).ToString()},
            {"%PRINTER-INTERLINIA%10", ((char)27).ToString() + ((char)65).ToString() + ((char)6).ToString()},
            {"%PRINTER-INTERLINIA%12", ((char)27).ToString() + ((char)65).ToString() + ((char)5).ToString()},
            {"%PRINTER-KONIEC-STRONY%", ((char)12).ToString()},
            {"%PRINTER-FONT%nlq_on", ((char)27).ToString() + ((char)120).ToString() + ((char)1).ToString()},
            {"%PRINTER-FONT%nlq_off", ((char)27).ToString() + ((char)120).ToString() + ((char)0).ToString()},

        };

        public override string ReplaceChars(string tekst)
        {

            StringBuilder b = new StringBuilder(tekst);
            b.Replace("%FONT-WEIGHT%bold_on", codes["%PRINTER-FONT-WEIGHT%bold_on"])
             .Replace("%FONT-WEIGHT%bold_off", codes["%PRINTER-FONT-WEIGHT%bold_off"])
             .Replace("%FONT-STYLE%italic_on", codes["%PRINTER-FONT-STYLE%italic_on"])
             .Replace("%FONT-STYLE%italic_off", codes["%PRINTER-FONT-STYLE%italic_off"])

             .Replace("%FONT-SIZE%6.0pt_on", codes["%PRINTER-FONT-SIZE%20.0cpi_on"])
             .Replace("%FONT-SIZE%6.0pt_off", codes["%PRINTER-FONT-SIZE%20.0cpi_off"])

             .Replace("%FONT-SIZE%8.0pt_on", codes["%PRINTER-FONT-SIZE%20.0cpi_on"])
             .Replace("%FONT-SIZE%8.0pt_off", codes["%PRINTER-FONT-SIZE%20.0cpi_off"])

             .Replace("%FONT-SIZE%10.0pt_on", codes["%PRINTER-FONT-SIZE%17.0cpi_on"])
             .Replace("%FONT-SIZE%10.0pt_off", codes["%PRINTER-FONT-SIZE%17.0cpi_off"])

             .Replace("%FONT-SIZE%12.0pt_on", codes["%PRINTER-FONT-SIZE%12.0cpi_on"])
             .Replace("%FONT-SIZE%12.0pt_off", codes["%PRINTER-FONT-SIZE%12.0cpi_off"])

             .Replace("%FONT-SIZE%14.0pt_on", codes["%PRINTER-FONT-SIZE%15.0cpi_on"])
             .Replace("%FONT-SIZE%14.0pt_off", codes["%PRINTER-FONT-SIZE%15.0cpi_off"])

             .Replace("%FONT-SIZE%17.0pt_on", codes["%PRINTER-FONT-SIZE%17.0cpi_on"])
             .Replace("%FONT-SIZE%17.0pt_off", codes["%PRINTER-FONT-SIZE%17.0cpi_off"])

             .Replace("%FONT-SIZE%20.0pt_on", codes["%PRINTER-FONT-SIZE%default_on"])
             .Replace("%FONT-SIZE%20.0pt_off", codes["%PRINTER-FONT-SIZE%default_off"])

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
