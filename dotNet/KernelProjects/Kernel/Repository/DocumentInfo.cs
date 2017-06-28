using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Makolab.Fractus.Kernel.Repository
{
    public class DocumentInfo
    {
        public DocumentInfo(string name, string id, string mimeType, DateTime modificationDate, string repositoryUrl)
        {
            this.Name = name;
            this.Id = id;
            this.MimeType = mimeType;
            this.ModificationDate = modificationDate;
            this.RepositoryUrl = repositoryUrl;
        }

        public string Name { get; private set; }

        public string Id { get; private set; }

        public string MimeType { get; private set; }

        public DateTime ModificationDate { get; private set; }

        public string RepositoryUrl { get; private set; }

        public Stream Content { get; set; }
    }
}
