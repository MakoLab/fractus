using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Makolab.Fractus.Kernel.Coordinators;
using System.Xml.Linq;
using System.Globalization;
using Makolab.RestUpload;

namespace Makolab.Fractus.Kernel.Repository
{
    public abstract class DocumentRepository : Makolab.Fractus.Kernel.Interfaces.IDocumentRepository
    {
        public string Url { get; protected set; }
        public string Path { get; protected set; }

        public DocumentRepository(string url, string path)
        {
            if (String.IsNullOrEmpty(url)) throw new ArgumentNullException("url");

            this.Url = url;

            if (path != null) this.Path = path.Trim();
        }

        public abstract string AddFile(Stream file, string name);

        public abstract IEnumerable<UploadedFile> AddMultipleFiles(Stream files);

        public abstract DocumentInfo Get(string documentId);

        public DocumentInfo AddDocumentDescriptor(string documentName, string documentId)
        {
            XDocument dictionaries = null;


            using (ListCoordinator listCoordinator = new ListCoordinator())
            {
                dictionaries = listCoordinator.GetDictionaries();
            }

            string repoId = (from node in dictionaries.Root.Element("repository").Elements()
                             where node.Element("url").Value == this.Url
                             select node.Element("id").Value).ElementAt(0);

            string extension = documentName.Substring(documentName.LastIndexOf('.') + 1);

            var mimeTypeNode = (from node in dictionaries.Root.Element("mimeType").Elements()
                                where node.Element("extensions").Value.Contains(extension) == true
                                select node).First();

            using (RepositoryCoordinator repoCoordinator = new RepositoryCoordinator())
            {
                XDocument fileDescriptor = repoCoordinator.CreateNewBusinessObject(XDocument.Parse("<root><type>FileDescriptor</type></root>"));
                fileDescriptor.Root.Element("fileDescriptor").Element("repositoryId").Value = repoId;
                fileDescriptor.Root.Element("fileDescriptor").Element("id").Value = documentId;
                fileDescriptor.Root.Element("fileDescriptor").Element("mimeTypeId").Value = mimeTypeNode.Element("id").Value;
                fileDescriptor.Root.Element("fileDescriptor").Add(new XElement("originalFilename", documentName));

                XDocument responseXml = repoCoordinator.SaveBusinessObject(fileDescriptor);
                var modificationDate = DateTime.Parse(responseXml.Root.Element("modificationDate").Value, CultureInfo.InvariantCulture);

                return new DocumentInfo(documentName, documentId, mimeTypeNode.Element("name").Value, modificationDate, this.Url);
            }
        }

        public DocumentInfo GetDocumentDescriptor(string id)
        {
            //load dictionaries
            XDocument dictionaries = null;

            using (ListCoordinator listCoordinator = new ListCoordinator())
            {
                dictionaries = listCoordinator.GetDictionaries();
            }

            //load file descriptor
            XDocument descriptor = null;

            using (RepositoryCoordinator repoCoordinator = new RepositoryCoordinator())
            {
                descriptor = repoCoordinator.LoadBusinessObject(XDocument.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<root><type>FileDescriptor</type><id>{0}</id></root>", id)));
            }

            //get the date from descriptor
            DateTime descriptorDate = DateTime.Parse(descriptor.Root.Element("fileDescriptor").Element("modificationDate").Value, CultureInfo.InvariantCulture);
            descriptorDate = new DateTime(descriptorDate.Year, descriptorDate.Month, descriptorDate.Day, descriptorDate.Hour, descriptorDate.Minute, descriptorDate.Second);

            //get content type
            var mimeType = (from node in dictionaries.Root.Element("mimeType").Elements()
                                 where node.Element("id").Value == descriptor.Root.Element("fileDescriptor").Element("mimeTypeId").Value
                                 select node.Element("name").Value).ElementAt(0);

            var name = descriptor.Root.Element("fileDescriptor").Element("originalFilename").Value;

            var repoUlr = this.GetRepositoryUrl(descriptor, dictionaries);

            return new DocumentInfo(name, id, mimeType, descriptorDate, repoUlr);
        }

        private string GetRepositoryUrl(XDocument descriptor, XDocument dictionaries)
        {
            string repoId = descriptor.Root.Element("fileDescriptor").Element("repositoryId").Value;

            string repoUrl = (from node in dictionaries.Root.Element("repository").Elements()
                              where node.Element("id").Value == repoId
                              select node.Element("url").Value).ElementAt(0);

            return repoUrl;
        }
    }
}

