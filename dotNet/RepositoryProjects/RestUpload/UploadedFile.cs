
namespace Makolab.RestUpload
{
    /// <summary>
    /// Class containing binary file data and filename.
    /// </summary>
    public class UploadedFile
    {
        /// <summary>
        /// Original filename.
        /// </summary>
        public string FileName { get; set; }

        /// <summary>
        /// Gets or sets the id that is used instead of file name to retrieve the file from repository.
        /// </summary>
        /// <value>The file identifier.</value>
        public string FileIdentifier { get; set; }

        /// <summary>
        /// Binary file data.
        /// </summary>
        public byte[] Data { get; set; }
    }
}
