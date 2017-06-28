package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.DictionaryManager;
	
	public class LoadAttributeValuesCommand extends ExecuteCustomProcedureCommand
	{
		public function LoadAttributeValuesCommand()
		{
			super('dictionary.p_getAutoDictionaryValues', <root/>);
		}
		
		override public function result(data:Object):void
		{
			var values:Object = {};
			var list:XMLList = XML(data.result).*;
			for each (var x:XML in list)
			{
				var attr:String = x.@attribute;
				if (!values[attr]) values[attr] = [];
				values[attr].push(String(x.@value));
			}
			DictionaryManager.getInstance().attributeValues = values;
			super.result(data);
		}
		
	}
}