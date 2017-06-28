using System;
using System.Globalization;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    public class SalesOrderSettlement
    {
        public string Symbol { get; private set; }
        public Guid VatRateId { get; private set; }
        public decimal NetValue { get; set; }
        public decimal GrossValue { get; set; }
        public decimal VatValue { get; set; }

        public SalesOrderSettlement(Guid vatRateId)
        {
            this.Symbol = DictionaryMapper.Instance.GetVatRate(vatRateId).Symbol;
            this.VatRateId = vatRateId;
        }

        public XElement Serialize()
        {
            return new XElement("vatRate",
                new XAttribute("id", this.VatRateId.ToUpperString()),
                new XAttribute("netValue", this.NetValue.ToString(CultureInfo.InvariantCulture)),
                new XAttribute("grossValue", this.GrossValue.ToString(CultureInfo.InvariantCulture)),
                new XAttribute("vatValue", this.VatValue.ToString(CultureInfo.InvariantCulture)));
        }
    }
}
