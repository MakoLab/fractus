package com.makolab.components.list
{
	import flash.events.Event;

	public class MakoListEvent extends Event
	{
		public static const SET_PAGE:String = "setPage";
		
		public var pageNumber:int;
		
		public function MakoListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}