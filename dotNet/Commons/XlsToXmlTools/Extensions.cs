
namespace XlsToXmlTools.extensionsTemp
{
    using System;
    using System.Collections.Generic;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Xml;
    using System.Xml.Linq;
	using System.Collections;
	using System.Text;
	using System.Security.Cryptography;

    /// <summary>
    /// Static class containing extension methods for other classes.
    /// </summary>
    public static class Extensions
	{
		#region XNode
		/// <summary>
        /// Gets the <see cref="XNode"/>'s OuterXml.
        /// </summary>
        /// <returns><see cref="XNode"/>'s xml.</returns>
        public static string OuterXml(this XNode node)
        {
            StringWriter w = new StringWriter(CultureInfo.InvariantCulture);
            XmlWriter writer = XmlTextWriter.Create(w);

            try
            {
                node.WriteTo(writer);
            }
            finally
            {
                writer.Close();
            }

            return w.ToString();
        }

        /// <summary>
        /// Gets the <see cref="XNode"/>'s InnerXml.
        /// </summary>
        /// <param name="node">The node.</param>
        /// <returns>The node InnerXml.</returns>
        public static string InnerXml(this XNode node)
        {
            if (node == null) throw new ArgumentNullException("node");

            XmlReader reader = node.CreateReader();
            reader.MoveToContent();
            return reader.ReadInnerXml();
        }
		#endregion

		#region XElement

		/// <summary>
		/// Compares child nodes of two elements. Child nodes with nested nodes are not compared.
		/// </summary>
		/// <param name="parent">Pattern element.</param>
		/// <param name="obj">Element to compare.</param>
		/// <param name="nodesToSkip">Xml node names that should be skipped during comparison</param>
		/// <returns><c>true</c> if the elements are equal; otherwise <c>false</c>.</returns>
		public static bool Compare(this XElement parent, XElement obj, string[] nodesToSkip)
		{
			IEnumerable<XElement> newElements = null;
			IEnumerable<XElement> oldElements = null;

			if (nodesToSkip != null)
			{
				newElements = from node in parent.Elements()
							  where node.HasElements == false && nodesToSkip.Contains(node.Name.LocalName) == false
							  select node;

				oldElements = from node in obj.Elements()
							  where node.HasElements == false && nodesToSkip.Contains(node.Name.LocalName) == false
							  select node;
			}
			else
			{
				newElements = from node in parent.Elements()
							  where node.HasElements == false
							  select node;

				oldElements = from node in obj.Elements()
							  where node.HasElements == false
							  select node;
			}

			// compare new to old
			foreach (XElement newElement in newElements)
			{
				var oldElement = from node in oldElements
								 where node.Name.LocalName == newElement.Name.LocalName
								 select node;

				if (oldElement.Count() == 0 || oldElement.ElementAt(0).Value != newElement.Value)
				{
					return false;
				}
			}

			// compare old to new
			foreach (XElement newElement in oldElements)
			{
				var oldElement = from node in newElements
								 where node.Name.LocalName == newElement.Name.LocalName
								 select node;

				if (oldElement.Count() == 0 || oldElement.ElementAt(0).Value != newElement.Value)
				{
					return false;
				}
			}

			return true;
		}

		/// <summary>
		/// Compares child nodes of two elements. Child nodes with nested nodes are not compared.
		/// </summary>
		/// <param name="parent">Pattern element.</param>
		/// <param name="obj">Element to compare.</param>
		/// <returns><c>true</c> if the elements are equal; otherwise <c>false</c>.</returns>
		public static bool Compare(this XElement parent, XElement obj)
		{
			return Extensions.Compare(parent, obj, null);
		}

		/// <summary>
		/// Compare type attribute of xml element with specified value
		/// </summary>
		/// <param name="element">Element to check</param>
		/// <param name="type">Value of type to compare</param>
		/// <returns>true if type of element and parameter are equal, false otherwise</returns>
		public static bool CheckType(this XElement element, string type)
		{
			return element.Attribute("type") != null && element.Attribute("type").Value == type;
		}

		/// <summary>
		/// Returns text value of element or null if it doesn't exist.
		/// </summary>
		/// <param name="element"></param>
		/// <returns></returns>
		public static string GetTextValueOrNull(this XElement element, string name)
		{
			return element.Element(name) == null ? null : element.Element(name).Value;
		}

		/// <summary>
		/// Returns text value of attribute if it exists in current context
		/// </summary>
		/// <param name="element"></param>
		/// <param name="attributeName"></param>
		/// <returns></returns>
		public static string GetAtributeValueOrNull(this XElement element, string attributeName)
		{
			return element != null && attributeName != null && element.Attribute(attributeName) != null ?
				element.Attribute(attributeName).Value : null;
		}

		#endregion

		#region Guid, Guid?

		/// <summary>
		/// Returns a <see cref="System.String"/> representation of the value of this instance in uppercase registry format.
		/// </summary>
		/// <param name="value">Guid to convert.</param>
		/// <returns><see cref="System.String"/> representation of the value of this instance in uppercase registry format.</returns>
		public static string ToUpperString(this Guid value)
		{
			return value.ToString().ToUpperInvariant();
		}

		/// <summary>
		/// Returns a <see cref="System.String"/> representation of the value of this instance in uppercase registry format.
		/// </summary>
		/// <param name="value">Guid to convert.</param>
		/// <returns><see cref="System.String"/> representation of the value of this instance in uppercase registry format.</returns>
		public static string ToUpperString(this Guid? value)
		{
			return value.Value.ToString().ToUpperInvariant();
		}

		#endregion

		#region String

		public static string SubstringAfter(this string source, string value)
		{
			if (source == null)
				return null;
			if (string.IsNullOrEmpty(value))
			{
				return source;
			}
			CompareInfo compareInfo = CultureInfo.InvariantCulture.CompareInfo;
			int index = compareInfo.IndexOf(source, value, CompareOptions.Ordinal);
			if (index < 0)
			{
				//No such substring
				return string.Empty;
			}
			return source.Substring(index + value.Length);
		}

		public static string SubstringBefore(this string source, string value)
		{
			if (string.IsNullOrEmpty(value))
			{
				return value;
			}
			CompareInfo compareInfo = CultureInfo.InvariantCulture.CompareInfo;
			int index = compareInfo.IndexOf(source, value, CompareOptions.Ordinal);
			if (index < 0)
			{
				//No such substring
				return string.Empty;
			}
			return source.Substring(0, index);
		}

		/// <summary>
		/// Capitalizes the specified value.
		/// </summary>
		/// <param name="value">The value.</param>
		/// <returns>Capitalized value.</returns>
		public static string Capitalize(this string value)
		{
			if (String.IsNullOrEmpty(value))
				return value;
			else
				return Convert.ToString(value[0], CultureInfo.InvariantCulture).ToUpperInvariant() + value.Substring(1);
		}

		/// <summary>
		/// Decapitalizes the specified value.
		/// </summary>
		/// <param name="value">The value.</param>
		/// <returns>Decapitalized value.</returns>
		public static string Decapitalize(this string value)
		{
			if (String.IsNullOrEmpty(value))
				return value;
			else
				return Convert.ToString(value[0], CultureInfo.InvariantCulture).ToLowerInvariant() + value.Substring(1);
		}

		/// <summary>
		/// I know that it is a bad habit but i have no choice
		/// </summary>
		/// <param name="value"></param>
		/// <returns></returns>
		public static bool IsGuid(this string value)
		{
			try
			{
				Guid result = new Guid(value);
				return true;
			}
			catch (FormatException fex)
			{
				fex.ToString();
				return false;
			}
		}

		public static int IndexOfNumber(this string value)
		{
			return value.IndexOfAny(new char[] {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'});
		}

		public static string ToXmlName(this string value)
		{
			value = new String(value.Where(c => Char.IsLetterOrDigit(c)).ToArray());

			if (value.Length == 0)
			{
				return "_";
			}
			else if (Char.IsDigit(value[0]))
			{
				return String.Concat("_", value);
			}

			return value;
		}

		/// <summary>
		/// Replaces individual characters of a string with other individual characters. The toReplace argument is a list of characters to be changed, and replacement is the list of replacement characters. Each character in toReplace is replaced by the character in the same position in replacement. If toReplace is longer than replacement, the characters in toReplace that have no corresponding character in processed string are not included in the result. Characters in the original string that do not appear in toReplac are copied to the result unchanged. Null values are treated as String.Empty;
		/// </summary>
		/// <param name="value"></param>
		/// <param name="toReplace">Characters to replace</param>
		/// <param name="replacement">Replacing characters</param>
		/// <returns></returns>
		public static string Translate(this string value, string toReplace, string replacement)
		{
			if (toReplace == null)
				return value;

			#region Create mapping

			long replacementCount = replacement != null ? replacement.Length : 0;

			Dictionary<char, char?> mapping = new Dictionary<char, char?>(toReplace.Length);
			
			IEnumerator toReplacePtr = toReplace.GetEnumerator();
			if (replacementCount > 0)
			{
				IEnumerator replacementPtr = replacement.GetEnumerator();
				while (toReplacePtr.MoveNext() && replacementPtr.MoveNext())
				{
					mapping.Add((char)toReplacePtr.Current, (char)replacementPtr.Current);
				}
			}

			while (toReplacePtr.MoveNext())
			{
				mapping.Add((char)toReplacePtr.Current, null);
			}
			#endregion

			#region Create translated string

			StringBuilder resultBuilder = new StringBuilder(value.Length);
			foreach (char currentChar in value)
			{
				if (mapping.ContainsKey(currentChar))
				{
					if (mapping[currentChar] != null)
					{
						resultBuilder.Append(mapping[currentChar]);
					}
				}
				else
				{
					resultBuilder.Append(currentChar);
				}
			}

			return resultBuilder.ToString();

			#endregion
		}

		public static string ReplaceLocalCharacters(this string value)
		{
			return value.Translate("ĄąĆćĘęŁłŃńÓóŚśŹźŻż", "AaCcEeLlNnOoSsZzZz");
		}

		public static DateTime? ToDateNullableDateTime(this string dateString, string format, IFormatProvider formatProvider, DateTimeStyles styles)
		{
			DateTime resultDate = DateTime.Now;
			DateTime? result = null;
			if (!String.IsNullOrEmpty(dateString))
			{
				if (DateTime.TryParseExact(dateString, format, formatProvider, styles, out resultDate))
				{
					result = resultDate;
				}
			}

			return result;
		}

		public static string ComputeMD5Hash(this string input)
		{
			using (MD5 md5Hash = MD5.Create())
			{
				// Convert the input string to a byte array and compute the hash.
				byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

				// Create a new Stringbuilder to collect the bytes
				// and create a string.
				StringBuilder sBuilder = new StringBuilder();

				// Loop through each byte of the hashed data 
				// and format each one as a hexadecimal string.
				for (int i = 0; i < data.Length; i++)
				{
					sBuilder.Append(data[i].ToString("x2"));
				}

				// Return the hexadecimal string.
				return sBuilder.ToString();
			}
		}

		public static List<Guid> SplitToGuidList(this string input)
		{
			if (!String.IsNullOrEmpty(input) && !String.IsNullOrEmpty(input.Trim(" ,".ToCharArray())))
				return input.Trim(" ,".ToCharArray()).Split(',').Select(x => new Guid(x.Trim())).ToList();

			return new List<Guid>(0);
		}

		#endregion

		#region bool?

		public static bool ToBoolean(this bool? val)
		{
			return val.HasValue && val.Value;
		}

		#endregion

		#region DateTime



	

		public static string ToIsoString(this DateTime value)
		{
			string str = value.ToString("o", CultureInfo.InvariantCulture);

			if (str.Length > 23)
				str = str.Substring(0, 23);

			return str;
		}

		public static DateTime DayBegining(this DateTime date)
		{
			return new DateTime(date.Year, date.Month, date.Day, 0, 0, 0, 0);
		}

		public static DateTime DayEnd(this DateTime date)
		{
			return new DateTime(date.Year, date.Month, date.Day, 23, 59, 59, 999);
		}

		public static DateTime PreviousWorkDay(this DateTime date)
		{
			TimeSpan threeDays = TimeSpan.FromDays(3);
			TimeSpan twoDays = TimeSpan.FromDays(2);
			TimeSpan oneDay = TimeSpan.FromDays(1);

			DateTime result = DateTime.Now;

			if (date.DayOfWeek == DayOfWeek.Sunday)
			{
				result = date.Subtract(twoDays);
			}
			else if (date.DayOfWeek == DayOfWeek.Monday)
			{
				result = date.Subtract(threeDays);
			}
			else
			{
				result = date.Subtract(oneDay);
			}

			return result;
		}

		public static DateTime FirstDayOfMonth(this DateTime dateTime)
		{
			return new DateTime(dateTime.Year, dateTime.Month, 1);
		}

		public static DateTime LastDayOfMonth(this DateTime dateTime)
		{
			DateTime firstDayOfTheMonth = new DateTime(dateTime.Year, dateTime.Month, 1);
			return firstDayOfTheMonth.AddMonths(1).AddDays(-1);
		}

		/// <summary>
		/// Returns the first day of the week that the specified
		/// date is in using the current culture.
		/// </summary>
		public static DateTime GetFirstDayOfWeek(this DateTime dayInWeek)
		{
			CultureInfo defaultCultureInfo = CultureInfo.CurrentCulture;
			return Extensions.GetFirstDayOfWeek(dayInWeek, defaultCultureInfo);
		}

		/// <summary>
		/// Returns the first day of the week that the specified date
		/// is in.
		/// </summary>
		public static DateTime GetFirstDayOfWeek(DateTime dayInWeek, CultureInfo cultureInfo)
		{
			DayOfWeek firstDay = cultureInfo.DateTimeFormat.FirstDayOfWeek;
			DateTime firstDayInWeek = dayInWeek.Date;
			while (firstDayInWeek.DayOfWeek != firstDay)
				firstDayInWeek = firstDayInWeek.AddDays(-1);

			return firstDayInWeek;
		}

		/// <summary>
		/// Returns the last day of the week that the specified
		/// date is in using the current culture.
		/// </summary>
		public static DateTime GetLastDayOfWeek(this DateTime dayInWeek)
		{
			CultureInfo defaultCultureInfo = CultureInfo.CurrentCulture;
			return Extensions.GetLastDayOfWeek(dayInWeek, defaultCultureInfo);
		}

		/// <summary>
		/// Returns the last day of the week that the specified date
		/// is in.
		/// </summary>
		public static DateTime GetLastDayOfWeek(DateTime dayInWeek, CultureInfo cultureInfo)
		{
			DateTime firstDayOfNextWeek = Extensions.GetFirstDayOfWeek(dayInWeek.AddDays(7), cultureInfo);
			return firstDayOfNextWeek.AddDays(-1);
		}

		#endregion

		#region Enums



		#endregion

		#region Int32

		public static string ToStringInvariant(this Int32 number)
		{
			return number.ToString(CultureInfo.InvariantCulture);
		}

		#endregion

        #region Stream

        public static byte[] ToByteArray(this Stream stream)
        {
            byte[] byteArray = null;

            if (stream is MemoryStream)
            {
                byteArray = (stream as MemoryStream).ToArray();
            }
            else if (stream.CanSeek)
            {
                int position = 0;
                int bytesToRead = 0;
                int chunk = 1024;
                byteArray = new byte[stream.Length];

                while (position < stream.Length)
                {
                    bytesToRead = (stream.Length - position < chunk) ? (int)stream.Length - position : chunk;
                    position += stream.Read(byteArray, position, bytesToRead);
                }
            }
            else
            {
                var bytes = new List<byte>();
                int i = -1;

                while ((i = stream.ReadByte()) != -1) bytes.Add((byte)i);

                byteArray = bytes.ToArray();
            }
            return byteArray;
        }

        #endregion

		#region byte[]

		public static byte[] ToMicrosoftGuidByteArray(this byte[] array)
		{
			array.Swap(0, 3);
			array.Swap(1, 2);
			array.Swap(4, 5);
			array.Swap(6, 7);
			//Oracle { 3, 2, 1, 0, 5, 4, 7, 6, 8, 9, 10, 11, 12, 13, 14, 15 };
			return array;
		}

		public static void Swap(this byte[] array, int i1, int i2)
		{
			byte temp = array[i1];
			array[i1] = array[i2];
			array[i2] = temp;
		}
		#endregion
	}   
}
