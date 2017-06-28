using System;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.OutcomeStrategies;

namespace Makolab.Fractus.Kernel.Managers
{
    /// <summary>
    /// Class that manages outcome strategies for all warehouses.
    /// </summary>
    internal class OutcomeStrategyManager
    {
        /// <summary>
        /// Instance of <see cref="OutcomeStrategyManager"/>.
        /// </summary>
        private static OutcomeStrategyManager instance = new OutcomeStrategyManager();

        /// <summary>
        /// Gets the instance of <see cref="OutcomeStrategyManager"/>.
        /// </summary>
        public static OutcomeStrategyManager Instance
        {
            get { return OutcomeStrategyManager.instance; }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="OutcomeStrategyManager"/> class.
        /// </summary>
        protected OutcomeStrategyManager()
        {
        }

        /// <summary>
        /// Gets the outcome strategy for the requested warehouse.
        /// </summary>
        /// <param name="warehouseId">The warehouse id for which to get the outcome strategy.</param>
        /// <returns>Outcome strategy object that implements <see cref="IOutcomeStrategy"/>.</returns>
        public IOutcomeStrategy GetOutcomeStrategy(Guid warehouseId)
        {
            Warehouse wh = DictionaryMapper.Instance.GetWarehouse(warehouseId);

            if (wh.ValuationMethod == ValuationMethod.DeliverySelection)
                return new DeliverySelectionStrategy(BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(wh).Value);
            else if (wh.ValuationMethod == ValuationMethod.Fifo)
                return new FifoStrategy(BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(wh).Value);
            else
                throw new InvalidOperationException("Unknown warehouse strategy.");
        }
    }
}
