package com.makolab.fractus.view.finance
{
	import flash.events.Event;

	public class SalesOrderEvent extends Event
	{
		public static const SALESORDER_SELECT:String = "salesOrderSelect";
		
		public var salesOrderId:String;
		
		public function SalesOrderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static function createEvent(type:String):SalesOrderEvent
		{
			var event:SalesOrderEvent = new SalesOrderEvent(type);
			return event;
		}
	}
}