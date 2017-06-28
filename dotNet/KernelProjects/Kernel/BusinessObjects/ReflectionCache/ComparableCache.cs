using System.Reflection;
using Makolab.Fractus.Kernel.Attributes;

namespace Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache
{
    public class ComparableCache
    {
        public PropertyInfo Property { get; set; }
        public ComparableAttribute Attribute { get; set; }
    }
}
