package com.makolab.fractus.commands
{
	public class UpdateAccountingEntriesCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function UpdateAccountingEntriesCommand(param:XML)
		{
			operationParams = param;
			super("accounting.p_updateAccountingEntries");
		}		
	}
}