package com.makolab.fractus.commands
{
	import com.makolab.components.util.Tools;
		
	public class GetItemStockHistoryCommand extends ExecuteCustomProcedureCommand
	{
		public function GetItemStockHistoryCommand(warehouseId:String, itemId:String, dateFrom:Date=null, dateTo:Date=null)
		{
			super('document.p_getStockHistory');
			operationParams = <params><itemId>{itemId}</itemId><warehouseId>{warehouseId}</warehouseId></params>;
			
			if(dateFrom)
			{
				operationParams.dateFrom = Tools.dateToString(dateFrom);
			}
			
			if(dateTo)
			{
				operationParams.dateTo = Tools.dateToString(dateTo) + "T23:59:59.997";
			}
		}
	}
}