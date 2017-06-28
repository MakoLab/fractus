package com.makolab.fractus.commands
{	
	public class GetApplicationUsersCommand extends ExecuteCustomProcedureCommand
	{
		public function  GetApplicationUsersCommand()
		{
			operationParams = <root/>;
			super("contractor.p_getApplicationUsers");
		}
	}
}