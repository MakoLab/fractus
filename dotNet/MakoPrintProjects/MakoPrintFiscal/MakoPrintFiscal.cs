using System;
using System.IO;
using System.Xml;

namespace Makolab.Printing.Fiscal
{
    /// <summary>
    /// Class that prints document to fiscal printer.
    /// </summary>
    public class MakoPrintFiscal
    {
        /// <summary>
        /// Fiscal printer driver that is used for printing to specific printer.
        /// </summary>
        private IFiscalPrinterDriver printerDriver;

        /// <summary>
        /// Object that is used to synchronize access to serial port.
        /// </summary>
        internal static readonly object SerialPortSyncRoot = new object();

        /// <summary>
        /// Initializes a new instance of the <see cref="MakoPrintFiscal"/> class.
        /// </summary>
        /// <param name="printer">The printer model.</param>
        /// <param name="configuration">The printer configuration.</param>
        public MakoPrintFiscal(PrinterModel printer, string configuration)
        {
            XmlDocument xd = new XmlDocument();
            xd.LoadXml(configuration);
            printerDriver = FiscalPrinterDriverFactory.CreateDriver(printer, xd.DocumentElement);
        }

        /// <summary>
        /// Prints the bill.
        /// </summary>
        /// <param name="bill">The bill.</param>
        public void PrintBill(string bill)
        {
            XmlDocument xd = new XmlDocument();
            xd.LoadXml(bill);
            printerDriver.PrintBill(xd);
        }

        /// <summary>
        /// Prints specfied document to fiscal printer.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <param name="output">Output stream, not used.</param>
        /// <remarks>
        /// xml should containt information from printed document and configuration for printer.
        /// </remarks>
        public static void Generate(string xml, Stream output)
        {
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(xml);
          

            XmlNode configuration = GetConfiguration(xmlDocument);
            PrinterModel printerModel = GetPrinterModel(configuration);

            using (IFiscalPrinterDriver printer = FiscalPrinterDriverFactory.CreateDriver(printerModel, configuration))
            {
                string documentType = GetDocumentType(xmlDocument);
                switch (documentType)
                {
                    case "bill": printer.PrintBill(xmlDocument);
                        break;
                    case "dailyReport": printer.PrintDailyReport(xmlDocument);
                        break;
                    case "display": printer.Display(xmlDocument);
                        break;
                    default:
                        break;
                }
            }
        }

        /// <summary>
        /// Gets the type of the document from specified xml.
        /// </summary>
        /// <param name="xmlData">The xml with document.</param>
        /// <returns>The type of document.</returns>
        internal static string GetDocumentType(XmlDocument xmlData)
        {
            XmlAttribute documentType = xmlData.DocumentElement.Attributes["type"];
            if (documentType == null || String.IsNullOrEmpty(documentType.Value.Trim()))
            {
                throw new ArgumentException("Document type not specified in type argument", "xmlData");
            }

            return documentType.Value;
        }

        /// <summary>
        /// Gets the configuration node from input xml.
        /// </summary>
        /// <param name="documentXml">The xml with configuration.</param>
        /// <returns></returns>
        internal static XmlNode GetConfiguration(XmlDocument documentXml)
        {
            XmlNode configuration = documentXml.DocumentElement.SelectSingleNode("configuration");
            if (configuration == null) throw new ArgumentException("Configuration element not specified.");

            XmlAttribute printerModel = configuration.Attributes["printerModel"];
            if (printerModel == null || String.IsNullOrEmpty(printerModel.Value.Trim()))
            {
                throw new ArgumentException("Printer model not specified in configuration.");
            }

            return configuration;
        }

        /// <summary>
        /// Gets the printer model from printer configuration.
        /// </summary>
        /// <param name="configuration">The printer configuration.</param>
        /// <returns></returns>
        internal static PrinterModel GetPrinterModel(XmlNode configuration)
        {
            PrinterModel printerModel;
            try
            {
                printerModel = (PrinterModel)Enum.Parse(typeof(PrinterModel), configuration.Attributes["printerModel"].Value);
            }
            catch (ArgumentException) { throw new ArgumentException("Unknown printer model."); }

            return printerModel;
        }
    }
}
