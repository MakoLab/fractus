package com.makolab.fractus.commands.dictionaries
{
	import com.makolab.fractus.commands.FractusCommand;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.rpc.AsyncToken;
	
	public class LoadDictionaryCommand extends FractusCommand
	{		
		public function LoadDictionaryCommand()
		{
			super("kernelService", "LoadDictionary");
		}
		
		override public function execute(data:Object = null,addUser:Boolean=true):AsyncToken
		{
			logExecution({ data : data });
			operation.send(data).addResponder(this);
			return null;
		}
		
		override public function result(data:Object):void
		{
			super.result(data);
			ModelLocator.getInstance().dictionaryManager.dictionaryData[XML(data.result).*[0].name()] = XML(data.result).*;		
		}
	}
}