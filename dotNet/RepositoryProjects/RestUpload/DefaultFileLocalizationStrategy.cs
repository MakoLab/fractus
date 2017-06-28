using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Makolab.RestUpload
{
    /// <summary>
    /// Puts the file to the repository folder
    /// </summary>
    public class DefaultFileLocalizationStrategy : IFileLocalizationStrategy
    {
        #region IFileLocalizationStrategy Members

        /// <summary>
        /// Gets the file location.
        /// </summary>
        /// <param name="repositoryPath">The repository path.</param>
        /// <param name="fileId">The file id.</param>
        /// <returns></returns>
        public string GetFileLocation(string repositoryPath, string fileId)
        {
            return Path.Combine(repositoryPath, fileId);
        }

        #endregion
    }
}
