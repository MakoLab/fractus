namespace Makolab.Commons.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;

    /// <summary>
    /// Interface for wrappers around database connection object.
    /// </summary>
    public interface IConnectionWrapper : IDisposable
    {
        /// <summary>
        /// Gets the database connection.
        /// </summary>
        /// <value>The database connection.</value>
        SqlConnection Connection { get; }
    }
}
