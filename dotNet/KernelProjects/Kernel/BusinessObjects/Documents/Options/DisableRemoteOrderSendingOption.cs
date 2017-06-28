using System.Xml.Linq;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents.Options
{
    internal class DisableRemoteOrderSendingOption : IDocumentOption
    {
        public DisableRemoteOrderSendingOption()
        {
        }

		public bool ExecuteWithinTransaction
		{
			get { return false; }
		}
		
		public void Execute(Document document)
        {
        }

        public XElement Serialize()
        {
            XElement element = new XElement("disableRemoteOrderSending", new XAttribute("selected", "1"));
            return element;
        }
    }
}
