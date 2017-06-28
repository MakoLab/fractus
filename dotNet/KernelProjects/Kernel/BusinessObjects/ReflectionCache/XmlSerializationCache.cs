using System.Reflection;
using Makolab.Fractus.Kernel.Attributes;

namespace Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache
{
    public class XmlSerializationCache
    {
        public PropertyInfo Property { get; set; }
        public XmlSerializableAttribute Attribute { get; set; }
    }
}
