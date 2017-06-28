using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Makolab.Repository;

namespace Makolab.Fractus.Kernel.Repository
{
    public class LocalDocumentRepository : DocumentRepository 
    {
        protected FileRepository Repository { get; set; }

        public LocalDocumentRepository(string url, string path, bool authenticate) : base(url, path)
        {
            if (String.IsNullOrEmpty(path)) throw new ArgumentNullException("path");

            this.Repository = new FileRepository(path);

            if (authenticate) Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);  
        }

        public override string AddFile(Stream file, string name)
        {
            string id = this.Repository.AddFile(file);

            AddDocumentDescriptor(name, id);

            return id;            
        }

        public override IEnumerable<RestUpload.UploadedFile> AddMultipleFiles(Stream files)
        {
            var uploadedDocs = this.Repository.AddFilesFromStream(files);
            foreach (var doc in uploadedDocs) AddDocumentDescriptor(doc.FileName, doc.FileIdentifier);

            return uploadedDocs;
        }

        public override DocumentInfo Get(string documentId)
        {
            DocumentInfo doc = GetDocumentDescriptor(documentId);

            doc.Content = this.Repository.GetFile(doc.Id);

            return doc;
        }
    }
}
