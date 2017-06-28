namespace Makolab.Commons.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using System.Xml.Linq;

    /// <summary>
    /// Defines interface for scripts that executes communication packages.
    /// </summary>
    public interface IExecutingScript : IDisposable
    {
        /// <summary>
        /// Gets or sets the unit of work.
        /// </summary>
        /// <value>The unit of work.</value>
        IUnitOfWork UnitOfWork { get; set; }

        /// <summary>
        /// Gets or sets the message log.
        /// </summary>
        /// <value>The message log.</value>
        ICommunicationLog Log { get; set; }

        /// <summary>
        /// Gets or sets the local transaction id of generated outgoing packages.
        /// </summary>
        /// <value>The local transaction id.</value>
        Guid LocalTransactionId { get; set; }

        /// <summary>
        /// Executes the communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns><c>true</c> if execution succeeded; otherwise, <c>false</c></returns>
        bool ExecutePackage(ICommunicationPackage communicationPackage);
    }
}
