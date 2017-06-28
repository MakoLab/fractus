package com.makolab.fraktus2.modules.warehouse
{
	import flash.events.IEventDispatcher;
	
	/*[Event(name="slotClick", type="warehouse.WarehouseSlotEvent")]*/
	public interface IWarehouseStructureRenderer extends IEventDispatcher
	{
		/*
		public static const NOT_AVAILABLE:int = 0;
		public static const PARTIALLY_AVAILABLE:int = 1;
		public static const AVAILABLE:int = 2;
		public static const PREFERRED:int = 3;
		*/
		
		/**
		 * XML containing the structure of slots and slotGroups
		 */
		function set warehouseStructure(value:XML):void;
		function get warehouseStructure():XML;
		
		/**
		 * List of slots determining their availability.
		 * Significant fields:
		 * @id - slot id
		 * @available - 0 (not available), 1 (partially available), 2 (available), 3 (preferred) 
		 */
		function set availableSlots(value:XMLList):void;
		function get availableSlots():XMLList;
		
		/**
		 * Array of GUID's of highlighted slots.
		 */
		function set highlightedSlots(value:Array):void;
		function get highlightedSlots():Array;
		
		function set displayMode(value:int):void;
		function get displayMode():int;
		
		function set selectedSlotId(value:String):void;
		function get selectedSlotId():String;
		
	}
}