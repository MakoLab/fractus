using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TrackerDataAccessLayer.Enums
{
	public enum SalesOrderStatusName
	{
		None = 0, /*Nieokreślony - pomocniczy*/
		Cancelled = -1, /*Anulowane*/
		Registered = 1, /*Przyjęte*/
		InProgress= 2, /*W realizacji*/
		Ready = 3, /*Gotowe do odbioru/montażu*/
		Commited = 4, /*Zrealizowane*/
	}
}
