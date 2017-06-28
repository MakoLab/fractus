package com.makolab.fractus.commands
{
	public class GetPaymentsCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function GetPaymentsCommand(param:XML)
		{
			operationParams = param;
			super("finance.p_getPayments");
		}		
	}
}