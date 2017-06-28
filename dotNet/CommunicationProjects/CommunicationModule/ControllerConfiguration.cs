namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Serialization;

    /// <summary>
    /// Configuration of DatabaseConnector module.
    /// </summary>
    [XmlRoot(ElementName = "controller")]
    public sealed class ControllerConfiguration : CommunicationModuleConfiguration
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="ControllerConfiguration"/> class.
        /// </summary>
        public ControllerConfiguration()
        {
            SetDefaultValues();
        } 
        #endregion

        #region Configuration Properties
        /// <summary>
        /// Gets or sets the name of assembly and main factory that contains classes for specific application.
        /// </summary>
        /// <value>The name of the assembly.</value>
        [XmlAttribute]
        public string ProgramSpecificAssembly { get; set; }

        #endregion

        #region CommunicationModuleConfiguration Members
        /// <summary>
        /// Sets DatabaseConnector configuration default values.
        /// </summary>
        public override void SetDefaultValues()
        {
            ModuleType = CommunicationModuleType.Other;
        } 
        #endregion

    }
}
