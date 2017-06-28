using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;

namespace Makolab.Fractus.Kernel.Interfaces
{
	internal interface IPaymentsContainingDocument
	{
		Payments Payments { get; }
	}
}
