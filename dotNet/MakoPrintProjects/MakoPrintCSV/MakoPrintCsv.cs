using System;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace Makolab.Printing.CSV
{
    /// <summary>
    /// Class that prints document to CSV format.
    /// </summary>
    public static class MakoPrintCsv
    {
        /// <summary>
        /// Generates a CSV file from the specified xml to the specified output stream.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <param name="output">Output stream.</param>
        public static void Generate(string xml, Stream output)
        {
            XDocument xdoc = XDocument.Parse(xml);

            Settings settings = MakoPrintCsv.LoadConfig(xdoc);

            StreamWriter writer = new StreamWriter(output, Encoding.GetEncoding(settings.Encoding));
            
            MakoPrintCsv.InsertAutonumberingElements(xdoc);
            MakoPrintCsv.ReplaceDecimalSeparators(xdoc, settings);

            MakoPrintCsv.ProcessItemHeaders(xdoc, writer, settings);
            MakoPrintCsv.ProcessItems(xdoc, writer, settings);
            
            writer.Flush();
        }

        /// <summary>
        /// Loads the configuration from input xml.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <returns>Loaded settings.</returns>
        private static Settings LoadConfig(XDocument xml)
        {
            Settings s = new Settings();

            if (xml.Root.Attribute("outputEncoding") != null)
                s.Encoding = xml.Root.Attribute("outputEncoding").Value;
            else
                s.Encoding = "utf-8";

            if (xml.Root.Attribute("fieldSeparator") != null)
                s.FieldSeparator = xml.Root.Attribute("fieldSeparator").Value[0];
            else
                s.FieldSeparator = ',';

            if (xml.Root.Attribute("quoteAllFields") != null)
                s.QuoteAllFields = Convert.ToBoolean(xml.Root.Attribute("quoteAllFields").Value, CultureInfo.InvariantCulture);
            else
                s.QuoteAllFields = false;

            if (xml.Root.Attribute("decimalSeparator") != null)
                s.DecimalSeparator = xml.Root.Attribute("decimalSeparator").Value[0];
            else
                s.DecimalSeparator = '.';

            return s;
        }

        /// <summary>
        /// Replaces the decimal separators.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <param name="settings">The settings for CSV processing.</param>
        private static void ReplaceDecimalSeparators(XDocument xml, Settings settings)
        {
            var columns = from node in xml.Root.Element("table").Element("configuration").Elements()
                          where node.Attribute("type") != null && node.Attribute("type").Value.StartsWith("decimal", StringComparison.Ordinal)
                          select node;

            foreach (XElement column in columns)
            {
                var items = from node in xml.Root.Element("table").Element("items").Elements()
                            where node.Element(column.Name) != null
                            select node.Element(column.Name);

                foreach (XElement item in items)
                {
                    item.Value = item.Value.Replace('.', settings.DecimalSeparator);
                }
            }
        }

        /// <summary>
        /// Inserts the autonumbering elements if user specified column type = "autonumbering".
        /// </summary>
        /// <param name="xml">The XML.</param>
        private static void InsertAutonumberingElements(XDocument xml)
        {
            var configNodes = xml.Root.Element("table").Element("configuration").Elements();

            //1-based column index
            int autonumberColumnIndex = -1;
            string autonumberColumnName = null;
            int i = 0;

            foreach (XElement element in configNodes)
            {
                i++;

                if (element.Attribute("type") != null && element.Attribute("type").Value == "autonumbering")
                {
                    autonumberColumnIndex = i;
                    autonumberColumnName = element.Value;
                    break;
                }
            }

            if (autonumberColumnIndex != -1)
            {
                //ordinal number counter
                int counter = 1;

                var items = xml.Root.Element("table").Element("items").Elements();

                foreach (XElement item in items)
                {
                    if (autonumberColumnIndex == 1) //autonumbering column is the first
                        item.AddFirst(new XElement(autonumberColumnName, counter));
                    else //put the column amongst others
                    {
                        XElement previousElement = item.Elements().ElementAt(autonumberColumnIndex - 1);

                        previousElement.AddAfterSelf(new XElement(autonumberColumnName, counter));
                    }

                    counter++;
                }
            }
        }

        /// <summary>
        /// Encapsulates field value. It escapes double quotas and quote full value if necessary.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <param name="settings">The settings for CSV processing.</param>
        /// <returns>Encapsulated value.</returns>
        private static string EncapsulateFieldValue(string value, Settings settings)
        {
            Regex regex = new Regex(String.Format(CultureInfo.InvariantCulture, "{0}|\"|\r|\n", settings.FieldSeparator));

            if (regex.Match(value).Success || settings.QuoteAllFields)
            {
                return "\"" + value.Replace("\"", "\"\"") + "\"";
            }
            else
                return value;
        }

        /// <summary>
        /// Processes the column values from /*/table/items/* nodes.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <param name="output">Output stream.</param>
        /// <param name="settings">The settings for CSV processing.</param>
        private static void ProcessItems(XDocument xml, StreamWriter output, Settings settings)
        {
            var items = xml.Root.Element("table").Element("items").Elements();

            foreach (XElement item in items)
            {
                bool firstNodePassed = false;

                foreach (XElement column in item.Elements())
                {
                    if (firstNodePassed)
                        output.Write(settings.FieldSeparator);

                    output.Write(MakoPrintCsv.EncapsulateFieldValue(column.Value, settings));

                    firstNodePassed = true;
                }

                output.Write("\r\n");
            }
        }

        /// <summary>
        /// Processes the item headers from /*/table/configuration/* nodes.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <param name="output">Output stream.</param>
        /// <param name="settings">The settings for CSV processing.</param>
        private static void ProcessItemHeaders(XDocument xml, StreamWriter output, Settings settings)
        {
            if (xml.Root.Element("table").Element("configuration").Attribute("visible") != null &&
                xml.Root.Element("table").Element("configuration").Attribute("visible").Value == "false")
                return;

            var configNodes = xml.Root.Element("table").Element("configuration").Elements();

            int count = configNodes.Count();
            int i = 0;

            foreach (XElement element in configNodes)
            {
                output.Write(MakoPrintCsv.EncapsulateFieldValue(element.Value, settings));

                if (i + 1 == count)
                    output.Write("\r\n");
                else
                    output.Write(settings.FieldSeparator);

                i++;
            }
        }
    }
}
