package com.makolab.fractus.commands
{
	public class LoadConfigurationCommand extends FractusCommand
	{
		public function LoadConfigurationCommand()
		{
			super("kernelService", "GetConfiguration");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return String(data.key);
		}
		
	}
}