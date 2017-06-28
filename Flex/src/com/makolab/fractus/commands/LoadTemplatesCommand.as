package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.rpc.AsyncToken;
	
	public class LoadTemplatesCommand extends FractusCommand
	{
		public function LoadTemplatesCommand()
		{
			super("kernelService", "GetTemplates");
		}
		
		override public function execute(data:Object=null,addUser:Boolean=true):AsyncToken
		{
			logExecution(null);
			if (operation) operation.send().addResponder(this);
			return null;
		}
		
		private var type:String;
		public var xml:XML;
		
		override public function result(data:Object):void
		{
			var xml:XML = XML(data.result);
			var model:ModelLocator = ModelLocator.getInstance();
			model.documentTemplates = xml;
			for each (var x:XML in xml.*)
			{
				var type:String = x.localName();
				model[type + "Templates"] = x.*;
			}			
			super.result(data);
		}
		
	}
}