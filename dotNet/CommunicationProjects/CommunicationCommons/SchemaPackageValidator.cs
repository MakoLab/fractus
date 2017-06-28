using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Schema;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Validates communication package using XmlSchema.
    /// </summary>
    public class SchemaPackageValidator : IPackageValidator
    {
        /// <summary>
        /// Contains schemas for specified communication package types.
        /// </summary>
        private IDictionary<string, XmlSchemaSet> schemas;

        /// <summary>
        /// Initializes a new instance of the <see cref="SchemaPackageValidator"/> class.
        /// </summary>
        /// <param name="provider">The validation schema provider.</param>
        public SchemaPackageValidator(IPackageSchemaProvider provider)
        {
            this.schemas = provider.GetValidationSchemas();
        }

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
            try
            {
                Validate(package);
                return true;
            }
            catch (XmlSchemaValidationException e)
            {
                validationExceptionMessage = e.ToString();
                return false;
            }
        }

        /// <summary>
        /// Validates the specified communication package and throws exception when package is invalid.
        /// </summary>
        /// <param name="package">The communication package.</param>
        /// <exception cref="XmlSchemaValidationException">Xml is invalid.</exception>
        public void Validate(ICommunicationPackage package)
        {
            if (this.schemas.ContainsKey(package.XmlData.XmlType))
            {
                System.Xml.Linq.XDocument doc = System.Xml.Linq.XDocument.Parse(package.XmlData.Content);
                doc.Validate(this.schemas[package.XmlData.XmlType], null);
            }
        }

        #endregion
    }
}
