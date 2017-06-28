using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace zzTest
{
    public class MazoviaEncoding : ASCIIEncoding
    {
        private MazoviaEncoding()
        {
        }

        private static MazoviaEncoding _encoding = null;
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

        public override byte[] GetBytes(string s)
        {
            List<byte> data = new List<byte>();
            foreach (char c in s)
            {
                data.Add(CharToByte(c));
            }
            return data.ToArray();
        }

        public override string GetString(byte[] bytes, int index, int count)
        {
            if (bytes == null)
            {
                throw new NullReferenceException();
            }

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

        private byte CharToByte(char c)
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

        private char ByteToChar(byte b)
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

        public override int GetByteCount(char[] chars, int index, int count)
        {
            return count;
        }

        public override int GetBytes(char[] chars, int charIndex, int charCount, byte[] bytes, int byteIndex)
        {
            if (bytes == null || chars == null)
            {
                throw new NullReferenceException();
            }

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

        public override int GetCharCount(byte[] bytes, int index, int count)
        {
            return count;
        }

        public override int GetChars(byte[] bytes, int byteIndex, int byteCount, char[] chars, int charIndex)
        {
            if (bytes == null || chars == null)
            {
                throw new NullReferenceException();
            }

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

        public override int GetMaxByteCount(int charCount)
        {
            return charCount;
        }

        public override int GetMaxCharCount(int byteCount)
        {
            return byteCount;
        }

        public override int CodePage
        {
            get
            {
                return 790;
            }
        }

        public override int WindowsCodePage
        {
            get
            {
                return 790;
            }
        }
    }
}
