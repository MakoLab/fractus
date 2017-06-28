package com.makolab.fractus.commands
{
	public class LoadLabelCommand extends ExecuteCustomProcedureCommand
	{
		public function LoadLabelCommand(containerId:String)
		{
			var parameter:XML = <root><containerId>{containerId}</containerId></root>;
			super('warehouse.p_getContainerContent', parameter);

		}
		
	}
}