using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SalesOrderTracker
{
	public class SalesOrderStatus
	{
		//#region StatusFlow
		//private static Dictionary<SalesOrderStatusName, Dictionary<ActionName, SalesOrderStatusName>> StatusFlow
		//    = new Dictionary<SalesOrderStatusName, Dictionary<ActionName, SalesOrderStatusName>>()
		//    {
		//        //Początek
		//        {SalesOrderStatusName.None, 
		//            new Dictionary<ActionName, SalesOrderStatusName> () 
		//            { 
		//                //Rejestracja w systemie -> Przyjęte
		//                {ActionName.DocumentIssued, SalesOrderStatusName.Registered}
		//            }
		//        },
		//        //Przyjęte
		//        {SalesOrderStatusName.Registered,
		//            new Dictionary<ActionName, SalesOrderStatusName> ()
		//            {
		//                //FZ -> W realizacji
		//                {ActionName.PrepaymentIssued, SalesOrderStatusName.InProgress},
		//                //Atr. "Gotowe" -> Gotowe do montażu/odbioru
		//                {ActionName.MarkedAsReady, SalesOrderStatusName.Ready}
		//            }
		//        },
		//        //W realizacji
		//        {SalesOrderStatusName.InProgress,
		//            new Dictionary<ActionName, SalesOrderStatusName> ()
		//            {
		//                //Atr. "zaplanowane" lub FZ -> W realizacji
		//                {ActionName.MarkedAsPlanned, SalesOrderStatusName.InProgress},
		//                {ActionName.PrepaymentIssued, SalesOrderStatusName.InProgress},
		//                //Atr. "gotowe" -> Gotowe...
		//                {ActionName.MarkedAsReady, SalesOrderStatusName.Ready}
		//            }
		//        },
		//        //Gotowe...
		//        {SalesOrderStatusName.Ready,
		//            new Dictionary<ActionName, SalesOrderStatusName> ()
		//            {
		//                //FZ -> Gotowe...
		//                {ActionName.PrepaymentIssued, SalesOrderStatusName.Ready},
		//                //Commit -> Zrealizowane
		//                {ActionName.Commit, SalesOrderStatusName.Commited}
		//            }
		//        }
		//    };
		//#endregion

		//public SalesOrderStatusName StatusName { get; set; }

		//public void SetCurrentStatus(List<ActionName> actionsTaken)
		//{
		//    foreach (ActionName action in actionsTaken)
		//    {
		//        this.StatusName = SalesOrderStatus.StatusFlow[this.StatusName][action];
		//    }
		//}
	}
}
