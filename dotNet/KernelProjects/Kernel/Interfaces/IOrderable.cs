using Makolab.Fractus.Kernel.BusinessObjects;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for a <see cref="BusinessObject"/> to be save and load from the database in order.
    /// </summary>
    public interface IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        int Order { get; set; }
    }
}
