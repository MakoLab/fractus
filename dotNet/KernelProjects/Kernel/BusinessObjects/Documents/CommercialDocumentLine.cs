using System;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class representing a line in a <see cref="CommercialDocument"/>.
    /// </summary>
    [XmlSerializable(XmlField = "line")]
    [DatabaseMapping(TableName = "commercialDocumentLine")]
    internal class CommercialDocumentLine : BusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        public int Order { get { return this.OrdinalNumber; } set { this.OrdinalNumber = value; } }

        /// <summary>
        /// Gets or sets line's ordinal number.
        /// </summary>
        [XmlSerializable(XmlField = "ordinalNumber")]
        [Comparable]
        [DatabaseMapping(ColumnName = "ordinalNumber")]
        public int OrdinalNumber { get; set; }

        /// <summary>
        /// Gets or sets line's item id.
        /// </summary>
        [XmlSerializable(XmlField = "itemId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemId")]
        public Guid ItemId { get; set; }

        /// <summary>
        /// Gets or sets line's item version.
        /// </summary>
        [XmlSerializable(XmlField = "itemVersion")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemVersion")]
        public Guid ItemVersion { get; set; }

        /// <summary>
        /// Gets or sets line's item name. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "itemName")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemName")]
        public string ItemName { get; set; }

        /// <summary>
        /// Gets or sets line's item name. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "visible")]
        [DatabaseMapping(ColumnName = "visible")]
        public string Visible { get; set; }


        [XmlSerializable(XmlField = "itemCode")]
        [DatabaseMapping(ColumnName = "itemCode", LoadOnly = true)]
        public string ItemCode { get; set; }

        [XmlSerializable(XmlField = "itemTypeId")]
        [DatabaseMapping(ColumnName = "itemTypeId", LoadOnly = true)]
        public string ItemTypeId { get; set; }

        /// <summary>
        /// Gets or sets line's item quantity.
        /// </summary>
        [XmlSerializable(XmlField = "quantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "quantity")]
        public decimal Quantity { get; set; }

        /// <summary>
        /// Gets or sets line's item net price.
        /// </summary>
        [XmlSerializable(XmlField = "netPrice")]
        [Comparable]
        [DatabaseMapping(ColumnName = "netPrice")]
        public decimal NetPrice { get; set; }

        /// <summary>
        /// Gets or sets line's item gross price.
        /// </summary>
        [XmlSerializable(XmlField = "grossPrice")]
        [Comparable]
        [DatabaseMapping(ColumnName = "grossPrice")]
        public decimal GrossPrice { get; set; }

        /// <summary>
        /// Gets or sets line's item initial net price.
        /// </summary>
        [XmlSerializable(XmlField = "initialNetPrice")]
        [Comparable]
        [DatabaseMapping(ColumnName = "initialNetPrice")]
        public decimal InitialNetPrice { get; set; }

        /// <summary>
        /// Gets or sets line's item initial gross price.
        /// </summary>
        [XmlSerializable(XmlField = "initialGrossPrice")]
        [Comparable]
        [DatabaseMapping(ColumnName = "initialGrossPrice")]
        public decimal InitialGrossPrice { get; set; }

        /// <summary>
        /// Gets or sets line's discount rate.
        /// </summary>
        [XmlSerializable(XmlField = "discountRate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "discountRate")]
        public decimal DiscountRate { get; set; }

        /// <summary>
        /// Gets or sets line's discount net value.
        /// </summary>
        [XmlSerializable(XmlField = "discountNetValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "discountNetValue")]
        public decimal DiscountNetValue { get; set; }

        /// <summary>
        /// Gets or sets line's discount gross value.
        /// </summary>
        [XmlSerializable(XmlField = "discountGrossValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "discountGrossValue")]
        public decimal DiscountGrossValue { get; set; }

        /// <summary>
        /// Gets or sets line's item initial net value.
        /// </summary>
        [XmlSerializable(XmlField = "initialNetValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "initialNetValue")]
        public decimal InitialNetValue { get; set; }

        /// <summary>
        /// Gets or sets line's item initial gross value.
        /// </summary>
        [XmlSerializable(XmlField = "initialGrossValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "initialGrossValue")]
        public decimal InitialGrossValue { get; set; }

        /// <summary>
        /// Gets or sets line's item net value.
        /// </summary>
        [XmlSerializable(XmlField = "netValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "netValue")]
        public decimal NetValue { get; set; }

        /// <summary>
        /// Gets or sets line's item gross value.
        /// </summary>
        [XmlSerializable(XmlField = "grossValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "grossValue")]
        public decimal GrossValue { get; set; }

        /// <summary>
        /// Gets or sets line's item vat value.
        /// </summary>
        [XmlSerializable(XmlField = "vatValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "vatValue")]
        public decimal VatValue { get; set; }

        /// <summary>
        /// Gets or sets line's vat rate id.
        /// </summary>
        [XmlSerializable(XmlField = "vatRateId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "vatRateId")]
        public Guid VatRateId { get; set; }

        /// <summary>
        /// Gets or sets line's unit id.
        /// </summary>
        [XmlSerializable(XmlField = "unitId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "unitId")]
        public Guid UnitId { get; set; }

        /// <summary>
        /// Gets or sets line's warehouse id.
        /// </summary>
        [XmlSerializable(XmlField = "warehouseId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseId")]
        public Guid? WarehouseId { get; set; }

        [XmlSerializable(XmlField = "tag", UseAttribute = true)]
        public string Tag { get; set; }

        [XmlSerializable(XmlField = "commercialDirection")]
        [Comparable]
        [DatabaseMapping(ColumnName = "commercialDirection")]
        public int CommercialDirection { get; set; }

		public decimal CommercialQuantity
		{
			get { return this.Quantity * this.CommercialDirection; }
		}

		public decimal AbsoluteCommercialQuantity
		{
			get { return Math.Abs(this.CommercialQuantity); }
		}

        [XmlSerializable(XmlField = "orderDirection")]
        [Comparable]
        [DatabaseMapping(ColumnName = "orderDirection")]
        public int OrderDirection { get; set; }

        //test dodatkowej kolumny
        [XmlSerializable(XmlField = "stock")]
        //[Comparable]
        [DatabaseMapping(ColumnName = "stock")]
        public decimal Stock { get; set; }


        [XmlSerializable(XmlField = "correctedLine", RelatedObjectType = BusinessObjectType.CommercialDocumentLine, SelfOnlySerialization = true)]
        [Comparable]
        [DatabaseMapping(ColumnName = "correctedCommercialDocumentLineId", OnlyId = true)]
        public CommercialDocumentLine CorrectedLine { get; set; }

        [DatabaseMapping(ColumnName = "initialCommercialDocumentLineId", OnlyId = true)]
        public CommercialDocumentLine InitialCommercialDocumentLine
        {
            get
            {
                if (this.CorrectedLine == null)
                    return null;

                CommercialDocumentLine line = this;

                while (line.CorrectedLine != null)
                {
                    line = line.CorrectedLine;
                }

                return line;
            }
        }

        [DatabaseMapping(ColumnName = "commercialDocumentHeaderId")]
        public Guid CommercialDocumentHeaderId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Gets or sets the <see cref="CommercialWarehouseValuations"/> object that manages <see cref="CommercialDocumentLine"/>'s valuations.
        /// </summary>
        [XmlSerializable(XmlField = "commercialWarehouseValuations")]
        public CommercialWarehouseValuations CommercialWarehouseValuations { get; private set; }

        /// <summary>
        /// Gets or sets the <see cref="CommercialWarehouseRelations"/> object that manages <see cref="CommercialDocumentLine"/>'s relations.
        /// </summary>
        [XmlSerializable(XmlField = "commercialWarehouseRelations")]
        public CommercialWarehouseRelations CommercialWarehouseRelations { get; private set; }

        [XmlSerializable(XmlField = "incomeOutcomeRelations")]
        public IncomeOutcomeRelations IncomeOutcomeRelations { get; set; }

        [XmlSerializable(XmlField = "attributes", ProcessLast = true)]
        public DocumentLineAttrValues Attributes { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommercialDocumentLine"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="CommercialDocumentHeader"/>.</param>
        public CommercialDocumentLine(CommercialDocumentBase parent)
            : base(parent, BusinessObjectType.CommercialDocumentLine)
        {
            this.CommercialWarehouseValuations = new CommercialWarehouseValuations(this);
            this.CommercialWarehouseRelations = new CommercialWarehouseRelations(this);
            this.IncomeOutcomeRelations = new IncomeOutcomeRelations(this);
            this.Attributes = new DocumentLineAttrValues(this);
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ItemId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemId");

            if (this.ItemVersion == Guid.Empty)
                throw new ClientException(ClientExceptionId.InsufficientLineDetails, null, "ordinalNumber:" + this.OrdinalNumber.ToString(CultureInfo.InvariantCulture));

            if (String.IsNullOrEmpty(this.ItemName))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemName");

            if (this.VatRateId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:vatRateId");

            if (this.UnitId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:unitId");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

            CommercialDocumentBase parent = this.Parent as CommercialDocumentBase;
            CommercialDocument commercialParent = this.Parent as CommercialDocument;
            string minusPosition;
            try
            {
                if (parent.DocumentType.Options.Element("commercialDocument").Attribute("exchangeDoublePosition") != null)
                {
                    minusPosition = parent.DocumentType.Options.Element("commercialDocument").Attribute("exchangeDoublePosition").Value;
                }
                else
                {
                    minusPosition = "true";
                }
            } catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:3" + ex.Message + ex.StackTrace);
                minusPosition = "false";
            }

            if (commercialParent != null && commercialParent.IsCorrectiveDocument())
            {
                //mozemy korygowac na + jezeli korygujemy pozycje z naszego dokumentu
                //czyli jest to wybranie opcji w panelu "Stworz pozycje korygujaca"
                if (this.Quantity > 0 && this.CorrectedLine.Parent.Id.Value != commercialParent.Id.Value)
                    throw new ClientException(ClientExceptionId.QuantityOnCorrectionAboveZero);
            }
            else if (commercialParent != null && commercialParent.DocumentType.DocumentCategory == DocumentCategory.Technology)
            {
                DocumentLineAttrValue attr = this.Attributes[DocumentFieldName.LineAttribute_ProductionItemType];

                if (attr == null || attr.Value == null || attr.Value.Value.Length == 0)
                    throw new ClientException(ClientExceptionId.MissingProductionItemType, null, "ordinalNumber:" + this.OrdinalNumber.ToString(CultureInfo.InvariantCulture));
            }
            else if (commercialParent != null && commercialParent.DocumentType.DocumentCategory == DocumentCategory.ProductionOrder)
            {
                DocumentLineAttrValue attr = this.Attributes[DocumentFieldName.LineAttribute_ProductionTechnologyName];

                if (attr == null || attr.Value == null || attr.Value.Value.Length == 0)
                    throw new ClientException(ClientExceptionId.MissingProductionTechnologyName, null, "ordinalNumber:" + this.OrdinalNumber.ToString(CultureInfo.InvariantCulture));
            }
            else
            {
                if (this.Quantity <= 0 && minusPosition != "true")
                    throw new ClientException(ClientExceptionId.QuantityBelowOrEqualZero, null, "itemName:" + this.ItemName);

                DocumentCategory dc = parent.DocumentType.DocumentCategory;

                //jezeli jest to pozycja sprzedazowa na zamowieniu sprzedazowym (zdefiniowany atrybut rodzaju sprzedaży) to NIE dopusczamy
                if (dc == DocumentCategory.SalesOrder && this.NetPrice <= 0)
                {
                    if (this.Attributes != null)
                    {
                        var attr = this.Attributes[DocumentFieldName.LineAttribute_SalesOrderGenerateDocumentOption];

                        if (attr != null)
                        {
                            if (attr.Value.Value == "1" || attr.Value.Value == "3") //sprzedazowe
                                throw new ClientException(ClientExceptionId.LinePriceBelowOrEqualZero);
                        }
                    }
                   
                }

                if (dc == DocumentCategory.Sales || dc == DocumentCategory.Purchase)
                {
                    if (this.NetPrice <= 0)
                        throw new ClientException(ClientExceptionId.LinePriceBelowOrEqualZero);
                }
                else if (dc == DocumentCategory.Reservation || dc == DocumentCategory.Order || dc == DocumentCategory.SalesOrder)
                {
                    if (this.NetPrice < 0 && minusPosition != "true" )
                        throw new ClientException(ClientExceptionId.LinePriceBelowZero);
                }
            }
			//Sprawdzenie czy pozycja jest na magazyn lokalny
			Warehouse warehouse = DictionaryMapper.Instance.GetWarehouse(this.WarehouseId.Value);
			if (this.WarehouseId.HasValue && !warehouse.IsLocal)
			{
				throw new ClientException(ClientExceptionId.WarehouseNotLocal, null, "warehouse:" + warehouse.Symbol);
			}

            if (this.CommercialWarehouseValuations != null)
                this.CommercialWarehouseValuations.Validate();

            if (this.CommercialWarehouseRelations != null)
                this.CommercialWarehouseRelations.Validate();

            if (this.Attributes != null)
                this.Attributes.Validate();
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            CommercialDocumentLine line = (CommercialDocumentLine)alternate;

            if (this.CommercialWarehouseRelations != null)
                this.CommercialWarehouseRelations.SetAlternateVersion(line.CommercialWarehouseRelations);

            if (this.CommercialWarehouseValuations != null)
                this.CommercialWarehouseValuations.SetAlternateVersion(line.CommercialWarehouseValuations);

            if (this.Attributes != null)
                this.Attributes.SetAlternateVersion(line.Attributes);
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            if (this.CommercialWarehouseRelations.Children != null && this.CommercialWarehouseRelations.Children.Count > 0 && this.Parent != null)
            {
                CommercialDocument parent = (CommercialDocument)this.Parent;
                DocumentCategory cat = parent.DocumentType.DocumentCategory;

                if (cat != DocumentCategory.SalesOrder)
                    parent.DisableLinesChange = DisableDocumentChangeReason.LINES_RELATED_WAREHOUSE_DOCUMENT;

                if (cat == DocumentCategory.Reservation || cat == DocumentCategory.Order || cat == DocumentCategory.SalesOrder)
                {
                    if (this.CommercialWarehouseRelations.Children.Where(r => r.IsOrderRelation).FirstOrDefault() != null)
                        parent.DisableContractorChange = DisableDocumentChangeReason.CONTRACTOR_PARTIALLY_REALIZED_ORDER;
                }
            }
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/>.
        /// </summary>
        /// <param name="isNew">Value indicating whether the <see cref="BusinessObject"/> should be considered as the new one or the old one.</param>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.CommercialWarehouseValuations != null)
                this.CommercialWarehouseValuations.UpdateStatus(isNew);

            if (this.CommercialWarehouseRelations != null)
                this.CommercialWarehouseRelations.UpdateStatus(isNew);

            if (this.Attributes != null)
                this.Attributes.UpdateStatus(isNew);
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }

		public void CalculateSimplified(int precision)
		{
			VatRate vr = DictionaryMapper.Instance.GetVatRate(this.VatRateId);

			decimal vatRate = vr.Rate;

			if (((CommercialDocumentBase)this.Parent).CalculationType == CalculationType.Gross)
			{
				if (this.InitialGrossPrice == 0 && this.InitialNetPrice != 0)
					this.InitialGrossPrice = Decimal.Round(this.InitialNetPrice * (1 + vatRate / 100), precision, MidpointRounding.AwayFromZero);

				if (this.GrossPrice != 0 && this.InitialGrossPrice != 0)
				{
					this.DiscountRate = 100 * (1 - this.GrossPrice / this.InitialGrossPrice);
				}
			}
			else //if (((CommercialDocument)this.Parent).CalculationType == CalculationType.Net)
			{
				if (this.NetPrice != 0 && this.InitialNetPrice != 0)
				{
					this.DiscountRate = 100 * (1 - this.NetPrice / this.InitialNetPrice);
				}
				this.InitialGrossPrice = Decimal.Round(this.InitialNetPrice * (1 + vatRate / 100), precision, MidpointRounding.AwayFromZero);
			}
			//Ponieważ DiscountRate może mieć teraz po przeliczeniu więcej niż dwa miejsca po przecinku to zaokraglamy aby w bazie nie bylo przeklaman
			this.DiscountRate = Decimal.Round(this.DiscountRate, precision, MidpointRounding.AwayFromZero);

			this.DiscountGrossValue = Decimal.Round(this.InitialGrossPrice - this.GrossPrice, precision, MidpointRounding.AwayFromZero);
			this.DiscountNetValue = Decimal.Round(this.InitialNetPrice - this.NetPrice, precision, MidpointRounding.AwayFromZero);
			this.InitialNetValue = Decimal.Round(this.InitialNetPrice * this.Quantity, precision, MidpointRounding.AwayFromZero);
			this.InitialGrossValue = Decimal.Round(this.InitialGrossPrice * this.Quantity, precision, MidpointRounding.AwayFromZero);
		}
		
		/// <summary>
        /// Calculates the line.
        /// </summary>
        /// <param name="quantity">Quantity.</param>
        /// <param name="initialNetPrice">Initial net price.</param>
        /// <param name="discountRate">Discount rate.</param>
        /// <param name="initialGrossPrice">Initial gross price.</param>
        /// <param name="precision">Precision.</param>
        public void Calculate(decimal quantity, decimal initialNetPrice, decimal discountRate, decimal initialGrossPrice, int precision)
        {
            this.Quantity = quantity;
            this.DiscountRate = discountRate;
            this.InitialNetPrice = initialNetPrice;
            this.InitialGrossPrice = initialGrossPrice;

            VatRate vr = DictionaryMapper.Instance.GetVatRate(this.VatRateId);

            decimal vatRate = vr.Rate;

            if (((CommercialDocumentBase)this.Parent).CalculationType == CalculationType.Gross)
            {
                if (initialGrossPrice == 0 && initialNetPrice != 0)
                    this.InitialGrossPrice = Decimal.Round(this.InitialNetPrice * (1 + vatRate / 100), precision, MidpointRounding.AwayFromZero);

                this.InitialNetPrice = Decimal.Round(this.InitialGrossPrice / (1 + vatRate / 100), precision, MidpointRounding.AwayFromZero);

				//Zabezpieczenie przed przeliczeniem, które zwróci inne wyniki niż były na dokumencie źródłowym o ile taki istnieje (wtedy GrossPrice jest większe od 0), celowo obliczamy z większa precyzją
				if (this.GrossPrice != 0 && this.InitialGrossPrice != 0)
				{
					this.DiscountRate = 100 * (1 - this.GrossPrice / this.InitialGrossPrice);
				}
                this.GrossPrice = Decimal.Round(this.InitialGrossPrice * (1 - this.DiscountRate / 100), precision, MidpointRounding.AwayFromZero);
                this.NetPrice = Decimal.Round(this.GrossPrice / (1 + vatRate / 100), precision, MidpointRounding.AwayFromZero);

                this.GrossValue = Decimal.Round(this.GrossPrice * this.Quantity, precision, MidpointRounding.AwayFromZero);
                this.VatValue = Decimal.Round(this.GrossValue * vatRate / (vatRate + 100), precision, MidpointRounding.AwayFromZero);
                this.NetValue = Decimal.Round(this.GrossValue - this.VatValue, precision, MidpointRounding.AwayFromZero);
            }
            else //if (((CommercialDocument)this.Parent).CalculationType == CalculationType.Net)
            {
                if (initialNetPrice == 0 && initialGrossPrice != 0)
                    this.InitialNetPrice = Decimal.Round(this.InitialGrossPrice / (1 + vatRate / 100), precision, MidpointRounding.AwayFromZero);

				//Zabezpieczenie przed przeliczeniem, które zwróci inne wyniki niż były na dokumencie źródłowym o ile taki istnieje (wtedy NetPrice jest większe od 0), celowo obliczamy z większa precyzją
				if (this.NetPrice != 0 && this.InitialNetPrice != 0)
				{
					this.DiscountRate = 100 * (1 - this.NetPrice / this.InitialNetPrice);
				}
				this.NetPrice = Decimal.Round(this.InitialNetPrice * (1 - this.DiscountRate / 100), precision, MidpointRounding.AwayFromZero);
                this.InitialGrossPrice = Decimal.Round(this.InitialNetPrice * (1 + vatRate / 100), precision, MidpointRounding.AwayFromZero);
                this.GrossPrice = Decimal.Round(this.NetPrice * (1 + Decimal.Round(vatRate / 100, precision, MidpointRounding.AwayFromZero)), precision, MidpointRounding.AwayFromZero);

                this.NetValue = Decimal.Round(this.NetPrice * this.Quantity, precision, MidpointRounding.AwayFromZero);
                this.VatValue = Decimal.Round(this.NetValue * vatRate / 100, precision, MidpointRounding.AwayFromZero);
                this.GrossValue = Decimal.Round(this.NetValue + this.VatValue, precision, MidpointRounding.AwayFromZero);
            }
			//Ponieważ DiscountRate może mieć teraz po przeliczeniu więcej niż dwa miejsca po przecinku to zaokraglamy aby w bazie nie bylo przeklaman
			this.DiscountRate = Decimal.Round(this.DiscountRate, precision, MidpointRounding.AwayFromZero);

            this.DiscountGrossValue = Decimal.Round(this.InitialGrossPrice - this.GrossPrice, precision, MidpointRounding.AwayFromZero);
            this.DiscountNetValue = Decimal.Round(this.InitialNetPrice - this.NetPrice, precision, MidpointRounding.AwayFromZero);
            this.InitialNetValue = Decimal.Round(this.InitialNetPrice * this.Quantity, precision, MidpointRounding.AwayFromZero);
            this.InitialGrossValue = Decimal.Round(this.InitialGrossPrice * this.Quantity, precision, MidpointRounding.AwayFromZero);
        }

        /// <summary>
        /// Calculates the line.
        /// </summary>
        /// <param name="quantity">Quantity.</param>
        /// <param name="initialNetPrice">Initial net price.</param>
        /// <param name="discountRate">Discount rate.</param>
        /// <param name="initialGrossPrice">Initial gross price.</param>
        public void Calculate(decimal quantity, decimal initialNetPrice, decimal discountRate, decimal initialGrossPrice)
        {
            this.Calculate(quantity, initialNetPrice, discountRate, initialGrossPrice, 2);
        }

        /// <summary>
        /// Calculates the line.
        /// </summary>
        /// <param name="quantity">Quantity.</param>
        /// <param name="initialNetPrice">Initial net price.</param>
        /// <param name="discountRate">Discount rate.</param>
        public void Calculate(decimal quantity, decimal initialNetPrice, decimal discountRate)
        {
            this.Calculate(quantity, initialNetPrice, discountRate, 0);
        }
    }
}
