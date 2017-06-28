using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    internal class ContainerShifts : BusinessObjectsContainer<ContainerShift>
    {
        public ContainerShifts(ShiftTransaction parent)
            : base(parent, "shift")
        {
        }

        public override ContainerShift CreateNew()
        {
            ShiftTransaction parent = (ShiftTransaction)this.Parent;

            //create new object and attach it to the element
            ContainerShift line = new ContainerShift(parent);

            line.Order = this.Children.Count + 1;

            //add object to the collection
            this.Children.Add(line);

            return line;
        }

        /// <summary>
        /// Validates the collection.
        /// </summary>
        public override void Validate()
        {
            if (this.Children.Count == 0)
                throw new ClientException(ClientExceptionId.NoLines);

            base.Validate();
        }
    }
}
