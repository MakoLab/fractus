using System;
using System.Collections.Generic;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class that manages <see cref="CommercialDocument"/>'s lines.
    /// </summary>
    internal class WarehouseDocumentLines : BusinessObjectsContainer<WarehouseDocumentLine>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="WarehouseDocumentLines"/> class with a specified <see cref="WarehouseDocument"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="WarehouseDocument"/> to attach to.</param>
        public WarehouseDocumentLines(WarehouseDocument parent)
            : base(parent, "line")
        {
        }

        /// <summary>
        /// Creates new <see cref="WarehouseDocumentLine"/> according to the WarehouseDocument's defaults and attaches it to the parent <see cref="WarehouseDocument"/>.
        /// </summary>
        /// <returns>A new <see cref="WarehouseDocumentLine"/>.</returns>
        public override WarehouseDocumentLine CreateNew()
        {
            WarehouseDocument parent = (WarehouseDocument)this.Parent;

            //create new object and attach it to the element
            WarehouseDocumentLine line = new WarehouseDocumentLine(parent);

            WarehouseDirection parentDirection = parent.DocumentType.WarehouseDocumentOptions.WarehouseDirection;

            if (!parent.IsBeforeSystemStart)
            {
                if (parentDirection == WarehouseDirection.Outcome || parentDirection == WarehouseDirection.OutcomeShift)
                    line.Direction = -1;
                else
                    line.Direction = 1;
            }

            if (parentDirection == WarehouseDirection.OutcomeShift || parentDirection == WarehouseDirection.IncomeShift)
                line.IsDistributed = true;

            line.Order = this.Children.Count + 1;

            //add object to the collection
            this.Children.Add(line);

            return line;
        }

        /// <summary>
        /// Validates the collection.
        /// </summary>
        public override void Validate()
        {
            if (this.Children.Count == 0)
                throw new ClientException(ClientExceptionId.NoLines);

            WarehouseDocument parent = (WarehouseDocument)this.Parent;

            DependencyContainerManager.Container.Get<DocumentMapper>().AddItemsToItemTypesCache(parent);

            IDictionary<Guid, Guid> cache = SessionManager.VolatileElements.ItemTypesCache;

            foreach (WarehouseDocumentLine line in this.Children)
            {
                Guid itemTypeId = cache[line.ItemId];
                ItemType itemType = DictionaryMapper.Instance.GetItemType(itemTypeId);

                if (!itemType.IsWarehouseStorable)
                    throw new ClientException(ClientExceptionId.NonStorableItemOnWarehouseDocument);
            }

            if (parent.DocumentType.WarehouseDocumentOptions.WarehouseDirection == WarehouseDirection.Income)
            {
                //validation for incomes

                foreach (WarehouseDocumentLine line in this.Children)
                {
                    if(line.IncomeDate == null)
                        throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:incomeDate");
                }
            }
            else if (parent.DocumentType.WarehouseDocumentOptions.WarehouseDirection == WarehouseDirection.Outcome)
            {
                foreach (WarehouseDocumentLine line in this.Children)
                {
                    if (line.OutcomeDate == null)
                        throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:outcomeDate");
                }
            }

            base.Validate();
        }
    }
}
