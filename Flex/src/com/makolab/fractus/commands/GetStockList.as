package com.makolab.fractus.commands
{
	public class GetStockList extends ExecuteCustomProcedureCommand
	{	
		public var params:XML;	
		
		public function GetStockList(param:XML)
		{
			operationParams = param;
			super("document.p_getStockList");
		}
		/*
		override protected function getOperationParams(data:Object):Object
		{
			return <root></root>.toXMLString();
		}
		*/
	}
}