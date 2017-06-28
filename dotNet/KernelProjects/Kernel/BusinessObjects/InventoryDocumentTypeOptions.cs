using System;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    internal class InventoryDocumentTypeOptions
    {
        private DocumentType documentType;

        public string IncomeDifferentialDocumentTemplate
        {
            get
            {
                var attr = this.documentType.Options.Element("inventoryDocument").Attribute("incomeDifferentialDocumentTemplate");

                if (attr == null || attr.Value == String.Empty)
                    throw new InvalidOperationException("No 'incomeDifferentialDocumentTemplate' specified in document type.");

                return attr.Value;
            }
        }

        public string OutcomeDifferentialDocumentTemplate
        {
            get
            {
                var attr = this.documentType.Options.Element("inventoryDocument").Attribute("outcomeDifferentialDocumentTemplate");

                if (attr == null || attr.Value == String.Empty)
                    throw new InvalidOperationException("No 'outcomeDifferentialDocumentTemplate' specified in document type.");

                return attr.Value;
            }
        }

        public InventoryDocumentTypeOptions(DocumentType documentType)
        {
            this.documentType = documentType;
        }
    }
}
