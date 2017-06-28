using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Xml;
using System.Globalization;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Configuration section handler for modules from external assemblies.
    /// </summary>
    public class ModulesSectionHandler : IConfigurationSectionHandler
    {
        /// <summary>
        /// Gets the collection of modules information.
        /// </summary>
        /// <value>The modules.</value>
        public ICollection<ModuleInfo> Modules { get; private set; }

        #region IConfigurationSectionHandler Members

        /// <summary>
        /// Creates a configuration section handler.
        /// </summary>
        /// <param name="parent">Parent object.</param>
        /// <param name="configContext">Configuration context object.</param>
        /// <param name="section">Section XML node.</param>
        /// <returns>The created section handler object.</returns>
        public object Create(object parent, object configContext, System.Xml.XmlNode section)
        {
            Modules = new List<ModuleInfo>();
            List<string> addedModulesName = new List<string>();
            foreach (XmlNode module in section.SelectNodes("module"))
            {
                ModuleInfo m = new ModuleInfo();
                m.Name          = module.Attributes["name"].Value;
                m.TypeName      = module.Attributes["type"].Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[0];
                m.AssemblyName  = module.Attributes["type"].Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[1];
                if (addedModulesName.Contains(m.Name) == true)
                {
                    throw new ConfigurationErrorsException(String.Format(CultureInfo.CurrentCulture, "Module named '{0}' already exists.", m.Name));
                }

                Modules.Add(m);
                addedModulesName.Add(m.Name);
            }
        
            return this;
        }

        #endregion
    }

    /// <summary>
    /// Class that represents information required to instantiate module.
    /// </summary>
    public class ModuleInfo
    {
        /// <summary>
        /// Gets or sets the module name.
        /// </summary>
        /// <value>The name.</value>
        public string Name {get; set; }

        /// <summary>
        /// Gets or sets the name of the module class type that is instantiated.
        /// </summary>
        /// <value>The name of the type.</value>
        public string TypeName { get; set; }

        /// <summary>
        /// Gets or sets the name of the assembly.
        /// </summary>
        /// <value>The name of the assembly.</value>
        public string AssemblyName { get; set; }
    }
}
