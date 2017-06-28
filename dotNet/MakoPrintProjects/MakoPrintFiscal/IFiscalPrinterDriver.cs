using System;
using System.Xml;

namespace Makolab.Printing.Fiscal
{
    /// <summary>
    /// Defines methods for all fiscal printer drivers.
    /// </summary>
    public interface IFiscalPrinterDriver : IDisposable
    {
        /// <summary>
        /// Configures fiscal printer driver by setting the port name, speed etc.
        /// </summary>
        /// <param name="configuration">The printer configuration.</param>
        void Configure(XmlNode configuration);

        /// <summary>
        /// Prints the bill.
        /// </summary>
        /// <param name="bill">The xml representation of bill.</param>
        void PrintBill(XmlDocument bill);

        /// <summary>
        /// Prints the daily report.
        /// </summary>
        void PrintDailyReport(XmlDocument reportData);

        /// <summary>
        /// Sends the specified data to display.
        /// </summary>
        /// <param name="data">The data to display.</param>
        void Display(XmlDocument data);
    }
}
