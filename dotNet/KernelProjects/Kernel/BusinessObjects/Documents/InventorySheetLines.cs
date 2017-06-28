using System.Collections.Generic;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    internal class InventorySheetLines : BusinessObjectsContainer<InventorySheetLine>
    {
        public InventorySheetLines(InventorySheet parent)
            : base(parent, "line")
        {
        }

        public override InventorySheetLine CreateNew()
        {
            InventorySheet parent = (InventorySheet)this.Parent;

            //create new object and attach it to the element
            InventorySheetLine line = new InventorySheetLine(parent);

            line.Order = this.Children.Count + 1;

            //add object to the collection
            this.Children.Add(line);

            return line;
        }

        public override void Validate()
        {
            if (this.Children.Count == 0)
                throw new ClientException(ClientExceptionId.NoLines);

            List<InventorySheetLine> list = (List<InventorySheetLine>)this.Children;

            for (int i = 0; i < list.Count; i++)
            {
                if (list[i].Direction == 0)
                    continue;

                for (int u = i + 1; u < list.Count; u++)
                {
                    if (list[u].Direction == 0)
                        continue;

                    if (list[i].ItemId == list[u].ItemId)
                        throw new ClientException(ClientExceptionId.DuplicatedItemInInventorySheet);
                }
            }

            base.Validate();
        }
    }
}
