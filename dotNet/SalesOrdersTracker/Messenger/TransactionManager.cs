using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;

namespace Makolab.Fractus.Messenger
{
    public class TransactionManager : IDisposable
    {
        public SqlTransaction Transaction { get; set; }
        public SqlConnection Connection { get; set; }

        private bool isTransactionCommited;

        public TransactionManager(SqlTransaction transaction)
        {
            if (transaction == null) throw new ArgumentNullException("transaction");
            this.Transaction = transaction;
            this.Connection = this.Transaction.Connection;
        }

        public void SubmitChanges()
        {
            this.Transaction.Commit();
            this.isTransactionCommited = true;
        }

        /// <summary>
        /// Cancels the changes by rollbacking transaction.
        /// </summary>
        public void CancelChanges()
        {
            this.Transaction.Rollback();
            this.isTransactionCommited = true;
        }

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (this.isTransactionCommited == false) this.CancelChanges();

            this.Transaction.Dispose();
            this.Connection.Dispose();
        }

        #endregion
    }
}
