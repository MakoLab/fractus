using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Makolab.Fractus.Kernel.Repository
{
    public class HybridDocumentRepository : RemoteDocumentRepository
    {
        protected LocalDocumentRepository LocalRepository { get; set; }

        public HybridDocumentRepository(string url, string cacheLocation, bool useOneTimeSession) : base(url, cacheLocation, useOneTimeSession)
        {
            if (String.IsNullOrEmpty(cacheLocation)) throw new ArgumentNullException("cacheLocation");

            this.LocalRepository = new LocalDocumentRepository(url, cacheLocation, false);
        }

        public override string AddFile(Stream file, string name)
        {
            base.Autenticate();

            return this.LocalRepository.AddFile(file, name);
        }

        public override IEnumerable<RestUpload.UploadedFile> AddMultipleFiles(Stream files)
        {
            base.Autenticate();

            return this.LocalRepository.AddMultipleFiles(files);
        }

        public override DocumentInfo Get(string documentId)
        {
            base.Autenticate();

            var documentDesc = GetDocumentDescriptor(documentId);

            if (IsLocalRepository(documentDesc.RepositoryUrl)) return this.LocalRepository.Get(documentId);
            else return base.Get(documentId);
        }

        protected bool IsLocalRepository(string repositoryUrl)
        {
            return repositoryUrl.Equals(this.Url, StringComparison.OrdinalIgnoreCase);
        }
    }
}
