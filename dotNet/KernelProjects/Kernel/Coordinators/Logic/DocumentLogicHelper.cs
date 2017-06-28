using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Interfaces;
using System;
using Makolab.Fractus.Kernel.BusinessObjects.Documents.Options;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
    /// <summary>
    /// Helper class for logic that controls document operations.
    /// </summary>
    internal static class DocumentLogicHelper
    {
        public static void AssignNumber(SimpleDocument document, DocumentMapper mapper)
        {
            if (document.IsNew && !document.Number.SkipAutonumbering)
            {
                document.Number.ComputedSeriesValue = mapper.ComputeSeries(document);
                document.Number.FullNumber = mapper.ComputeFullDocumentNumber(document, null);
            }
			if (String.IsNullOrEmpty(document.Number.FullNumber))
			{
				throw new ClientException(ClientExceptionId.EmptyDocumentNumberError);
			}
        }
    }
}
