using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Ninject.Core.Creation;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Provider of <see cref="IPackageValidator"/> class.
    /// </summary>
    public class FractusPackageValidatorProvider : SimpleProvider<IPackageValidator>
    {
        /// <summary>
        /// Creates a new instance of the specified type.
        /// </summary>
        /// <param name="context">The context in which the activation is occurring.</param>
        /// <returns>The instance of the specified type.</returns>
        protected override IPackageValidator CreateInstance(Ninject.Core.Activation.IContext context)
        {
            FractusContainerContext fractusContext = (FractusContainerContext)context;
            IDatabaseConnectionManager dbMan = (IDatabaseConnectionManager)fractusContext.Parameters["IDatabaseConnectionManager"];

            ExtensiblePackageValidator validator = new ExtensiblePackageValidator();
            SchemaPackageValidator schemaValidator = new SchemaPackageValidator(new FractusPackageSchemaProvider(dbMan));
            validator.AddValidator(schemaValidator);
            return validator;
        }
    }
}
