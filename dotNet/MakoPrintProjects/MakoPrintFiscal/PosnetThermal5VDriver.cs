using System;
using System.Globalization;
using System.IO.Ports;
using System.Text;
using System.Xml;

namespace Makolab.Printing.Fiscal
{
    /// <summary>
    /// Driver that handles printing on Posnet Thermal 5V fiscal printer.
    /// </summary>
    public class PosnetThermal5VDriver : IFiscalPrinterDriver
    {
        /// <summary>
        /// Serial port used to communicate with printer.
        /// </summary>
        private SerialPort printerPort;

		// gdereck - protocol configuration
        /// <summary>
        /// Bit mask describing protocol variations:
		/// 0 - default for Thermal 5V etc. - dots in quantites and amounts, system number passed with # prefix
        /// 1 - no system number (start transaction with simplified LBTRSHDR)
        /// 2 - system number printed in header (no # prefix for extended LBTRSHDR)
        /// 4 - comma as a decimal separator in quantities
        /// 8 - comma as a decimal separator in amounts
        /// 16 - "wpłata" equal to document sum
        /// 32 - don't require ONL (on-line) bit = 1 before printing
        /// 64 - don't try to communicate with the printer before sending data to print
        /// </summary>		
		private int protocolOptions = 0;

        /// <summary>
        /// Regular expressions pattern that extracts error code from printer LBERNRQ message.
        /// </summary>
        private const string regexPatternLBERNRQ = ".*P1#E([0-9]+)";

        private const int printerStartTimeout = 15000;

        ///// <summary>
        ///// Printer configuration.
        ///// </summary>
        //private XmlElement configuration;

        #region IFiscalPrinterDriver Members

        /// <summary>
        /// Configures fiscal printer driver by setting the port name, speed etc.
        /// </summary>
        /// <param name="configuration">The printer configuration.</param>
        public void Configure(XmlNode configuration)
        {
            string portName = GetPortName(configuration);

                       
            this.printerPort = new SerialPort(portName, 9600, Parity.None, 8, StopBits.One);
            this.printerPort.Encoding = MazoviaEncoding.Mazovia;
            this.printerPort.RtsEnable = true;
            this.printerPort.ReadTimeout = 1000;
            this.printerPort.Handshake = Handshake.None;
            this.printerPort.DtrEnable = true;
            this.printerPort.DiscardNull = true;

            this.protocolOptions = GetProtocolOptions(configuration);
        }

        /// <summary>
        /// Prints the bill.
        /// </summary>
        /// <param name="bill">The xml representation of bill.</param>
        public void PrintBill(XmlDocument bill)
        {
            lock (MakoPrintFiscal.SerialPortSyncRoot)
            {
                StringBuilder output = new StringBuilder(1000);
                CheckPrinterPort();
                try
                {
                    if ((this.protocolOptions & 64) == 0) WaitUntillPrinterIsReady(printerStartTimeout);

                    this.printerPort.Write(PrepareLine(PosnetSpecialChars.CancelTransactionCommand));
                    //block error handling
                    this.printerPort.Write(PosnetSpecialChars.BeginCommand + PosnetSpecialChars.BlockErrorHandlingCommand + PosnetSpecialChars.EndCommand);
                    if (CheckENQ() == false) CheckDLE();
                    int numberOfLines = 0;
                    if (bill.DocumentElement.SelectSingleNode("configuration").Attributes["mode"].Value.Equals("OFFLINE", StringComparison.InvariantCultureIgnoreCase))
                    {
                        numberOfLines = bill.DocumentElement.SelectNodes("lines/line").Count;
                    }

                    #region for debugging
                    //if (bill.Root.Element("mode").Value.Equals("OFFLINE", StringComparison.InvariantCultureIgnoreCase))
                    //{
                    //    StartBillTransaction(bill.Root.Element("lines").Elements("line").Count(), bill.Root.Element("number").Value, output);
                    //    PrintBillLines(bill, output);
                    //    StopBillTransaction("21", "D13", bill.Root.Element("grossValue").Value, output);
                    //}
                    //else if (bill.Root.Element("mode").Value.Equals("ONLINE", StringComparison.InvariantCultureIgnoreCase))
                    //{
                    //    XmlElement billNr = bill.Root.Element("number");
                    //    if (billNr != null) StartBillTransaction(0, bill.Root.Element("number").Value, output);

                    //    if (bill.Root.Element("lines") != null) PrintBillLines(bill, output);

                    //    XmlElement grossValue = bill.Root.Element("grossValue");
                    //    if (grossValue != null) StopBillTransaction("21", "D13", grossValue.Value, output);

                    //} 
                    #endregion

                    XmlNode billNr = bill.DocumentElement.SelectSingleNode("number");
                    if (billNr != null) StartBillTransaction(numberOfLines, billNr.InnerText, output);
                    PrintAndCheck(output);

                    if (bill.DocumentElement.SelectNodes("lines") != null) PrintBillLines(bill, output);

                    XmlNode grossValue = bill.DocumentElement.SelectSingleNode("grossValue");
                    if (grossValue != null)
                    {
                        string till = ((bill.DocumentElement.SelectSingleNode("till") != null) ? bill.DocumentElement.SelectSingleNode("till").InnerText : "1").Substring(0, 1);
                        string cashier = ((bill.DocumentElement.SelectSingleNode("cashier") != null) ? bill.DocumentElement.SelectSingleNode("cashier").InnerText : "1").PadLeft(2, '0').Substring(0, 2);
                        StopBillTransaction(till, cashier, grossValue.InnerText, output);
                    }
                    PrintAndCheck(output);
                }
                finally
                {
                    this.printerPort.Close();
                }
            }
        }

        private void PrintAndCheck(StringBuilder output)
        {
            this.printerPort.Write(output.ToString());
            output.Length = 0;

            if (CheckENQ() == false) CheckDLE();
        }

        /// <summary>
        /// Prints the daily report.
        /// </summary>
        /// <param name="reportData"></param>
        public void PrintDailyReport(XmlDocument reportData)
        {
            string optionalData = String.Empty;
            XmlNode date = reportData.DocumentElement.SelectSingleNode("date");
            if (date != null)
            { 
                DateTime reportDate = DateTime.Parse(date.InnerText);
                string year = (reportDate.Year < 100) ? reportDate.Year.ToString() : reportDate.Year.ToString().Substring(2);
                optionalData = String.Format("1;{0};{1};{2} ", year, reportDate.Month, reportDate.Day);
            }

            CheckPrinterPort();
            WaitUntillPrinterIsReady(printerStartTimeout);
            this.printerPort.Write(PrepareLine(optionalData + "#r"));
            ValidatePrintOperation();
            this.printerPort.Close();
        }

        /// <summary>
        /// Sends the specified data to display.
        /// </summary>
        /// <param name="data">The data to display.</param>
        public void Display(XmlDocument data)
        {
            string result = "";
            string displayLineMask = "10{0} $d{1}";

            foreach (XmlNode line in data.DocumentElement.SelectNodes("displayContent/line"))
            {
                result += PrepareLine(String.Format(displayLineMask, line.Attributes["position"].Value, line.InnerText));
            }

            CheckPrinterPort();
            WaitUntillPrinterIsReady(printerStartTimeout);
            this.printerPort.Write(result);
            ValidatePrintOperation();
            this.printerPort.Close();
        }

        #endregion

        private void WaitUntillPrinterIsReady(int timeout)
        {

            bool isReady = false;

            // if options sixth bit is set, any response is ok (just check if the printer replies)

            bool dontRequireOnl = ((this.protocolOptions & 32) == 32);

            this.printerPort.Write(PosnetSpecialChars.DLE);

            try
            {

                int printerStatusCode = this.printerPort.ReadByte();



                if ((printerStatusCode & 4) == 4 || dontRequireOnl) isReady = true;

            }

            catch (Exception) { }



            if (isReady == false)
            {

                int orgReadTimeout = this.printerPort.ReadTimeout;

                this.printerPort.ReadTimeout = 1000;

                int loopNr = 0;

                int maxLoops = (timeout / this.printerPort.ReadTimeout) + ((timeout % this.printerPort.ReadTimeout) == 0 ? 0 : 1);

                int printerStatusCode = -99;

                while (!isReady && maxLoops > loopNr)
                {

                    try
                    {

                        printerStatusCode = this.printerPort.ReadByte();

                        if ((printerStatusCode & 4) == 4 || dontRequireOnl) isReady = true;

                        else this.printerPort.Write(PosnetSpecialChars.DLE);

                    }

                    catch (TimeoutException te)
                    {

                        //should never validates to true but it is here for legacy code compatybility :)

                        if (loopNr >= maxLoops)
                        {

                            if (printerStatusCode == -99) throw new FiscalPrinterException(FiscalExceptionId.UnableToConnectToPrinterError, te);

                        }

                        else this.printerPort.Write(PosnetSpecialChars.DLE);

                    }

                    finally
                    {

                        ++loopNr;

                    }

                }

                if (printerStatusCode == -99) throw new FiscalPrinterException(FiscalExceptionId.UnableToConnectToPrinterError);

                if ((printerStatusCode & 4) == 0 && !dontRequireOnl) throw new FiscalPrinterException(FiscalExceptionId.PrinterDLEError);

                this.printerPort.ReadTimeout = orgReadTimeout;

            }

        }

        /// <summary>
        /// Validates the printer state by checking error codes.
        /// </summary>
        private void ValidatePrintOperation()
        {
            this.printerPort.Write(String.Concat(PosnetSpecialChars.BeginCommand, "#n", PosnetSpecialChars.EndCommand));
            int errorCode = GetErrorCode(this.printerPort);
            if (errorCode > 0)
            {
                FiscalExceptionId fei = (FiscalExceptionId)errorCode;
                throw new FiscalPrinterException(fei);
            }
        }

        /// <summary>
        /// Prints the bill lines.
        /// </summary>
        /// <param name="bill">The bill.</param>
        /// <param name="outputStream">The output stream.</param>
        private void PrintBillLines(XmlDocument bill, StringBuilder outputStream)
        {
            //int billLineNr = 0;

            foreach (XmlNode line in bill.DocumentElement.SelectNodes("lines/line"))
            {
                //++billLineNr;
                string quantity = line.SelectSingleNode("quantity").InnerText;
                if (quantity.Length < 6) quantity = String.Concat(new String(' ', 6 - quantity.Length), quantity);

                string price = line.SelectSingleNode("grossPrice").InnerText;
                string value = line.SelectSingleNode("grossValue").InnerText;

                // gdereck
                // protocol third bit - comma as a decimal separator in quantity
                if ((this.protocolOptions & 4) == 4) quantity = quantity.Replace('.', ',');
                // protocol fourth bit - comma as a decimal separator in price and value
                if ((this.protocolOptions & 8) == 8)
                {
                    price = price.Replace('.', ',');
                    value = value.Replace('.', ',');
                }

                string name = line.SelectSingleNode("name").InnerText;
                string currentLine = String.Concat(line.Attributes["position"].Value,
                                                    "$l", // ATTENTION this is small L letter (like lol) not number ONE (1)
                                                    name.Substring(0, name.Length > 40 ? 40 : name.Length),
                                                    "\r",
                                                    quantity,
                    ////line.Element("unitOfMeasure").Value, ////- the printer does not use it and it can create problems when contains numbers.
                                                    "\r",
                                                    line.SelectSingleNode("vatRateType").InnerText,
                                                    "/",
                                                    price,
                                                    "/",
                                                    value,
                                                    "/");

                outputStream.Append(PrepareLine(currentLine));
                PrintAndCheck(outputStream);
            }
        }

        /// <summary>
        /// Prepares the specified line for pinting by enclosing it with special characters and adding line checksum.
        /// </summary>
        /// <param name="line">The line.</param>
        /// <returns>Line that is ready to be send to printer.</returns>
        internal static string PrepareLine(string line)
        {
            return String.Concat(PosnetSpecialChars.BeginCommand, line, GenerateChecksum(line), PosnetSpecialChars.EndCommand);
        }

        /// <summary>
        /// Generates the checksum for specified data.
        /// </summary>
        /// <param name="data">The data.</param>
        /// <returns>Checksum of specified data.</returns>
        internal static string GenerateChecksum(string data)
        {
            int checksum = 255;
            if (String.IsNullOrEmpty(data)) return data;

            byte[] dataInMazovia = MazoviaEncoding.Mazovia.GetBytes(data);
            for (int i = 0; i < dataInMazovia.Length; i++) checksum = checksum ^ dataInMazovia[i];

            return checksum.ToString("X2", CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Starts the bill transaction by printing specific command.
        /// </summary>
        /// <param name="amountOfLines">The amount of bill lines.</param>
        /// <param name="additionalLine">The additional line.</param>
        /// <param name="outputStream">The output stream.</param>
        internal void StartBillTransaction(int amountOfLines, string additionalLine, StringBuilder outputStream)
        {
            //amountOfLines|;|amountOfAdditionaLines|$h|additionalLine -   "2;1$h#1068/S/2008"
			if ((this.protocolOptions & 1) == 1)
            // no system number
			{
                    outputStream.Append(PrepareLine(String.Concat(
                        amountOfLines.ToString(System.Globalization.CultureInfo.InvariantCulture),
                        "$h"
                    )));
            }
            else if ((this.protocolOptions & 2) == 2)
            {
				outputStream.Append(PrepareLine(String.Concat(
                        amountOfLines.ToString(System.Globalization.CultureInfo.InvariantCulture),
                        ";1$hNr sys. ",
                        additionalLine,
                        ((char)13).ToString()
                    )));
            }
            else
            {
                outputStream.Append(PrepareLine(String.Concat(
                        amountOfLines.ToString(System.Globalization.CultureInfo.InvariantCulture),
                        ";1$h#",
                        additionalLine
                    )));
            }
        }

        /// <summary>
        /// Commits the bill transaction by printing specific command.
        /// </summary>
        /// <param name="till">The till.</param>
        /// <param name="cashier">The cashier.</param>
        /// <param name="grossValue">The bill gross value.</param>
        /// <param name="outputStream">The output stream.</param>
        internal void StopBillTransaction(string till, string cashier, string grossValue, StringBuilder outputStream)
        {
            //TransactionStatus(1-OK)|;|Optional rediscount|$e|till|cashier|<CR>|WPLATA|/|grossValue|/ - "1;0$e11A\r0/3324,48/"
            string settled = "0";
            if ((this.protocolOptions & 8) == 8) grossValue = grossValue.Replace('.', ',');
            if ((this.protocolOptions & 16) == 16) settled = grossValue;
            outputStream.Append(PrepareLine(String.Concat("1;0$e",till,cashier,"\r", settled, "/",grossValue,"/")));
        }

        /// <summary>
        /// Gets the name of the printer port from configuration.
        /// </summary>
        /// <param name="configuration">The configuration.</param>
        /// <returns>Name of the printer port</returns>
        internal static string GetPortName(XmlNode configuration)
        {
            XmlAttribute portName = configuration.Attributes["portName"];
            if (portName == null || String.IsNullOrEmpty(portName.Value)) throw new ArgumentException("Port name not specified in confoguration.");

            return portName.Value;
        }

        /// <summary>
        /// Gets the protocol options from configuration.
        /// </summary>
        /// <param name="configuration">The configuration.</param>
        /// <returns>Number of the protocol</returns>
        internal static int GetProtocolOptions(XmlNode configuration)
        {
            XmlAttribute options = configuration.Attributes["protocolOptions"];
            if (options == null || String.IsNullOrEmpty(options.Value)) return 0;

            return Int32.Parse(options.Value);
        }

        /// <summary>
        /// Checks the printer port status.
        /// </summary>
        private void CheckPrinterPort()
        {
            if (this.printerPort == null) throw new InvalidOperationException("Driver is not configured.");
            if (this.printerPort.IsOpen == false)
            {
                try
                {
                    this.printerPort.Open();
                }
                catch (Exception)
                {
                    throw new FiscalPrinterException(FiscalExceptionId.UnableToConnectToPrinterError);
                }
            }
        }

        private int GetErrorCode(SerialPort port)
        {
            try
            {
                SerialPortHelper.ReadUntil(port, "1#E");

               return Int32.Parse(SerialPortHelper.ReadUntil(port, PosnetSpecialChars.EndCommand));
            }
            catch (TimeoutException te)
            {
                throw new FiscalPrinterException(FiscalExceptionId.TimeoutException, te);
            }
            
        }

        private bool CheckENQ()
        {
            this.printerPort.Write(PosnetSpecialChars.ENQ);
            uint stateByte = (uint)this.printerPort.ReadChar();
            uint[] stateArray = calculateBinaryBytes(stateByte);
	
			if(stateArray[2] != 1) {
				return false;
			}
			
			return true;

        }

        private void CheckDLE()
        {
             this.printerPort.Write(PosnetSpecialChars.DLE);
			
			uint stateByte = (uint)this.printerPort.ReadChar();

            uint[] stateArray = calculateBinaryBytes(stateByte);

            if (stateArray[0] == 1)
            {
                throw new FiscalPrinterException(FiscalExceptionId.PrinterDLEError);
			}
            else if (stateArray[1] == 1)
			{
                throw new FiscalPrinterException(FiscalExceptionId.PrinterDLEError);
			}

            this.printerPort.Write(String.Concat(PosnetSpecialChars.BeginCommand, "#n", PosnetSpecialChars.EndCommand));
            int errorCode = GetErrorCode(this.printerPort);
            if (errorCode > 0)
            {
                FiscalExceptionId fei = (FiscalExceptionId)errorCode;
                throw new FiscalPrinterException(fei);
            }

        }


        private uint[] calculateBinaryBytes(uint value)
		{
			uint[] result = new uint[8];
              
       					
			for(int i=0; i<8; i++)
			{
				result[i] = value % 2;
				value = value / 2;
			}
			
			return result;
		}

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            this.printerPort.Dispose();
        }

        #endregion
    }
}
