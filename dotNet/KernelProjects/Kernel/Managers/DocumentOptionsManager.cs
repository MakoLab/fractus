using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.Managers
{
    internal static class DocumentOptionsManager
    {
        public static XElement GetOptionsForDocument(Document document)
        {
            if (document == null || document.DocumentTypeId == Guid.Empty)
                return null;

            XElement options = new XElement("options");

            XElement issueOptions = ((XElement)document.DocumentType.Options.FirstNode).Element("issueOptions");

            //faktura wystawiana do paragonu ma nie miec standardowych opcji
            if (document.Source != null && document.Source.Attribute("type").Value == "invoiceToBill" ||
                (document.Relations.Children.Where(r => r.RelationType == DocumentRelationType.InvoiceToBill).FirstOrDefault() != null &&
                !document.DocumentType.CommercialDocumentOptions.IsInvoiceAppendable))
            {
                //document.DocumentOptions.Add(new UpdatePaymentSettlementsOption());
            }
            else if (issueOptions != null)
            {
                //faktury zaliczkowe nie moga wystawiac dok. magazynowego
                if (document.Source != null && document.Source.Attribute("type").Value == "salesOrder" ||
                    (document.Relations.Children.Where(r => r.RelationType == DocumentRelationType.SalesOrderToInvoice).FirstOrDefault() != null))
                {
                    XElement outcomeFromSales = issueOptions.Elements("generateDocument").Where(o => o.Attribute("method") != null && o.Attribute("method").Value == "outcomeFromSales").FirstOrDefault();

                    if (outcomeFromSales != null)
                        outcomeFromSales.Remove();
                }

                options.Add(issueOptions.Elements());
            }

            foreach (IDocumentOption option in document.DocumentOptions)
            {
                options.Add(option.Serialize());
            }

            return options;
        }
    }
}
