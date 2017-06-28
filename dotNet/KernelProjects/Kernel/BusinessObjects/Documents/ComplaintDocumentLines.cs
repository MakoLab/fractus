using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    internal class ComplaintDocumentLines : BusinessObjectsContainer<ComplaintDocumentLine>
    {
        public ComplaintDocumentLines(ComplaintDocument parent)
            : base(parent, "line")
        {
        }

        public override ComplaintDocumentLine CreateNew()
        {
            ComplaintDocument parent = (ComplaintDocument)this.Parent;

            //create new object and attach it to the element
            ComplaintDocumentLine line = new ComplaintDocumentLine(parent);

            line.Order = this.Children.Count + 1;

            //add object to the collection
            this.Children.Add(line);

            return line;
        }

        public override void Validate()
        {
            if (this.Children.Count == 0)
                throw new ClientException(ClientExceptionId.NoLines);

            base.Validate();
        }
    }
}
