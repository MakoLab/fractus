

namespace Makolab.Fractus.Kernel.BusinessObjects.Finances
{
    internal class PaymentSettlements : BusinessObjectsContainer<PaymentSettlement>
    {
        public PaymentSettlements(Payment parent)
            : base(parent, "settlement")
        {
        }

        public override PaymentSettlement CreateNew()
        {
            PaymentSettlement attribute = new PaymentSettlement((Payment)this.Parent);

            //add the attribute to the collection
            this.Children.Add(attribute);

            return attribute;
        }
    }
}
