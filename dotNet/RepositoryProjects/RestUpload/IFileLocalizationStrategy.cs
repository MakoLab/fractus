using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.RestUpload
{
    /// <summary>
    /// Provides a way to determin file destination path in a configurable way.
    /// </summary>
    public interface IFileLocalizationStrategy
    {
        /// <summary>
        /// Gets the file location.
        /// </summary>
        /// <param name="repositoryPath">The repository path.</param>
        /// <param name="fileId">The file id.</param>
        /// <returns></returns>
        string GetFileLocation(string repositoryPath, string fileId);
    }
}
