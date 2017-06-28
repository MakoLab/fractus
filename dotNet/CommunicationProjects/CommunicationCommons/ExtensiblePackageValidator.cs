using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// The communication package validator that bahaves as containter for other validators.
    /// </summary>
    public class ExtensiblePackageValidator : IPackageValidator
    {
        private List<IPackageValidator> validators = new List<IPackageValidator>();

        #region IPackageValidator Members

        /// <summary>
        /// Gets or sets the database connection manager.
        /// </summary>
        /// <value>The connection database manager.</value>
        public IDatabaseConnectionManager ConnectionManager { get; set; }


        /// <summary>
        /// Validates the specified communication package.
        /// </summary>
        /// <param name="package">The communication package.</param>
        /// <param name="validationExceptionMessage">The validation exception message.</param>
        /// <returns>
        /// 	<c>true</c> if communication package is valid; otherwise, <c>false</c>
        /// </returns>
        /// <remarks>When communication pakage is invalid method returns <c>false</c> and <c>validationExceptionMessage</c> parameter contains validation error message.</remarks>
        public bool Validate(ICommunicationPackage package, ref string validationExceptionMessage)
        {
            bool validationResult = false;
            foreach (var validator in this.validators)
            {
                validationResult = validator.Validate(package, ref validationExceptionMessage);
                if (validationResult == false) return false;
            }
            return true;
        }

        /// <summary>
        /// Validates the specified communication package and throws exception when package is invalid.
        /// </summary>
        /// <param name="package">The communication package.</param>
        public void Validate(ICommunicationPackage package)
        {
            this.validators.ForEach(validator => validator.Validate(package));
        }

        #endregion

        /// <summary>
        /// Adds the validator to collection of used validators.
        /// </summary>
        /// <param name="validator">The validator.</param>
        public void AddValidator(IPackageValidator validator)
        {
            this.validators.Add(validator);
        }

        /// <summary>
        /// Removes the validator from the collection of used validators.
        /// </summary>
        /// <param name="validator">The validator.</param>
        public void RemoveValidator(IPackageValidator validator)
        {
            this.validators.Remove(validator);
        }
    }
}
