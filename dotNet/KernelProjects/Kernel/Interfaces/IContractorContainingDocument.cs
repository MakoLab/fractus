using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;

namespace Makolab.Fractus.Kernel.Interfaces
{
	internal interface IContractorContainingDocument
	{
		Contractor Contractor { get; set; }
		Guid? ContractorAddressId { get; set; }
	}
}
