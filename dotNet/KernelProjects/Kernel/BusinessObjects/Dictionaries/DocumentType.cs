using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a document type (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "documentType")]
    [DatabaseMapping(TableName = "documentType")]
    internal class DocumentType : BusinessObject, ILabeledDictionaryBusinessObject, IVersionedBusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets <see cref="DocumentType"/>'s symbol. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "symbol")]
        [Comparable]
        [DatabaseMapping(ColumnName = "symbol")]
        public string Symbol { get; set; }

        /// <summary>
        /// Gets or sets <see cref="DocumentType"/>'s label. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

        /// <summary>
        /// Gets or sets <see cref="DocumentType"/>'s options. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlOptions")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlOptions")]
        public XElement Options { get; set; }

        /// <summary>
        /// Document options for commercial document type.
        /// </summary>
        public CommercialDocumentTypeOptions CommercialDocumentOptions { get; private set; }

        /// <summary>
        /// Document options for warehouse document type.
        /// </summary>
        public WarehouseDocumentTypeOptions WarehouseDocumentOptions { get; private set; }

        public FinancialDocumentTypeOptions FinancialDocumentOptions { get; private set; }

        public ServiceDocumentTypeOptions ServiceDocumentOptions { get; private set; }

        public InventoryDocumentTypeOptions InventoryDocumentOptions { get; private set; }

        /// <summary>
        /// Gets or sets the document category.
        /// </summary>
        [XmlSerializable(XmlField = "documentCategory")]
        [Comparable]
        [DatabaseMapping(ColumnName = "documentCategory")]
        public DocumentCategory DocumentCategory { get; set; }

        public BusinessObjectType BusinessObjectType { get; private set; }

		private NoneNegativeIntRange allowedPayments = null;
		public NoneNegativeIntRange AllowedPayments
		{
			get
			{
				if (this.allowedPayments == null) 
				{
					this.allowedPayments = 
						new NoneNegativeIntRange(this.Options.Elements().ElementAt(0).GetAtributeValueOrNull(XmlName.AllowedPayments));
				}
				return this.allowedPayments;
			}
		}

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentType"/> class with a specified xml root element.
        /// </summary>
        public DocumentType()
            : base(null, BusinessObjectType.DocumentType)
        {
            this.Labels = new XElement("labels");

            if (this.DocumentCategory == DocumentCategory.Sales || this.DocumentCategory == DocumentCategory.Purchase ||
                this.DocumentCategory == DocumentCategory.Order || this.DocumentCategory == DocumentCategory.Reservation ||
                this.DocumentCategory == DocumentCategory.SalesCorrection || this.DocumentCategory == DocumentCategory.PurchaseCorrection ||
                this.DocumentCategory == DocumentCategory.Technology || this.DocumentCategory == DocumentCategory.ProductionOrder)
            {
                this.CommercialDocumentOptions = new CommercialDocumentTypeOptions(this);
                this.BusinessObjectType = BusinessObjectType.CommercialDocument;
            }

            if (this.DocumentCategory == DocumentCategory.Warehouse || this.DocumentCategory == DocumentCategory.OutcomeWarehouseCorrection ||
                this.DocumentCategory == DocumentCategory.IncomeWarehouseCorrection)
            {
                this.WarehouseDocumentOptions = new WarehouseDocumentTypeOptions(this);
                this.BusinessObjectType = BusinessObjectType.WarehouseDocument;
            }

            if (this.DocumentCategory == DocumentCategory.Financial)
            {
                this.FinancialDocumentOptions = new FinancialDocumentTypeOptions(this);
                this.BusinessObjectType = BusinessObjectType.FinancialDocument;
            }

            if (this.DocumentCategory == DocumentCategory.Service)
            {
                this.ServiceDocumentOptions = new ServiceDocumentTypeOptions(this);
                this.BusinessObjectType = BusinessObjectType.ServiceDocument;
            }

            if (this.DocumentCategory == DocumentCategory.Complaint)
            {
                this.BusinessObjectType = BusinessObjectType.ComplaintDocument;
            }

            if (this.DocumentCategory == DocumentCategory.Inventory)
            {
                this.BusinessObjectType = BusinessObjectType.InventoryDocument;
                this.InventoryDocumentOptions = new InventoryDocumentTypeOptions(this);
            }
        }

        public bool CanHaveAttribute(string attributeName, Guid id)
        {
            if (String.IsNullOrEmpty(attributeName))
                throw new ArgumentException("attributeName cannot be null or String.Empty", attributeName);

            XElement docElement = (XElement)this.Options.FirstNode;
            XElement basicAttributes = docElement.Element("basicAttributes");
            XElement additionalAttributes = docElement.Element("additionalAttributes");
            XElement documentFeatures = docElement.Element("documentFeatures");

            if (basicAttributes != null && basicAttributes.Elements().Where(b => b.Attribute("name").Value == attributeName).FirstOrDefault() != null)
                return true;

            if (additionalAttributes != null && additionalAttributes.Elements().Where(b => b.Attribute("name").Value == attributeName).FirstOrDefault() != null)
                return true;

            if (documentFeatures != null && documentFeatures.Elements().Where(b => new Guid(b.Value) == id).FirstOrDefault() != null)
                return true;

            return false;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (String.IsNullOrEmpty(this.Symbol))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:symbol");

            if (this.Labels == null || !this.Labels.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlLabels");

            if (this.Options == null || !this.Options.HasElements)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:xmlOptions");

            if (this.DocumentCategory == DocumentCategory.Unknown)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:documentCategory");
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            if (this.DocumentCategory == DocumentCategory.Sales || this.DocumentCategory == DocumentCategory.Purchase ||
                this.DocumentCategory == DocumentCategory.Order || this.DocumentCategory == DocumentCategory.Reservation ||
                this.DocumentCategory == DocumentCategory.SalesCorrection || this.DocumentCategory == DocumentCategory.PurchaseCorrection ||
                this.DocumentCategory == DocumentCategory.SalesOrder || this.DocumentCategory == DocumentCategory.Technology ||
                this.DocumentCategory == DocumentCategory.ProductionOrder)
                this.CommercialDocumentOptions = new CommercialDocumentTypeOptions(this);
            else
                this.CommercialDocumentOptions = null;

            if (this.DocumentCategory == DocumentCategory.Warehouse || this.DocumentCategory == DocumentCategory.OutcomeWarehouseCorrection ||
                this.DocumentCategory == DocumentCategory.IncomeWarehouseCorrection)
                this.WarehouseDocumentOptions = new WarehouseDocumentTypeOptions(this);
            else
                this.WarehouseDocumentOptions = null;

            if (this.DocumentCategory == DocumentCategory.Financial)
                this.FinancialDocumentOptions = new FinancialDocumentTypeOptions(this);
            else
                this.FinancialDocumentOptions = null;

            if (this.DocumentCategory == DocumentCategory.Complaint)
            {
                this.BusinessObjectType = BusinessObjectType.ComplaintDocument;
            }

            if (this.DocumentCategory == DocumentCategory.Inventory)
                this.InventoryDocumentOptions = new InventoryDocumentTypeOptions(this);
            else
                this.InventoryDocumentOptions = null;
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }
    }
}
