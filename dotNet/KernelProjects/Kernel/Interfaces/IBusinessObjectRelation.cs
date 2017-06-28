using Makolab.Fractus.Kernel.BusinessObjects;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for a <see cref="BusinessObject"/> to be a relation between two other <see cref="BusinessObject"/>s.
    /// </summary>
    public interface IBusinessObjectRelation : IVersionedBusinessObject
    {
        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the main <see cref="BusinessObject"/>.
        /// </summary>
        bool UpgradeMainObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the related <see cref="BusinessObject"/>.
        /// </summary>
        bool UpgradeRelatedObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets related <see cref="IBusinessObject"/>.
        /// </summary>
        IBusinessObject RelatedObject { get; set; }
    }
}
