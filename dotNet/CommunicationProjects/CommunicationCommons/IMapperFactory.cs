namespace Makolab.Commons.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Interface form mappers factory classes.
    /// </summary>
    public interface IMapperFactory
    {
        /// <summary>
        /// Creates the mapper object.
        /// </summary>
        /// <typeparam name="T">Type of mapper to create</typeparam>
        /// <param name="connectionManager">The connection manager.</param>
        /// <returns>Created mapper object.</returns>
        T CreateMapper<T>(IDatabaseConnectionManager connectionManager) where T : class;
    }
}
