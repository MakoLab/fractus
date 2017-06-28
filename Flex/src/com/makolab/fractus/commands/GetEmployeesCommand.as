package com.makolab.fractus.commands
{
	public class GetEmployeesCommand extends ExecuteCustomProcedureCommand
	{
		public function GetEmployeesCommand()
		{
			operationParams = <root/>;
			super("contractor.p_getEmployees");
		}
		
	}
}