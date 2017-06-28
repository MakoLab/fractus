package com.makolab.components.catalogue
{
	import flash.events.Event;
	
	import mx.rpc.Fault;
	public class CatalogueEvent extends Event
	{
		public static const OPERATION_INVOKE:String = "operationInvoke";
		public static const UPDATE_EVENT:String = "updateEvent";
		public static const XML_LOADED:String = "xmlLoaded";
		public static const ITEM_SEARCH:String = "itemSearch";
		public static const ITEM_GET_DATA:String = "itemGetData";
		public static const ITEM_DETAILS_LOADED:String = "itemDetailsLoaded";
		public static const ITEM_SEARCH_ERROR:String = "itemSearchError";
		public static const ITEM_GET_DATA_ERROR:String = "itemGetDataError";
		public static const ITEM_SELECT:String = "itemSelect";
		public static const ITEM_TO_GROUP_ASSIGN:String = "itemToGroupAssign";

		public var itemData:Object;
		public var operation:CatalogueOperation;
		public var parameters:Object;
		public var fault:Fault;
		public var deselectItem:Boolean = false;
		public var extendedOperationId:String = null;
				
		public function CatalogueEvent(type:String, operation:CatalogueOperation = null, itemData:Object = null, fault:Fault = null, extendedOperationId:String = null)
		{
			super(type);
			this.operation = operation;
			this.itemData = itemData;
			this.fault = fault;
			this.extendedOperationId = extendedOperationId;
		}

		override public function clone():Event
		{
			return new CatalogueEvent(type, operation, itemData, fault);
		}
	}
}