using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.Repository
{
    public class DocumentRepositoryFactory
    {
        public static IDocumentRepository Create(string mode, string url, string path, bool autoLogon)
        { 
            IDocumentRepository repo = null;
            if (mode.Equals("local", StringComparison.OrdinalIgnoreCase)) repo = new LocalDocumentRepository(url, path, autoLogon);
            else if (mode.Equals("remote", StringComparison.OrdinalIgnoreCase)) repo = new RemoteDocumentRepository(url, autoLogon);
            else if (mode.Equals("remoteWithCache", StringComparison.OrdinalIgnoreCase)) repo = new RemoteDocumentRepository(url, path, autoLogon);
            else if (mode.Equals("hybrid", StringComparison.OrdinalIgnoreCase)) repo = new HybridDocumentRepository(url, path, autoLogon);
            else throw new ArgumentException("Invalid mode value", "mode");

            return repo;
        }

        public static IDocumentRepository Create(bool skipCachingForMainRepository, string url, string path)
        {
            if (skipCachingForMainRepository) return Create("hybrid", url, path, false);
            else return Create("remoteWithCache", url, path, false);
        }
    }

}
