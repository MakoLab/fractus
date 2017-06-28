
namespace Makolab.Fractus.Commons
{
    /// <summary>
    /// Specifies DateTime's accuracy.
    /// </summary>
    public enum DateTimeAccuracy
    {
        /// <summary>
        /// Round to the nearest second.
        /// </summary>
        Second,

        /// <summary>
        /// Round to the nearest minute.
        /// </summary>
        Minute,

        /// <summary>
        /// Round to the nearest hour.
        /// </summary>
        Hour,

        /// <summary>
        /// Round to the nearest day.
        /// </summary>
        Day,

        /// <summary>
        /// Round to the nearest millisecond.
        /// </summary>
        Millisecond
    }
}
