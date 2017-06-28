namespace Makolab.Fractus.Communication.Transmitter
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Serialization;

    /// <summary>
    /// Configuration of Transmitter module.
    /// </summary>
    [XmlRoot(ElementName = "transmitter")]
    public sealed class TransmitterConfiguration : CommunicationModuleConfiguration, ICommunicationModuleCreator
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="TransmitterConfiguration"/> class.
        /// </summary>
        public TransmitterConfiguration()
        {
            SetDefaultValues();
        } 
        #endregion

        #region Configuration Properties

        /// <summary>
        /// Gets or sets the packages send interval in miliseconds.
        /// </summary>
        /// <value>The package send interval in miliseconds.</value>
        [XmlAttribute]
        public int SendInterval { get; set; }

        /// <summary>
        /// Gets or sets the packages retrieve interval in miliseconds.
        /// </summary>
        /// <value>The package retrieve interval in miliseconds.</value>
        [XmlAttribute]
        public int ReceiveInterval { get; set; }

        /// <summary>
        /// Gets or sets the statistics send interval in miliseconds.
        /// </summary>
        /// <value>The statistics send interval in miliseconds.</value>
        [XmlAttribute]
        public int UpdateStatisticsIntervalInSec { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Receiver is enabled.
        /// </summary>
        /// <value><c>true</c> if Receiver is enabled; otherwise, <c>false</c>.</value>
        [XmlAttribute]
        public bool EnableReceiver { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Sender is enabled.
        /// </summary>
        /// <value><c>true</c> if Sender is enabled; otherwise, <c>false</c>.</value>
        [XmlAttribute]
        public bool EnableSender { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether statistics update is enabled.
        /// </summary>
        /// <value><c>true</c> if statistics update is enabled; otherwise, <c>false</c>.</value>
        [XmlAttribute]
        public bool EnableStatistics { get; set; }

        /// <summary>
        /// Gets or sets the maximum amout of returned transactions.
        /// </summary>
        /// <value>The maximum amout of returned transactions.</value>
        /// <remarks>
        /// MaxTransactionCount is used in retrieving undelivered packages. 
        /// It limits maximum amout of local transactions (groups of packages) that are returned.
        /// </remarks>
        [XmlAttribute]
        public int MaxTransactionCount { get; set; }

        /// <summary>
        /// Gets or sets the store procedure name that returns some additional data that is send with communication statistics
        /// </summary>
        /// <value>The additional data store procedure name.</value>
        [XmlAttribute]
        public string AdditionalDataStoreProcedure { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether package validation is enabled.
        /// </summary>
        /// <value><c>true</c> if package validation is enabled; otherwise, <c>false</c>.</value>
        [XmlAttribute]
        public bool EnablePackageValidation { get; set; } 
        #endregion

        /// <summary>
        /// Sets configuration default values.
        /// </summary>
        public override void SetDefaultValues()
        {
            ModuleType                          = CommunicationModuleType.Transmitter;
            this.SendInterval                   = 3000;
            this.ReceiveInterval                = 3000;
            this.UpdateStatisticsIntervalInSec  = 30;
            this.EnableReceiver                 = true;
            this.EnableSender                   = true;
            this.EnableStatistics               = true;
            this.EnablePackageValidation        = false;
            this.MaxTransactionCount            = 20;
        }

        #region ICommunicationModuleCreator Members

        /// <summary>
        /// Creates the transmitter module.
        /// </summary>
        /// <returns>Created transmitter module.</returns>
        public ICommunicationModule CreateModule()
        {
            return new TransmitterManager();
        }

        #endregion
    }
}
