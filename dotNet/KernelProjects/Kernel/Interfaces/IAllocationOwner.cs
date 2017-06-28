using Makolab.Fractus.Kernel.HelperObjects;

namespace Makolab.Fractus.Kernel.Interfaces
{
    internal interface IAllocationOwner
    {
        AllocationCollection AllocationCollection { get; set; }
    }
}
