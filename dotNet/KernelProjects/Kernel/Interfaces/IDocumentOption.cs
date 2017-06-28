using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;

namespace Makolab.Fractus.Kernel.Interfaces
{
    internal interface IDocumentOption
    {
		bool ExecuteWithinTransaction { get; }
        void Execute(Document document);
        XElement Serialize();
    }
}
