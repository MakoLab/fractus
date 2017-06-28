
namespace Makolab.Fractus.Kernel.Enums
{
    public enum WarehouseDocumentLineType
    {
        Standard = 0,
        IncomeCorrectionOutgoing = -1,
        IncomeCorrectionIncoming = 1,
        OutcomeQuantityCorrectionOutgoing = -2,
        OutcomeQuantityCorrectionIngoing = 2,
        OutcomeValueCorrectionOutgoing = -3,
        OutcomeValueCorrectionIngoing = 3
    }
}
