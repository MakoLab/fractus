using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Provides extension points to run the custom logic in specific moments of package execution.
    /// </summary>
    public interface IExecutionManager
    {
        /// <summary>
        /// Gets or sets the log object.
        /// </summary>
        /// <value>The log.</value>
        /// <remarks>
        /// Log object allows logging of different message types to configured sink.
        /// </remarks>
        ICommunicationLog Log { get; set; }

        /// <summary>
        /// Initializes the execution engine. Runs before any package is executed.
        /// </summary>
        /// <param name="connectionManager">The database connection manager.</param>
        void Initialize(IDatabaseConnectionManager connectionManager);

        /// <summary>
        /// Cleans the execution engine. Runs when execution engine is stopping.
        /// </summary>
        /// <param name="connectionManager">The database connection manager.</param>
        void Clean(IDatabaseConnectionManager connectionManager);

        /// <summary>
        /// Determines whether the execution of specified communication package is required or package must be skipped.
        /// </summary>
        /// <param name="communicationPackage">The communication package.</param>
        /// <returns>
        /// 	<c>true</c> if execution is required; otherwise, <c>false</c>.
        /// </returns>
        bool IsExecutionRequired(ICommunicationPackage communicationPackage);

        /// <summary>
        /// Allow to run custom logic before execution of local transaction.
        /// </summary>
        /// <param name="unitOfWork">The active unit of work.</param>
        void BeforeTransactionExecution(IUnitOfWork unitOfWork);

        /// <summary>
        /// Allow to run custom logic after  execution of local transaction.
        /// </summary>
        /// <param name="unitOfWork">The active unit of work.</param>
        void AfterTransactionExecution(IUnitOfWork unitOfWork);

        /// <summary>
        /// Allow to run custom logic before execution of communication package.
        /// </summary>
        /// <param name="unitOfWork">The active unit of work.</param>
        void BeforePackageExecution(IUnitOfWork unitOfWork);

        /// <summary>
        /// Executes the local transaction.
        /// </summary>
        /// <param name="packageList">The list of packages belonging to one local transaction.</param>
        /// <returns>
        /// 	<c>true</c> if succeeded; otherwise, <c>false</c>.
        /// </returns>
        bool ExecuteLocalTransaction(IEnumerable<ICommunicationPackage> packageList, IUnitOfWork unitOfWork);
    }
}
