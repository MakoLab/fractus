
namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies item relations type's name.
    /// </summary>
    public enum ItemRelationTypeName
    {
        /// <summary>
        /// Unknown relation.
        /// </summary>
        Unknown,

		/// <summary>
		/// Item - supplier relation.
		/// </summary>
		Item_Supplier,

		/// <summary>
		/// Item - owner relation.
		/// </summary>
		Item_Owner,

        /// <summary>
        /// Item - equivalent group relation.
        /// </summary>
        Item_EquivalentGroup,
        Item_Equivalent,
        /// <summary>
        /// Item - FileDescriptor relation.
        /// </summary>
        Item_FileDescriptor,

		/// <summary>
		/// Item - Item relation.
		/// </summary>
		Item_ItemRelation
    }
}
