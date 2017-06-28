package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.ModelLocator;
	
	public class GetRegistersOpenReportsCommand extends ExecuteCustomProcedureCommand
	{
		public function GetRegistersOpenReportsCommand()
		{
			var branchId:String = ModelLocator.getInstance().branchId;
			super('finance.p_getRegistersOpenReports', <params><branchId>{branchId}</branchId></params>);
		}
		
	}
}