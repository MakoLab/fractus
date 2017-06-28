using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using System.Xml.Schema;
using System.IO;
using Makolab.Fractus.Kernel.Coordinators;
using System.Xml.Linq;
using System.Configuration;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Retrive communication package schemas from database.
    /// </summary>
    public class FractusPackageSchemaProvider : IPackageSchemaProvider
    {
        private IDatabaseConnectionManager dbManager;

        /// <summary>
        /// Initializes a new instance of the <see cref="FractusPackageSchemaProvider"/> class.
        /// </summary>
        /// <param name="dbManager">The database connection manager.</param>
        public FractusPackageSchemaProvider(IDatabaseConnectionManager dbManager)
        {
            this.dbManager = dbManager;
        }

        #region IPackageSchemaProvider Members

        /// <summary>
        /// Gets the validation schemas used in comunication package validation.
        /// </summary>
        /// <returns>Collection of validation schemas.</returns>
        public IDictionary<string, System.Xml.Schema.XmlSchemaSet> GetValidationSchemas()
        {
            Dictionary<string, XmlSchemaSet> schemasColl = new Dictionary<string, XmlSchemaSet>();
            XmlSchemaSet schemaSet = new XmlSchemaSet();
            XDocument schemas = null;

            using (IConnectionWrapper wrapper = dbManager.SynchronizeConnection())
            {
                Makolab.Fractus.Kernel.Managers.SqlConnectionManager.Instance.SetConnection(wrapper.Connection, null);
                bool logOut = false;
                if (KernelSessionManager.IsLogged == false)
                {
                    Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
                    KernelSessionManager.IsLogged = true;
                    logOut = true;
                    Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.LocalTransactionId = Guid.NewGuid();
                    Makolab.Fractus.Kernel.Managers.SessionManager.VolatileElements.DeferredTransactionId = Guid.NewGuid(); 
                }
                ConfigurationCoordinator confCoord = new ConfigurationCoordinator();
                schemas = confCoord.GetConfiguration("communication.validation.schema");
                if (logOut)
                {
                    Makolab.Fractus.Kernel.Managers.SecurityManager.Instance.LogOff();
                    KernelSessionManager.IsLogged = false;
                }
            }

            if (schemas == null) throw new ConfigurationErrorsException("communication.validation.schema element is not defined in configuration.");

            foreach (var schema in schemas.Root.Elements("validationSchama"))
            {
                XmlSchema contrSchema = XmlSchema.Read(new StringReader(schema.Value), null);
                schemaSet.Add(contrSchema);
                schemasColl.Add(schema.Attribute("xmlType").Value, schemaSet);
            }
            
            return schemasColl;
        }

        #endregion
    }
}
