package com.makolab.fractus.commands
{
	import mx.collections.XMLListCollection;
	
	public class GetDeliveriesValueCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function GetDeliveriesValueCommand(listOfIds:XMLListCollection)
		{
			var s:XML = new XML(<root/>);
			for each (var node:XML in listOfIds) {
			 	s.appendChild(node);
			 }
			operationParams = s;
			super("document.p_getDeliveries");
		}		
	}
}