using System;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
    internal class GetFinancialReportValidationDatesResponse
    {
        public DateTime? PreviousFinancialReportClosureDate { get; set; }
        public DateTime? NextFinancialReportOpeningDate { get; set; }
        public DateTime? GreatestIssueDateOnFinancialDocument { get; set; }
    }
}
