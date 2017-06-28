using Makolab.Fractus.Kernel.Coordinators;

namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies phases that the <see cref="Coordinator"/> can take, e.g. it can load plugins during object creations, loads and saves.
    /// </summary>
    public enum CoordinatorPluginPhase
    {
        /// <summary>
        /// Coordinator wants to load plugins in order to save object to database.
        /// </summary>
        SaveObject,

        /// <summary>
        /// Coordinator wants to load plugins in order to create object to database.
        /// </summary>
        CreateObject,

        /// <summary>
        /// Coordinator wants to load plugins in order to load object to database.
        /// </summary>
        LoadObject
    }
}
