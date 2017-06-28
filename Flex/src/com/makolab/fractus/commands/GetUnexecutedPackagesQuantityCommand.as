package com.makolab.fractus.commands
{
	public class GetUnexecutedPackagesQuantityCommand extends ExecuteCustomProcedureCommand
	{
		public function GetUnexecutedPackagesQuantityCommand(databaseId:String)
		{
			operationParams =  <root>{databaseId}</root>;
			super('communication.p_getUnexecutedPackagesQuantity');
		}
	}
}