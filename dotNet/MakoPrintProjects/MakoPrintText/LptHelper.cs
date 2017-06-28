using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;

namespace Makolab.Printing.Text
{
    public static class LptHelper
    {
        public const short FILE_ATTRIBUTE_NORMAL = 0x80;
        public const short INVALID_HANDLE_VALUE = -1;

        [CLSCompliantAttribute(false)]
        public const uint GENERIC_READ = 0x80000000;
        [CLSCompliantAttribute(false)]
        public const uint GENERIC_WRITE = 0x40000000;
        [CLSCompliantAttribute(false)]
        public const uint CREATE_NEW = 1;
        [CLSCompliantAttribute(false)]
        public const uint CREATE_ALWAYS = 2;
        [CLSCompliantAttribute(false)]
        public const uint OPEN_EXISTING = 3;

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr CreateFile(string lpFileName, uint dwDesiredAccess,
            uint dwShareMode, IntPtr lpSecurityAttributes, uint dwCreationDisposition,
            uint dwFlagsAndAttributes, IntPtr hTemplateFile);


        public static void LptPrint(String portName, String receiptText, String textEncoding)
        {
            IntPtr ptr = CreateFile(portName, GENERIC_WRITE, 0, IntPtr.Zero, OPEN_EXISTING, 0, IntPtr.Zero);
            
            if (ptr.ToInt32() == -1)
            {
                int errorCode = Marshal.GetHRForLastWin32Error();

                if ((errorCode == -2147024894) || (errorCode == -2147023888))
                {
                    throw new TextPrinterException(TextExceptionId.PortNameError);
                }
                else
                {
                    Marshal.ThrowExceptionForHR(Marshal.GetHRForLastWin32Error());
                }
            }
            else
            {
                // musi być true bo inaczej drukuje wszystko oprócz ostatniej linii i dzieją się dziwne rzeczy
                Microsoft.Win32.SafeHandles.SafeFileHandle sfh = new Microsoft.Win32.SafeHandles.SafeFileHandle(ptr, true);
                FileStream lpt = new FileStream(sfh, FileAccess.ReadWrite);


                Byte[] buffer = new Byte[4096];

                buffer = (MazoviaEncoding.GetEncoding(textEncoding)).GetBytes(receiptText);
                  
                lpt.Write(buffer, 0, buffer.Length);
                lpt.Close();
            }
        }
    


    }
}
