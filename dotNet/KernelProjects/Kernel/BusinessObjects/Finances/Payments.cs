
using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;

namespace Makolab.Fractus.Kernel.BusinessObjects.Finances
{
    /// <summary>
    /// Class that manages document's Payments.
    /// </summary>
    internal class Payments : BusinessObjectsContainer<Payment>
    {
		internal Document SourceDocument { get; set; }

		private IPaymentsContainingDocument PaymentContainingSourceDocument
		{
			get
			{
				return SourceDocument as IPaymentsContainingDocument;
			}
		}

        /// <summary>
        /// Initializes a new instance of the <see cref="Payments"/> class with a specified <see cref="Document"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="Document"/> to attach to.</param>
        public Payments(Document parent)
            : base(parent, "payment")
        {
        }

        /// <summary>
        /// Creates new <see cref="Payment"/> according to the document's defaults and attaches it to the parent <see cref="Document"/>.
        /// </summary>
        /// <returns>A new <see cref="Payment"/>.</returns>
        public override Payment CreateNew()
        {
            //create new Payment object and attach it to the element
            Document parent = (Document)this.Parent;
            Payment payment = new Payment(parent);

            payment.Order = this.Children.Count + 1;

            DocumentCategory dc = parent.DocumentType.DocumentCategory;

            CommercialDocument commercialDocument = this.Parent as CommercialDocument;
            FinancialDocument financialDocument = this.Parent as FinancialDocument;

            if (dc == DocumentCategory.Sales || dc == DocumentCategory.SalesCorrection)
                payment.Direction = -1;
            else if (dc == DocumentCategory.Purchase || dc == DocumentCategory.PurchaseCorrection)
                payment.Direction = 1;
            else if (dc == DocumentCategory.Financial)
            {
                FinancialDirection fdc = parent.DocumentType.FinancialDocumentOptions.FinancialDirection;

                if (fdc == FinancialDirection.Income)
                    payment.Direction = 1;
                else
                    payment.Direction = -1;
            }

			//Copy payment contractor from source if exists
			if (this.PaymentContainingSourceDocument != null
				&& this.PaymentContainingSourceDocument.Payments != null
				&& this.PaymentContainingSourceDocument.Payments.Children.Count >= payment.Order)
			{
				Payment sourcePayment = this.PaymentContainingSourceDocument.Payments[payment.Order - 1];
				payment.Contractor = sourcePayment.Contractor;
				payment.ContractorAddressId = sourcePayment.ContractorAddressId;
			}
            else if (commercialDocument != null)
            {
                payment.Contractor = commercialDocument.Contractor;
                payment.ContractorAddressId = commercialDocument.ContractorAddressId;
            }
            else if (financialDocument != null)
            {
                payment.Contractor = financialDocument.Contractor;
                payment.ContractorAddressId = financialDocument.ContractorAddressId;
            }

            //add the attribute to the collection
            this.Children.Add(payment);

            return payment;
        }

        /// <summary>
        /// Validates the collection.
        /// </summary>
        public override void Validate()
        {
            Document parent = (Document)this.Parent;
            DocumentType dt = parent.DocumentType;
            decimal totalAmountOnPayments = 0;
            bool doesAnyPaymentExist = false;

			#region Walidacja ilości płatności na dokumencie
			if (!dt.AllowedPayments.IsUndefined)
			{
				if (!dt.AllowedPayments.IsInRange(this.Children.Count))
				{
					if (dt.AllowedPayments.IsSingleValue && dt.AllowedPayments.Min == 0)
					{
						throw new ClientException(ClientExceptionId.IncorrectNumberOfPayments);
					}
					else if (dt.AllowedPayments.IsMaxInfinity && dt.AllowedPayments.Min == 1)
					{
						throw new ClientException(ClientExceptionId.IncorrectNumberOfPayments2);
					}
					else
					{
						throw new ClientException(ClientExceptionId.IncorrectNumberOfPayments3, 
							null, "count:"+dt.AllowedPayments.Serialize());
					}
				}
			}
			else
			{
				DocumentCategory dc = dt.DocumentCategory;
				if (dc == DocumentCategory.SalesOrder || dc == DocumentCategory.Service)
				{
					if (this.Children.Count != 0)
					{
						throw new ClientException(ClientExceptionId.IncorrectNumberOfPayments);
					}
				}
				else if (dc == DocumentCategory.Sales && this.Children.Count == 0)
				{
					throw new ClientException(ClientExceptionId.IncorrectNumberOfPayments2);
				}
			}
			#endregion

			//validate if all payments contains forbidden payment method id
            foreach (Payment pt in this.Children)
            {
                doesAnyPaymentExist = true;

                if (pt.Amount > 0 || parent == null || parent.BOType != BusinessObjectType.FinancialDocument)
                    totalAmountOnPayments += pt.Amount;

                if (dt.CommercialDocumentOptions != null)
                {
                    bool exists = false;

                    foreach (XElement id in dt.CommercialDocumentOptions.PaymentMethods.Elements())
                    {
                        if (pt.PaymentMethodId == new Guid(id.Value))
                        {
                            exists = true;
                            break;
                        }
                    }


                    if (!exists)
                    {
                        string paymentMethod = BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(DictionaryMapper.Instance.GetPaymentMethod(pt.PaymentMethodId.Value)).Value;
                        throw new ClientException(ClientExceptionId.PaymentMethodForbidden, null, "paymentMethodName:" + paymentMethod);
                    }
                }
            }

            if (doesAnyPaymentExist)
            {
                totalAmountOnPayments = Math.Round(Math.Abs(totalAmountOnPayments), 2, MidpointRounding.AwayFromZero);

				DocumentCategory parentCategory = parent.DocumentType.DocumentCategory;
				if (parent.BOType == BusinessObjectType.CommercialDocument
					&& parentCategory != DocumentCategory.Purchase && parentCategory != DocumentCategory.PurchaseCorrection)
				{
					CommercialDocument parentDocument = (CommercialDocument)parent;

					decimal grossValueToCompare = parentDocument.DifferentialPaymentsAndDocumentValueCheck ?
						parentDocument.GrossValue + parentDocument.GrossValueBeforeCorrection : 
						parentDocument.GrossValue;

					if (Math.Abs(grossValueToCompare) != totalAmountOnPayments)
					{
						throw new ClientException(ClientExceptionId.DifferentPaymentsAndDocumentValue);
					}
				}
				else if (parent.BOType == BusinessObjectType.FinancialDocument && Math.Round(Math.Abs(((FinancialDocument)parent).Amount), 2, MidpointRounding.AwayFromZero) != totalAmountOnPayments)
				{
					throw new ClientException(ClientExceptionId.DifferentPaymentsAndDocumentValue);
				}
            }
            base.Validate();
        }

		/// <summary>
		/// Calculate DueDays on all payments
		/// </summary>
		/// <param name="subtrahend">Subtrahend in calculation</param>
		public void CalculateDueDaysOnPayments(DateTime subtrahend)
		{
			foreach (Payment payment in this.Children)
			{
				payment.CalculateDueDays(subtrahend);
			}
		}

		/// <summary>
		/// Makes a copy of contractor from document containg payments
		/// </summary>
		/// <param name="document">Document containing payments and contractor</param>
		public void CopyDocumentContractor()
		{
			IContractorContainingDocument document = this.Parent as IContractorContainingDocument;
			if (document != null)
			{
				foreach (Payment payment in this.Children)
				{
					payment.CopyDocumentContractor(document);
				}
			}
		}
    }
}
