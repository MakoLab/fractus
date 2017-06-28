using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for an object to contain default settings for itself and for child objects.
    /// </summary>
    public interface IDefaultsHolder
    {
        /// <summary>
        /// Gets or sets an xml storing default settings for <see cref="IBusinessObject"/>.
        /// </summary>
        XDocument DefaultsXml { get; }
    }
}
