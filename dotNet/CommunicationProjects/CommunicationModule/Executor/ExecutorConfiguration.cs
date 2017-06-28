namespace Makolab.Fractus.Communication.Executor
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Serialization;

    /// <summary>
    /// Configuration of Executor module.
    /// </summary>
    [XmlRoot(ElementName = "executor")]
    public sealed class ExecutorConfiguration : CommunicationModuleConfiguration, ICommunicationModuleCreator
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="ExecutorConfiguration"/> class.
        /// </summary>
        public ExecutorConfiguration()
        {
            SetDefaultValues();
        } 
        #endregion

        /// <summary>
        /// Gets or sets the maximum amout of returned transactions.
        /// </summary>
        /// <value>The maximum amout of returned transactions.</value>
        /// <remarks>
        /// MaxTransactionCount is used in retrieving unprocessed packages. 
        /// It limits maximum amout of local transactions (groups of packages) that are returned.
        /// </remarks>
        [XmlAttribute]
        public int MaxTransactionCount { get; set; }

        /// <summary>
        /// Gets or sets the package processing interval in miliseconds.
        /// </summary>
        /// <value>The package processing interval in miliseconds.</value>
        [XmlAttribute]
        public int ExecutionInterval { get; set; }

        /// <summary>
        /// Gets or sets whether custom package execution method is used.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if custom execution method should be used; otherwise, <c>false</c>.
        /// </value>
        [XmlAttribute]
        public bool UseCustomPackageExecutor { get; set; } 

        /// <summary>
        /// Sets configuration default values.
        /// </summary>
        public override void SetDefaultValues()
        {
            ModuleType = CommunicationModuleType.Executor;
            this.MaxTransactionCount = 5;
            this.ExecutionInterval = 1000;
            this.UseCustomPackageExecutor = false;
        }



        #region ICommunicationModuleCreator Members

        /// <summary>
        /// Creates the executor module.
        /// </summary>
        /// <returns>Created executor module manager.</returns>
        public ICommunicationModule CreateModule()
        {
            return new ExecutorManager();
        }

        #endregion
    }
}
