using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace Makolab.Printing.Text
{
    public class DotMatrixPrinter
    {
        PrinterModel printerModel;
        XmlDocument configuration;
        String portName;
        PrinterCodes printerCodes;
        String textEncoding;
        

        public void Print(string input)
        {
            string[] data = input.Split(new string[] { "@@@@" }, StringSplitOptions.RemoveEmptyEntries);

            LoadConfiguration(data);
            
            switch (printerModel)
            {
                case PrinterModel.Epson:
                    printerCodes = new EpsonPrinterCodes();
                    break;
                case PrinterModel.Seikosha:
                    printerCodes = new SeikoshaPrinterCodes();
                    break;
                case PrinterModel.OkiML320:
                    printerCodes = new OkiML320PrinterCodes();
                    break;
                case PrinterModel.IBM:
                    printerCodes = new IBMPrinterCodes();
                    break;
                default:
                    throw new ArgumentException("Unknown printer model.");
            }

            XmlAttribute printerSelectionMode = configuration.DocumentElement.Attributes["selectPrinterByName"];

            if (IsPrinterSelectedByName(printerSelectionMode)) RawPrinterHelper.Print(portName, printerCodes.ReplaceChars(data[1]), textEncoding);
            else LptHelper.LptPrint(portName, printerCodes.ReplaceChars(data[1]), textEncoding);
        }

        private bool IsPrinterSelectedByName(XmlAttribute printerSelectionMode)
        {
            if (printerSelectionMode == null) return (portName.StartsWith("\\"));
            else return (Boolean.Parse(printerSelectionMode.Value));
        }

        public void LoadConfiguration(string[] data)
        {
            if (data.Length < 2) throw new TextPrinterException(TextExceptionId.MissingConfiguration);
            
            this.configuration = new XmlDocument();
            this.configuration.LoadXml(data[0]);

            if (this.configuration == null) throw new TextPrinterException(TextExceptionId.MissingConfiguration);
            
            this.printerModel = GetPrinterModel(configuration.DocumentElement);
                        
            this.portName = configuration.DocumentElement.Attributes["portName"].Value;

            if (this.portName == null)
            {
                throw new TextPrinterException(TextExceptionId.MissingPortName);
            }

            /*czy nie powinno być

            if (!configuration.DocumentElement.HasAttribute("portName"))
            {
                throw new TextPrinterException(TextExceptionId.MissingPortName);
            }
            else
            {
               this.portName = configuration.DocumentElement.Attributes["portName"].Value;
            }
             * 
            */
            if (!configuration.DocumentElement.HasAttribute("textEncoding"))
            {
                this.textEncoding = "mazovia";
            }
            else
            {
                this.textEncoding = configuration.DocumentElement.Attributes["textEncoding"].Value;
            }


        }

        

        /// <summary>
        /// Gets the printer model from printer configuration.
        /// </summary>
        /// <param name="configuration">The printer configuration.</param>
        /// <returns></returns>
        internal PrinterModel GetPrinterModel(XmlNode configuration)
        {
            PrinterModel printerModel;
            try
            {
                printerModel = (PrinterModel)Enum.Parse(typeof(PrinterModel), configuration.Attributes["printerModel"].Value);
            }
            catch (ArgumentException) { throw new TextPrinterException(TextExceptionId.UnknownPrinterModel); }

            return printerModel;
        }
        
    }
}