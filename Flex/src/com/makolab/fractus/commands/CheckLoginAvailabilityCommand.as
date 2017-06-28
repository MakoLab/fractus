package com.makolab.fractus.commands
{
	import mx.collections.XMLListCollection;
	
	public class CheckLoginAvailabilityCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function CheckLoginAvailabilityCommand(value:String)
		{
			var s:XML = new XML('<root><contractor><checkLogin>' + value + '</checkLogin></contractor></root>');
			operationParams = s;
			super("contractor.p_checkContractorCodeExistence");
		}		
	}
}