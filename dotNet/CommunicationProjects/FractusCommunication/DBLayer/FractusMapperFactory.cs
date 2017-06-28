namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Commons.Communication;
    using Makolab.Commons.Communication.DBLayer;

    /// <summary>
    /// Creates mappers of specified type.
    /// </summary>
    public class FractusMapperFactory : IMapperFactory
    {
        #region IMapperFactory Members

        /// <summary>
        /// Creates the mapper.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="connectionManager">The connection manager.</param>
        /// <returns>Created mapper.</returns>
        public T CreateMapper<T>(IDatabaseConnectionManager connectionManager) where T : class
        {
            if (typeof(T) == typeof(ICommunicationPackageMapper)) return new CommunicationPackageMapper(connectionManager) as T;
            else if (typeof(T) == typeof(ICommunicationStatisticsMapper)) return new CommunicationStatisticsMapper(connectionManager) as T;
            else return null;
        }

        #endregion
    }
}
