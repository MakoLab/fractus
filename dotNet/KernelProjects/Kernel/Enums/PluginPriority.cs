using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Coordinators.Plugins;

namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies <see cref="Coordinator"/>'s <see cref="Plugin"/>s priority.
    /// </summary>
    public enum PluginPriority
    {
        /// <summary>
        /// Critical priority.
        /// </summary>
        Critical = 0,

        /// <summary>
        /// High priority.
        /// </summary>
        High = 1,

        /// <summary>
        /// Above normal priority.
        /// </summary>
        AboveNormal = 2,

        /// <summary>
        /// Normal (default) priority.
        /// </summary>
        Normal = 3,

        /// <summary>
        /// Below normal priority.
        /// </summary>
        BelowNormal = 4,

        /// <summary>
        /// Low priority.
        /// </summary>
        Low = 5
    }
}
