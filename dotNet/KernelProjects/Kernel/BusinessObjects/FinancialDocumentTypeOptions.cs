using System;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    internal class FinancialDocumentTypeOptions
    {
        private DocumentType documentType;

        public FinancialDirection FinancialDirection
        {
            get
            {
                string type = this.documentType.Options.Element("financialDocument").Attribute("financialDirection").Value;

                return (FinancialDirection)Enum.Parse(typeof(FinancialDirection), type, true);
            }
        }

        public Guid? PayerId
        {
            get
            {
                if (this.documentType.Options.Element("financialDocument").Attribute("payerId") == null)
                    return null;

                string pId = this.documentType.Options.Element("financialDocument").Attribute("payerId").Value;

                if (!String.IsNullOrEmpty(pId))
                    return new Guid(pId);
                else
                    return null;
            }
        }

        public int RegisterCategory
        {
            get
            {
                string val = this.documentType.Options.Element("financialDocument").Attribute("registerCategory").Value;

                return Convert.ToInt32(val, CultureInfo.InvariantCulture);
            }
        }

		public RegisterCategory RegisterCategoryAsEnum
		{
			get
			{
				return (RegisterCategory)Enum.ToObject(typeof(RegisterCategory), this.RegisterCategory);
			}
		}

        public XElement DocumentFeatures
        {
            get
            {
                return this.documentType.Options.Element("financialDocument").Element("documentFeatures");
            }
        }

        public FinancialDocumentTypeOptions(DocumentType documentType)
        {
            this.documentType = documentType;
        }
    }
}
