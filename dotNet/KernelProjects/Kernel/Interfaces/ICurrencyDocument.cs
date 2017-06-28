using System;

namespace Makolab.Fractus.Kernel.Interfaces
{
    public interface ICurrencyDocument
    {
        Guid DocumentCurrencyId { get; set; }
        DateTime ExchangeDate { get; set; }
        int ExchangeScale { get; set; }
        decimal ExchangeRate { get; set; }
    }
}
