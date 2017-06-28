using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Kernel.Enums
{
	public enum OfferStatusName
	{
		Unknown = 0,
		Rejected = -40, //Odrzucona
		Suspended = -20, //Zawieszona
		Initial = 20, //Wstępna
		InPreparation = 30, //W przygotowaniu
		Specified = 40, //Opisana
		Accepted = 60, //Aktualna - podpisano umowę
		Realized = 80 //Nieaktualna - zakupiono/wynajęto
	}
}
