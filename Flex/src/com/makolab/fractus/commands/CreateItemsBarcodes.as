package com.makolab.fractus.commands
{
	import mx.controls.Alert;
	
	public class CreateItemsBarcodes extends FractusCommand
	{
		public function CreateItemsBarcodes()
		{
			super('kernelService', 'CreateItemsBarcodes');
		}

		override public function fault(data:Object):void
		{
			Alert.show(data.fault.toString());		
		}
	}
}