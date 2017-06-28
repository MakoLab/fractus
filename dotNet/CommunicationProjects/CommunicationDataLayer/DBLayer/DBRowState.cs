namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Describes the current state of DBRow object. 
    /// </summary>
    public enum DBRowState
    {
        /// <summary>
        /// The row was removed.
        /// </summary>
        Delete,

        /// <summary>
        /// The row was added.
        /// </summary>
        Insert, 

        /// <summary>
        /// The row was changed.
        /// </summary>
        Update
    }

    /// <summary>
    /// Class with <see cref="DBRowState"/> extensions methods.
    /// </summary>
    public static class Extension
    {
        /// <summary>
        /// Converts <see cref="DBRowState"/> to string value.
        /// </summary>
        /// <param name="rowState">The <see cref="DBRowState"/> to convert.</param>
        /// <returns>The string value of specified<see cref="DBRowState"/>.</returns>
        public static string ToStateName(this DBRowState rowState)
        {
            return rowState.ToString().ToLowerInvariant();
        }
    }
}
