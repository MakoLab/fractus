package com.makolab.fractus.commands
{
	
	public class GetContractorByNip extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function GetContractorByNip(nip:String)
		{
			operationParams = XML('<root><nip>'+nip+"</nip></root>");
			super("contractor.p_getContractorsSimpleByNip");
		}		
	}
}