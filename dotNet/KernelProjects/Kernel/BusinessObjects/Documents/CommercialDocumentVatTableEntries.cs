
using System;
using System.Collections.Generic;
using System.Linq;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    internal class CommercialDocumentVatTableEntries : BusinessObjectsContainer<CommercialDocumentVatTableEntry>
    {
        public CommercialDocumentVatTableEntries(CommercialDocumentBase parent)
            : base(parent, "vtEntry")
        {
        }

        public CommercialDocumentVatTableEntry CreateNewAfter(CommercialDocumentVatTableEntry previous, Guid vatRateId)
        {
            //create new object and attach it to the element
            CommercialDocumentVatTableEntry vtentry = new CommercialDocumentVatTableEntry((CommercialDocumentBase)this.Parent);

            vtentry.Order = this.Children.Count + 1;

            var list = (List<CommercialDocumentVatTableEntry>)this.Children;

            //add address to the addresses collection
			if (previous == null)
			{
				//jeśli nie ma poprzednika to pobieramy ostatni o nie większej stawce Vat albo null gdy takiego nie ma
				decimal vatRate = DictionaryMapper.Instance.GetVatRate(vatRateId).Rate;
				previous = list.Where(ventry => DictionaryMapper.Instance.GetVatRate(ventry.VatRateId).Rate <= vatRate).LastOrDefault();
			}
			int index = previous != null ? list.IndexOf(previous) + 1 : 0;
            list.Insert(index, vtentry);

            this.UpdateOrder();

            return vtentry;
        }

        public void RemoveZeroValuesEntries()
        {
            List<CommercialDocumentVatTableEntry> listToDelete = new List<CommercialDocumentVatTableEntry>();

            foreach (var v in this.Children)
            {
                if (v.NetValue == 0 && v.GrossValue == 0 && v.VatValue == 0)
                    listToDelete.Add(v);
            }

            foreach (var v in listToDelete)
                this.Children.Remove(v);
        }

        public ICollection<Guid> GetVatRates()
        {
            List<Guid> list = new List<Guid>();

            foreach (var vt in this.Children)
            {
                if (!list.Contains(vt.VatRateId))
                    list.Add(vt.VatRateId);
            }

            return list;
        }

        public override CommercialDocumentVatTableEntry CreateNew()
        {
            //create new object and attach it to the element
            CommercialDocumentVatTableEntry vtentry = new CommercialDocumentVatTableEntry((CommercialDocumentBase)this.Parent);

            vtentry.Order = this.Children.Count + 1;
            
            //add address to the addresses collection
            this.Children.Add(vtentry);

            return vtentry;
        }
    }
}
