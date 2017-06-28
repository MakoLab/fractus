using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;
using Makolab.Fractus.Kernel.Coordinators;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class that represents any commercial document.
    /// </summary>
    [XmlSerializable(XmlField = "warehouseDocument")]
    [DatabaseMapping(TableName = "warehouseDocumentHeader",
		GetData = StoredProcedure.document_p_getWarehouseDocumentData, GetDataParamName = "warehouseDocumentHeaderId", List = StoredProcedure.document_p_getWarehouseDocuments)]
    internal class WarehouseDocument : Document
    {
        public override XDocument FullXml
        {
            get
            {
                XDocument xdoc = base.FullXml;

                if (ConfigurationMapper.Instance.IsWmsEnabled && this.ShiftTransaction != null)
                    xdoc.Root.Add(this.ShiftTransaction.Serialize());

                return xdoc;
            }
        }

        /// <summary>
        /// Gets or sets the document contractor.
        /// </summary>
        [XmlSerializable(XmlField = "contractor", RelatedObjectType = BusinessObjectType.Contractor)]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorId", OnlyId = true)]
        public Contractor Contractor { get; set; }

        /// <summary>
        /// Gets or sets warehouse id.
        /// </summary>
        [XmlSerializable(XmlField = "warehouseId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "warehouseId")]
        public Guid WarehouseId { get; set; }

        private WarehouseDirection? warehouseDirection;

        public WarehouseDirection WarehouseDirection
        {
            get
            {
                if (this.warehouseDirection == null)
                    this.warehouseDirection = this.DocumentType.WarehouseDocumentOptions.WarehouseDirection;

                return this.warehouseDirection.Value;
            }
        }

        /// <summary>
        /// Gets or sets document's value.
        /// </summary>
        [XmlSerializable(XmlField = "value")]
        [Comparable]
        [DatabaseMapping(ColumnName = "value")]
        public decimal Value { get; set; }

        public bool SkipManualValuations { get; set; }

		public bool CorrectedDocumentEditEnabled { get; set; }

		public override string ParentIdColumnName
		{
			get
			{
				return "warehouseDocumentHeaderId";
			}
		}

        /// <summary>
        /// Gets or sets the <see cref="WarehouseDocumentLines"/> object that manages <see cref="WarehouseDocument"/>'s lines.
        /// </summary>
        [XmlSerializable(XmlField = "lines", ProcessLast = true)]
        public WarehouseDocumentLines Lines { get; private set; }

        private ShiftTransaction _shiftTransaction;
        public ShiftTransaction ShiftTransaction
        {
            get { return this._shiftTransaction; }
            set
            {
                this._shiftTransaction = value;

                if (value != null)
                {
                    this._shiftTransaction.Parent = this;

                    foreach (Shift shift in this._shiftTransaction.Shifts.Children)
                    {
                        if (shift.LineOrdinalNumber != null)
                            shift.RelatedWarehouseDocumentLine = this.Lines[shift.LineOrdinalNumber.Value - 1];
                        else
                        {
                            WarehouseDocumentLine whLine = this.Lines.Children.Where(l => l.Id.Value == shift.WarehouseDocumentLineId.Value).FirstOrDefault();
                            shift.LineOrdinalNumber = whLine.OrdinalNumber;
                            shift.RelatedWarehouseDocumentLine = whLine;
                        }
                    }
                }
            }
        }

        public Guid? ValuateFromOutcomeDocumentId { get; set; }

        public bool SkipReservedQuantityCheck { get; set; }

        public bool SkipQuantityValidation { get; set; }

		public bool IsBeforeSystemStartOutcomeCorrection { get; set; }

		public bool HasAnyCommercialCommercialWarehouseRelations
		{
			get
			{
				return this.Lines.Any(line => line.HasAnyCommercialCommercialWarehouseRelations);
			}
		}

		public WarehouseDocument InitialCorrectedDocument { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="WarehouseDocument"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        public WarehouseDocument()
            : base(BusinessObjectType.WarehouseDocument)
        {
            this.Lines = new WarehouseDocumentLines(this);
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.WarehouseId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:warehouseId");
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

			Warehouse warehouse = DictionaryMapper.Instance.GetWarehouse(this.WarehouseId);

            if (this.AlternateVersion != null && ((WarehouseDocument)this.AlternateVersion).WarehouseId != this.WarehouseId)
                throw new ClientException(ClientExceptionId.WarehouseChangeError);

            if (this.Lines != null)
                this.Lines.Validate();

            if (ConfigurationMapper.Instance.IsWmsEnabled &&
                warehouse.ValuationMethod == ValuationMethod.DeliverySelection)
            {
                //sprawdzamy czy nie ma wiekszej ilosci na shiftach niz na pozycji

                foreach (WarehouseDocumentLine line in this.Lines.Children)
                {
                    decimal relatedQuantity = 0;

                    if (this.ShiftTransaction != null)
                        relatedQuantity = this.ShiftTransaction.Shifts.Children.Where(sh => sh.RelatedWarehouseDocumentLine == line).Sum(s => s.Quantity);

                    if (relatedQuantity > Math.Abs(line.Quantity))
                    {
                        ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();
                        string itemName = mapper.GetItemName(line.ItemId);

                        if (this.WarehouseDirection == WarehouseDirection.Income || this.WarehouseDirection == WarehouseDirection.IncomeShift)
                            throw new ClientException(ClientExceptionId.TotalShiftQuantityError, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture), "itemName:" + itemName);
                        else
                            throw new ClientException(ClientExceptionId.TotalShiftQuantityError2, null, "ordinalNumber:" + line.OrdinalNumber.ToString(CultureInfo.InvariantCulture), "itemName:" + itemName);
                    }
                }
            }

			if (this.DocumentType.WarehouseDocumentOptions.RelatedLinesChangePolicy != RelatedLinesChangePolicy.ValueOnly)
			{

				if (this.DisableLinesChange != null && this.DisableLinesChange.Contains(DisableDocumentChangeReason.LINES_RELATED_OUTCOMES) &&
					(this.Lines.IsAnyChildNew() || this.Lines.IsAnyChildModified() || this.Lines.IsAnyChildDeleted()))
				{
					throw new ClientException(ClientExceptionId.UnableToEditIncomeWarehouseDocument);
				}

				if (!this.IsNew && this.DisableLinesChange != null && this.DisableLinesChange.Contains(DisableDocumentChangeReason.LINES_RELATED_COMMERCIAL_DOCUMENT) &&
					(this.Lines.IsAnyChildNew() || this.Lines.IsAnyChildModified() || this.Lines.IsAnyChildDeleted()))
				{
					throw new ClientException(ClientExceptionId.UnableToEditOutcomeWarehouseDocument2);
				}

				if (this.DisableDocumentChange != null && this.DisableDocumentChange.Contains(DisableDocumentChangeReason.DOCUMENT_RELATED_CORRECTIVE_DOCUMENTS) &&
					(this.Lines.IsAnyChildNew() || this.Lines.IsAnyChildModified() || this.Lines.IsAnyChildDeleted()))
				{
					throw new ClientException(ClientExceptionId.UnableToEditDocumentBecauseOfCorrections);
				}
			}

            if (this.WarehouseDirection == WarehouseDirection.OutcomeShift 
                || this.WarehouseDirection == WarehouseDirection.IncomeShift)
            {
                //sprawdzenie czy dokument posiada wymagane atrybuty

                bool hasWarehouseAttribute = false;

                foreach (DocumentAttrValue attr in this.Attributes.Children)
                {
                    if (attr.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId && attr.Value.Value.Length != 0)
                        hasWarehouseAttribute = true;
                }

                if (!hasWarehouseAttribute)
                    throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:oppositeWarehouse");
            }

			//Sprawdzenie czy dokument jest wystawiany na magazyn lokalny
			if (!warehouse.IsLocal)
			{
				throw new ClientException(ClientExceptionId.WarehouseNotLocal, null, "warehouse:" + warehouse.Symbol);
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

            //save changes of child elements first
            if (this.Attributes != null)
                this.Attributes.SaveChanges(document);

            if (this.Lines != null)
                this.Lines.SaveChanges(document);

            //if the document has been changed or some of his children have been changed
            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                if (this.AlternateVersion == null || ((this.AlternateVersion.Status == BusinessObjectStatus.Unchanged ||
                    this.AlternateVersion.Status == BusinessObjectStatus.Unknown) && ((IVersionedBusinessObject)this.AlternateVersion).ForceSave == false))
                {
                    Dictionary<string, object> forcedToSave = new Dictionary<string, object>();
                    forcedToSave.Add("modificationApplicationUserId", SessionManager.User.UserId.ToString());

                    if (!this.IsNew)
                        forcedToSave.Add("modificationDate", SessionManager.VolatileElements.CurrentDateTime.ToIsoString());

                    BusinessObjectHelper.SaveBusinessObjectChanges(this, document, forcedToSave, null);
                    this.Number.SaveChanges(document);
                }
            }
        }

        public override void SaveRelations(XDocument document)
        {
            foreach (WarehouseDocumentLine line in this.Lines.Children)
            {
                line.CommercialWarehouseRelations.SaveChanges(document);
                line.CommercialWarehouseValuations.SaveChanges(document);
            }

            base.SaveRelations(document);
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/> as well as AlternateVersion BO's status.
        /// </summary>
        public override void UpdateStatus(bool isNew)
        {
            base.UpdateStatus(isNew);

            if (this.Lines != null)
            {
                this.Lines.UpdateStatus(isNew);

                if (this.Lines.IsAnyChildDeleted() && this.AlternateVersion.Status == BusinessObjectStatus.Unchanged)
                    this.AlternateVersion.Status = BusinessObjectStatus.Modified;
            }

            if (this.ShiftTransaction != null)
                this.ShiftTransaction.UpdateStatus(isNew);
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public override void SetAlternateVersion(IBusinessObject alternate)
        {
            base.SetAlternateVersion(alternate);

            WarehouseDocument alternateDocument = (WarehouseDocument)alternate;

            if (this.Lines != null)
                this.Lines.SetAlternateVersion(alternateDocument.Lines);

            if (this.ShiftTransaction != null)
                this.ShiftTransaction.SetAlternateVersion(alternateDocument.ShiftTransaction);
        }

        public bool IsLocalShift()
        {
            var oppositeAttr = this.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId).FirstOrDefault();

            if (oppositeAttr == null)
                return false;

            Guid oppositeWhId = new Guid(oppositeAttr.Value.Value);
            Warehouse oppositeWh = DictionaryMapper.Instance.GetWarehouse(oppositeWhId);
            Warehouse sourceWh = DictionaryMapper.Instance.GetWarehouse(this.WarehouseId);

            return oppositeWh.BranchId == sourceWh.BranchId;
        }

		internal void CheckDoesRealizeClosedSalesOrder(DocumentCoordinator coordinator)
		{
			//to ma działać tylko dla RW i tylko gdy jest on zapisywany bezpośrednio a nie jako powiązany dokument
			if (!this.IsNew &&
				this.WarehouseDirection == Enums.WarehouseDirection.Outcome &&
				!this.HasAnyCommercialCommercialWarehouseRelations)
			{
				DocumentMapper mapper =
					(DocumentMapper)DependencyContainerManager.Container.Get<DocumentMapper>();

				IEnumerable<Document> relatedSalesOrders = this.Relations.GetRelatedDocuments(DocumentRelationType.SalesOrderToWarehouseDocument);

				foreach (Document relatedSalesOrder in relatedSalesOrders)
				{
					CommercialDocument salesOrder = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, relatedSalesOrder.Id.Value);
					if (relatedSalesOrder.Id.HasValue && SalesOrderFactory.IsSalesOrderClosed(salesOrder))
					{
						throw new ClientException(ClientExceptionId.DocumentEditForbiddenRelatedSalesOrderClosed);
					}
				}
			}
		}

    }
}
