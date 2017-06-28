namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Commons.Communication;

    //// TODO -1 fix this wicked design.
    //// Wicked design is the idea of NullMapperFactory.
    /// <summary>
    /// Mapper factory that returns null when asked for mapper.
    /// </summary>
    public class NullMapperFactory : IMapperFactory
    {
        /// <summary>
        /// Instance of <see cref="NullMapperFactory"/> class.
        /// </summary>
        public static readonly NullMapperFactory Instance = new NullMapperFactory();

        #region IMapperFactory Members

        /// <summary>
        /// Creates the mapper object.
        /// </summary>
        /// <typeparam name="T">Type of mapper to create</typeparam>
        /// <param name="connectionManager">The connection manager.</param>
        /// <returns>Created mapper object.</returns>
        public T CreateMapper<T>(IDatabaseConnectionManager connectionManager) where T : class
        {
            throw new InvalidOperationException("Cannot create mapper without specifying Mapper Factory.");
        }
        #endregion
    }
}
