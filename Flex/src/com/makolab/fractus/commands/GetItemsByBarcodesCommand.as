package com.makolab.fractus.commands
{
	public class GetItemsByBarcodesCommand extends ExecuteCustomProcedureCommand
	{
		public function GetItemsByBarcodesCommand(procedureName:String, params:XML=null)
		{
			super(procedureName, params);
		}
		
	}
}