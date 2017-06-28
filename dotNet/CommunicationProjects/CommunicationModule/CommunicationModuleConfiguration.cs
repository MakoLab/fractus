namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Serialization;

    /// <summary>
    /// Base configuration class for communication modules.
    /// </summary>
    public abstract class CommunicationModuleConfiguration : ICommunicationModuleConfiguration
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationModuleConfiguration"/>.
        /// </summary>
        protected CommunicationModuleConfiguration()
        {
            this.Autostart = true;
        } 
        #endregion

        #region ICommunicationModuleConfiguration Members

        /// <summary>
        /// Gets or sets module name.
        /// </summary>
        [XmlAttribute]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets module dependencies.
        /// </summary>
        [XmlElement(ElementName = "internalDependencies")]
        public SerializableStringDictionary InternalDependencies { get; set; }

        /// <summary>
        /// Gest or sets module type.
        /// </summary>
        [XmlIgnore]
        public CommunicationModuleType ModuleType { get; set; }

        /// <summary>
        /// Gets or sets if module starts automatically.
        /// </summary>
        [XmlAttribute]
        public bool Autostart { get; set; }

        /// <summary>
        /// Sets configuration default values.
        /// </summary>
        public abstract void SetDefaultValues();

        #endregion
    }
}
