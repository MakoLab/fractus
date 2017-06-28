namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Commons.Communication;

    /// <summary>
    /// Repositories base class.
    /// </summary>
    /// <typeparam name="T">Type of repository object.</typeparam>
    public abstract class Repository<T> : IRepository<T>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Repository&lt;T&gt;"/> class.
        /// </summary>
        /// <param name="context">The context.</param>
        protected Repository(IUnitOfWork context)
        {
            this.Context = context;
        }

        /// <summary>
        /// Gets or sets the UnitOfWork.
        /// </summary>
        /// <value>The context.</value>
        public IUnitOfWork Context { get; protected set; }
    }
}
