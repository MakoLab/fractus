using System;

namespace Makolab.Fractus.Kernel.Attributes
{
    [AttributeUsage(AttributeTargets.Property, AllowMultiple = false, Inherited = true)]
    public sealed class ComparableAttribute : Attribute
    {
        public ComparableAttribute()
        { }
    }
}
