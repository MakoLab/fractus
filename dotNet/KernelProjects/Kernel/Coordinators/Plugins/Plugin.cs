
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    /// <summary>
    /// Base class for all <see cref="Coordinator"/>'s plugins.
    /// </summary>
    public abstract class Plugin
    {
        private PluginPriority loadObjectsPriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>LoadObject</c> phase.
        /// </summary>
        public PluginPriority LoadObjectsPriority
        { 
            get { return this.loadObjectsPriority; }
            protected set { this.loadObjectsPriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>LoadObjects</c> phase.
        /// </summary>
        /// <param name="param">Optional parameter.</param>
        public virtual void OnLoadObjects(object param)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>PreValidate</c> phase.
        /// </summary>
        private PluginPriority preValidatePriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>PreValidate</c> phase.
        /// </summary>
        public PluginPriority PreValidatePriority
        {
            get { return this.preValidatePriority; }
            protected set { this.preValidatePriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>PreValidate</c> phase.
        /// </summary>
        /// <param name="param">Optional parameter.</param>
        public virtual void OnPreValidate(object param)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>ExecuteLogic</c> phase.
        /// </summary>
        private PluginPriority executeLogicPriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>ExecuteLogic</c> phase.
        /// </summary>
        public PluginPriority ExecuteLogicPriority
        {
            get { return this.executeLogicPriority; }
            protected set { this.executeLogicPriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>ExecuteLogic</c> phase.
        /// </summary>
        /// <param name="businessObject">Main business object currently processed.</param>
        public virtual void OnExecuteLogic(IBusinessObject businessObject)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>ValidateLogic</c> phase.
        /// </summary>
        private PluginPriority validateLogicPriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>ValidateLogic</c> phase.
        /// </summary>
        public PluginPriority ValidateLogicPriority
        {
            get { return this.validateLogicPriority; }
            protected set { this.validateLogicPriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>ValidateLogic</c> phase.
        /// </summary>
        /// <param name="param">Optional parameter.</param>
        public virtual void OnValidateLogic(object param)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>BeginTransaction</c> phase.
        /// </summary>
        private PluginPriority beginTransactionPriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>BeginTransaction</c> phase.
        /// </summary>
        public PluginPriority BeginTransactionPriority
        {
            get { return this.beginTransactionPriority; }
            protected set { this.beginTransactionPriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>BeginTransaction</c> phase.
        /// </summary>
        /// <param name="businessObject">Main business object currently processed.</param>
        public virtual void OnBeginTransaction(IBusinessObject businessObject)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>ValidateTransaction</c> phase.
        /// </summary>
        private PluginPriority validateTransactionPriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>ValidateTransaction</c> phase.
        /// </summary>
        public PluginPriority ValidateTransactionPriority
        {
            get { return this.validateTransactionPriority; }
            protected set { this.validateTransactionPriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>ValidateTransaction</c> phase.
        /// </summary>
        /// <param name="businessObject">Optional parameter.</param>
        public virtual void OnValidateTransaction(IBusinessObject businessObject)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>BeforeSave</c> phase.
        /// </summary>
        private PluginPriority beforeSavePriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>BeforeSave</c> phase.
        /// </summary>
        public PluginPriority BeforeSavePriority
        {
            get { return this.beforeSavePriority; }
            protected set { this.beforeSavePriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>BeforeSave</c> phase.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObject"/> that is to be saved.</param>
        public virtual void OnBeforeSave(IBusinessObject businessObject)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>AfterExecuteOperations</c> phase.
        /// </summary>
        private PluginPriority afterExecuteOperationsPriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>AfterExecuteOperations</c> phase.
        /// </summary>
        public PluginPriority AfterExecuteOperationsPriority
        {
            get { return this.afterExecuteOperationsPriority; }
            protected set { this.afterExecuteOperationsPriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>AfterExecuteOperations</c> phase.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObject"/> that has just been saved to database.</param>
        public virtual void OnAfterExecuteOperations(IBusinessObject businessObject)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>AfterSave</c> phase.
        /// </summary>
        private PluginPriority afterSavePriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>AfterSave</c> phase.
        /// </summary>
        public PluginPriority AfterSavePriority
        {
            get { return this.afterSavePriority; }
            protected set { this.afterSavePriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>AfterSave</c> phase.
        /// </summary>
        /// <param name="operationsList">The operations list.</param>
        /// <param name="returnXml">Xml that will be returned to the client.</param>
        public virtual void OnAfterSave(XDocument operationsList, XDocument returnXml)
        { }

        /// <summary>
        /// Value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>AfterCreate</c> phase.
        /// </summary>
        private PluginPriority afterCreatePriority = PluginPriority.Normal;

        /// <summary>
        /// Gets or sets the value indicating priority in which the <see cref="Plugin"/> have to be processed relatively to other plugins attached to the <c>AfterCreate</c> phase.
        /// </summary>
        public PluginPriority AfterCreatePriority
        {
            get { return this.afterCreatePriority; }
            protected set { this.afterCreatePriority = value; }
        }

        /// <summary>
        /// Method executed when parent <see cref="Coordinator"/> enters the <c>AfterCreate</c> phase.
        /// </summary>
        /// <param name="businessObject">Created <see cref="IBusinessObject"/> so far.</param>
        /// <param name="requestXml">Client's request Xml containing info about source document.</param>
        public virtual void OnAfterCreate(IBusinessObject businessObject, XDocument requestXml)
        { }
    }
}
