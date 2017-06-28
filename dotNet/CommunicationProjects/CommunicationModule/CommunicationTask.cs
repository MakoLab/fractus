namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading;

    /// <summary>
    /// Base class for communication module's tasks.
    /// </summary>
    /// <remarks>
    /// Communication module task is well defined piece of work running is seprete thread like package execution.
    /// </remarks>
    /// <typeparam name="TManager">The type of the manager associated with the task.</typeparam>
    public abstract class CommunicationTask<TManager>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationTask&lt;T&gt;"/>.
        /// </summary>
        /// <param name="manager">The manager associated with communication task.</param>
        protected CommunicationTask(TManager manager)
        {
            this.Manager = manager;
        }
        
        /// <summary>
        /// Gets or sets communication module manager.
        /// </summary>
        public TManager Manager { get; set; }

        /// <summary>
        /// Gest or sets whether task is enabled or disabled.
        /// </summary>
        protected bool IsEnabled { get; set; }

        /// <summary>
        /// Thread associated with the task.
        /// </summary>
        protected Thread Task { get; set; }

        /// <summary>
        /// Starts the task in seprete thread. 
        /// </summary>
        public virtual void Start()
        {
            this.IsEnabled = true;
            this.Task = new Thread(Run);
            this.Task.Start();
        }

        /// <summary>
        /// Stops the task.
        /// </summary>
        public virtual void Stop()
        {
            this.IsEnabled = false;
            if (this.Task == null) return;

            this.Task.Join(TimeSpan.FromSeconds(10));
        }

        /// <summary>
        /// Task main method.
        /// </summary>
        protected abstract void Run();
    }
}
