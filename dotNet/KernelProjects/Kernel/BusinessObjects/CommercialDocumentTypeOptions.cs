using System;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    /// <summary>
    /// Class representing document options allowed for commercial documents.
    /// </summary>
    internal class CommercialDocumentTypeOptions : DocumentTypeOptions
    {
		protected override string OptionsRootElementName { get { return "commercialDocument"; } }
		
		/// <summary>
        /// Gets document's calculation type.
        /// </summary>
        public CalculationType CalculationType
        {
            get
            {
                string type = this.OptionsRootElement.Attribute("calculationType").Value;

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
                string val = this.OptionsRootElement.Attribute("allowCalculationTypeChange").Value;
                return Convert.ToBoolean(val, CultureInfo.InvariantCulture);
            }
        }

        public string CommunicationPackageName
        {
            get
            {
                if (this.OptionsRootElement.Attribute("communicationPackageName") == null ||
                    this.OptionsRootElement.Attribute("communicationPackageName").Value.Length == 0)
                    return null;
                else
                    return this.OptionsRootElement.Attribute("communicationPackageName").Value;
            }
        }

        public bool IsShiftOrder
        {
            get
            {
                if (this.OptionsRootElement.Attribute("isShiftOrder") == null ||
                    this.OptionsRootElement.Attribute("isShiftOrder").Value.Length == 0)
                    return false;
                else
                    return this.OptionsRootElement.Attribute("isShiftOrder").Value.ToUpperInvariant() == "TRUE";
            }
        }
        
        public string BeforeSystemStartWhCorrectionTemplate
        {
            get
            {
                if (this.OptionsRootElement.Attribute("beforeSystemStartWhCorrectionTemplate") == null ||
                    this.OptionsRootElement.Attribute("beforeSystemStartWhCorrectionTemplate").Value.Length == 0)
                    return null;
                else
                    return this.OptionsRootElement.Attribute("beforeSystemStartWhCorrectionTemplate").Value;
            }
        }

        public string SimulatedInvoice
        {
            get
            {
                if (this.OptionsRootElement.Attribute("simulatedInvoice") == null ||
                    this.OptionsRootElement.Attribute("simulatedInvoice").Value.Length == 0)
                    return null;
                else
                    return this.OptionsRootElement.Attribute("simulatedInvoice").Value;
            }
        }

        /// <summary>
        /// Gets document's summation type.
        /// </summary>
        public SummationType SummationType
        {
            get
            {
                string type = this.OptionsRootElement.Attribute("summationType").Value;

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
                string val = this.OptionsRootElement.Attribute("allowOtherCurrencies").Value;
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
                string val = this.OptionsRootElement.Attribute("allowMultiplePositions").Value;
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
                string type = this.OptionsRootElement.Attribute("contractorOptionality").Value;

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
                string val = this.OptionsRootElement.Attribute("allowIssuingPersonChange").Value;
                return Convert.ToBoolean(val, CultureInfo.InvariantCulture);
            }
        }

        /// <summary>
        /// Gets the collection of payment methods id that the document can use.
        /// </summary>
        public XElement PaymentMethods
        {
            get
            {
                return this.OptionsRootElement.Element("paymentMethods");
            }
        }

        public bool IsInvoiceAppendable
        {
            get
            {
                if (this.OptionsRootElement.Attribute("invoiceAppendable") == null ||
                    this.OptionsRootElement.Attribute("invoiceAppendable").Value == "")
                    return false;
                else
                    return true;
            }
        }

        public string RetailInvoiceTemplateName
        {
            get
            {
                if (this.OptionsRootElement.Attribute("invoiceAppendable") == null ||
                    this.OptionsRootElement.Attribute("invoiceAppendable").Value.Length == 0)
                    return null;
                else
                    return this.OptionsRootElement.Attribute("invoiceAppendable").Value;
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommercialDocumentTypeOptions"/> class.
        /// </summary>
        /// <param name="documentType"><see cref="DocumentType"/> object to which to attach the options.</param>
        public CommercialDocumentTypeOptions(DocumentType documentType) : base(documentType) { }
    }
}
