namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data;
    using System.Data.SqlClient;

    /// <summary>
    /// NullObject implementation for IDbTransaction
    /// </summary>
    public sealed class NullTransaction : IDbTransaction
    {
        /// <summary>
        /// Instance of <see cref="NullTransaction"/> object.
        /// </summary>
        public static readonly NullTransaction Instance = new NullTransaction();

        /// <summary>
        /// Initializes a new instance of the <see cref="NullTransaction"/> class.
        /// </summary>
        private NullTransaction() { }


        #region IDbTransaction Members

        /// <summary>
        /// Specifies the Connection object to associate with the transaction.
        /// </summary>
        /// <value></value>
        /// <returns>Null.</returns>
        public IDbConnection Connection { get { return null; } }

        /// <summary>
        /// Specifies the <see cref="T:System.Data.IsolationLevel"/> for this transaction.
        /// </summary>
        /// <value></value>
        /// <returns>IsolationLevel.Unspecified.</returns>
        public IsolationLevel IsolationLevel
        {
            get { return IsolationLevel.Unspecified; }
        }

        /// <summary>
        /// Empty method.
        /// </summary>
        public void Commit() { }

        /// <summary>
        /// Empty method.
        /// </summary>
        public void Rollback() { }

        #endregion

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose() 
        {
            GC.SuppressFinalize(this);
        }

        #endregion
    }
}
