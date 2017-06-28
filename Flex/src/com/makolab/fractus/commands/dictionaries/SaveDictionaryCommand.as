package com.makolab.fractus.commands.dictionaries
{
	import com.makolab.fractus.commands.FractusCommand;
	
	import mx.controls.Alert;
	
	public class SaveDictionaryCommand extends FractusCommand
	{		
		public function SaveDictionaryCommand()
		{
			super("kernelService", "SaveDictionary");
		}
		
		override public function result(data:Object):void
		{
			Alert.show(data.result.toString());		
		}
		
		override public function fault(data:Object):void
		{
			Alert.show(data.fault.toString());		
		}
	}
}