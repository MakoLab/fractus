using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents.Options
{
    internal class CloseProcessOption : IDocumentOption
    {
        public CloseProcessOption()
        {
        }

		public bool ExecuteWithinTransaction
		{
			get { return false; }
		}

        public void Execute(Document document)
        {
            if (document.IsBeforeSystemStart)
                return;

            DocumentAttrValue attr = document.Attributes[DocumentFieldName.Attribute_ProcessState];

            if (attr != null)
            {
                ComplaintDocument complaintDocument = (ComplaintDocument)document;

                foreach (var line in complaintDocument.Lines)
                {
                    decimal decisionQuantity = line.ComplaintDecisions.Children.Sum(d => d.Quantity);

                    if (line.Quantity != decisionQuantity)
                        throw new ClientException(ClientExceptionId.ComplaintDocumentCloseError);

                    if (line.ComplaintDecisions.Children.Where(dd => dd.RealizeOption != RealizationStage.Realized).FirstOrDefault() != null)
                        throw new ClientException(ClientExceptionId.ComplaintDocumentCloseError);
                }

                attr.Value.Value = "closed";
                complaintDocument.DocumentStatus = DocumentStatus.Committed;
            }
        }

        public XElement Serialize()
        {
            XElement element = new XElement("closeProcess", new XAttribute("selected", "1"));
            return element;
        }
    
}
}
