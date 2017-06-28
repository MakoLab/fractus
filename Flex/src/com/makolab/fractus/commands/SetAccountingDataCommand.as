package com.makolab.fractus.commands
{
	public class SetAccountingDataCommand extends ExecuteCustomProcedureCommand
	{
		public function SetAccountingDataCommand(params:XML)
		{
			super('accounting.p_setDocumentData', params);
		}
	}
}