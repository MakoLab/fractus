package com.makolab.fractus.view.menu
{
	import flash.events.Event;

	public class MultiButtonEvent extends Event
	{
		public static const ITEM_SELECT:String = "itemSelect";
		
		public var itemId:String;
		
		public var item:Object;
		
		public function MultiButtonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}