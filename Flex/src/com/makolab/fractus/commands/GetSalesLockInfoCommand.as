package com.makolab.fractus.commands
{
	public class GetSalesLockInfoCommand extends ExecuteCustomProcedureCommand
	{
		public function GetSalesLockInfoCommand(contractorId:String)
		{
			super("contractor.p_getSalesLockInfo", <root><contractorId>{contractorId}</contractorId></root>);
		}
		
	}
}