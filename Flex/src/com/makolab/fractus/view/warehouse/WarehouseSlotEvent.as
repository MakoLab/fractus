package com.makolab.fractus.view.warehouse
{
	import flash.events.Event;

	public class WarehouseSlotEvent extends Event
	{
		public static const SLOT_CLICK:String = "slotClick";
		public static const MAP_OPEN:String = "mapOpen";
		
		public function WarehouseSlotEvent(type:String, slotId:String)
		{
			super(type);
			this.slotId = slotId;
		}
		
		public var slotId:String;
	}
}