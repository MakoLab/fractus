package com.makolab.fractus.commands.items
{
	import com.makolab.fractus.commands.FractusCommand;
	
	import mx.rpc.events.ResultEvent;
	
	public class ItemRemoveEquivalentCommand extends FractusCommand
	{
		
		public function ItemRemoveEquivalentCommand()
		{
			super("kernelService", "RemoveItemFromEquivalent");			
		}
		
		public override function result(data:Object):void
		{
			//model.itemsCatalogueManager.editedItemData = XML(data.result);
			//model.itemsCatalogueManager.currentListItemData = null;
			//Alert.show(XML(data.result).toString());
			dispatchEvent(ResultEvent.createEvent(data));
		}
	}
}