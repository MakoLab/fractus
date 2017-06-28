using Makolab.Fractus.Kernel.BusinessObjects;

namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies status of any <see cref="BusinessObject"/>.
    /// </summary>
    public enum BusinessObjectStatus
    {
        /// <summary>
        /// Object status is unknown.
        /// </summary>
        Unknown,

        /// <summary>
        /// Object is new.
        /// </summary>
        New,

        /// <summary>
        /// Object has been modified.
        /// </summary>
        Modified,

        /// <summary>
        /// Object has been deleted.
        /// </summary>
        Deleted,

        /// <summary>
        /// Object hasn't been modified by the client.
        /// </summary>
        Unchanged
    }
}
