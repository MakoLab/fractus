using System.Collections.Generic;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for an object to creates <see cref="IncomeOutcomeRelation"/> for <see cref="WarehouseDocumentLine"/>.
    /// </summary>
    internal interface IOutcomeStrategy
    {
        /// <summary>
        /// Creates the outcomes for the specifies lines using specified deliveries.
        /// </summary>
        /// <param name="lines">The lines for which to create the outcomes.</param>
        /// <param name="deliveries">Collection of deliveries.</param>
        void CreateOutcomes(ICollection<WarehouseDocumentLine> lines, ICollection<DeliveryResponse> deliveries);

        void CreateLinesForOutcomeShiftDocument(ICollection<WarehouseDocumentLine> sourceLines, ICollection<DeliveryResponse> deliveryResponses, WarehouseDocument destinationDocument);
    }
}
