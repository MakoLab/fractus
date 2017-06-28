using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using Makolab.Printing.CSV;
using Makolab.Printing.Fiscal;
using Makolab.Printing.Text;
using Makolab.Printing.VCard;
using Makolab.Printing.XLS;
using Makolab.Printing.Pdf;

namespace Makolab.Printing
{
    /// <summary>
    /// Class that prints to many document formats from an input XML.
    /// </summary>
    public static class MakoPrint
    {
        /// <summary>
        /// Generates the chosen document from the input parameters.
        /// </summary>
        /// <param name="xml">Xml containing data.</param>
        /// <param name="xslt">XSL Transformation.</param>
        /// <param name="printProfileXml">Print profile XML.</param>
        /// <param name="driverConfigXml">Driver config XML.</param>
        /// <param name="format">Output format.</param>
        /// <param name="output">Output stream.</param>
        /// <exception cref="InvalidOperationException">if the output format is unknown.</exception>
        public static void Generate(string xml, string xslt, string printProfileXml, string driverConfigXml, string format, Stream output)
        {
            OutputFormat outFormat = OutputFormat.Xml;

            try
            {
                outFormat = (OutputFormat)Enum.Parse(typeof(OutputFormat), format, true);
            }
            catch (ArgumentException)
            {
                throw new InvalidOperationException("Unknown output format");
            }

            MakoPrint.Generate(xml, xslt, printProfileXml, driverConfigXml, outFormat, output);
        }

        /// <summary>
        /// Generates the chosen document from the input parameters.
        /// </summary>
        /// <param name="xml">Xml containing data.</param>
        /// <param name="xslt">XSL Transformation.</param>
        /// <param name="printProfileXml">Print profile XML.</param>
        /// <param name="driverConfigXml">Driver config XML.</param>
        /// <param name="format">Output format.</param>
        /// <param name="output">Output stream.</param>
        public static void Generate(string xml, string xslt, string printProfileXml, string driverConfigXml, OutputFormat format, Stream output)
        {
            string inputXml = MakoPrintPdf.TransformXml(xml, xslt, printProfileXml, driverConfigXml);

            switch (format)
            {
                case OutputFormat.Html:
                case OutputFormat.Xml:
                    StreamWriter writer = new StreamWriter(output);
                    writer.Write(inputXml);
                    writer.Flush();
                    break;
                case OutputFormat.Csv:
                    MakoPrintCsv.Generate(inputXml, output);
                    break;
                case OutputFormat.Fiscal:
                    MakoPrintFiscal.Generate(inputXml, output);
                    break;
                case OutputFormat.Pdf:
                    MakoPrintPdf.GeneratePdf(inputXml, output);
                    break;
                case OutputFormat.Xls:
                    MakoPrintXls.Generate(inputXml, output);
                    break;
                case OutputFormat.Vcf:
                    MakoPrintVCard.Generate(inputXml, output);
                    break;
                case OutputFormat.Text:
                    MakoPrintText.Generate(inputXml, output, driverConfigXml);
                    break;
            }
        }
    }
}
