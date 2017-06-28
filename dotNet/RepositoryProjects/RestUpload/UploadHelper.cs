using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Makolab.RestUpload
{
    /// <summary>
    /// Main class containing methods for handling http uploads.
    /// </summary>
    public static class UploadHelper
    {
        /// <summary>
        /// Extracts files from the http request stream.
        /// </summary>
        /// <param name="input">Binary data from request (body).</param>
        /// <returns>Collection of uploaded files.</returns>
        public static ICollection<UploadedFile> ExtractFiles(byte[] input)
        {
            using (HttpUploadStream stream = new HttpUploadStream(input, Encoding.UTF8))
            {
                return ParseStream(stream);
            }
        }

        /// <summary>
        /// Extracts files from the http request stream.
        /// </summary>
        /// <param name="input">Http request stream (body).</param>
        /// <returns>Collection of uploaded files.</returns>
        public static ICollection<UploadedFile> ExtractFiles(Stream input)
        {
            using (HttpUploadStream stream = new HttpUploadStream(input, Encoding.UTF8))
            {
                return ParseStream(stream);
            }
        }

        private static ICollection<UploadedFile> ParseStream(HttpUploadStream stream)
        {
            List<UploadedFile> files = new List<UploadedFile>();

            string token = stream.ReadLine();
            string endToken = token + "--";

            stream.Position = 0;

            bool wasContentDisposition = false;
            bool wasContentType = false;
            bool wasToken = false;
            string filename = null;
            byte[] fileData = null;

            while (!stream.IsEndOfStream)
            {
                if (!wasContentType || !wasContentDisposition || !wasToken) //process headers
                {
                    string line = stream.ReadLine();

                    if (line == null || line == endToken)
                        break;
                    else if (line == token)
                        wasToken = true;
                    else if (line.StartsWith("Content-Disposition", StringComparison.Ordinal))
                    {
                        wasContentDisposition = true;
                        int fIndex = line.IndexOf("filename=\"", StringComparison.Ordinal);

                        if (fIndex >= 0)
                            filename = line.Substring(fIndex + 10, line.IndexOf('\"', fIndex + 10) - fIndex - 10);
                    }
                    else if (line.StartsWith("Content-Type", StringComparison.Ordinal))
                        wasContentType = true;
                    else
                    {
                        wasContentDisposition = false;
                        wasContentType = false;
                        wasToken = false;
                        filename = null;
                    }
                }
                else //get the file data
                {
                    fileData = stream.ReadFileData(token);

                    if (fileData != null)
                    {
                        UploadedFile file = new UploadedFile();
                        file.Data = fileData;

                        if (filename.IndexOf('\\') >= 0)
                        {
                            filename = filename.Substring(filename.LastIndexOf('\\') + 1);
                        }

                        file.FileName = filename;
                        files.Add(file);
                    }

                    wasContentDisposition = false;
                    wasContentType = false;
                    wasToken = false;
                    filename = null;
                }
            }

            return files;
        }

    }
}
