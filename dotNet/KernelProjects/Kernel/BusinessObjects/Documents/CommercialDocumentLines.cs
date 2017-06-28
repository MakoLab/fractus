using System.Linq;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class that manages <see cref="CommercialDocument"/>'s lines.
    /// </summary>
    internal class CommercialDocumentLines : BusinessObjectsContainer<CommercialDocumentLine>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="CommercialDocumentLines"/> class with a specified <see cref="CommercialDocument"/> to attach to.
        /// </summary>
        /// <param name="parent"><see cref="CommercialDocument"/> to attach to.</param>
        public CommercialDocumentLines(CommercialDocumentBase parent)
            : base(parent, "line")
        {
        }

        /// <summary>
        /// Creates new <see cref="CommercialDocumentLine"/> according to the CommercialDocument's defaults and attaches it to the parent <see cref="CommercialDocument"/>.
        /// </summary>
        /// <returns>A new <see cref="CommercialDocumentLine"/>.</returns>
        public override CommercialDocumentLine CreateNew()
        {
            CommercialDocumentBase parent = (CommercialDocumentBase)this.Parent;
            
            //create new object and attach it to the element
            CommercialDocumentLine line = new CommercialDocumentLine(parent);

            line.Order = this.Children.Count + 1;

            DocumentCategory dc = parent.DocumentType.DocumentCategory;

            if (!parent.IsBeforeSystemStart)
            {
                if ((dc == DocumentCategory.Sales || dc == DocumentCategory.SalesCorrection) && parent.DocumentType.CommercialDocumentOptions.SimulatedInvoice == null)
                    line.CommercialDirection = -1;
                else if (dc == DocumentCategory.Purchase || dc == DocumentCategory.PurchaseCorrection)
                    line.CommercialDirection = 1;
                else if (dc == DocumentCategory.Order)
                    line.OrderDirection = 1;
                else if (dc == DocumentCategory.Reservation)
                    line.OrderDirection = -1;
                else
                {
                    line.CommercialDirection = 0;
                    line.OrderDirection = 0;
                }
            }
            else
            {
                line.CommercialDirection = 0;
                line.OrderDirection = 0;
            }

            //add object to the collection
            this.Children.Add(line);
            
            return line;
        }

        /// <summary>
        /// Validates the collection.
        /// </summary>
        public override void Validate()
        {
            if (this.Children.Count == 0 && this.Parent.BOType != BusinessObjectType.ServiceDocument)
                throw new ClientException(ClientExceptionId.NoLines);

            DocumentType dt = DictionaryMapper.Instance.GetDocumentType(((CommercialDocumentBase)this.Parent).DocumentTypeId);

            if (dt.CommercialDocumentOptions != null && !dt.CommercialDocumentOptions.AllowMultiplePositions && this.Children.Count > 1 && this.Parent.BOType != BusinessObjectType.ServiceDocument)
                throw new ClientException(ClientExceptionId.OnlyOneDocumentLineAllowed);

            if (dt.DocumentCategory == DocumentCategory.SalesCorrection || dt.DocumentCategory == DocumentCategory.PurchaseCorrection)
            {
                bool hasCorrectedLine = false;

                foreach (CommercialDocumentLine line in this.Children)
                {
                    if (line.NetPrice != 0 ||
                        line.GrossPrice != 0 ||
                        line.Quantity != 0)
                    {
                        hasCorrectedLine = true;
                        break;
                    }
                }

				CommercialDocument correctiveCommercialDocument = (CommercialDocument)this.Parent;

                bool hasDescriptiveAttributes = correctiveCommercialDocument.Attributes.Children.Where(a => a.DocumentFieldName == DocumentFieldName.Attribute_DescriptiveCorrectionAfter || a.DocumentFieldName == DocumentFieldName.Attribute_DescriptiveCorrectionBefore).Count() != 0;

				/*
				 * bool numberChanged = correctiveCommercialDocument.Number.Number != correctiveCommercialDocument.CorrectedDocument.Number.Number || correctiveCommercialDocument.Number.FullNumber != correctiveCommercialDocument.CorrectedDocument.Number.FullNumber;
				 */

                if (!hasCorrectedLine && !hasDescriptiveAttributes)
                    throw new ClientException(ClientExceptionId.NonCorrectiveCorrection);
            }

            base.Validate();
        }
    }
}
