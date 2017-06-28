using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace FractusDesktop
{
    internal static class CryptoUtils
    {
        public static string PasswordFractus = "Mako3labFractus2";
        public static string PasswordSite = "3MakolabFractus2";

        public static string Encrypt(string password, string dataToEncrypt)
        {
            byte[] key = Encoding.UTF8.GetBytes(password);
            // Initialise
            RijndaelManaged encryptor = new RijndaelManaged();
            encryptor.KeySize = 128;
            // Set the key
            encryptor.Key = key;
            encryptor.IV = key;

            // create a memory stream
            using (MemoryStream encryptionStream = new MemoryStream())
            {
                // Create the crypto stream
                using (CryptoStream encrypt = new CryptoStream(encryptionStream, encryptor.CreateEncryptor(), CryptoStreamMode.Write))
                {
                    // Encrypt
                    byte[] utfD1 = UTF8Encoding.UTF8.GetBytes(dataToEncrypt);
                    encrypt.Write(utfD1, 0, utfD1.Length);
                    encrypt.FlushFinalBlock();
                    encrypt.Close();

                    // Return the encrypted data
                    return BitConverter.ToString(encryptionStream.ToArray());
                }
            }
        }

        private static byte[] ReverseBitConversion(string data)
        {
            string[] splittedData = data.Split(new char[] { '-' });

            byte[] result = new byte[splittedData.Length];

            for (int i = 0; i < splittedData.Length; i++)
            {
                result[i] = (byte)Convert.ToInt32(splittedData[i], 16);
            }

            return result;
        }

        public static string Decrypt(string password, string encryptedString)
        {
            byte[] key = Encoding.UTF8.GetBytes(password);
            // Initialise
            RijndaelManaged decryptor = new RijndaelManaged();
            decryptor.KeySize = 128;
            byte[] encryptedData = ReverseBitConversion(encryptedString);

            // Set the key
            decryptor.Key = key;
            decryptor.IV = key;

            // create a memory stream
            using (MemoryStream decryptionStream = new MemoryStream())
            {
                // Create the crypto stream
                using (CryptoStream decrypt = new CryptoStream(decryptionStream, decryptor.CreateDecryptor(), CryptoStreamMode.Write))
                {
                    // Encrypt
                    decrypt.Write(encryptedData, 0, encryptedData.Length);
                    decrypt.Flush();
                    decrypt.Close();

                    // Return the unencrypted data
                    byte[] decryptedData = decryptionStream.ToArray();
                    return UTF8Encoding.UTF8.GetString(decryptedData, 0, decryptedData.Length);
                }
            }
        }
    }
}
