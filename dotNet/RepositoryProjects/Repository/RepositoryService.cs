using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.ServiceModel;
using System.Xml.Linq;
using Makolab.RestUpload;

namespace Makolab.Repository
{
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    public class RepositoryService : IRepositoryService
    {
        private FileRepository repository;

        public RepositoryService()
        {
            string repositoryFolder = ConfigurationManager.AppSettings["RepositoryFolder"];

            if (repositoryFolder[repositoryFolder.Length - 1] != '\\')
                repositoryFolder += "\\";

            this.repository = new FileRepository(repositoryFolder);
        }

        public Stream PutFile(Stream input)
        {
            var filesInfo = this.repository.AddFilesFromStream(input);

            XDocument xml = XDocument.Parse("<response></response>");

            foreach (var file in filesInfo)
            {
                xml.Root.Add(XElement.Parse(String.Format(CultureInfo.InvariantCulture,
                    "<file oldFilename=\"{0}\" newFilename=\"{1}\" />", file.FileName, file.FileIdentifier)));
            }

            MemoryStream ms = new MemoryStream();
            xml.Save(new StreamWriter(ms));
            ms.Flush();
            ms.Position = 0;
            return ms;
        }

        public Stream PutSingleFile(Stream input)
        {            
            var fileId = this.repository.AddFile(input);

            XDocument xml = XDocument.Parse("<response></response>");
            xml.Root.Add(new XElement("file", new XAttribute("newFilename", fileId)));

            MemoryStream ms = new MemoryStream();
            xml.Save(new StreamWriter(ms));
            ms.Flush();
            ms.Position = 0;
            return ms;
        }

        public Stream GetFile(string name)
        {
            return this.repository.GetFile(name);
        }
    }
}
