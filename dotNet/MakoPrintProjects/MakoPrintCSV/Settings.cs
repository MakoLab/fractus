
namespace Makolab.Printing.CSV
{
    /// <summary>
    /// Class that contains settings for CSV processing.
    /// </summary>
    internal class Settings
    {
        /// <summary>
        /// Separator for CSV fields.
        /// </summary>
        public char FieldSeparator { get; set; }

        /// <summary>
        /// Flag deciding whether to quote all fields.
        /// </summary>
        public bool QuoteAllFields { get; set; }

        /// <summary>
        /// Decimal separator for CSV fields.
        /// </summary>
        public char DecimalSeparator { get; set; }

        /// <summary>
        /// Output encoding.
        /// </summary>
        public string Encoding { get; set; }
    }
}
