using System;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    internal class ServiceDocumentTypeOptions
    {
        private DocumentType documentType;

        /// <summary>
        /// Gets document's calculation type.
        /// </summary>
        public CalculationType CalculationType
        {
            get
            {
                string type = this.documentType.Options.Element("serviceDocument").Attribute("calculationType").Value;

                return (CalculationType)Enum.Parse(typeof(CalculationType), type, true);
            }
        }

        /// <summary>
        /// Gets a value indicating whether the document can change calculation type.
        /// </summary>
        public bool AllowCalculationTypeChange
        {
            get
            {
                string val = this.documentType.Options.Element("serviceDocument").Attribute("allowCalculationTypeChange").Value;
                return Convert.ToBoolean(val, CultureInfo.InvariantCulture);
            }
        }

        /// <summary>
        /// Gets document's summation type.
        /// </summary>
        public SummationType SummationType
        {
            get
            {
                string type = this.documentType.Options.Element("serviceDocument").Attribute("summationType").Value;

                return (SummationType)Enum.Parse(typeof(SummationType), type, true);
            }
        }

        /// <summary>
        /// Gets a value indicating whether the document can use other currencies than system currency.
        /// </summary>
        public bool AllowOtherCurrencies
        {
            get
            {
                string val = this.documentType.Options.Element("serviceDocument").Attribute("allowOtherCurrencies").Value;
                return Convert.ToBoolean(val, CultureInfo.InvariantCulture);
            }
        }

        /// <summary>
        /// Gets a value indicating whether the document can contains more than one document line.
        /// </summary>
        public bool AllowMultiplePositions
        {
            get
            {
                string val = this.documentType.Options.Element("serviceDocument").Attribute("allowMultiplePositions").Value;
                return Convert.ToBoolean(val, CultureInfo.InvariantCulture);
            }
        }

        /// <summary>
        /// Gets the contractor optionality in the document.
        /// </summary>
        public Optionality ContractorOptionality
        {
            get
            {
                string type = this.documentType.Options.Element("serviceDocument").Attribute("contractorOptionality").Value;

                return (Optionality)Enum.Parse(typeof(Optionality), type, true);
            }
        }

        /// <summary>
        /// Gets a value indicating whether issuing person on the document can be changed.
        /// </summary>
        public bool AllowIssuingPersonChange
        {
            get
            {
                string val = this.documentType.Options.Element("serviceDocument").Attribute("allowIssuingPersonChange").Value;
                return Convert.ToBoolean(val, CultureInfo.InvariantCulture);
            }
        }

        /// <summary>
        /// Gets the collection of document features id that the document can contain.
        /// </summary>
        public XElement DocumentFeatures
        {
            get
            {
                return this.documentType.Options.Element("serviceDocument").Element("documentFeatures");
            }
        }

        public ServiceDocumentTypeOptions(DocumentType documentType)
        {
            this.documentType = documentType;
        }
    }
}
