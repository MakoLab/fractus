using System;
using System.IO;

namespace Makolab.Printing.Mappers
{
    /// <summary>
    /// Mapper class that reads data from files.
    /// </summary>
    internal class FileMapper : IMapper
    {
        /// <summary>
        /// Full path to folder where files are stored.
        /// </summary>
        private string path;

        /// <summary>
        /// Initializes a new instance of the <see cref="FileMapper"/> class.
        /// </summary>
        /// <param name="path">Full path of the folder where files are stored.</param>
        public FileMapper(string path)
        {
            if (path.EndsWith("\\", StringComparison.Ordinal))
                this.path = path;
            else
                this.path = path + "\\";
        }

        /// <summary>
        /// Gets the data from datasource.
        /// </summary>
        /// <param name="name">Name of the data to get.</param>
        /// <returns>Loaded data.</returns>
        public string GetData(string name)
        {
            using (StreamReader file = new StreamReader(new FileStream(this.path + name, FileMode.Open, FileAccess.Read)))
            {
                return file.ReadToEnd();
            }
        }
    }
}
