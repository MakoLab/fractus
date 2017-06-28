using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Makolab.RestUpload;
using Makolab.Fractus.Commons;

namespace Makolab.Repository
{
    public class FileRepository
    {
        public string RepositoryPath { get; private set; }

        public IFileLocalizationStrategy Localizator { get; set; }

        public FileRepository(string repositoryPath) : this(repositoryPath, new DefaultFileLocalizationStrategy())
        {
            this.RepositoryPath = repositoryPath;
        }

        public FileRepository(string repositoryPath, IFileLocalizationStrategy localizator)
        {
            this.RepositoryPath = repositoryPath;
            this.Localizator = localizator;
        }

        /// <summary>
        /// Adds the file from <see cref="Stream"/> to repository.
        /// </summary>
        /// <param name="file">The file stream.</param>
        /// <returns>The file identifier that is used instead of file name to retrieve the file from repository.</returns>
        public string AddFile(Stream file)
        {
            return AddFile(file.ToByteArray());
        }

        /// <summary>
        /// Adds the file from byte array to repository with random name.
        /// </summary>
        /// <param name="file">The file bytes.</param>
        /// <returns>The file identifier that is used instead of file name to retrieve the file from repository.</returns>
        public string AddFile(byte[] file)
        { 
            string fileId = Guid.NewGuid().ToString().ToUpperInvariant();
            SaveFile(file, fileId);
            return fileId;
        }

        /// <summary>
        /// Adds the file from byte array to repository with defined name.
        /// </summary>
        /// <param name="file">The file bytes.</param>
        /// <param name="fileId">The file identifier.</param>
        /// <returns>The file identifier that is used instead of file name to retrieve the file from repository.</returns>
        public string AddFile(byte[] file, string fileId)
        {           
            SaveFile(file, fileId);
            return fileId;
        }

        /// <summary>  
        /// Extracts files from multipart MIME format from stram and adds them to repository.
        /// </summary>
        /// <param name="stream">The stream with files in multipart MIME format.</param>
        /// <returns>Collection of orginal file names and corresponding identifiers that are used instead of file name to retrieve files from repository.</returns>
        public IEnumerable<UploadedFile> AddFilesFromStream(Stream stream)
        {
            ICollection<UploadedFile> files = UploadHelper.ExtractFiles(stream);

            foreach (UploadedFile file in files)
            {
                file.FileIdentifier = Guid.NewGuid().ToString().ToUpperInvariant();

                SaveFile(file.Data, file.FileIdentifier);
            }
            return files;        
        }

        public Stream GetFile(string id)
        {
            MemoryStream ms = null;

            using (FileStream fs = new FileStream(this.Localizator.GetFileLocation(this.RepositoryPath, id), FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                byte[] data = new byte[fs.Length];

                fs.Read(data, 0, (int)fs.Length);

                ms = new MemoryStream(data);
            }

            return ms;
        }

        private void SaveFile(byte[] file, string fileName)
        {
            using (FileStream fs = new FileStream(this.Localizator.GetFileLocation(this.RepositoryPath, fileName), FileMode.Create, FileAccess.Write))
            {
                fs.Write(file, 0, file.Length);
            }
        }

    }
}
