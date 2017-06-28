package com.makolab.fraktus2.events
{
	import flash.events.Event;
	
	public class WarehouseEvent extends Event
	{
		public static const SLOT_SELECTED:String = "WarehouseEvent.SLOT_SELECTED";
		
		public var slotId:String; 
		
		public function WarehouseEvent(	type:String, bubbles:Boolean = false, 
										cancelable:Boolean = false, slotId:String="")
		{
			this.slotId = slotId;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event 
		{
			return new WarehouseEvent(type, bubbles, cancelable, slotId);
		}

	}
}