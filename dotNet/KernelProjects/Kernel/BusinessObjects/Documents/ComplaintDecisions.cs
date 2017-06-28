
namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    internal class ComplaintDecisions : BusinessObjectsContainer<ComplaintDecision>
    {
        public ComplaintDecisions(ComplaintDocumentLine parent)
            : base(parent, "complaintDecision")
        {
        }

        public override ComplaintDecision CreateNew()
        {
            ComplaintDocumentLine parent = (ComplaintDocumentLine)this.Parent;

            //create new object and attach it to the element
            ComplaintDecision line = new ComplaintDecision(parent);

            line.Order = this.Children.Count + 1;

            //add object to the collection
            this.Children.Add(line);

            return line;
        }
    }
}
