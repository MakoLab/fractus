package com.makolab.fractus.commands
{
	public class GetUndeliveredPackagesQuantityCommand extends ExecuteCustomProcedureCommand
	{
		public function GetUndeliveredPackagesQuantityCommand(databaseId:String)
		{
			operationParams =  <root>{databaseId}</root>;
			super('communication.p_getUndeliveredPackagesQuantity');
		}
	}
}