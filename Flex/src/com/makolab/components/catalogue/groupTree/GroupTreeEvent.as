package com.makolab.components.catalogue.groupTree
{
	import flash.events.Event;

	public class GroupTreeEvent extends Event
	{
		public static const ITEM_DRAG_DROP:String = "itemDragDrop";
		public static const GROUP_DOUBLE_CLICK:String = "groupDoubleClick";
		
		public var itemId:String;
		public var groupId:String;
		public var leaves:Array;
		public var unassignedSelected:Boolean;
		public var itemIds:Array;
		
		public function GroupTreeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static function createEvent(type:String, groupId:String = null, itemId:String = null, itemIds:Array = null):GroupTreeEvent
		{
			var event:GroupTreeEvent = new GroupTreeEvent(type);
			event.groupId = groupId;
			event.itemId = itemId;
			event.itemIds = itemIds;
			return event;
		}
	}
}