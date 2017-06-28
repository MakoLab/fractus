
namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class that manages <see cref="Contractor"/>'s bank accounts.
    /// </summary>
    public class ContractorAccounts : BusinessObjectsContainer<ContractorAccount>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorAccounts"/> class with a specified <see cref="Contractor"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Contractor"/> to attach to.</param>
        public ContractorAccounts(Contractor parent) 
            : base(parent, "account")
        {
        }

        /// <summary>
        /// Creates new <see cref="ContractorAccount"/> according to the contractor's defaults and attaches it to the parent <see cref="Contractor"/>.
        /// </summary>
        /// <returns>A new <see cref="ContractorAccount"/>.</returns>
        public override ContractorAccount CreateNew()
        {
            //create new ContractorAccount object and attach it to the element
            ContractorAccount account = new ContractorAccount((Contractor)this.Parent);

            account.Order = this.Children.Count + 1;

            //add the account to the accounts collection
            this.Children.Add(account);

            return account;
        }
    }
}
