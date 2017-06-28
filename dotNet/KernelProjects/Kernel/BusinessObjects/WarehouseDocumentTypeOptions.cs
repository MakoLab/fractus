using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    /// <summary>
    /// Class representing document options allowed for warehouse documents.
    /// </summary>
    internal class WarehouseDocumentTypeOptions : DocumentTypeOptions
    {
		protected override string OptionsRootElementName { get { return "warehouseDocument"; }}

        /// <summary>
        /// Gets the document warehouse direction.
        /// </summary>
        public WarehouseDirection WarehouseDirection
        {
            get
            {
                string type = this.OptionsRootElement.Attribute("warehouseDirection").Value;

                return (WarehouseDirection)Enum.Parse(typeof(WarehouseDirection), type, true);
            }
        }

        public string AutomaticCostCorrectionTemplate
        {
            get
            {
                XAttribute attr = this.OptionsRootElement.Attribute("automaticCostCorrectionTemplate");

                if (attr != null)
                    return attr.Value;
                else
                    return null;
            }
        }

        public string CorrectiveDocumentTemplate
        {
            get
            {
                XElement correctiveDocuments = this.OptionsRootElement.Element("correctiveDocuments");

                if (correctiveDocuments != null && correctiveDocuments.HasElements)
                {
                    XElement firstElement = (XElement)correctiveDocuments.FirstNode;
                    return firstElement.Attribute("template").Value;
                }

                return null;
            }
        }

		public RelatedLinesChangePolicy RelatedLinesChangePolicy
		{
			get
			{
				RelatedLinesChangePolicy result = RelatedLinesChangePolicy.Unknown;
				XElement wdElement = this.OptionsRootElement;
				if (wdElement != null)
				{
					XAttribute rlcpAttribute = wdElement.Attribute("relatedLinesChangePolicy");
					if (rlcpAttribute != null)
						result = (RelatedLinesChangePolicy)Enum.Parse(typeof(RelatedLinesChangePolicy), rlcpAttribute.Value, true);
				}
				return result;
			}
		}

		/// <summary>
        /// Initializes a new instance of the <see cref="WarehouseDocumentTypeOptions"/> class.
        /// </summary>
        /// <param name="documentType"><see cref="DocumentType"/> object to which to attach the options.</param>
		public WarehouseDocumentTypeOptions(DocumentType documentType) : base(documentType) { }
    }
}
