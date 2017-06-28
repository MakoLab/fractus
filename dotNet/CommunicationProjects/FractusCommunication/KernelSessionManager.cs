using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Manages Kernel log state.
    /// </summary>
    public static class KernelSessionManager
    {
        [ThreadStatic]
        private static bool isLogged;

        /// <summary>
        /// Gets or sets a value indicating whether communication is logged to Kernel module.
        /// </summary>
        /// <value><c>true</c> if communication is logged; otherwise, <c>false</c>.</value>
        public static bool IsLogged
        {
            get
            {
                return isLogged;
            }
            set
            {
                isLogged = value;
            }
        }
    }
}
