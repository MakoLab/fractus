using System;
using System.Globalization;
using System.Reflection;

namespace Makolab.Printing.XLS
{
    /// <summary>
    /// Class that contains utils for XLS printing.
    /// </summary>
    internal static class Utils
    {
        /// <summary>
        /// Capitalizes the specified value.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <returns>Capitalized value.</returns>
        internal static string Capitalize(this string value)
        {
            if (String.IsNullOrEmpty(value))
                return value;
            else
                return Convert.ToString(value[0], CultureInfo.InvariantCulture).ToUpperInvariant() + value.Substring(1);
        }

        /// <summary>
        /// Parses the color from input string and returns proper <see cref="org.in2bits.MyXls.Color"/> structure.
        /// </summary>
        /// <param name="name">The name of color.</param>
        /// <exception cref="ArgumentException">If the color is unknown.</exception>
        /// <returns>Parsed color.</returns>
        internal static org.in2bits.MyXls.Color ParseColor(string name)
        {
            Assembly ass = Assembly.GetAssembly(typeof(org.in2bits.MyXls.Colors));

            Type colorType = ass.GetType("org.in2bits.MyXls.Colors");
            
            FieldInfo fi = colorType.GetField(name.Capitalize(), BindingFlags.Public | BindingFlags.Static);

            if (fi == null)
                throw new ArgumentException("Unknown color name.", "name");

            return (org.in2bits.MyXls.Color)fi.GetValue(null);
        }
    }
}
