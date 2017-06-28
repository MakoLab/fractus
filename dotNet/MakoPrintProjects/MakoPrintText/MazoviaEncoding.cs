using System.Collections.Generic;

namespace System.Text
{
    /// <summary>
    /// Represents Mazovia encoding of Unicode characters.
    /// </summary>
    /// <remarks>
    /// If You wander why MazoviaEncoding does not inherits from Encoding instead of ASCIIEncoding, 
    /// it's because SerialPort class accepts only few fixed encodings and ASCIIEncoding is one of them.
    /// So if you want to use your custom encoding class with SerialPort it has to inherit from one of fixed encoding classes.
    /// </remarks>
    public class MazoviaEncoding : ASCIIEncoding
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="MazoviaEncoding"/> class.
        /// </summary>
        private MazoviaEncoding()
        {
        }

        private static MazoviaEncoding _encoding;
        /// <summary>
        /// Gets instance of <see cref="MazoviaEncoding"/> class.
        /// </summary>
        /// <value>The <see cref="MazoviaEncoding"/> object.</value>
        public static Encoding Mazovia
        {
            get
            {
                if (_encoding == null)
                {
                    _encoding = new MazoviaEncoding();
                }
                return _encoding;
            }
        }

        /// <summary>
        /// Encodes all the characters in the specified <see cref="T:System.String"/> into a sequence of bytes.
        /// </summary>
        /// <param name="s">String that is encoded.</param>
        /// <returns>
        /// A byte array containing the results of encoding the specified set of characters.
        /// </returns>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="s"/> is null. </exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">A fallback occurred (see Understanding Encodings for complete explanation)-and-<see cref="P:System.Text.Encoding.EncoderFallback"/> is set to <see cref="T:System.Text.EncoderExceptionFallback"/>.</exception>
        public override byte[] GetBytes(string s)
        {
            List<byte> data = new List<byte>();
            foreach (char c in s)
            {
                data.Add(CharToByte(c));
            }
            return data.ToArray();
        }

        /// <summary>
        /// Decodes a sequence of bytes from the specified byte array into a string.
        /// </summary>
        /// <param name="bytes">The byte array containing the sequence of bytes to decode.</param>
        /// <param name="index">The index of the first byte to decode.</param>
        /// <param name="count">The number of bytes to decode.</param>
        /// <returns>
        /// A <see cref="T:System.String"/> containing the results of decoding the specified sequence of bytes.
        /// </returns>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="bytes"/> is null. </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="index"/> or <paramref name="count"/> is less than zero.-or- <paramref name="index"/> and <paramref name="count"/> do not denote a valid range in <paramref name="bytes"/>. </exception>
        /// <exception cref="T:System.Text.DecoderFallbackException">A fallback occurred (see Understanding Encodings for complete explanation)-and-<see cref="P:System.Text.Encoding.DecoderFallback"/> is set to <see cref="T:System.Text.DecoderExceptionFallback"/>.</exception>
        public override string GetString(byte[] bytes, int index, int count)
        {
            if (bytes == null) throw new ArgumentNullException("bytes");

            if (index < 0 || index + count > bytes.Length)
            {
                throw new IndexOutOfRangeException();
            }

            StringBuilder sb = new StringBuilder();
            for (int i = index; i < index + count; i++)
            {
                if (bytes[i] == 0)
                {
                    break;
                }
                sb.Append(ByteToChar(bytes[i]));
            }
            return sb.ToString();
        }

        /// <summary>
        /// Returns the byte that represents specified char.
        /// </summary>
        /// <param name="c">The char.</param>
        /// <returns>Byte represents specified char.</returns>
        private static byte CharToByte(char c)
        {
            byte b = (byte)'?';
            switch ((int)c)
            {
                case 0x105: // ą
                    b = (byte)0x86;
                    break;
                case 0x104: // Ą
                    b = (byte)0x8F;
                    break;

                case 0x107: // ć
                    b = (byte)0x8D;
                    break;
                case 0x106: // Ć
                    b = (byte)0x95;
                    break;

                case 0x119: // ę
                    b = (byte)0x91;
                    break;
                case 0x118: // Ę
                    b = (byte)0x90;
                    break;

                case 0x142: // ł
                    b = (byte)0x92;
                    break;
                case 0x141: // Ł
                    b = (byte)0x9C;
                    break;

                case 0x15B: // ś
                    b = (byte)0x9E;
                    break;
                case 0x15A: // Ś
                    b = (byte)0x98;
                    break;

                case 0xF3: // ó
                    b = (byte)0xA2;
                    break;
                case 0xD3: // Ó
                    b = (byte)0xA3;
                    break;

                case 0x144: // ń
                    b = (byte)0xA4;
                    break;
                case 0x143: // Ń
                    b = (byte)0xA5;
                    break;

                case 0x17A: // ź
                    b = (byte)0xA6;
                    break;
                case 0x179: // Ź
                    b = (byte)0xA0;
                    break;

                case 0x17C: // ż
                    b = (byte)0xA7;
                    break;
                case 0x17B: // Ż
                    b = (byte)0xA1;
                    break;
                default:
                    b = (byte)c;
                    break;
            };
            return b;
        }

        /// <summary>
        /// Returns the char that is represented by specified byte.
        /// </summary>
        /// <param name="b">The byte.</param>
        /// <returns>Char that is represented by specified byte.</returns>
        private static char ByteToChar(byte b)
        {
            char c = '?';
            switch ((int)b)
            {
                case 0x86: // ą
                    c = (char)0x105;
                    break;
                case 0x8F: // Ą
                    c = (char)0x104;
                    break;

                case 0x8D: // ć
                    c = (char)0x107;
                    break;
                case 0x95: // Ć
                    c = (char)0x106;
                    break;

                case 0x91: // ę
                    c = (char)0x119;
                    break;
                case 0x90: // Ę
                    c = (char)0x118;
                    break;

                case 0x92: // ł
                    c = (char)0x142;
                    break;
                case 0x9C: // Ł
                    c = (char)0x141;
                    break;

                case 0x9E: // ś
                    c = (char)0x15B;
                    break;
                case 0x98: // Ś
                    c = (char)0x15A;
                    break;

                case 0xA2: // ó
                    c = (char)0xF3;
                    break;
                case 0xA3: // Ó
                    c = (char)0xD3;
                    break;

                case 0xA4: // ń
                    c = (char)0x144;
                    break;
                case 0xA5: // Ń
                    c = (char)0x143;
                    break;

                case 0xA6: // ź
                    c = (char)0x17A;
                    break;
                case 0xA0: // Ź
                    c = (char)0x179;
                    break;

                case 0xA7: // ż
                    c = (char)0x17C;
                    break;
                case 0xA1: // Ż
                    c = (char)0x17B;
                    break;
                default:
                    c = (char)b;
                    break;
            };
            return c;
        }

        /// <summary>
        /// Calculates the number of bytes produced by encoding a set of characters from the specified character array.
        /// </summary>
        /// <param name="chars">The character array containing the set of characters to encode.</param>
        /// <param name="index">The index of the first character to encode.</param>
        /// <param name="count">The number of characters to encode.</param>
        /// <returns>
        /// The number of bytes produced by encoding the specified characters.
        /// </returns>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="chars"/> is null. </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="index"/> or <paramref name="count"/> is less than zero.-or- <paramref name="index"/> and <paramref name="count"/> do not denote a valid range in <paramref name="chars"/>.-or- The resulting number of bytes is greater than the maximum number that can be returned as an integer. </exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">A fallback occurred (see Understanding Encodings for complete explanation)-and-<see cref="P:System.Text.Encoding.EncoderFallback"/> is set to <see cref="T:System.Text.EncoderExceptionFallback"/>.</exception>
        public override int GetByteCount(char[] chars, int index, int count)
        {
            return count;
        }

        /// <summary>
        /// Encodes a set of characters from the specified character array into the specified byte array.
        /// </summary>
        /// <param name="chars">The character array containing the set of characters to encode.</param>
        /// <param name="charIndex">The index of the first character to encode.</param>
        /// <param name="charCount">The number of characters to encode.</param>
        /// <param name="bytes">The byte array to contain the resulting sequence of bytes.</param>
        /// <param name="byteIndex">The index at which to start writing the resulting sequence of bytes.</param>
        /// <returns>
        /// The actual number of bytes written into <paramref name="bytes"/>.
        /// </returns>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="chars"/> is null.-or- <paramref name="bytes"/> is null. </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="charIndex"/> or <paramref name="charCount"/> or <paramref name="byteIndex"/> is less than zero.-or- <paramref name="charIndex"/> and <paramref name="charCount"/> do not denote a valid range in <paramref name="chars"/>.-or- <paramref name="byteIndex"/> is not a valid index in <paramref name="bytes"/>. </exception>
        /// <exception cref="T:System.ArgumentException">
        /// 	<paramref name="bytes"/> does not have enough capacity from <paramref name="byteIndex"/> to the end of the array to accommodate the resulting bytes. </exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">A fallback occurred (see Understanding Encodings for complete explanation)-and-<see cref="P:System.Text.Encoding.EncoderFallback"/> is set to <see cref="T:System.Text.EncoderExceptionFallback"/>.</exception>
        public override int GetBytes(char[] chars, int charIndex, int charCount, byte[] bytes, int byteIndex)
        {
            if (bytes == null) throw new ArgumentNullException("bytes");
            if (chars == null) throw new ArgumentNullException("chars");

            if (charIndex < 0 || charIndex + charCount > chars.Length)
            {
                throw new IndexOutOfRangeException();
            }

            if (byteIndex < 0 || byteIndex + charCount > bytes.Length)
            {
                throw new IndexOutOfRangeException();
            }

            for (int i = 0; i < charCount; i++)
            {
                bytes[byteIndex + i] = CharToByte(chars[charIndex + i]);
            }

            return charCount;
        }

        /// <summary>
        /// Calculates the number of characters produced by decoding a sequence of bytes from the specified byte array.
        /// </summary>
        /// <param name="bytes">The byte array containing the sequence of bytes to decode.</param>
        /// <param name="index">The index of the first byte to decode.</param>
        /// <param name="count">The number of bytes to decode.</param>
        /// <returns>
        /// The number of characters produced by decoding the specified sequence of bytes.
        /// </returns>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="bytes"/> is null. </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="index"/> or <paramref name="count"/> is less than zero.-or- <paramref name="index"/> and <paramref name="count"/> do not denote a valid range in <paramref name="bytes"/>.-or- The resulting number of bytes is greater than the maximum number that can be returned as an integer. </exception>
        /// <exception cref="T:System.Text.DecoderFallbackException">A fallback occurred (see Understanding Encodings for complete explanation)-and-<see cref="P:System.Text.Encoding.DecoderFallback"/> is set to <see cref="T:System.Text.DecoderExceptionFallback"/>.</exception>
        public override int GetCharCount(byte[] bytes, int index, int count)
        {
            return count;
        }

        /// <summary>
        /// Decodes a sequence of bytes from the specified byte array into the specified character array.
        /// </summary>
        /// <param name="bytes">The byte array containing the sequence of bytes to decode.</param>
        /// <param name="byteIndex">The index of the first byte to decode.</param>
        /// <param name="byteCount">The number of bytes to decode.</param>
        /// <param name="chars">The character array to contain the resulting set of characters.</param>
        /// <param name="charIndex">The index at which to start writing the resulting set of characters.</param>
        /// <returns>
        /// The actual number of characters written into <paramref name="chars"/>.
        /// </returns>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="bytes"/> is null.-or- <paramref name="chars"/> is null. </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="byteIndex"/> or <paramref name="byteCount"/> or <paramref name="charIndex"/> is less than zero.-or- <paramref name="byteindex"/> and <paramref name="byteCount"/> do not denote a valid range in <paramref name="bytes"/>.-or- <paramref name="charIndex"/> is not a valid index in <paramref name="chars"/>. </exception>
        /// <exception cref="T:System.ArgumentException">
        /// 	<paramref name="chars"/> does not have enough capacity from <paramref name="charIndex"/> to the end of the array to accommodate the resulting characters. </exception>
        /// <exception cref="T:System.Text.DecoderFallbackException">A fallback occurred (see Understanding Encodings for complete explanation)-and-<see cref="P:System.Text.Encoding.DecoderFallback"/> is set to <see cref="T:System.Text.DecoderExceptionFallback"/>.</exception>
        public override int GetChars(byte[] bytes, int byteIndex, int byteCount, char[] chars, int charIndex)
        {
            if (bytes == null) throw new ArgumentNullException("bytes");
            if (chars == null) throw new ArgumentNullException("chars");

            if (byteIndex < 0 || byteIndex + byteCount > bytes.Length)
            {
                throw new IndexOutOfRangeException();
            }

            if (charIndex < 0 || charIndex + byteCount > chars.Length)
            {
                throw new IndexOutOfRangeException();
            }

            for (int i = 0; i < byteCount; i++)
            {
                chars[charIndex + i] = ByteToChar(bytes[byteIndex + i]);
            }

            return byteCount;
        }

        /// <summary>
        /// Calculates the maximum number of bytes produced by encoding the specified number of characters.
        /// </summary>
        /// <param name="charCount">The number of characters to encode.</param>
        /// <returns>
        /// The maximum number of bytes produced by encoding the specified number of characters.
        /// </returns>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="charCount"/> is less than zero.-or- The resulting number of bytes is greater than the maximum number that can be returned as an integer. </exception>
        public override int GetMaxByteCount(int charCount)
        {
            return charCount;
        }

        /// <summary>
        /// Calculates the maximum number of characters produced by decoding the specified number of bytes.
        /// </summary>
        /// <param name="byteCount">The number of bytes to decode.</param>
        /// <returns>
        /// The maximum number of characters produced by decoding the specified number of bytes.
        /// </returns>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="byteCount"/> is less than zero.-or- The resulting number of bytes is greater than the maximum number that can be returned as an integer. </exception>
        public override int GetMaxCharCount(int byteCount)
        {
            return byteCount;
        }

        /// <summary>
        /// Gets the code page identifier of the current <see cref="T:System.Text.Encoding"/>.
        /// </summary>
        /// <value></value>
        /// <returns>The code page identifier of the current <see cref="T:System.Text.Encoding"/>.</returns>
        public override int CodePage
        {
            get
            {
                return 790;
            }
        }

        /// <summary>
        /// Gets the Windows operating system code page that most closely corresponds to the current encoding.
        /// </summary>
        /// <value></value>
        /// <returns>The Windows operating system code page that most closely corresponds to the current <see cref="T:System.Text.Encoding"/>.</returns>
        public override int WindowsCodePage
        {
            get
            {
                return 790;
            }
        }

        public override string EncodingName
        {
            get
            {
                return "mazovia";
            }
        }

        public override string WebName
        {
            get
            {
                return "mazovia";
            }
        }

        public new static Encoding GetEncoding(string name)
        { 
            if (name.Equals("mazovia", StringComparison.OrdinalIgnoreCase)) return MazoviaEncoding.Mazovia;
            else return Encoding.GetEncoding(name);
        }
    }
}
