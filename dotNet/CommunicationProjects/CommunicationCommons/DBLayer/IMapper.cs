namespace Makolab.Commons.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using System.Data;

    /// <summary>
    /// Interface for mapper classes.
    /// </summary>
    public interface IMapper
    {
        /// <summary>
        /// Gets or sets the database transaction.
        /// </summary>
        /// <value>The database transaction.</value>
        IDbTransaction Transaction { get; set; }
    }
}
