package com.makolab.fractus.commands
{
	public class GetDeliveriesCommand extends ExecuteCustomProcedureCommand
	{
		public function GetDeliveriesCommand(itemId:String = null,warehouseId:String = null)
		{
			super('item.p_getDeliveriesWithNoLock');
			//to i argumenty konstruktora zosatają na wszelki wypadek:
			this.itemId = itemId;
			this.warehouseId = warehouseId;
			if(itemId){
				var item:XML = <item id={itemId}/>;
				if(warehouseId)item.@warehouseId = warehouseId;
				this.items = [item];
			}
		}
		
		public var itemId:String;
		public var warehouseId:String;
		public var items:Array = [];
		
		override protected function getOperationParams(data:Object):Object
		{
			operationParams = <root/>;
			for (var i:int = 0; i < items.length; i++){
				operationParams.appendChild(items[i]);
			}
			/* if(warehouseId)
			{
				operationParams.item.@warehouseId = warehouseId;
			} */
			return operationParams; 
		}
	}
}