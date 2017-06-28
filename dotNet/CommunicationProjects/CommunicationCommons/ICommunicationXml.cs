using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Represents set of data that is synchronized between branches.
    /// </summary>
    public interface ICommunicationPackage : ICloneable
    {
        /// <summary>
        /// Gets or sets the XML data.
        /// </summary>
        /// <value>The XML data.</value>
        XmlTransferObject XmlData { get; set; }

        /// <summary>
        /// Gets or sets the database id.
        /// </summary>
        /// <value>The database id.</value>
        Guid? DatabaseId { get; set; }

        /// <summary>
        /// Gets or sets the communication package order number.
        /// </summary>
        /// <value>The order number.</value>
        int OrderNumber { get; set; }

        /// <summary>
        /// Compresses communication package.
        /// </summary>
        void Compress();

        /// <summary>
        /// Decompresses communication package.
        /// </summary>
        void Decompress();

        /// <summary>
        /// Checks the syntax of communication package.
        /// </summary>
        /// <returns>
        /// 	<c>true</c> if communication package is valid; otherwise, <c>false</c>.
        /// </returns>
        bool CheckSyntax();

        /// <summary>
        /// Gets or sets the xml execution time in seconds.
        /// </summary>
        /// <value>The xml execution time.</value>
        double ExecutionTime { get; set; }
    }
}
