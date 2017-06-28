using System;
using Makolab.Fractus.Kernel.BusinessObjects;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for a <see cref="BusinessObject"/> to be independently versioned.
    /// </summary>
    public interface IVersionedBusinessObject : IBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        Guid? NewVersion { get; set; }
    }
}
