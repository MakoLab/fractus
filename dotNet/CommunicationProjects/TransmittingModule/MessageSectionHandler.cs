using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Handles access to messageHandler configuration section.
    /// </summary>
    public class MessageHandlerSectionHandler : IConfigurationSectionHandler
    {
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
            System.Xml.XmlAttribute messageHandler = section.Attributes["SynchronizationHandler"];
            if (messageHandler == null) throw new Exception("SynchronizationHandler was not specified.");

            string typeName = messageHandler.Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[0];
            string assemblyName = messageHandler.Value.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[1];

            HandlerInfo hi = new HandlerInfo();
            hi.AssemblyName = assemblyName;
            hi.TypeName = typeName;

            return hi;
        }

        #endregion
    }
}
