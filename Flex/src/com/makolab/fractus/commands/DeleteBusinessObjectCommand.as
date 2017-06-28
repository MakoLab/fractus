package com.makolab.fractus.commands
{
	public class DeleteBusinessObjectCommand extends FractusCommand
	{
		public function DeleteBusinessObjectCommand()
		{
			super("kernelService", "DeleteBusinessObject");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return String(data.requestXml);
		}
	}
}