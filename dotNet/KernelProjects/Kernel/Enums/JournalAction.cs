
namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies allowed journal actions.
    /// </summary>
    public enum JournalAction
    {
        /// <summary>
        /// Unspecified action.
        /// </summary>
        Unspecified,

        /// <summary>
        /// User logged on.
        /// </summary>
        User_LogOn,

        /// <summary>
        /// User logged off.
        /// </summary>
        User_LogOff,

        /// <summary>
        /// A new Contractor was created.
        /// </summary>
        Contractor_New,

		/// <summary>
		/// Contractor was edited.
		/// </summary>
		Contractor_Edit,

		/// <summary>
		/// Contractor was deleted.
		/// </summary>
		Contractor_Delete,

        /// <summary>
        /// A new Item was created.
        /// </summary>
        Item_New,

		/// <summary>
		/// Item was edited.
		/// </summary>
		Item_Edit,

		/// <summary>
		/// Item was deleted.
		/// </summary>
		Item_Delete,

        /// <summary>
        /// Document was created.
        /// </summary>
        Document_New,

        /// <summary>
        /// Document was edited.
        /// </summary>
        Document_Edit,

		/// <summary>
		/// Documents were unrelated.
		/// </summary>
		Documents_Unrelate,

		/// <summary>
		/// Documents were related.
		/// </summary>
		Documents_Relate,

		/// <summary>
		/// Configuration value was edited
		/// </summary>
		ConfigValue_New,

		/// <summary>
		/// Configuration value was edited
		/// </summary>
		ConfigValue_Edit,

		/// <summary>
		/// Configuration value was deleted
		/// </summary>
		ConfigValue_Delete,

		/// <summary>
		/// Dictionary was saved
		/// </summary>
		Dictionary_Save
    }
}
