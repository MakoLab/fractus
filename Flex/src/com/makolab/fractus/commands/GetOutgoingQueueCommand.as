package com.makolab.fractus.commands
{
	public class GetOutgoingQueueCommand extends ExecuteCustomProcedureCommand
	{
		public function GetOutgoingQueueCommand(id:String, databaseId:String)
		{
			operationParams =  <root/>;
			operationParams.@maxTransactionCount = 1;
			operationParams.@id =id;
			operationParams.@databaseId = databaseId
			super('communication.p_getOutgoingQueueXML');
		}
	}
}