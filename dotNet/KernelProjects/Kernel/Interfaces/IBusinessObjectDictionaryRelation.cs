using System;
using Makolab.Fractus.Kernel.BusinessObjects;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for a <see cref="BusinessObject"/> to be a relation between an ordinary <see cref="BusinessObject"/> and a dictionary <see cref="BusinessObject"/>.
    /// </summary>
    public interface IBusinessObjectDictionaryRelation : IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the main <see cref="BusinessObject"/>.
        /// </summary>
        bool UpgradeMainObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets related dictionary object's id.
        /// </summary>
        Guid RelatedDictionaryObjectId { get; set; }
    }
}
