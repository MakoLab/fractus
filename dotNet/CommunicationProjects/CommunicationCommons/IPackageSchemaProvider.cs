using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using System.Xml.Schema;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Provides a mechanism to retrive communication package schemas.
    /// </summary>
    public interface IPackageSchemaProvider
    {
        /// <summary>
        /// Gets the validation schemas used in comunication package validation.
        /// </summary>
        /// <returns>Collection of validation schemas.</returns>
        IDictionary<string, XmlSchemaSet> GetValidationSchemas();
    }
}
