package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.ModelLocator;
	
	public class LoadDictionariesCommand extends FractusCommand
	{
		public function LoadDictionariesCommand()
		{
			super("kernelService", "GetDictionaries");
		}

		override public function result(data:Object):void
		{
			ModelLocator.getInstance().dictionaryManager.setDictionariesXML(XML(data.result));
			super.result(data);
		}
	}
}