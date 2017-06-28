using System;
using System.Collections.Generic;
using System.Text;
using System.IO.Ports;
using System.Xml;
using System.Runtime.InteropServices;
using System.Collections;

namespace Makolab.Printing.Fiscal
{
    public class ElzabDriver : IFiscalPrinterDriver //internal
    {

        int portName;
        string billNr;
        string cash;
        string cashier;
        string grossValue;
        ArrayList receitLines = new ArrayList();


        #region IFiscalPrinterDriver Members

        /// <summary>
        /// Configures fiscal printer driver by setting the port name, speed etc.
        /// </summary>
        /// <param name="configuration">The printer configuration.</param>
        public void Configure(XmlNode configuration)
        {
            portName = GetPortName(configuration);
        }



        /// <summary>
        /// Prints the bill.
        /// </summary>
        /// <param name="bill">The xml representation of bill.</param>
        /// 
        /// 
        public void PrintBill(XmlDocument bill)
        {

            ProcessBill(bill);

            StringBuilder errorMessage = null;

            lock (MakoPrintFiscal.SerialPortSyncRoot)
            {
                //inicjalizacja portu
                if ((errorMessage = ElzabLibWrapper.LibCommunicationInit(portName, 9600, 5)) != null)
                {
                    HandleError(errorMessage.ToString());
                }

                // ustawienie numeru kasy i kasjera
                SetCashierCode();


                //rozpoczecie paragonu
                if ((errorMessage = ElzabLibWrapper.LibReceiptBegin()) != null)
                {
                    HandleError(errorMessage.ToString());
                }

                //linie paragonu
                for (int i = 0; i < receitLines.Count; i++)
                {
                    ReceiptLine rLine = (ReceiptLine)receitLines[i];
                    if ((errorMessage = ElzabLibWrapper.LibReceiptItem(rLine.name, rLine.vatRate, rLine.quantity, rLine.coma, rLine.measure, rLine.price, rLine.value)) != null)
                    {
                        HandleError(errorMessage.ToString());
                    }
                }


                // wydrukowanie numeru systemowego
                if ((errorMessage = ElzabLibWrapper.LibAdditionalLine(12, billNr)) != null)
                {
                    HandleError(errorMessage.ToString());
                }

                //zakonczenie paragonu
                if ((errorMessage = ElzabLibWrapper.LibReceiptEnd(0)) != null)
                {
                    HandleError(errorMessage.ToString());
                }


                //zamkniecie portu
                if ((errorMessage = ElzabLibWrapper.LibCommunicationEnd()) != null)
                {
                    HandleError(errorMessage.ToString());
                }
            }
        }

        public void SetCashierCode()
        {
            StringBuilder errorMessage = null;
            byte[] output = new byte[4];
            byte[] input = new byte[255];

            for (int i = 0; i < 2; i++)
            {
                output[i] = (byte)this.cash[i];
                output[i + 2] = (byte)this.cashier[i];
            }

            if ((errorMessage = ElzabLibWrapper.LibRSSequence(0x43, 1, 4, input, output)) != null)
            {
                HandleError(errorMessage.ToString());
            }
        }



        /// <summary>
        /// Prints the daily report.
        /// </summary>
        /// <param name="reportData"></param>
        public void PrintDailyReport(XmlDocument reportData)
        {
            StringBuilder errorMessage = null;

            lock (MakoPrintFiscal.SerialPortSyncRoot)
            {
                //inicjalizacja portu
                if ((errorMessage = ElzabLibWrapper.LibCommunicationInit(portName, 9600, 5)) != null)
                {
                    HandleError(errorMessage.ToString());
                }

                if ((errorMessage = ElzabLibWrapper.LibDailyReport(1)) != null)
                {
                    HandleError(errorMessage.ToString());
                }

                //zamkniecie portu
                if ((errorMessage = ElzabLibWrapper.LibCommunicationEnd()) != null)
                {
                    HandleError(errorMessage.ToString());
                }

            }
        }

        /// <summary>
        /// Sends the specified data to display.
        /// </summary>
        /// <param name="data">The data to display.</param>
        public void Display(XmlDocument data)
        {
            throw new FiscalPrinterException(FiscalExceptionId.NotImplementedFeature);
        }

        #endregion


        public void ProcessBill(XmlDocument bill)
        {
            XmlNode cashierNode = bill.DocumentElement.SelectSingleNode("cashier");
            if (cashierNode != null)
            {
                cashier = cashierNode.InnerText.PadLeft(2, '0').Substring(0, 2); ;
            }
            else
            {
                throw new FiscalPrinterException(FiscalExceptionId.MissingCashierError);
            }

            XmlNode cashNode = bill.DocumentElement.SelectSingleNode("cash");
            if (cashNode != null)
            {
                cash = cashNode.InnerText.PadLeft(2, '0').Substring(0, 2); ;
            }
            else
            {
                cash = "01";
            }


            XmlNode billNrNode = bill.DocumentElement.SelectSingleNode("number");
            if (billNrNode != null)
            {
                billNr = billNrNode.InnerText;
            }
            else
            {
                throw new FiscalPrinterException(FiscalExceptionId.MissingBillNumberError);
            }


            XmlNode grossValueNode = bill.DocumentElement.SelectSingleNode("grossValue");
            if (grossValueNode != null)
            {
                grossValue = grossValueNode.InnerText;
            }
            else
            {
                throw new FiscalPrinterException(FiscalExceptionId.PrinterPrecisionError);
            }

            foreach (XmlNode line in bill.DocumentElement.SelectNodes("lines/line"))
            {
                ReceiptLine rLine = new ReceiptLine();

                string quantity = (line.SelectSingleNode("quantity").InnerText).Replace(".", ",");

                Double q = Math.Round(Double.Parse(quantity), 4, MidpointRounding.ToEven);

                if ((Double.Parse(quantity) - q) != 0)
                {
                    throw new FiscalPrinterException(FiscalExceptionId.PrinterPrecisionError);
                }
                else
                {
                    int coma = checkComaPosition(q.ToString());
                    rLine.quantity = (int)(Math.Round(q * Math.Pow(10, coma), MidpointRounding.AwayFromZero));
                    rLine.coma = coma;
                }

                string name = line.SelectSingleNode("name").InnerText;
                rLine.name = name;

                string vatRate = line.SelectSingleNode("vatRateType").InnerText;
                rLine.vatRate = Char.ConvertToUtf32(vatRate, 0);


                String price = (line.SelectSingleNode("grossPrice").InnerText).Replace(".", ",");
                rLine.price = (int)(Math.Round(Double.Parse(price) * 100.0, MidpointRounding.AwayFromZero));

                String value = (line.SelectSingleNode("grossValue").InnerText).Replace(".", ",");
                rLine.value = (int)(Math.Round(Double.Parse(value) * 100, MidpointRounding.AwayFromZero));

                String measure = line.SelectSingleNode("unit").InnerText;
                rLine.measure = measure;

                receitLines.Add(rLine);
            }
        }


        /// <summary>
        /// Gets the name of the printer port from configuration.
        /// </summary>
        /// <param name="configuration">The configuration.</param>
        /// <returns>Name of the printer port</returns>
        internal static int GetPortName(XmlNode configuration)
        {
            XmlAttribute portName = configuration.Attributes["portName"];
            if (portName == null || String.IsNullOrEmpty(portName.Value)) throw new ArgumentException("Port name not specified in confoguration.");

            int port = Int32.Parse(portName.Value.Substring(3)); // z COM1 wycinam 1
            return port;
        }


        internal static int checkComaPosition(String value)
        {
            return value.IndexOf(",") + 1;
        }


        public void HandleError(String errorMessage)
        {
            if (errorMessage.Equals("Timeout nadawania") || errorMessage.Equals("Timeout odbierania"))
            {
                throw new FiscalPrinterException(FiscalExceptionId.ConnectionError);
            }
            else
            {
                throw new FiscalPrinterException(errorMessage.ToString());
            }
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

        }

        #endregion

        public ArrayList GetReceiptLinesForTests()
        {
            return this.receitLines;
        }

    }
    public class ReceiptLine
    {
        public String name;
        public int vatRate;
        public int quantity;
        public int coma;
        public String measure;
        public int price;
        public int value;

        public ReceiptLine()
        {

        }

        public ReceiptLine(string name, int vatRate, int quantity, int coma, String measure, int price, int value)
        {
            this.name = name;
            this.vatRate = vatRate;
            this.quantity = quantity;
            this.coma = coma;
            this.measure = measure;
            this.price = price;
            this.value = value;
        }

        public ReceiptLine(ReceiptLine rLine)
        {
            this.name = rLine.name;
            this.vatRate = rLine.vatRate;
            this.quantity = rLine.quantity;
            this.coma = rLine.coma;
            this.measure = rLine.measure;
            this.price = rLine.price;
            this.value = rLine.value;
        }

        public override int GetHashCode()
        {
            return name.GetHashCode() ^ vatRate.GetHashCode() ^ quantity.GetHashCode() ^ coma.GetHashCode() ^ measure.GetHashCode() ^ price.GetHashCode() ^ value.GetHashCode();
        }

        public override bool Equals(Object obj)
        {
            //Check for null and compare run-time types.
            if (obj == null || GetType() != obj.GetType()) return false;
            ReceiptLine rt = (ReceiptLine)obj;
            return (name == rt.name) && (vatRate == rt.vatRate) && (quantity == rt.quantity) && (coma == rt.coma) && (measure == rt.measure) && (price == rt.price) && (value == rt.value);
        }

       


    }
}
