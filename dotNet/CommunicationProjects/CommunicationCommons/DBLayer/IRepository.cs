namespace Makolab.Commons.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Interface for repository objects.
    /// </summary>
    /// <typeparam name="T">Type of domain object that is handled by repository.</typeparam>
    public interface IRepository<T>
    {
        /// <summary>
        /// Gets the active database context.
        /// </summary>
        /// <value>The context.</value>
        IUnitOfWork Context { get; }
    }
}
