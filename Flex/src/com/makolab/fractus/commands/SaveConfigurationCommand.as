package com.makolab.fractus.commands
{
	public class SaveConfigurationCommand extends FractusCommand
	{
		public function SaveConfigurationCommand()
		{
			super("kernelService", "SaveConfiguration");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return String(data.requestXml);
		}
		
	}
}