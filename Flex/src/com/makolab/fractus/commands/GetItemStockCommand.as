package com.makolab.fractus.commands
{
	public class GetItemStockCommand extends ExecuteCustomProcedureCommand
	{
		public function GetItemStockCommand(itemId:String)
		{
			super('document.p_getItemStock');
			operationParams = <params><itemId>{itemId}</itemId></params>;
		}
	}
}