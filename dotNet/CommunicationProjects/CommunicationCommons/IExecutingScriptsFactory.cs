using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Executing script factory is responible for creation of proper execution object for specified communciation package.
    /// </summary>
    public interface IExecutingScriptsFactory
    {
        /// <summary>
        /// Gets or sets the active unit of work.
        /// </summary>
        /// <value>The unit of work.</value>
        IUnitOfWork UnitOfWork { get; set; }

        /// <summary>
        /// Creates object responsible for processing package of specified type.
        /// </summary>
        /// <param name="packageType">Type of the package to processed.</param>
        /// <param name="xmlPackage">The XML package to process.</param>
        /// <returns>Created package processing object.</returns>
        IExecutingScript CreateScript(string packageType, XDocument xmlPackage);

        /// <summary>
        /// Gets or sets a value indicating whether execution occurres in headquarter branch or not.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this branch is headquarter; otherwise, <c>false</c>.
        /// </value>
        bool IsHeadquarter { get; set; }

        /// <summary>
        /// Gets or sets the local transaction id of generated outgoing packages.
        /// </summary>
        /// <value>The local transaction id.</value>
        Guid LocalTransactionId { get; set; }
    }
}
