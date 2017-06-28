using System;
using System.Collections.Generic;
using System.IO;
using Makolab.Fractus.Kernel.Repository;
namespace Makolab.Fractus.Kernel.Interfaces
{
    public interface IDocumentRepository
    {
        string Path { get; }
        string Url { get; }

        string AddFile(Stream file, string name);
        IEnumerable<Makolab.RestUpload.UploadedFile> AddMultipleFiles(Stream files);
        DocumentInfo Get(string documentId);
    }
}
