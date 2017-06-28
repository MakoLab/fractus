package com.makolab.fractus.commands
{
	public class GetItemLotsCommand extends ExecuteCustomProcedureCommand
	{
		public function GetItemLotsCommand(itemId:String, warehouseId:String,shiftTransactionId:String = null,warehouseDocumentHeaderId:String = null)
		{
			var parameter:XML = <root><itemId>{itemId}</itemId></root>;

			if(warehouseId && warehouseId != "")
				parameter.appendChild(<warehouseId>{warehouseId}</warehouseId>);

			if(shiftTransactionId)parameter.shiftTransactionId = shiftTransactionId;
			if(warehouseDocumentHeaderId)parameter.warehouseDocumentHeaderId = warehouseDocumentHeaderId;
			super('warehouse.p_getAvailableLots', parameter);
		}
		
	}
}