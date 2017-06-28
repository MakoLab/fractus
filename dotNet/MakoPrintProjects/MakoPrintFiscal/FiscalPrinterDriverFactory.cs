using System;
using System.Xml;

namespace Makolab.Printing.Fiscal
{
    /// <summary>
    /// Factory call that creates fiscal printer driver.
    /// </summary>
    public sealed class FiscalPrinterDriverFactory
    {
        private FiscalPrinterDriverFactory()
        {

        }

        /// <summary>
        /// Creates the driver for specified printer model.
        /// </summary>
        /// <param name="model">The printer model.</param>
        /// <param name="configuration">The printer configuration.</param>
        /// <returns>Created fiscal driver.</returns>
        public static IFiscalPrinterDriver CreateDriver(PrinterModel model, XmlNode configuration)
        {
            IFiscalPrinterDriver driver = null;
            switch (model)
            {
                case PrinterModel.PosnetThermal5V:
                    driver = new PosnetThermal5VDriver();
                    break;
                case PrinterModel.Elzab:
                    driver = new ElzabDriver();
                    break;
                default:
                    throw new ArgumentException("Unknown printer model.");
            }
            driver.Configure(configuration);

            return driver;
        }
    }
}
