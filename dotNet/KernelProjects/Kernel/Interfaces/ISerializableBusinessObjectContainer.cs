using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.Interfaces
{
    public interface ISerializableBusinessObjectContainer
    {
        XElement Serialize();
        void Deserialize(XElement element);
    }
}
