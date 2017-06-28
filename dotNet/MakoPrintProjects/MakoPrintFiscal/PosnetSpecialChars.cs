
namespace Makolab.Printing.Fiscal
{
    /// <summary>
    /// Defines characters specific for Posnet fiscal printers.
    /// </summary>
    public static class PosnetSpecialChars
    {
        /// <summary>
        /// Characters that starts every command.
        /// </summary>
        public static readonly string BeginCommand = ((char)27).ToString() + ((char)80).ToString();

        /// <summary>
        /// Characters that ends every command.
        /// </summary>
        public static readonly string EndCommand = ((char)27).ToString() + ((char)92).ToString();

        /// <summary>
        /// Carriage return character.
        /// </summary>
        public const string CarriageReturn = "\r";

        /// <summary>
        /// New line character.
        /// </summary>
        public const string NewLine = "\r\n";

        /// <summary>
        /// Return printer status command.
        /// </summary>
        public static readonly string DLE = ((char)16).ToString();

        /// <summary>
        /// Return printer status command.
        /// </summary>
        public static readonly string ENQ = ((char)5).ToString();

        /// <summary>
        /// Sound signal.
        /// </summary>
        public static readonly string BEL = ((char)7).ToString();

        /// <summary>
        /// Stop interpreting current command.
        /// </summary>
        public static readonly string CAN = ((char)24).ToString();

        /// <summary>
        /// No data to read character.
        /// </summary>
        public static readonly string DC1 = ((char)17).ToString();

        /// <summary>
        /// Block error messages command.
        /// </summary>
        public static readonly string BlockErrorHandlingCommand = ((char)49).ToString() +((char)35).ToString() + ((char)101).ToString() + ((char)56).ToString() + ((char)56).ToString();

        /// <summary>
        /// Cancel unfinished transaction command.
        /// </summary>
        public static readonly string CancelTransactionCommand = ((char)48).ToString() + ((char)36).ToString() + ((char)101).ToString();
    }
}
