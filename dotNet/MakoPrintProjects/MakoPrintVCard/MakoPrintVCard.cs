using System;
using System.Globalization;
using System.IO;
using System.Xml.Linq;
using System.Text;

namespace Makolab.Printing.VCard
{
    public static class MakoPrintVCard
    {
        /// <summary>
        /// Generates a VCard file from the specified xml to the specified output stream.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <param name="output">Output stream.</param>
        public static void Generate(string xml, Stream output)
        {
            XDocument xdoc = XDocument.Parse(xml);

            StreamWriter wr = new StreamWriter(output, Encoding.GetEncoding("windows-1250"));

            //header
            wr.WriteLine("BEGIN:vCard");
            wr.WriteLine("VERSION:3.0");

            //name and fullname
            wr.WriteLine("N:" + MakoPrintVCard.EscapeString(xdoc.Root.Element("name").Value) + ";;;;");
            wr.WriteLine("FN:" + MakoPrintVCard.EscapeString(xdoc.Root.Element("fullName").Value));

            //addresses
            foreach (XElement address in xdoc.Root.Elements("address"))
            {
                wr.Write("ADR;TYPE=" + address.Attribute("type").Value);

                if (address.Attribute("pref") != null && address.Attribute("pref").Value.ToUpperInvariant() == "TRUE")
                    wr.Write(",pref");

                wr.WriteLine(String.Format(CultureInfo.InvariantCulture, ":;;{0};{1};;{2};{3}",
                    MakoPrintVCard.EscapeString(address.Element("street").Value), MakoPrintVCard.EscapeString(address.Element("city").Value), MakoPrintVCard.EscapeString(address.Element("postCode").Value),
                    MakoPrintVCard.EscapeString(address.Element("country").Value)));
            }

            //telephones
            foreach (XElement tel in xdoc.Root.Elements("telephone"))
            {
                wr.Write("TEL;TYPE=" + tel.Attribute("type").Value);

                if (tel.Attribute("voice") != null && tel.Attribute("voice").Value.ToUpperInvariant() == "TRUE")
                    wr.Write(",voice");

                if (tel.Attribute("fax") != null && tel.Attribute("fax").Value.ToUpperInvariant() == "TRUE")
                    wr.Write(",fax");

                if (tel.Attribute("pref") != null && tel.Attribute("pref").Value.ToUpperInvariant() == "TRUE")
                    wr.Write(",pref");

                wr.WriteLine(":" + MakoPrintVCard.EscapeString(tel.Value));
            }

            //email
            if (xdoc.Root.Element("email") != null)
                wr.WriteLine("EMAIL:" + MakoPrintVCard.EscapeString(xdoc.Root.Element("email").Value));

            //url
            if (xdoc.Root.Element("url") != null)
            {
                wr.WriteLine("URL;" + xdoc.Root.Element("url").Attribute("type").Value + ":" + MakoPrintVCard.EscapeString(xdoc.Root.Element("url").Value));
            }

            wr.WriteLine("END:vCard");

            wr.Flush();
        }

        /// <summary>
        /// Escapes the string so that it will not contain ';' and '\' character.
        /// </summary>
        /// <param name="value">The value to escape.</param>
        /// <returns>Escaped string.</returns>
        private static string EscapeString(string value)
        {
            return value.Replace("\\", "\\\\").Replace(";", "\\;");
        }
    }
}
