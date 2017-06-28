using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for a <see cref="BusinessObject"/> to be a LabeledDictionaryBusinessObject.
    /// </summary>
    public interface ILabeledDictionaryBusinessObject : IBusinessObject
    {
        /// <summary>
        /// Gets or sets label. Cannot be null.
        /// </summary>
        XElement Labels { get; set; }
    }
}
