package com.makolab.fractus.commands
{
	
	public class UpdatePermissionStructureCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function UpdatePermissionStructureCommand()
		{
			operationParams = XML('<root>update</root>');
			super("configuration.p_updatePermissionStructure");
		}		
	}
}