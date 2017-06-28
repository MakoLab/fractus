using System;
using System.IO.Ports;

namespace Makolab.Printing.Fiscal
{
    /// <summary>
    /// 
    /// </summary>
    public class SerialPortHelper
    {
        private const int DEFAULT_TIMEOUT = 5000;

        /// <summary>
        /// Reads from the specified port until specified character occurs.
        /// </summary>
        /// <param name="port">The port.</param>
        /// <param name="terminatingCharacter">The character that stops read operation.</param>
        /// <returns>Data read from port.</returns>
        public static string ReadUntil(SerialPort port, string terminatingCharacter)
        {
            return ReadUntil(port, terminatingCharacter, DEFAULT_TIMEOUT);
        }

        /// <summary>
        /// Reads from the specified port until specified character occurs.
        /// </summary>
        /// <param name="port">The port.</param>
        /// <param name="terminatingCharacter">The character that stops read operation.</param>
        /// <param name="timeoutInMilliseconds">The timeout in milliseconds.</param>
        /// <returns>Data read from port.</returns>
        public static string ReadUntil(SerialPort port, string terminatingCharacter, int timeoutInMilliseconds)
        {
            string buffer = null;
            bool endOfData = false;
            int loopNr = 0;
            int maxLoops;

            string orgNewLine = port.NewLine;
            int orgTimeout = port.ReadTimeout;
            port.NewLine = terminatingCharacter;
            port.ReadTimeout = 1000;
            maxLoops = (timeoutInMilliseconds / port.ReadTimeout) + ((timeoutInMilliseconds % port.ReadTimeout) == 0 ? 0 : 1);
            while (!endOfData)
            {
                try
                {
                    buffer = port.ReadLine();
                    endOfData = true;
                }
                catch (TimeoutException)
                {
                    ++loopNr;
                    if (loopNr >= maxLoops) throw;
                }
            }

            port.ReadTimeout = orgTimeout;
            port.NewLine = orgNewLine;
            return buffer;
        }
    }
}
