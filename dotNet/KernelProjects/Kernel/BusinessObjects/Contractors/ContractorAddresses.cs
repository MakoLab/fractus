using System;
using System.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class that manages <see cref="Contractor"/>'s addresses.
    /// </summary>
    public class ContractorAddresses : BusinessObjectsContainer<ContractorAddress>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorAddresses"/> class with a specified <see cref="Contractor"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Contractor"/> to attach to.</param>
        public ContractorAddresses(Contractor parent)
            : base(parent, "address")
        {
        }

        /// <summary>
        /// Creates new <see cref="ContractorAddress"/> according to the contractor's defaults and attaches it to the parent <see cref="Contractor"/>.
        /// </summary>
        /// <returns>A new <see cref="ContractorAddress"/>.</returns>
        public override ContractorAddress CreateNew()
        {
            //create new ContractorAddress object and attach it to the element
            ContractorAddress address = new ContractorAddress((Contractor)this.Parent);

            address.Order = this.Children.Count + 1;

            //add address to the addresses collection
            this.Children.Add(address);

            return address;
        }

        /// <summary>
        /// Gets the billing address from the collection. If it doesn't exist it returns default address.
        /// </summary>
        /// <returns>Billing address or default address or <c>null</c> if there are no addresses.</returns>
        public ContractorAddress GetBillingAddress()
        {
            if (Children.Count == 0)
                return null;

            //get the billing address id

            Guid billingAddressId = DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Billing).Id.Value;
            Guid defaultAddressId = DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Default).Id.Value;

            var billingAddress = from address in this.Children
                                 where address.ContractorFieldId == billingAddressId
                                 select address;

            if (billingAddress.Count() > 0)
                return billingAddress.ElementAt(0);

            var defaultAddress = from address in this.Children
                                 where address.ContractorFieldId == defaultAddressId
                                 select address;

            if (defaultAddress.Count() > 0)
                return defaultAddress.ElementAt(0);

            return this.Children.First();
        }

        public ContractorAddress GetDefaultAddress()
        {
            if (Children.Count == 0)
                return null;

            //get the billing address id

            Guid defaultAddressId = DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Default).Id.Value;

            var defaultAddress = from address in this.Children
                                 where address.ContractorFieldId == defaultAddressId
                                 select address;

            if (defaultAddress.Count() > 0)
                return defaultAddress.ElementAt(0);

            return this.Children.FirstOrDefault();
        }

        public override void Validate()
        {
            base.Validate();

            foreach (var attr in this.Children)
            {
                var count = this.Children.Where(c => c.ContractorFieldId == attr.ContractorFieldId && c != attr).Count();

                if (count > 0)
                {
                    var field = DictionaryMapper.Instance.GetContractorField(attr.ContractorFieldId);

                    if (field.Metadata.Element("allowMultiple") == null)
                        throw new ClientException(ClientExceptionId.SingleAttributeMultipled, null, "name:" + BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(field).Value);
                }
            }
        }
    }
}
