using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class representing a line in a <see cref="WarehouseDocument"/>.
    /// </summary>
    [XmlSerializable(XmlField = "line")]
    [DatabaseMapping(TableName = "warehouseDocumentLine")]
    internal class WarehouseDocumentLine : BusinessObject, IOrderable
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
        /// Gets or sets line's direction.
        /// </summary>
        [XmlSerializable(XmlField = "direction")]
        [Comparable]
        [DatabaseMapping(ColumnName = "direction")]
        public int Direction { get; set; }

        /// <summary>
        /// Gets or sets document's value.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value")]
        public decimal Value { get; set; }

        /// <summary>
        /// Gets or sets document's value.
        /// </summary>
        [XmlSerializable(XmlField = "price")]
        [Comparable]
        [DatabaseMapping(ColumnName = "price")]
        public decimal Price { get; set; }

        /// <summary>
        /// Gets or sets line's item id.
        /// </summary>
        [XmlSerializable(XmlField = "itemId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemId")]
        public Guid ItemId { get; set; }

        /// <summary>
        /// Gets or sets line's item name. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "itemName")]
        [Comparable]
        [DatabaseMapping(ColumnName = "itemName")]
        public string ItemName { get; set; }

        [XmlSerializable(XmlField = "itemCode")]
        [DatabaseMapping(ColumnName = "itemCode", LoadOnly = true)]
        public string ItemCode { get; set; }

        [XmlSerializable(XmlField = "itemTypeId")]
        [DatabaseMapping(ColumnName = "itemTypeId", LoadOnly = true)]
        public string ItemTypeId { get; set; }

        /// <summary>
        /// Gets or sets line's warehouse id.
        /// </summary>
        [XmlSerializable(XmlField = "warehouseId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseId")]
        public Guid WarehouseId { get; set; }

        /// <summary>
        /// Gets or sets line's unit id.
        /// </summary>
        [XmlSerializable(XmlField = "unitId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "unitId")]
        public Guid UnitId { get; set; }

        
        [XmlSerializable(XmlField = "visible")]
        [DatabaseMapping(ColumnName = "visible")]
        public string Visible { get; set; }

        /// <summary>
        /// Gets or sets line's item quantity.
        /// </summary>
        [XmlSerializable(XmlField = "quantity")]
        [Comparable]
        [DatabaseMapping(ColumnName = "quantity")]
        public decimal Quantity { get; set; }

        /// <summary>
        /// Gets or sets income date.
        /// </summary>
        [XmlSerializable(XmlField = "incomeDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "incomeDate")]
        public DateTime? IncomeDate { get; set; }

        /// <summary>
        /// Gets or sets income date.
        /// </summary>
        [XmlSerializable(XmlField = "outcomeDate")]
        [Comparable]
        [DatabaseMapping(ColumnName = "outcomeDate")]
        public DateTime? OutcomeDate { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        [XmlSerializable(XmlField = "description")]
        [Comparable]
        [DatabaseMapping(ColumnName = "description")]
        public string Description { get; set; }

        [XmlSerializable(XmlField = "isDistributed")]
        [Comparable]
        [DatabaseMapping(ColumnName = "isDistributed")]
        public bool IsDistributed { get; set; }

        public CommercialDocumentLine CommercialCorrectiveLine { get; set; }

        [DatabaseMapping(ColumnName = "warehouseDocumentHeaderId")]
        public Guid WarehouseDocumentHeaderId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        [XmlSerializable(XmlField = "correctedLine", RelatedObjectType = BusinessObjectType.WarehouseDocumentLine, SelfOnlySerialization = true)]
        [Comparable]
        [DatabaseMapping(ColumnName = "correctedWarehouseDocumentLineId", OnlyId = true)]
        public WarehouseDocumentLine CorrectedLine { get; set; }

        [XmlSerializable(XmlField = "initialLine", RelatedObjectType = BusinessObjectType.WarehouseDocumentLine, SelfOnlySerialization = true)]
        [DatabaseMapping(ColumnName = "initialWarehouseDocumentLineId", OnlyId = true)]
        public WarehouseDocumentLine InitialWarehouseDocumentLine { get; set; }

        [XmlSerializable(XmlField = "initialIncomeLine", RelatedObjectType = BusinessObjectType.WarehouseDocumentLine, SelfOnlySerialization = true)]
        [Comparable]
        [DatabaseMapping(ColumnName = "previousIncomeWarehouseDocumentLineId", OnlyId = true)]
        public WarehouseDocumentLine PreviousIncomeLine { get; set; }

        [XmlSerializable(XmlField = "lineType")]
        [DatabaseMapping(ColumnName = "lineType")]
        public WarehouseDocumentLineType LineType { get; set; }


    


        /// <summary>
        /// Gets or sets the <see cref="IncomeOutcomeRelations"/> object that manages <see cref="WarehouseDocumentLine"/>'s relations.
        /// </summary>
        [XmlSerializable(XmlField = "incomeOutcomeRelations")]
        public IncomeOutcomeRelations IncomeOutcomeRelations { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="CommercialWarehouseValuations"/> object that manages <see cref="WarehouseDocumentLine"/>'s valuations.
        /// </summary>
        [XmlSerializable(XmlField = "commercialWarehouseValuations")]
        public CommercialWarehouseValuations CommercialWarehouseValuations { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="CommercialWarehouseRelations"/> object that manages <see cref="WarehouseDocumentLine"/>'s relations.
        /// </summary>
        [XmlSerializable(XmlField = "commercialWarehouseRelations")]
        public CommercialWarehouseRelations CommercialWarehouseRelations { get; set; }

		public bool HasAnyCommercialCommercialWarehouseRelations
		{
			get
			{
				return this.CommercialWarehouseRelations.Any(cwr => cwr.IsCommercialRelation);
			}
		}

        [XmlSerializable(XmlField = "attributes", ProcessLast = true)]
        public DocumentLineAttrValues Attributes { get; private set; }

        /// <summary>
        /// Gets or sets the source line in the postprocessed outcome shift line that is divided according to income outcome relation.
        /// </summary>
        public WarehouseDocumentLine SourceOutcomeShiftLine { get; set; }

        public ICollection<Guid> ValuateFromOutcomeDocumentLinesId { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="WarehouseDocumentLine"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="WarehouseDocument"/>.</param>
        public WarehouseDocumentLine(WarehouseDocument parent)
            : base(parent, BusinessObjectType.WarehouseDocumentLine)
        {
            this.IncomeOutcomeRelations = new IncomeOutcomeRelations(this);
            this.CommercialWarehouseValuations = new CommercialWarehouseValuations(this);
            this.CommercialWarehouseRelations = new CommercialWarehouseRelations(this);
            this.Attributes = new DocumentLineAttrValues(this);
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ItemId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:itemId");

            if (this.WarehouseId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:warehouseId");

            if (this.UnitId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:unitId");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

			RelatedLinesChangePolicy relatedLinesChangePolicy = RelatedLinesChangePolicy.Unknown;
			WarehouseDocument warehouseParent = ((WarehouseDocument)this.Parent);
			if (warehouseParent != null)
				relatedLinesChangePolicy = warehouseParent.DocumentType.WarehouseDocumentOptions.RelatedLinesChangePolicy;

            bool skipQuantityValidation = ((WarehouseDocument)this.Parent).SkipQuantityValidation;

            if (!skipQuantityValidation && relatedLinesChangePolicy != RelatedLinesChangePolicy.ValueOnly)
            {
                if (this.Quantity <= 0)
                    throw new ClientException(ClientExceptionId.QuantityBelowOrEqualZero, null, "itemName:" + this.ItemName);

                decimal quantityOnOrderRelation = this.CommercialWarehouseRelations.Children.Where(r => r.IsOrderRelation).Sum(rr => rr.Quantity);

                if (quantityOnOrderRelation > this.Quantity)
                    throw new ClientException(ClientExceptionId.UnableToEditOutcomeWarehouseDocument3);
            }

            WarehouseDirection direction = ((WarehouseDocument)this.Parent).WarehouseDirection;

            if (relatedLinesChangePolicy != RelatedLinesChangePolicy.ValueOnly && direction == WarehouseDirection.Income && this.Price < 0)
                throw new ClientException(ClientExceptionId.LinePriceBelowOrEqualZero);

            if (this.IncomeOutcomeRelations != null)
                this.IncomeOutcomeRelations.Validate();

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

            WarehouseDocumentLine line = (WarehouseDocumentLine)alternate;

            if (this.IncomeOutcomeRelations != null)
                this.IncomeOutcomeRelations.SetAlternateVersion(line.IncomeOutcomeRelations);

            if (this.CommercialWarehouseRelations != null)
                this.CommercialWarehouseRelations.SetAlternateVersion(line.CommercialWarehouseRelations);

            if (this.CommercialWarehouseValuations != null)
                this.CommercialWarehouseValuations.SetAlternateVersion(line.CommercialWarehouseValuations);

            if (this.Attributes != null)
                this.Attributes.SetAlternateVersion(line.Attributes);
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/>.
        /// </summary>
        /// <param name="isNew">Value indicating whether the <see cref="BusinessObject"/> should be considered as the new one or the old one.</param>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            WarehouseDocument parent = (WarehouseDocument)this.Parent;

			WarehouseDocumentLine alternateLine = this.AlternateVersion as WarehouseDocumentLine;

			if (this.IncomeOutcomeRelations != null)
            {
                if (this.Status == BusinessObjectStatus.Deleted)
                {
                    this.IncomeOutcomeRelations.SetChildrenStatus(BusinessObjectStatus.Deleted);

                    //wywalamy wszystkie shifty ktore byly powiazane z ta pozycja bo zostana one usuniete w
                    //procedurze p_deleteWarehouseDocumentLine

                    ShiftTransaction st = ((WarehouseDocument)this.Parent).ShiftTransaction;

                    List<Shift> shiftsToDelete = new List<Shift>();

                    if (st != null)
                    {
                        foreach (var shift in st.Shifts.Children.Where(s => s.RelatedWarehouseDocumentLine == this))
                        {
                            //shift.Status = BusinessObjectStatus.Deleted;
                            shiftsToDelete.Add(shift);
                        }

                        foreach (var shift in shiftsToDelete)
                            st.Shifts.Remove(shift);

                        shiftsToDelete.Clear();
                    }

                    if (alternateLine != null)
                    {
                        WarehouseDocument alternateDocument = (WarehouseDocument)alternateLine.Parent;

                        if (alternateDocument.ShiftTransaction != null)
                        {
                            foreach (var shift in alternateDocument.ShiftTransaction.Shifts.Children.Where(ss => ss.RelatedWarehouseDocumentLine == alternateLine))
                            {
                                shiftsToDelete.Add(shift);
                            }

                            foreach (var shift in shiftsToDelete)
                                st.Shifts.Remove(shift);

                            shiftsToDelete.Clear();
                        }
                    }

                    //wywalamy wszystkie commercialWarehouseValuation
                    this.CommercialWarehouseValuations.RemoveAll();
                }
                else if (this.Status == BusinessObjectStatus.Modified
                    && parent.WarehouseDirection == WarehouseDirection.Outcome
                    && DictionaryMapper.Instance.GetWarehouse(this.WarehouseId).ValuationMethod == ValuationMethod.Fifo)
                {
                    ((WarehouseDocumentLine)this.AlternateVersion).IncomeOutcomeRelations.SetChildrenStatus(BusinessObjectStatus.Deleted);
                    this.IncomeOutcomeRelations.RemoveAll();
                }
                else if (this.IncomeOutcomeRelations != null)
                    this.IncomeOutcomeRelations.UpdateStatus(isNew);
            }

            if (this.CommercialWarehouseValuations != null)
                this.CommercialWarehouseValuations.UpdateStatus(isNew);

            if (this.CommercialWarehouseRelations != null)
                this.CommercialWarehouseRelations.UpdateStatus(isNew);

            if (this.Attributes != null)
                this.Attributes.UpdateStatus(isNew);

			//If RelatedLinesChangedPolicy is valueOnly, quantity and item cannot be changed
			if (parent.DocumentType.WarehouseDocumentOptions.RelatedLinesChangePolicy == RelatedLinesChangePolicy.ValueOnly)
			{
				bool throwException = false;

				if (alternateLine == null && !parent.IsNew && this.IsNew)
				{
					throwException = true;
				}

				if (alternateLine != null && 
					(this.Quantity != alternateLine.Quantity
					|| this.ItemId != alternateLine.ItemId
					|| this.ItemName != alternateLine.ItemName
					|| this.ItemCode != alternateLine.ItemCode))
				{
					throwException = true;
				}

				if (throwException)
				{
					throw new ClientException(ClientExceptionId.OnlyLineValuesCanBeEdited);
				}
			}

        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

			//Nie dopisuj atrybutu DisableLinesChange jesli skongigurowane inaczej
			RelatedLinesChangePolicy relatedLinesChangePolicy = RelatedLinesChangePolicy.Unknown;
			if (((WarehouseDocument)this.Parent) != null)
				relatedLinesChangePolicy = ((WarehouseDocument)this.Parent).DocumentType.WarehouseDocumentOptions.RelatedLinesChangePolicy;
			if (relatedLinesChangePolicy != RelatedLinesChangePolicy.ValueOnly)
			{
				if (this.CommercialWarehouseRelations.HasChildren && this.Parent != null)
					(this.Parent as Document).DisableLinesChange = DisableDocumentChangeReason.LINES_RELATED_COMMERCIAL_DOCUMENT;

				if (this.IncomeOutcomeRelations.HasChildren && this.Parent != null && ((WarehouseDocument)this.Parent).WarehouseDirection == WarehouseDirection.Income)
					(this.Parent as Document).DisableLinesChange = DisableDocumentChangeReason.LINES_RELATED_OUTCOMES;
			}
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

            if (this.IncomeOutcomeRelations != null)
                this.IncomeOutcomeRelations.SaveChanges(document);
        }
    }
}
