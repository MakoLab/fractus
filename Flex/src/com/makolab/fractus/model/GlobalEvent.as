package com.makolab.fractus.model
{
	import flash.events.Event;
		
	public class GlobalEvent extends Event
    {
    	public static const GLOBAL_EVENT:String = "globalEvent";
    	public static const CONTRACTOR_CHANGED:String = "contractorChanged";
		public static const DOCUMENT_CHANGED:String = "documentChanged";
		public static const ITEM_CHANGED:String = "itemChanged";
		public static const LIST_CHANGED:String = "listChange";
		public static const LANGUAGE_CHANGED:String="languageChanged";
		public static const SEND_TO_TERMINAL:String="sendToTerminal";
	
    	public var objectCategory:String;
    	public var objectId:String;

        public function GlobalEvent(type:String, objectCategory:String = null, objectId:String = null) {
                super(type);
    
                this.objectCategory = objectCategory;
                this.objectId = objectId;
        }

        // Override the inherited clone() method.
        override public function clone():Event {
            return new GlobalEvent(type, objectCategory, objectId);
        }
    }

} 