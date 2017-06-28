using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Defines the properties and methods that objects that participate in communication package validation must implement.
    /// </summary>
    public interface IPackageValidator
    {
        /// <summary>
        /// Gets or sets the database connection manager.
        /// </summary>
        /// <value>The connection database manager.</value>
        IDatabaseConnectionManager ConnectionManager { get; set; }

        /// <summary>
        /// Validates the specified communication package.
        /// </summary>
        /// <param name="package">The communication package.</param>
        /// <param name="validationExceptionMessage">The validation exception message.</param>
        /// <returns>
        /// 	<c>true</c> if communication package is valid; otherwise, <c>false</c>
        /// </returns>
        /// <remarks>When communication pakage is invalid method returns <c>false</c> and <c>validationExceptionMessage</c> parameter contains validation error message.</remarks>
        bool Validate(ICommunicationPackage package, ref string validationExceptionMessage);

        /// <summary>
        /// Validates the specified communication package and throws exception when package is invalid.
        /// </summary>
        /// <param name="package">The communication package.</param>
        void Validate(ICommunicationPackage package);   
    }
}
