using System;
using System.Xml.Linq;
using System.Xml.XPath;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Commons;
using System.Globalization;

namespace Makolab.Fractus.Kernel.BusinessObjects.Dictionaries
{
    /// <summary>
    /// Class representing a vat rate (dictionary entry).
    /// </summary>
    [XmlSerializable(XmlField = "vatRate")]
    [DatabaseMapping(TableName = "vatRate")]
    internal class VatRate : BusinessObject, ILabeledDictionaryBusinessObject, IVersionedBusinessObject, IOrderable
    {
		private const string _VatRates = "dictionaries.metaData.vatRates";

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
        /// Gets or sets <see cref="VatRate"/>'s symbol. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "symbol")]
        [Comparable]
        [DatabaseMapping(ColumnName = "symbol")]
        public string Symbol { get; set; }

        /// <summary>
        /// Gets or sets VatRate's rate.
        /// </summary>
        [XmlSerializable(XmlField = "rate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "rate")]
        public decimal Rate { get; set; }

        /// <summary>
        /// Gets or sets <see cref="VatRate"/>'s fiscal symbol.
        /// </summary>
        [XmlSerializable(XmlField = "fiscalSymbol")]
        [Comparable]
        [DatabaseMapping(ColumnName = "fiscalSymbol")]
        public string FiscalSymbol { get; set; }

        /// <summary>
        /// Gets or sets <see cref="VatRate"/>'s label. Cannot be null.
        /// </summary>
        [XmlSerializable(XmlField = "xmlLabels")]
        [Comparable]
        [DatabaseMapping(ColumnName = "xmlLabels")]
        public XElement Labels { get; set; }

		//public XElement XmlMetadata { get; private set; }

		public DateTime? ValidThroughBeginDate { get; private set; }

		public DateTime? ValidThroughEndDate { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="VatRate"/> class with a specified xml root element.
        /// </summary>
        public VatRate()
            : base(null, BusinessObjectType.VatRate)
        {
            this.Labels = new XElement("labels");
        }

		internal VatRate InitMetadata()
		{
			if (ConfigurationMapper.Instance.DictionariesMetadata.ContainsKey(_VatRates))
			{
				XElement result = ConfigurationMapper.Instance.DictionariesMetadata[_VatRates];
				result = result.XPathSelectElement(String.Format(@"vatRate[@id=""{0}""]", this.Id.ToUpperString()));
				
				if (result != null)
				{
					XElement validThroughElement = result.Element("validThrough");
					if (validThroughElement != null)
					{
						XAttribute beginDateAttr = validThroughElement.Attribute("beginDate");
						XAttribute endDateAttr = validThroughElement.Attribute("endDate");
						DateTime tmpDate;
						if (beginDateAttr != null)
						{
							if (DateTime.TryParse(beginDateAttr.Value, CultureInfo.InvariantCulture, DateTimeStyles.None , out tmpDate))
							{
								ValidThroughBeginDate = tmpDate;
							}
						}
						if (endDateAttr != null)
						{
							if (DateTime.TryParse(endDateAttr.Value, CultureInfo.InvariantCulture, DateTimeStyles.None, out tmpDate))
							{
								ValidThroughEndDate = tmpDate;
							}
						}
					}
				}
			}
			return this;
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

            if (String.IsNullOrEmpty(this.FiscalSymbol))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:fiscalSymbol");
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

		public bool IsEventDateValid(DateTime eventDate)
		{
			if (this.ValidThroughBeginDate.HasValue && eventDate < this.ValidThroughBeginDate.Value)
				return false;

			if (this.ValidThroughEndDate.HasValue && eventDate.Date > this.ValidThroughEndDate.Value)
				return false;

			return true;
		}
    }
}
