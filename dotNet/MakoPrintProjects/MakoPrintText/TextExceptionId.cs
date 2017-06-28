using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Printing.Text
{
    public enum TextExceptionId
    {
        TooManyCharsInRow,
        MissingConfiguration,
        MissingPortName,
        UnknownPrinterModel,
        PortNameError,
        PrinterNameError
    }
}
