
namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    internal class InventorySheets : BusinessObjectsContainer<InventorySheet>
    {
        public InventorySheets(InventoryDocument parent)
            : base(parent, "sheet")
        {
        }

        public override InventorySheet CreateNew()
        {
            InventoryDocument parent = (InventoryDocument)this.Parent;

            //create new object and attach it to the element
            InventorySheet line = new InventorySheet(parent);

            line.Order = this.Children.Count + 1;

            //add object to the collection
            this.Children.Add(line);

            return line;
        }
    }
}
