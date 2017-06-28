
namespace Makolab.Printing.Mappers
{
    /// <summary>
    /// Provides the capabilities for gathering data from datasource.
    /// </summary>
    internal interface IMapper
    {
        /// <summary>
        /// Gets the data from datasource.
        /// </summary>
        /// <param name="name">Name of the data to get.</param>
        /// <returns>Loaded data.</returns>
        string GetData(string name);
    }
}
