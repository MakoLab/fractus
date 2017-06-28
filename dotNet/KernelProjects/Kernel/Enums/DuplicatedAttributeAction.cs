
using System.Xml.Linq;
namespace Makolab.Fractus.Kernel.Enums
{
    public enum DuplicatedAttributeAction
    {
        NoDuplicate,
        OneInstance,
        Concatenate,
        Duplicate
    }

	internal static class DuplicatedAttributeActionExtensions
	{
		public static DuplicatedAttributeAction FromXElement(XElement daaElement)
		{
			if (daaElement != null)
			{
				XAttribute attr = daaElement.Attribute("action");

				if (attr == null || attr.Value.ToUpperInvariant() == "ONEINSTANCE")
					return DuplicatedAttributeAction.OneInstance;
				else if (attr.Value.ToUpperInvariant() == "CONCATENATE")
					return DuplicatedAttributeAction.Concatenate;
				else //if (attr.Value.ToUpperInvariant() == "DUPLICATE")
					return DuplicatedAttributeAction.Duplicate;
			}
			else
				return DuplicatedAttributeAction.NoDuplicate;
		}
	}
}
