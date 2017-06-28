using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Makolab.Fractus.Kernel.Managers;
using System.Net;
using Makolab.Fractus.Commons;
using System.Xml.Linq;
using Makolab.RestUpload;
using System.Globalization;

namespace Makolab.Fractus.Kernel.Repository
{
    public class RemoteDocumentRepository : DocumentRepository
    {
        public bool UseOneTimeSession { get; protected set; }

        public string CacheConfigFile { get; protected set; }

        public bool IsCachingEnabled { get; protected set; }

        public RemoteDocumentRepository(string url, bool useOneTimeSession) : this(url, null, useOneTimeSession)
        {
        }

        public RemoteDocumentRepository(string url, string cacheLocation, bool useOneTimeSession) : base(url, cacheLocation)
        {
            this.UseOneTimeSession = useOneTimeSession;

            if (String.IsNullOrEmpty(cacheLocation) == false)
            {
                this.IsCachingEnabled = true;
                this.CacheConfigFile = System.IO.Path.Combine(this.Path, "config.xml");
            }
        }

        public override string AddFile(Stream file, string name)
        {
            Autenticate();

            WebRequest request = WebRequest.Create(new Uri(this.Url + "/PutSingleFile"));
            request.Method = "POST";
            request.ContentType = "application/octet-stream";

            Stream requestStream = request.GetRequestStream();
            var bArray = file.ToByteArray();
            int position = 0;
            int bytesToWrite = 0;
            int chunk = 1024;

            while (position < bArray.LongLength)
            {
                bytesToWrite = (bArray.LongLength - position < chunk) ? (int)bArray.LongLength - position : chunk;
                requestStream.Write(bArray, position, bytesToWrite);
                position += bytesToWrite;
            }
            requestStream.Close();

            XDocument responseXml = null;

            using (StreamReader responseReader = new StreamReader(request.GetResponse().GetResponseStream()))
            {
                responseXml = XDocument.Parse(responseReader.ReadToEnd());
            }

            var fileId = (from node in responseXml.Root.Elements("file")
                                   select node.Attribute("newFilename").Value).First();

            var descriptor = AddDocumentDescriptor(name, fileId);

            if (this.IsCachingEnabled)
            {
                using (FileStream fs = new FileStream(System.IO.Path.Combine(this.Path, fileId), FileMode.Create, FileAccess.Write))
                {
                    fs.Write(bArray, 0, bArray.Length);
                }
                this.WriteToConfig(descriptor.Id, descriptor.ModificationDate);
            }

            return fileId;
        }

        public override IEnumerable<UploadedFile> AddMultipleFiles(Stream files)
        {
            Autenticate();

            WebRequest request = WebRequest.Create(new Uri(this.Url + "/PutFile"));
            request.Method = "POST";
            request.ContentType = "application/octet-stream";

            Stream requestStream = request.GetRequestStream();
            var bArray = files.ToByteArray();
            int position = 0;
            int bytesToWrite = 0;
            int chunk = 1024;

            while (position < bArray.LongLength)
            {
                bytesToWrite = (bArray.LongLength - position < chunk) ? (int)bArray.LongLength - position : chunk;
                requestStream.Write(bArray, position, bytesToWrite);
                position += bytesToWrite;
            }
            requestStream.Close();

            XDocument responseXml = null;

            using (StreamReader responseReader = new StreamReader(request.GetResponse().GetResponseStream()))
            {
                responseXml = XDocument.Parse(responseReader.ReadToEnd());
            }

            var uploadedFiles = UploadHelper.ExtractFiles(bArray);

            foreach (UploadedFile file in uploadedFiles)
            {
                file.FileIdentifier = (from node in responseXml.Root.Elements("file")
                                        where node.Attribute("oldFilename").Value == file.FileName
                                        select node.Attribute("newFilename").Value).ElementAt(0);

                var descriptor = AddDocumentDescriptor(file.FileName, file.FileIdentifier);

                if (this.IsCachingEnabled)
                {
                    using (FileStream fs = new FileStream(System.IO.Path.Combine(this.Path, file.FileIdentifier), FileMode.Create, FileAccess.Write))
                    {
                        fs.Write(file.Data, 0, file.Data.Length);
                    }
                    this.WriteToConfig(descriptor.Id, descriptor.ModificationDate);
                }
            }
            return uploadedFiles;
        }

        public override DocumentInfo Get(string documentId)
        {
            Autenticate();

            DocumentInfo doc = GetDocumentDescriptor(documentId);

            var cachedFile = (this.IsCachingEnabled) ? System.IO.Path.Combine(this.Path, documentId) : null;

            if (this.IsCachingEnabled && File.Exists(cachedFile) && this.IsCacheUpToDate(documentId, doc.ModificationDate)) //file already cached
            {
                doc.Content = new FileStream(cachedFile, FileMode.Open, FileAccess.Read, FileShare.Read);
            }
            else //download on demand
            {
                doc.Content = this.StreamFileFromRepository(doc);

                if (this.IsCachingEnabled)
                {
                    //write to the cache
                    FileStream fs = new FileStream(cachedFile, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.Read);

                    int b = -1;

                    while ((b = doc.Content.ReadByte()) >= 0)
                    {
                        fs.WriteByte((byte)b);
                    }

                    doc.Content.Dispose();
                    doc.Content = fs;

                    this.WriteToConfig(doc.Id, doc.ModificationDate);

                    fs.Position = 0;
                }
            }

            return doc;
        }

        public void Autenticate()
        {
            if (this.UseOneTimeSession)
            {
                Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
                SessionManager.OneTimeSession = true;
            }
        }

        protected void WriteToConfig(string name, DateTime date)
        {
            lock (this.CacheConfigFile)
            {
                if (!File.Exists(this.CacheConfigFile))
                    this.CreateConfigFile();

                XDocument xml = XDocument.Load(this.CacheConfigFile);
                xml.Root.Add(XElement.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<file name=\"{0}\" date=\"{1}\" />", name, date.ToIsoString())));
                xml.Save(this.CacheConfigFile);
            }
        }

        protected DateTime? ReadConfigEntry(string name)
        {
            lock (this.CacheConfigFile)
            {
                if (!File.Exists(this.CacheConfigFile))
                    this.CreateConfigFile();

                XDocument xml = XDocument.Load(this.CacheConfigFile);

                var entry = from node in xml.Root.Elements()
                            where node.Attribute("name").Value == name
                            select node;

                if (entry.Count() == 0)
                    return null;
                else
                    return DateTime.Parse(entry.ElementAt(0).Attribute("date").Value, CultureInfo.InvariantCulture);
            }
        }

        protected void CreateConfigFile()
        {
            XDocument xml = XDocument.Parse("<config></config>");
            xml.Save(this.CacheConfigFile);
        }

        protected bool IsCacheUpToDate(string name, DateTime descriptorDate)
        {
            DateTime? date = this.ReadConfigEntry(name);

            if (date == null || date.Value != descriptorDate)
                return false;
            else
                return true;
        }

        protected Stream StreamFileFromRepository(DocumentInfo document)
        {
            //do the webrequest
            WebRequest request = WebRequest.Create(new Uri(String.Format(CultureInfo.InvariantCulture,
                "{0}/GetFile/{1}", document.RepositoryUrl, document.Id)));

            return request.GetResponse().GetResponseStream();
        }
    }
}
