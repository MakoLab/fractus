using System;
using System.IO;
using System.Text;

namespace Makolab.RestUpload
{
    /// <summary>
    /// Stream that can extract files from the http request stream.
    /// </summary>
    public class HttpUploadStream : Stream
    {
        private MemoryStream ms;
        private Encoding encoding;
        
        /// <summary>
        /// Gets the value that indicates whether <see cref="Dispose(bool)"/> has been called.
        /// </summary>
        protected bool IsDisposed { get; set; }

        /// <summary>
        /// Gets a value indicating whether this end of stream was reached.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if end of stream was reached; otherwise, <c>false</c>.
        /// </value>
        public bool IsEndOfStream
        { get { return this.Position == this.Length; } }

        /// <summary>
        /// Initializes a new instance of the <see cref="HttpUploadStream"/> class.
        /// </summary>
        /// <param name="stream">The current stream.</param>
        /// <param name="encoding">The encoding for text reading.</param>
        public HttpUploadStream(Stream stream, Encoding encoding)
        {
            this.ms = new MemoryStream();
            int i = -1;

            while ((i = stream.ReadByte()) != -1)
            {
                this.ms.WriteByte((byte)i);
            }

            this.ms.Position = 0;
            this.encoding = encoding;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="HttpUploadStream"/> class.
        /// </summary>
        /// <param name="data">The request body.</param>
        /// <param name="encoding">The encoding for text reading.</param>
        public HttpUploadStream(byte[] data, Encoding encoding)
        {
            this.ms = new MemoryStream(data);
            this.ms.Position = 0;
            this.encoding = encoding;
        }

        /// <summary>
        /// Reads the line from the stream.
        /// </summary>
        /// <returns>Read line if found; otherwise <c>null</c>.</returns>
        public string ReadLine()
        {
            long currentPos = this.Position;
            long startingPos = currentPos;
            bool wasNewline = false;

            int ch = -1;

            while (this.Position < this.Length)
            {
                ch = this.ReadByte();

                if (ch == 13 || ch == 10 || this.Position == this.Length)
                {
                    if (ch == 13 || ch == 10)
                        wasNewline = true;

                    currentPos = this.Position;
                    break;
                }
            }

            this.Position = startingPos;

            if (currentPos == startingPos || (this.Position + 1 == this.Length && (ch == 10 || ch == 13)))
                return null;

            if (wasNewline)
                currentPos--;

            byte[] buffer = new byte[currentPos - startingPos];

            this.Read(buffer, 0, buffer.Length);
            this.SkipNewLine();

            return this.encoding.GetString(buffer);
        }
        
        /// <summary>
        /// Reads the file data.
        /// </summary>
        /// <param name="token">The token for the data.</param>
        /// <returns></returns>
        public byte[] ReadFileData(string token)
        {
            long startingPos = this.Position;

            byte[] delimiterBytes = this.encoding.GetBytes(token);

            int endPos = HttpUploadStream.FindToken(this.ms.ToArray(), delimiterBytes, (int)startingPos);
            
            int filesize = endPos - (int)startingPos;

            if (filesize > 0)
            {
                byte[] fileData = new byte[filesize];

                this.Position = startingPos;
                this.Read(fileData, 0, fileData.Length);

                return fileData;
            }
            else
                return null;
        }

        private static int FindToken(byte[] array, byte[] token, int arrayOffset)
        {
            if (array == null)
                throw new ArgumentNullException("array", "Value cannot be null.");

            if (token == null)
                throw new ArgumentNullException("token", "Value cannot be null.");

            for (int i = arrayOffset; i < array.Length; i++)
            {
                if (HttpUploadStream.CompareArray(array, token, i, 0, token.Length))
                    return i - 2; //2 bytes for newline
            }

            return -1;
        }

        /// <summary>
        /// Compares the array.
        /// </summary>
        /// <param name="first">The first array to compare.</param>
        /// <param name="second">The second array to compare.</param>
        /// <param name="firstStartPos">Starting position in the first array.</param>
        /// <param name="secondStartPos">Starting position in the second array.</param>
        /// <param name="length">Max chars to compare from both arrays.</param>
        /// <returns><c>true</c> if arrays are the same; otherwise <c>false</c>.</returns>
        private static bool CompareArray(byte[] first, byte[] second, int firstStartPos, int secondStartPos, int length)
        {
            if (first == null)
                throw new ArgumentNullException("first", "Value cannot be null.");

            if (second == null)
                throw new ArgumentNullException("second", "Value cannot be null.");

            int i = firstStartPos;

            while ((i - firstStartPos) < length && i < first.Length && (i - firstStartPos + secondStartPos) < second.Length)
            {
                if (first[i] != second[i - firstStartPos])
                    return false;
                else
                    i++;
            }

            return true;
        }

        /// <summary>
        /// Skips new line chars and sets the position to the next line.
        /// </summary>
        private void SkipNewLine()
        {
            bool read = false;

            while (this.Position < this.Length)
            {
                int ch = this.ReadByte();

                read = true;

                if (ch != 13 && ch != 10)
                    break;
            }

            if (read)
                this.Position = this.Position - 1;
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="T:System.IO.Stream"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing">true to release both managed and unmanaged resources; false to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (!this.IsDisposed)
            {
                if (disposing)
                {
                    //Dispose only managed resources here
                    if (this.ms != null)
                        this.ms.Dispose();
                }
            }
            // Code to dispose the unmanaged resources 
            // held by the class
            this.IsDisposed = true;
        }

        #region Stream class properties and methods
        /// <summary>
        /// When overridden in a derived class, gets a value indicating whether the current stream supports reading.
        /// </summary>
        /// <value></value>
        /// <returns>true if the stream supports reading; otherwise, false.
        /// </returns>
        public override bool CanRead
        {
            get { return this.ms.CanRead; }
        }

        /// <summary>
        /// When overridden in a derived class, gets a value indicating whether the current stream supports seeking.
        /// </summary>
        /// <value></value>
        /// <returns>true if the stream supports seeking; otherwise, false.
        /// </returns>
        public override bool CanSeek
        {
            get { return this.ms.CanSeek; }
        }

        /// <summary>
        /// When overridden in a derived class, gets a value indicating whether the current stream supports writing.
        /// </summary>
        /// <value></value>
        /// <returns>true if the stream supports writing; otherwise, false.
        /// </returns>
        public override bool CanWrite
        {
            get { return this.ms.CanWrite; }
        }

        /// <summary>
        /// When overridden in a derived class, gets the length in bytes of the stream.
        /// </summary>
        /// <value></value>
        /// <returns>
        /// A long value representing the length of the stream in bytes.
        /// </returns>
        /// <exception cref="T:System.NotSupportedException">
        /// A class derived from Stream does not support seeking.
        /// </exception>
        /// <exception cref="T:System.ObjectDisposedException">
        /// Methods were called after the stream was closed.
        /// </exception>
        public override long Length
        {
            get { return this.ms.Length; }
        }

        /// <summary>
        /// When overridden in a derived class, gets or sets the position within the current stream.
        /// </summary>
        /// <value></value>
        /// <returns>
        /// The current position within the stream.
        /// </returns>
        /// <exception cref="T:System.IO.IOException">
        /// An I/O error occurs.
        /// </exception>
        /// <exception cref="T:System.NotSupportedException">
        /// The stream does not support seeking.
        /// </exception>
        /// <exception cref="T:System.ObjectDisposedException">
        /// Methods were called after the stream was closed.
        /// </exception>
        public override long Position
        {
            get { return this.ms.Position; }
            set { this.ms.Position = value; }
        }

        /// <summary>
        /// When overridden in a derived class, clears all buffers for this stream and causes any buffered data to be written to the underlying device.
        /// </summary>
        /// <exception cref="T:System.IO.IOException">
        /// An I/O error occurs.
        /// </exception>
        public override void Flush()
        {
            this.ms.Flush();
        }

        /// <summary>
        /// When overridden in a derived class, reads a sequence of bytes from the current stream and advances the position within the stream by the number of bytes read.
        /// </summary>
        /// <param name="buffer">An array of bytes. When this method returns, the buffer contains the specified byte array with the values between <paramref name="offset"/> and (<paramref name="offset"/> + <paramref name="count"/> - 1) replaced by the bytes read from the current source.</param>
        /// <param name="offset">The zero-based byte offset in <paramref name="buffer"/> at which to begin storing the data read from the current stream.</param>
        /// <param name="count">The maximum number of bytes to be read from the current stream.</param>
        /// <returns>
        /// The total number of bytes read into the buffer. This can be less than the number of bytes requested if that many bytes are not currently available, or zero (0) if the end of the stream has been reached.
        /// </returns>
        /// <exception cref="T:System.ArgumentException">
        /// The sum of <paramref name="offset"/> and <paramref name="count"/> is larger than the buffer length.
        /// </exception>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="buffer"/> is null.
        /// </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="offset"/> or <paramref name="count"/> is negative.
        /// </exception>
        /// <exception cref="T:System.IO.IOException">
        /// An I/O error occurs.
        /// </exception>
        /// <exception cref="T:System.NotSupportedException">
        /// The stream does not support reading.
        /// </exception>
        /// <exception cref="T:System.ObjectDisposedException">
        /// Methods were called after the stream was closed.
        /// </exception>
        public override int Read(byte[] buffer, int offset, int count)
        {
            return this.ms.Read(buffer, offset, count);
        }

        /// <summary>
        /// When overridden in a derived class, sets the position within the current stream.
        /// </summary>
        /// <param name="offset">A byte offset relative to the <paramref name="origin"/> parameter.</param>
        /// <param name="origin">A value of type <see cref="T:System.IO.SeekOrigin"/> indicating the reference point used to obtain the new position.</param>
        /// <returns>
        /// The new position within the current stream.
        /// </returns>
        /// <exception cref="T:System.IO.IOException">
        /// An I/O error occurs.
        /// </exception>
        /// <exception cref="T:System.NotSupportedException">
        /// The stream does not support seeking, such as if the stream is constructed from a pipe or console output.
        /// </exception>
        /// <exception cref="T:System.ObjectDisposedException">
        /// Methods were called after the stream was closed.
        /// </exception>
        public override long Seek(long offset, SeekOrigin origin)
        {
            return this.ms.Seek(offset, origin);
        }

        /// <summary>
        /// When overridden in a derived class, sets the length of the current stream.
        /// </summary>
        /// <param name="value">The desired length of the current stream in bytes.</param>
        /// <exception cref="T:System.IO.IOException">
        /// An I/O error occurs.
        /// </exception>
        /// <exception cref="T:System.NotSupportedException">
        /// The stream does not support both writing and seeking, such as if the stream is constructed from a pipe or console output.
        /// </exception>
        /// <exception cref="T:System.ObjectDisposedException">
        /// Methods were called after the stream was closed.
        /// </exception>
        public override void SetLength(long value)
        {
            this.ms.SetLength(value);
        }

        /// <summary>
        /// When overridden in a derived class, writes a sequence of bytes to the current stream and advances the current position within this stream by the number of bytes written.
        /// </summary>
        /// <param name="buffer">An array of bytes. This method copies <paramref name="count"/> bytes from <paramref name="buffer"/> to the current stream.</param>
        /// <param name="offset">The zero-based byte offset in <paramref name="buffer"/> at which to begin copying bytes to the current stream.</param>
        /// <param name="count">The number of bytes to be written to the current stream.</param>
        /// <exception cref="T:System.ArgumentException">
        /// The sum of <paramref name="offset"/> and <paramref name="count"/> is greater than the buffer length.
        /// </exception>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="buffer"/> is null.
        /// </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException">
        /// 	<paramref name="offset"/> or <paramref name="count"/> is negative.
        /// </exception>
        /// <exception cref="T:System.IO.IOException">
        /// An I/O error occurs.
        /// </exception>
        /// <exception cref="T:System.NotSupportedException">
        /// The stream does not support writing.
        /// </exception>
        /// <exception cref="T:System.ObjectDisposedException">
        /// Methods were called after the stream was closed.
        /// </exception>
        public override void Write(byte[] buffer, int offset, int count)
        {
            this.ms.Write(buffer, offset, count);
        }
        #endregion
    }
}
