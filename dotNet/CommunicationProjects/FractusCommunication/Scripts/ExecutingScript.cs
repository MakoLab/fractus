namespace Makolab.Fractus.Communication.Scripts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using Makolab.Fractus.Communication.DBLayer;
    using Makolab.Commons.Communication;
    using System.Xml.Linq;

    /// <summary>
    /// Base class for all classes that executes communication packages.
    /// </summary>
    public abstract class ExecutingScript : IExecutingScript
    {
        public ExecutionController ExecutionController { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ExecutingScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        protected ExecutingScript(IUnitOfWork unitOfWork)
        {
            this.UnitOfWork = unitOfWork;
        }


        #region IExecutingScript Members

        /// <summary>
        /// Gets or sets the unit of work.
        /// </summary>
        /// <value>The unit of work.</value>
        public IUnitOfWork UnitOfWork { get; set; }

        /// <summary>
        /// Gets or sets the message log.
        /// </summary>
        /// <value>The message log.</value>
        public ICommunicationLog Log { get; set; }

        /// <summary>
        /// Gets or sets the local transaction id of generated outgoing packages.
        /// </summary>
        /// <value>The local transaction id.</value>
        public Guid LocalTransactionId { get; set; }

        /// <summary>
        /// Executes the communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public abstract bool ExecutePackage(ICommunicationPackage communicationPackage);

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        { 
        }
    }
}
