package com.makolab.components.catalogue
{
	import flash.events.Event;

	public class CatalogueItemWindowEvent extends Event
	{

		public static const ACCEPT:String = "accept";
		public static const CANCEL:String = "cancel";
		public static const DATA_SAVE_COMPLETE:String = "dataSaveComplete";
		
		public var itemId:String;
		public var itemData:Object;

		public function CatalogueItemWindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}