package com.makolab.fractus.commands.items
{
	import com.makolab.fractus.commands.FractusCommand;
	
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	
	public class ItemCreateEquivalentCommand extends FractusCommand
	{
		public function ItemCreateEquivalentCommand()
		{
			super("kernelService", "CreateItemEquivalent");			
		}
		
		public override function result(data:Object):void
		{
			//model.itemsCatalogueManager.editedItemData = XML(data.result);
			//Alert.show(XML(data.result).toString());
			dispatchEvent(ResultEvent.createEvent(data));
		}
		
	}
}