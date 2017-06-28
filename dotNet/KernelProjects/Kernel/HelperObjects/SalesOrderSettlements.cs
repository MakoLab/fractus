using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    public class SalesOrderSettlements
    {
        public ICollection<SalesOrderSettlement> SalesOrder { get; private set; }
        public ICollection<SalesOrderSettlement> Prepaids { get; private set; }
		public decimal CurrentMaxSettlementDifference { get; private set; }

        public SalesOrderSettlements()
        {
            this.SalesOrder = new List<SalesOrderSettlement>();
            this.Prepaids = new List<SalesOrderSettlement>();
        }

        internal void LoadSalesOrder(CommercialDocument salesOrder)
        {
            this.SalesOrder.Clear();

            foreach (var vtEntry in salesOrder.VatTableEntries)
            {
                SalesOrderSettlement so = new SalesOrderSettlement(vtEntry.VatRateId);
                so.NetValue = vtEntry.NetValue;
                so.GrossValue = vtEntry.GrossValue;
                so.VatValue = vtEntry.VatValue;
                this.SalesOrder.Add(so);
            }

			this.CurrentMaxSettlementDifference = ProcessManager.Instance.GetMaxSettlementDifference(salesOrder);
        }

        public ICollection<SalesOrderSettlement> GetUnsettledValues()
        {
            List<SalesOrderSettlement> retList = new List<SalesOrderSettlement>();

            foreach (var so in this.SalesOrder)
            {
                SalesOrderSettlement diff = new SalesOrderSettlement(so.VatRateId);
                diff.NetValue = so.NetValue;
                diff.GrossValue = so.GrossValue;
                diff.VatValue = so.VatValue;

                var pp = this.Prepaids.Where(p => p.VatRateId == so.VatRateId).FirstOrDefault();

                if (pp != null)
                {
                    diff.NetValue -= pp.NetValue;
                    diff.GrossValue -= pp.GrossValue;
                    diff.VatValue -= pp.VatValue;
                }

				SalesOrderBalanceValidator validator = new SalesOrderBalanceValidator(this.CurrentMaxSettlementDifference, diff);

				if (!validator.IsIllegalOverPayment) //pomijamy gdyż i tak zostanie rzucony wyjątek
				{
					if (!validator.IsAcceptableOverPayment) //pomijamy gdyż nastąpi automatyczna korekta
					{
						if (diff.NetValue > 0 || diff.GrossValue > 0 || diff.VatValue > 0)
							retList.Add(diff);
					}
				}
            }

            return retList;
        }

        internal void SubtractPrepaidDocument(CommercialDocument document)
        {
            foreach (var vtEntry in document.VatTableEntries)
            {
                var prepaid = this.Prepaids.Where(p => p.VatRateId == vtEntry.VatRateId).FirstOrDefault();

				if (prepaid != null)
				{
					prepaid.NetValue -= vtEntry.NetValue;
					prepaid.GrossValue -= vtEntry.GrossValue;
					prepaid.VatValue -= vtEntry.VatValue;

					if (prepaid.NetValue == 0 && prepaid.GrossValue == 0 && prepaid.VatValue == 0)
						this.Prepaids.Remove(prepaid);
				}
            }
        }

        public void LoadPrepaids(XElement source)
        {
            this.Prepaids.Clear();

            foreach (XElement vr in source.Elements())
            {
                SalesOrderSettlement so = new SalesOrderSettlement(new Guid(vr.Attribute("id").Value));
                so.NetValue = Convert.ToDecimal(vr.Attribute("netValue").Value, CultureInfo.InvariantCulture);
                so.GrossValue = Convert.ToDecimal(vr.Attribute("grossValue").Value, CultureInfo.InvariantCulture);
                so.VatValue = Convert.ToDecimal(vr.Attribute("vatValue").Value, CultureInfo.InvariantCulture);
                this.Prepaids.Add(so);
            }
        }

        public XElement Serialize()
        {
            XElement settlements = new XElement("settlements", new XElement("salesOrder"), new XElement("prepaids"));

            foreach (var set in this.SalesOrder.OrderByDescending(s => s.Symbol))
                settlements.Element("salesOrder").Add(set.Serialize());

            foreach (var set in this.Prepaids.OrderByDescending(s => s.Symbol))
                settlements.Element("prepaids").Add(set.Serialize());

            return settlements;
        }
    }
}
