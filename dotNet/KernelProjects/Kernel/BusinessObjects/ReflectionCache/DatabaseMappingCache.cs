using System.Reflection;
using Makolab.Fractus.Kernel.Attributes;

namespace Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache
{
    public class DatabaseMappingCache
    {
        public PropertyInfo Property { get; set; }
        public DatabaseMappingAttribute Attribute { get; set; }
    }
}
