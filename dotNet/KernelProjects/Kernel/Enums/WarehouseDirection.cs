
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Exceptions;
using System.Globalization;
namespace Makolab.Fractus.Kernel.Enums
{
    /// <summary>
    /// Specifies warehouse directions.
    /// </summary>
    public enum WarehouseDirection
    {
        /// <summary>
        /// Income direction.
        /// </summary>
        Income = 0,

        /// <summary>
        /// Outcome direction.
        /// </summary>
        Outcome = 1,

        OutcomeShift = 2,
        IncomeShift = 3
    }
}
